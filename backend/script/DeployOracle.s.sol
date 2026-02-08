// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/oracle/PriceOracle.sol";

contract DeployOracle is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address ftso = vm.envAddress("FTSO_CONTRACT");

        vm.startBroadcast(pk);
        PriceOracle oracle = new PriceOracle(ftso);
        vm.stopBroadcast();

        console.log("PriceOracle deployed at:", address(oracle));
    }
}
