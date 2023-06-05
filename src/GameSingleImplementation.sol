pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IGameSingleImplementation.sol";

// TODO :
// Checks for arbritage in play , pass ODD to play
// Checks for rebalancing

/**
 * @title GameSingleImplementation
 * @author Carlos Ramos
 * @notice A contract that allows betting on 3 choices
 * @dev Owner is always debet365 protocol
 */
contract GameSingleImplementation is IGameSingle {
    error Initialized(bool);
    error MaxStakeReached(uint256);
    error IsFinished(bool);
    error OnlyOwner();
    error NotEnoughToWithdraw();
    error ClaimWindow(bool);

    /**
     * @dev CONSTANT VARS
     */
    uint256 constant DECIMALS = 10 ** 18;
    uint256 constant FEE = 50; // 0.5 % bps = 10000
    uint256 constant THRESHOLD_REMAINING = 1000;
    uint256 constant CLAIM_WINDOW_TIME = 3 days;
    /**
     * @dev DYNAMIC VARs
     */
    mapping(address => mapping(Choice => uint256))
        public pendingBalancesPerOddPerUser;
    mapping(Choice => uint256) public pendingBalancePerOdd;
    uint256[3] public odds; // with 6 decimals

    mapping(address => uint256) stakersWeight;
    uint256 public compoundedWeight;
    uint256 public withdrawnAmount;

    /**
     * @dev IMPORTANT VARIABLES
     */
    uint256 public reserves;
    address public tokenAddr;
    bool public isInitialized;
    bool public isFinished;

    Choice public result;
    uint256 public claimWindowDeadline;
    address public owner;

    modifier whenInitilized() {
        if (!isInitialized) revert Initialized(false);
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    function updateOdds(uint256[3] calldata _odds) external onlyOwner {
        if (!isInitialized) revert Initialized(false);
        if (isFinished) revert IsFinished(true);
        odds = _odds;
    }

    function endGame(Choice _result) external onlyOwner {
        if (isFinished) revert IsFinished(true);
        result = _result;
        isFinished = true;
        claimWindowDeadline = block.timestamp + CLAIM_WINDOW_TIME;
    }

    function init(uint256[3] calldata _odds, address _tokenAddr) external {
        if (isInitialized) revert Initialized(true);
        odds = _odds;
        tokenAddr = _tokenAddr;
        owner = msg.sender;
        isInitialized = true;
    }

    /**
     * @notice Plays for an odd
     * @param choice the result of the game
     * @param _amount the amount to play for
     */
    function play(Choice choice, uint256 _amount) external whenInitilized {
        if (isFinished) revert IsFinished(true);
        IERC20(tokenAddr).transferFrom(msg.sender, address(this), _amount);
        uint256 maxStake = getMaxStake(choice);
        if (maxStake < _amount) {
            revert MaxStakeReached(maxStake);
        }
        uint256 eventualClaimable = (_amount * odds[uint256(choice)]) /
            DECIMALS;

        pendingBalancesPerOddPerUser[msg.sender][choice] += eventualClaimable;
        pendingBalancePerOdd[choice] += eventualClaimable;
    }

    /**
     * @notice Deposit tokens for prize release
     * @param _amount Amount to deposit
     * @dev takes a fee on everydeposit
     */
    function deposit(uint256 _amount) external {
        if (isFinished) revert IsFinished(true);
        IERC20(tokenAddr).transferFrom(msg.sender, address(this), _amount);
        _amount -= (_amount * FEE) / 10000;
        uint256 weight;
        if (reserves == 0) {
            weight = 1 * DECIMALS;
        } else {
            weight = (_amount * compoundedWeight) / reserves;
        }
        reserves += _amount;
        stakersWeight[msg.sender] += weight;
        compoundedWeight += weight;
    }

    /**
     * @dev allows stakers and players to claim with their earnings
     */
    function claim() external returns (uint256 claimable) {
        if (!isClaimWindow()) {
            revert ClaimWindow(false);
        }
        uint256 remainingAmount = reserves - pendingBalancePerOdd[result];
        uint256 pendingStake = (remainingAmount * stakersWeight[msg.sender]) /
            compoundedWeight;
        claimable += pendingStake;
        claimable += pendingBalancesPerOddPerUser[msg.sender][result];
        pendingBalancesPerOddPerUser[msg.sender][result] = 0;
        stakersWeight[msg.sender] = 0;
        if (claimable == 0) {
            revert NotEnoughToWithdraw();
        }
        IERC20(tokenAddr).transfer(msg.sender, claimable);
        withdrawnAmount += claimable;
    }

    function getMaxStake(
        Choice _choice
    ) public view returns (uint256 maxStake) {
        uint256 remainingAmount = reserves - pendingBalancePerOdd[_choice];
        remainingAmount -= (remainingAmount * THRESHOLD_REMAINING) / 10000;
        maxStake = (remainingAmount * DECIMALS) / odds[uint256(_choice)];
    }

    /**
     * @dev Recovers amounts sent by mistake
     */
    function withdraw() external {
        if (!isFinished) {
            revert IsFinished(false);
        }
        if (isClaimWindow()) {
            revert ClaimWindow(true);
        }
        uint256 balance = IERC20(tokenAddr).balanceOf(address(this));
        IERC20(tokenAddr).transfer(owner, balance);
    }

    function getOdds() external view returns (uint256[3] memory) {
        return odds;
    }

    function getStakerWeight(address _user) external view returns (uint256) {
        return stakersWeight[_user];
    }

    function isClaimWindow() public view returns (bool) {
        return isFinished && block.timestamp < claimWindowDeadline;
    }

    function getPendingBalanceOfUser(
        Choice _choice,
        address _user
    ) external view returns (uint256) {
        return pendingBalancesPerOddPerUser[_user][_choice];
    }

    function getPendingBalanceOfOdd(
        Choice _choice
    ) external view returns (uint256) {
        return pendingBalancePerOdd[_choice];
    }
}
