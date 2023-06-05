// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Game.sol";

contract GameTest is Test {

    Game public game;
    Game.Side public side;
    address bookie = vm.addr(0x009);
    address bob = vm.addr(0x001);
    event log_uint256(uint256);

    function setUp() public {
        game = new Game(address(bookie), 1, 2 ether);
    }

    // function testinitOdd() public {
    //     vm.prank(bookie);
    //     game.initOdd(2, 2, 3);
    //     assertEq(game.numberForSide(game.getSide()), 2);
    // } 

    function testchooseSide() public {

        vm.prank(bob);
        vm.deal(bob, 4 ether);
        emit log_uint256(bob.balance);
        game.chooseSide(1, 2);
        game.chooseSide(1, 5);
        game.chooseSide(1, 4);
        emit log_uint256(game.maxAmountBet());

    }


}

    
