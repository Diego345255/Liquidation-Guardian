// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/crosschain/CrossChainVerifier.sol";

contract DeployVerifier is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address fdc = vm.envAddress("FDC_VERIFICATION_CONTRACT");

        vm.startBroadcast(pk);
        CrossChainVerifier verifier = new CrossChainVerifier(fdc);
        vm.stopBroadcast();

        console.log("CrossChainVerifier deployed at:", address(verifier));
    }
}
