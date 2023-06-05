// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './Game.sol';

contract GameFactory {

    Game public game;

    uint256 gameId; 
    mapping(address => Game) gameIds;  //Mapping address to gameIds

    constructor() {
        gameId += gameId;
    }

    function createGame(address _bookie) public {
        game = new Game(_bookie, 1, 2 ether);
        gameIds[msg.sender] = game;
    }

}


