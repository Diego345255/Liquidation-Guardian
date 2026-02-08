// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./crosschain/CrossChainVerifier.sol";
import "./vault/LiquidationGuardian.sol";
import "./interfaces/IFDC.sol";

/// @title PositionManager
/// @notice Stores user collateral & debt positions on Flare after cross-chain verification.
contract PositionManager {

    struct Position {
        uint256 collateral;   // in asset units
        uint256 debt;         // in asset units
        bytes32 collateralAsset;
        bytes32 debtAsset;
    }

    mapping(address => Position) public positions;

    CrossChainVerifier public verifier;
    LiquidationGuardian public guardian;

    constructor(address _verifier, address _guardian) {
        require(_verifier != address(0), "Invalid verifier");
        require(_guardian != address(0), "Invalid guardian");

        verifier = CrossChainVerifier(_verifier);
        guardian = LiquidationGuardian(_guardian);
    }

    /// @notice Updates collateral after verifying cross-chain proof.
    function updateCollateral(
        address user,
        IFDC.Proof calldata collateralProof,
        bytes32 collateralAsset
    )
        external
    {
        bool ok = verifier.verifyEVMTransaction(collateralProof);
        require(ok, "Invalid collateral proof");

        uint256 amount = verifier.extractValue(collateralProof);

        Position storage p = positions[user];
        p.collateral += amount;
        p.collateralAsset = collateralAsset;
    }

    /// @notice Updates debt after verifying cross-chain proof.
    function updateDebt(
        address user,
        IFDC.Proof calldata debtProof,
        bytes32 debtAsset
    )
        external
    {
        bool ok = verifier.verifyEVMTransaction(debtProof);
        require(ok, "Invalid debt proof");

        uint256 amount = verifier.extractValue(debtProof);

        Position storage p = positions[user];
        p.debt += amount;
        p.debtAsset = debtAsset;
    }

    /// @notice Returns true if the user is liquidatable.
    function isLiquidatable(
        address user,
        IFDC.Proof calldata collateralProof,
        IFDC.Proof calldata debtProof
    )
        external
        returns (bool)
    {
        Position memory p = positions[user];
        return guardian.canLiquidate(
            collateralProof,
            debtProof,
            p.collateralAsset,
            p.debtAsset
        );
    }

    /// @notice Liquidates a user if their health factor < 1.0.
    function liquidate(
        address user,
        IFDC.Proof calldata collateralProof,
        IFDC.Proof calldata debtProof
    )
        external
    {
        Position memory p = positions[user];

        bool allowed = guardian.canLiquidate(
            collateralProof,
            debtProof,
            p.collateralAsset,
            p.debtAsset
        );

        require(allowed, "User not liquidatable");

        // Reset position
        delete positions[user];
    }
}
