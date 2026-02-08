// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/crosschain/CrossChainVerifier.sol";
import "../src/interfaces/IFDC.sol";

contract MockFDC is IFDC {
    bool public shouldVerify;

    function setResult(bool v) external {
        shouldVerify = v;
    }

    function verifyEVMTransaction(Proof calldata)
        external
        view
        override
        returns (bool)
    {
        return shouldVerify;
    }
}

contract CrossChainVerifierTest is Test {
    MockFDC fdc;
    CrossChainVerifier verifier;

    function setUp() public {
        fdc = new MockFDC();
        verifier = new CrossChainVerifier(address(fdc));
    }

    function testVerifyTrue() public {
        fdc.setResult(true);

        IFDC.Proof memory p;
        bool ok = verifier.verifyEVMTransaction(p);

        assertTrue(ok);
    }

    function testVerifyFalse() public {
        fdc.setResult(false);

        IFDC.Proof memory p;
        bool ok = verifier.verifyEVMTransaction(p);

        assertFalse(ok);
    }
}
