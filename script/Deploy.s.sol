// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Debet365FunctionsConsumer.sol";
import "../src/Mocks/MockToken.sol";
import "../src/GameSingleImplementation.sol";

contract DeployScript is Script {
    uint256 constant DECIMALS = 10 ** 18;
    address public constant consumerContractDeployed =
        0xCfa537e30F0af3495330cf7C200F1F7B153Be88a;
    address public constant usdc = 0xC612e8f0cb5fa09B89E980238428a32Fa78B8561;

    function run() public {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(pk);
        Debet365FunctionsConsumer debet = Debet365FunctionsConsumer(
            consumerContractDeployed
        );

        //----------deploy token---------------------------------
        // MockToken usdc = new MockToken("USDC", "USDC");

        // ----------set implementation---------------------------
        // GameSingleImplementation game = new GameSingleImplementation();
        // debet.setGameImplementation(
        //     Debet365FunctionsConsumer.GameType.SINGLE,
        //     address(game)
        // );

        //---------- open a game --------------------------------
        uint256[3] memory odds = generateOdds(15, 23, 33);
        debet.openGame(odds, Debet365FunctionsConsumer.GameType.SINGLE, usdc);
        debet.openGame(odds, Debet365FunctionsConsumer.GameType.SINGLE, usdc);

        vm.stopBroadcast();
    }

    function generateOdds(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256[3] memory odds) {
        odds[0] = (a * DECIMALS) / 10;
        odds[1] = (b * DECIMALS) / 10;
        odds[2] = (c * DECIMALS) / 10;
    }
}
