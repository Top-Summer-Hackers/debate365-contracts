// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./GameProxy.sol";
import "./interfaces/IGameSingle.sol";

contract Debet365 is Ownable {
    error InvalidImplementation();
    enum GameType {
        SINGLE,
        MULTIPLE
    }
    mapping(GameType => address) public implementations;
    mapping(uint256 => address) public games;
    mapping(address => uint256) public gameIds;

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
    ) external onlyOwner returns (address) {
        address _implementation = implementations[_type];
        if (_implementation == address(0)) {
            revert InvalidImplementation();
        }
        GameProxy game = new GameProxy(_implementation);
        IGameSingle(address(game)).init(_odds, _tokenAddr);

        games[gameCount] = address(game);
        gameIds[address(game)] = gameCount;

        return address(game);
    }

    function _updateOddsOfGame(
        uint256 _gameId,
        uint256[3] memory _odds
    ) internal {
        IGameSingle(games[_gameId]).updateOdds(_odds);
    }

    function getImplementation(GameType _type) external view returns (address) {
        return implementations[_type];
    }
}
