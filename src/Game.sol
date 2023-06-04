// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Game {

    uint256 public maxAmountBet; 
    uint256 public maxBet;
    address public bookie;

    mapping(uint => uint) lockedPerGame;
    mapping(uint => uint) totalLiquidityPerGame;  // mapping between gameId and total ETH in the poolGame 
    mapping(uint => uint) totalPayOut;
    // mapping(uint => Bet ) betPerGame; // mapping between gameId and a specific bet 


    enum Side {
        HOME,
        DRAW,
        AWAY
    }

    mapping(uint => Side) gameSide; // mapping between gameId and a result (1, 0, 2)
    mapping(address => Side) betOfUser ; 

    //mapping between odds and sides
    mapping(uint => Side) oddsForSide;


    Side public side;

    struct OpenGame {
        uint gameId; 
        uint initialOdd; 
        string teamA;
        string teamB;
    }

    constructor(
        address _bookie
    ){
        bookie = _bookie;
    }

    function initOdd(uint256 _homeOdd, uint256 _drawOdd, uint256 _awayOdd ) public onlyBookie {

        oddsForSide[_homeOdd] = Side.HOME;
        oddsForSide[_drawOdd] = Side.DRAW;
        oddsForSide[_awayOdd] = Side.AWAY;
    }

    function chooseSide(uint _gameId, uint _odd) public  payable {


        if (betOfUser[msg.sender] == Side.HOME) {
            _rebalanceSizeForLay(_gameId);
            require(isMaxBet() , "Maximum Bet Limit Exceeded");   
        } else if (betOfUser[msg.sender] == Side.DRAW) {
            rebalanceSizeForDraw(_odd);
            require(isMaxBet() , "Maximum Bet Limit Exceeded"); 
        } else if (betOfUser[msg.sender] == Side.AWAY) {
            rebalanceSizeForBack(_odd);
            require(isMaxBet() , "Maximum Bet Limit Exceeded");
        }
        
        totalLiquidityPerGame[_gameId] += msg.value;
        totalPayOut[_gameId] += msg.value * _odd;

    }


    function _rebalanceSizeForLay(uint _gameId) internal   {
       
       if ( (totalLiquidityPerGame[_gameId]) > totalPayOut[_gameId] ){
            maxAmountBet = maxAmountBet;
        } else { 
            maxAmountBet = maxAmountBet  - ((maxAmountBet * 20 ) / 100) ;  // Decrease the maxAmountBet by 20%
       }

    }

    function rebalanceSizeForDraw(uint _odd) internal {}
    
    function rebalanceSizeForBack(uint _odd) internal {}

    function isMaxBet() public payable returns (bool){
        require (msg.value < maxAmountBet );
    }

    function getMaxBetForHome(uint _odd, uint _gameId) public view returns (uint256){
        lockedPerGame[_gameId] ;
    }


    function getMaxBetForDraw() public view returns (uint256){}
    function getMaxBetForAway() public view returns (uint256){}


    function resolveGame(uint _gameId) internal {
    }

    modifier onlyBookie() {
        require(msg.sender == bookie, "Only bookie can call this function");
        _;
    }


}