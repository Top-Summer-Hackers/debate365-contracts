pragma solidity ^0.8.19;
import "forge-std/Test.sol";
import "../src/Debet365.sol";
import "../src/GameSingleImplementation.sol";
import "../src/Mocks/MockToken.sol";

contract Debet365Test is Test {
    error InvalidImplementation();

    Debet365 debet;
    GameSingleImplementation game;
    MockToken public usdc;

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);
    address user4 = vm.addr(4);
    address user5 = vm.addr(5);

    uint256 constant DECIMALS = 10 ** 18;

    function setUp() public {
        debet = new Debet365();
        game = new GameSingleImplementation();
        usdc = new MockToken("USDC", "USDC");
    }

    function _addImpl(address newImpl, Debet365.GameType _type) internal {
        debet.setGameImplementation(_type, newImpl);
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

    function testAddImplementation() public {
        vm.prank(user1);
        vm.expectRevert();
        _addImpl(address(game), Debet365.GameType.SINGLE);
        _addImpl(address(game), Debet365.GameType.SINGLE);
        require(
            debet.getImplementation(Debet365.GameType.SINGLE) == address(game)
        );
        require(
            debet.getImplementation(Debet365.GameType.MULTIPLE) == address(0)
        );
    }

    function testCreateGame() public {
        //reverts if implementation doesnt exist
        uint256[3] memory odds = generateOdds(15, 23, 33);
        vm.expectRevert(abi.encodeWithSelector(InvalidImplementation.selector));
        address newGame = debet.openGame(
            odds,
            Debet365.GameType.SINGLE,
            address(usdc)
        );
        vm.prank(user1);
        vm.expectRevert();
        newGame = debet.openGame(odds, Debet365.GameType.SINGLE, address(usdc));

        _addImpl(address(game), Debet365.GameType.SINGLE);

        newGame = debet.openGame(odds, Debet365.GameType.SINGLE, address(usdc));
        require(newGame != address(0));

        GameSingleImplementation actualGame = GameSingleImplementation(newGame);
        require(actualGame.owner() == address(debet));
    }

    // function testOpenGame
}
