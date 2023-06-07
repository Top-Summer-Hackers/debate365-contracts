pragma solidity ^0.8.19;

interface IGameSingle {
    error Initialized(bool);
    error MaxStakeReached(uint256);
    error IsFinished(bool);
    error OnlyOwner();
    error NotEnoughToWithdraw();
    error ClaimWindow(bool);

    enum Choice {
        WIN,
        DRAW,
        LOSS
    }

    function init(uint256[3] calldata, address) external;

    function withdraw() external;
}
