// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/oracle/PriceOracle.sol";
import "../src/interfaces/IFTSO.sol";

contract MockFTSO is IFTSO {
    uint256 public value;
    int8 public decimals;
    uint64 public timestamp;

    function set(uint256 v, int8 d, uint64 t) external {
        value = v;
        decimals = d;
        timestamp = t;
    }

    function getFeedById(bytes21)
        external
        payable
        override
    returns (uint256, int8, uint64)
    {
    return (value, decimals, timestamp);
    }

}

contract PriceOracleTest is Test {
    MockFTSO ftso;
    PriceOracle oracle;

    function setUp() public {
        ftso = new MockFTSO();
        oracle = new PriceOracle(address(ftso));
    }

    function testNormalizeDecimals() public {
        oracle.setFeedId("ETH", bytes21(uint168(1)));

        ftso.set(2000e8, 8, 123); // 2000 * 10^8

        (uint256 price, ) = oracle.getPrice("ETH");

        assertEq(price, 2000e18);
    }
}
