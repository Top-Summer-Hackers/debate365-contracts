// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Debet365FunctionsConsumer.sol";
import "../src/Mocks/MockToken.sol";
import "../src/GameSingleImplementation.sol";

contract DeployScript is Script {
    uint256 constant DECIMALS = 10 ** 18;

    function run() public {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(pk);
        Debet365FunctionsConsumer debet = new Debet365FunctionsConsumer(
            address(0xeA6721aC65BCeD841B8ec3fc5fEdeA6141a0aDE4)
        );
        GameSingleImplementation game = new GameSingleImplementation();
        MockToken usdc = new MockToken("USDC", "USDC");

        uint256[3] memory odds = generateOdds(15, 23, 33);

        debet.setGameImplementation(
            Debet365FunctionsConsumer.GameType.SINGLE,
            address(game)
        );

        debet.openGame(
            odds,
            Debet365FunctionsConsumer.GameType.SINGLE,
            address(usdc)
        );

        MockToken token = new MockToken("SRD", "SD");
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
