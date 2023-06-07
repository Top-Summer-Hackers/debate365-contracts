// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameSingleImplementation.sol";
import "../src/Mocks/MockToken.sol";
import "../src/interfaces/IGameSingle.sol";

contract GameSingleImplementationTest is Test, IGameSingle {
    // -- CONSTANTS
    uint256 constant DECIMALS = 10 ** 18;
    uint256 constant THRESHOLD_REMAINING = 1000;
    uint256 constant CLAIM_WINDOW_TIME = 3 days;

    uint256 constant FEE = 50; // 0.5 % bps = 10000

    GameSingleImplementation public game;
    MockToken public usdc;

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);
    address user4 = vm.addr(4);
    address user5 = vm.addr(5);

    function setUp() public {
        game = new GameSingleImplementation();
        usdc = new MockToken("USDC", "USDC");

        vm.prank(user1);
        usdc.faucet(1000000 * DECIMALS);
        vm.prank(user2);
        usdc.faucet(1000000 * DECIMALS);
        vm.prank(user3);
        usdc.faucet(1000000 * DECIMALS);
        vm.prank(user4);
        usdc.faucet(1000000 * DECIMALS);
        vm.prank(user5);
        usdc.faucet(1000000 * DECIMALS);
    }

    function generateOdds(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal view returns (uint256[3] memory odds) {
        odds[0] = (a * DECIMALS) / 10;
        odds[1] = (b * DECIMALS) / 10;
        odds[2] = (c * DECIMALS) / 10;
    }

    function _init(uint256 a, uint256 b, uint256 c) internal {
        uint256[3] memory odds = generateOdds(a, b, c);
        game.init(odds, address(usdc));
    }

    function testInit() public {
        // fails to initialize
        vm.expectRevert(abi.encodeWithSelector(Initialized.selector, false));
        uint256[3] memory odds = generateOdds(15, 23, 33);
        vm.prank(address(0));
        game.updateOdds(odds);
        _init(15, 23, 33);
        odds = game.getOdds();
        require(odds[0] == (15 * DECIMALS) / 10);
        require(odds[1] == (23 * DECIMALS) / 10);
        require(odds[2] == (33 * DECIMALS) / 10);

        require(game.owner() == address(this));
        require(game.isInitialized() == true);
        require(game.isFinished() == false);
        require(game.tokenAddr() == address(usdc));
    }

    function testUpdateOdds() public {
        _init(15, 23, 33);
        uint256[3] memory newOdds;
        newOdds[0] = (14 * DECIMALS) / 10;
        newOdds[1] = (25 * DECIMALS) / 10;
        newOdds[2] = (32 * DECIMALS) / 10;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(OnlyOwner.selector));
        game.updateOdds(newOdds);

        uint256 sp = vm.snapshot();

        game.endGame(IGameSingle.Choice.WIN);
        vm.expectRevert(abi.encodeWithSelector(IsFinished.selector, true));
        game.updateOdds(newOdds);

        vm.revertTo(sp);
        game.updateOdds(newOdds);
        uint256[3] memory odds = game.getOdds();
        require(odds[0] == newOdds[0]);
        require(odds[1] == newOdds[1]);
        require(odds[2] == newOdds[2]);
    }

    function testDeposit() public {
        _init(15, 23, 33);
        uint256 amountToDeposit = 1000 * DECIMALS;
        uint256 snp = vm.snapshot();

        game.endGame(IGameSingle.Choice.WIN);
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(IsFinished.selector, true));
        game.deposit(amountToDeposit);

        vm.revertTo(snp);
        vm.startPrank(user1);
        usdc.approve(address(game), amountToDeposit);
        game.deposit(amountToDeposit);
        vm.stopPrank();

        require(game.getStakerWeight(user1) == DECIMALS);
        require(game.compoundedWeight() == DECIMALS);

        vm.startPrank(user2);
        usdc.approve(address(game), amountToDeposit * 2);
        game.deposit(amountToDeposit * 2);
        vm.stopPrank();

        require(game.getStakerWeight(user2) == DECIMALS * 2);
        require(game.compoundedWeight() == DECIMALS * 3);

        vm.startPrank(user3);
        usdc.approve(address(game), amountToDeposit * 3);
        game.deposit(amountToDeposit * 3);
        vm.stopPrank();

        require(game.getStakerWeight(user3) == DECIMALS * 3);
        require(game.compoundedWeight() == DECIMALS * 6);

        vm.startPrank(user4);
        usdc.approve(address(game), amountToDeposit / 2);
        game.deposit(amountToDeposit / 2);
        vm.stopPrank();

        require(game.getStakerWeight(user4) == DECIMALS / 2);
        require(game.compoundedWeight() == (DECIMALS * 13) / 2);

        //deposit more
        vm.startPrank(user3);
        usdc.approve(address(game), amountToDeposit / 2);
        game.deposit(amountToDeposit / 2);
        vm.stopPrank();

        require(game.getStakerWeight(user3) == DECIMALS / 2 + DECIMALS * 3);
        require(game.compoundedWeight() == DECIMALS * 7);
    }

    function testDepositNoPlayEndGame() public {
        _init(15, 23, 33);
        uint256 amountToDeposit = 1000 * DECIMALS;
        // user 1 deposits 1000
        vm.startPrank(user1);
        usdc.approve(address(game), amountToDeposit);
        game.deposit(amountToDeposit);
        vm.stopPrank();

        // user 2 deposits 2000
        vm.startPrank(user2);
        usdc.approve(address(game), amountToDeposit * 2);
        game.deposit(amountToDeposit * 2);
        vm.stopPrank();

        // user 3 deposits 3000
        vm.startPrank(user3);
        usdc.approve(address(game), amountToDeposit * 3);
        game.deposit(amountToDeposit * 3);
        vm.stopPrank();

        // end game
        game.endGame(IGameSingle.Choice.WIN);

        vm.expectRevert(abi.encodeWithSelector(ClaimWindow.selector, true));
        game.withdraw();

        uint256 balanceBefore = usdc.balanceOf(user1);
        // claim shares
        vm.prank(user1);
        game.claim();
        uint256 balanceAfter = usdc.balanceOf(user1);

        require(
            balanceAfter ==
                balanceBefore +
                    (amountToDeposit - (amountToDeposit * FEE) / 10000)
        );

        balanceBefore = usdc.balanceOf(user2);
        // claim shares
        vm.prank(user2);
        game.claim();
        balanceAfter = usdc.balanceOf(user2);

        require(
            balanceAfter ==
                balanceBefore +
                    (amountToDeposit * 2 - (amountToDeposit * 2 * FEE) / 10000)
        );

        balanceBefore = usdc.balanceOf(address(this));
        uint256 gameBalance = usdc.balanceOf(address(game));
        require(game.isClaimWindow() == true);
        vm.warp(block.timestamp + 4 days);
        require(game.isClaimWindow() == false);
        game.withdraw();
        balanceAfter = usdc.balanceOf(address(this));
        require(balanceAfter == balanceBefore + gameBalance);
        vm.expectRevert(abi.encodeWithSelector(ClaimWindow.selector, false));
        game.claim();
    }

    function testGetMaxStakeNoPlay() public {
        _init(15, 23, 33);

        // owner cant claiim bcs claim window is active
        vm.expectRevert(abi.encodeWithSelector(IsFinished.selector, false));
        game.withdraw();

        uint256 amountToDeposit = 1000 * DECIMALS;
        // user 1 deposits 1000
        vm.startPrank(user1);
        usdc.approve(address(game), amountToDeposit);
        game.deposit(amountToDeposit);
        vm.stopPrank();

        uint256 reserves = game.reserves();

        uint256 maxStake = game.getMaxStake(IGameSingle.Choice.LOSS);

        require(
            maxStake > (reserves * (10000 - THRESHOLD_REMAINING)) / 10000 / 8
        );
        require(
            maxStake < (reserves * (10000 - THRESHOLD_REMAINING)) / 10000 / 6
        );

        vm.startPrank(user2);
        usdc.approve(address(game), amountToDeposit * 2);
        game.deposit(amountToDeposit * 2);
        vm.stopPrank();

        reserves = game.reserves();
        maxStake = game.getMaxStake(IGameSingle.Choice.WIN);

        require(
            maxStake > (reserves * (10000 - THRESHOLD_REMAINING)) / 10000 / 4
        );
        require(maxStake < (reserves * (10000 - THRESHOLD_REMAINING)) / 10000);
    }

    // --------  GAME TEST SUITE --------

    function testSimpleGameStatusUpdate() external {
        _init(15, 23, 33);
        uint256[3] memory odds = game.getOdds();
        uint256 amountToDeposit = 1000 * DECIMALS;
        // user 1 deposits 1000
        vm.startPrank(user1);
        usdc.approve(address(game), amountToDeposit);
        game.deposit(amountToDeposit);
        vm.stopPrank();

        // user 2 deposits 2000
        vm.startPrank(user2);
        usdc.approve(address(game), amountToDeposit * 2);
        game.deposit(amountToDeposit * 2);
        vm.stopPrank();

        // user 3 deposits 3000
        vm.startPrank(user3);
        usdc.approve(address(game), amountToDeposit * 3);
        game.deposit(amountToDeposit * 3);
        vm.stopPrank();

        vm.startPrank(user4);
        // fails is amount is more than max
        uint256 maxStake = game.getMaxStake(IGameSingle.Choice.WIN);
        usdc.approve(address(game), maxStake);
        vm.expectRevert(
            abi.encodeWithSelector(
                MaxStakeReached.selector,
                game.getMaxStake(IGameSingle.Choice.LOSS)
            )
        );
        game.play(IGameSingle.Choice.LOSS, maxStake);

        // revert if game is finished, use snpahost to reset the state
        vm.stopPrank();
        uint256 sp = vm.snapshot();
        game.endGame(IGameSingle.Choice.WIN);
        vm.expectRevert(abi.encodeWithSelector(IsFinished.selector, true));
        game.play(IGameSingle.Choice.LOSS, maxStake);
        vm.revertTo(sp);
        vm.startPrank(user4);

        // updates pending balances & max stake
        maxStake = game.getMaxStake(IGameSingle.Choice.WIN);
        usdc.approve(address(game), maxStake / 2);
        game.play(IGameSingle.Choice.WIN, maxStake / 2);
        vm.stopPrank();

        uint256 pendingBalanceOfOdd = game.getPendingBalanceOfOdd(
            IGameSingle.Choice.WIN
        );

        uint256 pendingBalanceOfUser = game.getPendingBalanceOfUser(
            IGameSingle.Choice.WIN,
            user4
        );

        require(pendingBalanceOfOdd == ((maxStake / 2) * odds[0]) / DECIMALS);
        require(pendingBalanceOfUser == pendingBalanceOfOdd);
        uint256 newMaxStake = game.getMaxStake(IGameSingle.Choice.WIN);

        uint256 pending = game.reserves() - pendingBalanceOfOdd;
        pending *= (10000 - THRESHOLD_REMAINING);
        pending /= 10000;
        pending = (pending + maxStake / 2) / 2;
        pending = (pending * DECIMALS) / odds[0];
        require(pending == newMaxStake);
        // finish game
        sp = vm.snapshot();
        game.endGame(IGameSingle.Choice.WIN);

        // user can claim some amount
        uint256 balanceBefore = usdc.balanceOf(user4);
        vm.prank(user4);
        uint256 claimed = game.claim();
        uint256 balanceAfter = usdc.balanceOf(user4);
        require(balanceAfter == balanceBefore + claimed);
        require(claimed == ((maxStake / 2) * odds[0]) / DECIMALS);

        // stakers can withdraw smaller amount than deposit
        vm.prank(user1);
        claimed = game.claim();

        // fails to withdraw twice
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(NotEnoughToWithdraw.selector));
        game.claim();

        vm.prank(user2);
        uint256 claimed2 = game.claim();

        vm.prank(user3);
        uint256 claimed3 = game.claim();

        require(claimed < amountToDeposit);
        require(claimed * 2 == claimed2);
        require(claimed * 3 == claimed3);

        pendingBalanceOfOdd = game.getPendingBalanceOfOdd(
            IGameSingle.Choice.WIN
        );
        require(
            game.reserves() - pendingBalanceOfOdd ==
                claimed + claimed2 + claimed3
        );
        balanceBefore = usdc.balanceOf(address(this));
        uint256 balanceOfContract = usdc.balanceOf(address(game));

        vm.warp(block.timestamp + CLAIM_WINDOW_TIME);
        game.withdraw();
        balanceAfter = usdc.balanceOf(address(this));
        require(balanceAfter == balanceBefore + balanceOfContract);
    }

    // Overwrite these functions from interface
    function init(uint256[3] calldata, address) external override {}

    function withdraw() external override {}
}
