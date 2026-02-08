// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PositionManager.sol";

contract DeployPositionManager is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address verifier = vm.envAddress("VERIFIER_CONTRACT");
        address guardian = vm.envAddress("GUARDIAN_CONTRACT");

        vm.startBroadcast(pk);
        PositionManager pm = new PositionManager(verifier, guardian);
        vm.stopBroadcast();

        console.log("PositionManager deployed at:", address(pm));
    }
}
