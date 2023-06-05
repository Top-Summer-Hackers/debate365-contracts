pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./GameProxy.sol";
import "./interfaces/IGameSingleImplementation.sol";

contract Debet365 is Ownable {
    error InvalidImplementation();
    enum GameType {
        SINGLE,
        MULTIPLE
    }

    mapping(GameType => address) implementations;
    mapping(uint256 => address) games;
    uint256 gameCount = 1;

    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }

    function setGameImplementation(
        GameType _type,
        address _impl
    ) external onlyOwner {
        implementations[_type] = _impl;
    }

    function openGame(
        uint256[3] calldata _odds,
        GameType _type,
        address _tokenAddr
    ) external returns (address) {
        address _implementation = implementations[_type];
        if (_implementation == address(0)) {
            revert InvalidImplementation();
        }
        GameProxy game = new GameProxy(_implementation);
        IGameSingle(address(game)).init(_odds, _tokenAddr);

        games[gameCount] = address(game);

        return address(game);
    }

    function withdrawFromGame(uint256 _gameIdx) external onlyOwner {
        IGameSingle(games[_gameIdx]).withdraw();
    }
}
