// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Rebalacing {

    uint256 public maxAmountBet; 

    mapping(uint => uint) lockedPerGame;
    mapping(uint => uint) totalLiquidityPerGame; 

    enum Side {
        HOME,
        DRAW,
        AWAY
    }



    mapping(uint => Side) gameOutcome; // mapping between gameId and a result (1, 0, 2)
    mapping(address => Side) betOfUser ; 

    Side public side;


    struct OpenGame {
        uint gameId; 
        uint initialOdd; 
        string teamA;
        string teamB;
    }


    function chooseSide(uint _gameId, Side side) public payable {

        if (betOfUser[msg.sender] == Side.HOME) {
            require(isMaxBet() , "Maximum Bet Limit Exceeded");
            totalLiquidityPerGame[_gameId] = lockedPerGame[_gameId] + msg.value; 
        } else if (betOfUser[msg.sender] == Side.DRAW) {
            require(isMaxBet() , "Maximum Bet Limit Exceeded"); 
        } else if (betOfUser[msg.sender] == Side.AWAY) {
            require(isMaxBet() , "Maximum Bet Limit Exceeded");
        }

    }


    function rebalanceSizeForLay(uint _odd) internal { }
    
    function rebalanceSizeForBack() internal {}

    function isMaxBet() public view returns (bool){}

    function getMaxBetForHome(uint _odd, uint _gameId) public view returns (uint256){

        lockedPerGame[_gameId] ;
    }


    function getMaxBetForDraw() public view returns (uint256){}
    function getMaxBetForAway() public view returns (uint256){}


    function resolveGame(uint _gameId) internal {

        if (gameOutcome[_gameId] == Side.HOME) {
            

        }




    }


}