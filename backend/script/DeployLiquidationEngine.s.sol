// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/LiquidationEngine.sol";

contract DeployLiquidationEngine is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address positionManager = vm.envAddress("POSITION_MANAGER_CONTRACT");

        vm.startBroadcast(pk);
        LiquidationEngine engine = new LiquidationEngine(positionManager);
        vm.stopBroadcast();

        console.log("LiquidationEngine deployed at:", address(engine));
    }
}
