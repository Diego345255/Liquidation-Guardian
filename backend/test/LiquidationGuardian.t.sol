// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/vault/LiquidationGuardian.sol";
import "../src/crosschain/CrossChainVerifier.sol";
import "../src/oracle/PriceOracle.sol";
import "../src/interfaces/IFDC.sol";
import "../src/interfaces/IFTSO.sol";

contract MockVerifier is CrossChainVerifier {
    bool public result;
    uint256 public extracted;

    constructor() CrossChainVerifier(address(0)) {}

    function set(bool r, uint256 v) external {
        result = r;
        extracted = v;
    }

    function verifyEVMTransaction(IFDC.Proof calldata)
        external
        view
        override
        returns (bool)
    {
        return result;
    }

    function extractValue(IFDC.Proof calldata)
        external
        view
        override
        returns (uint256)
    {
        return extracted;
    }
}

contract MockOracle is PriceOracle {
    uint256 public price;

    constructor() PriceOracle(address(0)) {}

    function set(uint256 p) external {
        price = p;
    }

    function getPrice(bytes32)
        public
        view
        override
        returns (uint256, uint64)
    {
        return (price, 0);
    }
}

contract LiquidationGuardianTest is Test {
    MockVerifier verifier;
    MockOracle oracle;
    LiquidationGuardian guardian;

    function setUp() public {
        verifier = new MockVerifier();
        oracle = new MockOracle();
        guardian = new LiquidationGuardian(address(verifier), address(oracle));

        guardian.setCollateralFactor("ETH", 0.75e18);
    }

    function testHealthFactor() public {
        verifier.set(true, 1e18); // 1 ETH collateral + 1 ETH debt
        oracle.set(2000e18);      // ETH price = $2000

        uint256 hf = guardian.computeHealthFactor(
            IFDC.Proof(new bytes32[](0), IFDC.Response({
                attestationType: 0,
                sourceId: 0,
                votingRound: 0,
                lowestUsedTimestamp: 0,
                requestBody: IFDC.RequestBody({
                    transactionHash: 0,
                    requiredConfirmations: 0,
                    provideInput: false,
                    listEvents: false,
                    logIndices: new uint32[](0)
                }),
                responseBody: IFDC.ResponseBody({
                    blockNumber: 0,
                    timestamp: 0,
                    sourceAddress: address(0),
                    isDeployment: false,
                    receivingAddress: address(0),
                    value: 0,
                    input: "",
                    status: 1,
                    events: new IFDC.Event[](0)
                })
            })),
            IFDC.Proof(new bytes32[](0), IFDC.Response({
                attestationType: 0,
                sourceId: 0,
                votingRound: 0,
                lowestUsedTimestamp: 0,
                requestBody: IFDC.RequestBody({
                    transactionHash: 0,
                    requiredConfirmations: 0,
                    provideInput: false,
                    listEvents: false,
                    logIndices: new uint32[](0)
                }),
                responseBody: IFDC.ResponseBody({
                    blockNumber: 0,
                    timestamp: 0,
                    sourceAddress: address(0),
                    isDeployment: false,
                    receivingAddress: address(0),
                    value: 0,
                    input: "",
                    status: 1,
                    events: new IFDC.Event[](0)
                })
            })),
            "ETH",
            "ETH"
        );

        // HF = (collateral * price * factor) / (debt * price)
        // HF = (1 * 2000 * 0.75) / (1 * 2000) = 0.75
        assertEq(hf, 0.75e18);
    }
}
