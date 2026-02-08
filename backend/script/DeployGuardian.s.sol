// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/vault/LiquidationGuardian.sol";

contract DeployGuardian is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address verifier = vm.envAddress("VERIFIER_CONTRACT");
        address oracle = vm.envAddress("ORACLE_CONTRACT");

        vm.startBroadcast(pk);
        LiquidationGuardian guardian = new LiquidationGuardian(verifier, oracle);
        vm.stopBroadcast();

        console.log("LiquidationGuardian deployed at:", address(guardian));
    }
}
