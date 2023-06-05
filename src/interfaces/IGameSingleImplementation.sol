pragma solidity ^0.8.19;

interface IGameSingle {
    function init(uint256[3] calldata, address) external;

    function withdraw() external;
}
