// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PositionManager.sol";
import "../src/vault/LiquidationGuardian.sol";
import "../src/crosschain/CrossChainVerifier.sol";
import "../src/interfaces/IFDC.sol";

contract MockGuardian is LiquidationGuardian {
    bool public allow;

    constructor() LiquidationGuardian(address(0), address(0)) {}

    function set(bool a) external {
        allow = a;
    }

    function canLiquidate(
        IFDC.Proof calldata,
        IFDC.Proof calldata,
        bytes32,
        bytes32
    )
        public
        view
        override
        returns (bool)
    {
        return allow;
    }
}

contract MockVerifier2 is CrossChainVerifier {
    bool public ok;
    uint256 public val;

    constructor() CrossChainVerifier(address(0)) {}

    function set(bool _ok, uint256 _val) external {
        ok = _ok;
        val = _val;
    }

    function verifyEVMTransaction(IFDC.Proof calldata)
        public
        view
        override
        returns (bool)
    {
        return ok;
    }

    function extractValue(IFDC.Proof calldata)
        public
        view
        override
        returns (uint256)
    {
        return val;
    }
}

contract PositionManagerTest is Test {
    MockVerifier2 verifier;
    MockGuardian guardian;
    PositionManager pm;

    function setUp() public {
        verifier = new MockVerifier2();
        guardian = new MockGuardian();
        pm = new PositionManager(address(verifier), address(guardian));
    }

    function testUpdateCollateral() public {
        verifier.set(true, 100e18);

        IFDC.Proof memory p;
        pm.updateCollateral(address(1), p, "ETH");

        (uint256 c,,,) = pm.positions(address(1));
        assertEq(c, 100e18);
    }

    function testLiquidation() public {
        verifier.set(true, 100e18);
        guardian.set(true);

        IFDC.Proof memory p;

        pm.updateCollateral(address(1), p, "ETH");
        pm.updateDebt(address(1), p, "ETH");

        pm.liquidate(address(1), p, p);

        (uint256 c, uint256 d,,) = pm.positions(address(1));
        assertEq(c, 0);
        assertEq(d, 0);
    }
}
