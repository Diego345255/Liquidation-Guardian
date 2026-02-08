// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IFDC.sol";

/// @title CrossChainVerifier
/// @notice Uses Flare FDC to verify EVM transaction proofs.
contract CrossChainVerifier {

    IFDC public fdc;

    constructor(address _fdc) {
        require(_fdc != address(0), "Invalid FDC address");
        fdc = IFDC(_fdc);
    }

    /// @notice Verifies an EVM transaction proof using FDC.
    /// @param proof The full EVMTransaction.Proof struct.
    /// @return proved True if the proof is valid.
    function verifyEVMTransaction(IFDC.Proof calldata proof)
        external
        view
        virtual
        returns (bool proved)
    {
        proved = fdc.verifyEVMTransaction(proof);
    }

    /// @notice Extracts the value transferred in the verified transaction.
    /// @dev This is optional but extremely useful for liquidation logic.
    function extractValue(IFDC.Proof calldata proof)
        external
        view
        virtual
        returns (uint256)
    {
        return proof.data.responseBody.value;
    }

    /// @notice Extracts the sender address from the verified transaction.
    function extractSender(IFDC.Proof calldata proof)
        external
        pure
        returns (address)
    {
        return proof.data.responseBody.sourceAddress;
    }

    /// @notice Extracts the receiver address from the verified transaction.
    function extractReceiver(IFDC.Proof calldata proof)
        external
        pure
        returns (address)
    {
        return proof.data.responseBody.receivingAddress;
    }
}
