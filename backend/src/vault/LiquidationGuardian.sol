// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../crosschain/CrossChainVerifier.sol";
import "../oracle/PriceOracle.sol";
import "../interfaces/IFDC.sol";

/// @title LiquidationGuardian
/// @notice Computes health factor using cross-chain verified data + FTSO prices.
contract LiquidationGuardian {

    CrossChainVerifier public verifier;
    PriceOracle public priceOracle;

    // Collateral factor (e.g., 75% = 0.75e18)
    mapping(bytes32 => uint256) public collateralFactors;

    constructor(address _verifier, address _priceOracle) {
        require(_verifier != address(0), "Invalid verifier");
        require(_priceOracle != address(0), "Invalid oracle");

        verifier = CrossChainVerifier(_verifier);
        priceOracle = PriceOracle(_priceOracle);
    }

    /// @notice Sets collateral factor for an asset.
    /// @dev Example: 0.75e18 means 75% LTV.
    function setCollateralFactor(bytes32 assetKey, uint256 factor) external {
        // In production: add onlyOwner
        collateralFactors[assetKey] = factor;
    }

    /// @notice Computes health factor using verified cross-chain collateral & debt.
    /// @param collateralProof Proof of collateral deposit on remote chain.
    /// @param debtProof Proof of debt mint on remote chain.
    /// @param collateralAsset Asset key (e.g., keccak256("ETH")).
    /// @param debtAsset Asset key (e.g., keccak256("USDC")).
    /// @return healthFactor Scaled by 1e18.
    function computeHealthFactor(
        IFDC.Proof calldata collateralProof,
        IFDC.Proof calldata debtProof,
        bytes32 collateralAsset,
        bytes32 debtAsset
    )
        external
        returns (uint256 healthFactor)
    {
        // 1. Verify both proofs
        bool ok1 = verifier.verifyEVMTransaction(collateralProof);
        bool ok2 = verifier.verifyEVMTransaction(debtProof);
        require(ok1 && ok2, "Invalid cross-chain proofs");

        // 2. Extract amounts
        uint256 collateralAmount = verifier.extractValue(collateralProof);
        uint256 debtAmount = verifier.extractValue(debtProof);

        // 3. Fetch prices
        (uint256 collateralPrice, ) = priceOracle.getPrice(collateralAsset);
        (uint256 debtPrice, ) = priceOracle.getPrice(debtAsset);

        // 4. Compute USD values
        uint256 collateralUSD = collateralAmount * collateralPrice / 1e18;
        uint256 debtUSD = debtAmount * debtPrice / 1e18;

        // 5. Apply collateral factor
        uint256 factor = collateralFactors[collateralAsset];
        uint256 adjustedCollateral = collateralUSD * factor / 1e18;

        // 6. Health factor = adjustedCollateral / debt
        if (debtUSD == 0) return type(uint256).max;
        healthFactor = adjustedCollateral * 1e18 / debtUSD;
    }

    /// @notice Returns true if liquidation is allowed.
    function canLiquidate(
        IFDC.Proof calldata collateralProof,
        IFDC.Proof calldata debtProof,
        bytes32 collateralAsset,
        bytes32 debtAsset
    )
        external
        virtual
        returns (bool)
    {
        uint256 hf = this.computeHealthFactor(
            collateralProof,
            debtProof,
            collateralAsset,
            debtAsset
        );

        return hf < 1e18; // HF < 1.0
    }
}
