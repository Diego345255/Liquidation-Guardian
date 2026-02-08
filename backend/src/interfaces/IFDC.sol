// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IFDC - Interface for Flare Data Connector (FDC) EVM Transaction Verification
/// @notice Structs and function signatures copied exactly from IEVMTransaction in Flare docs.
interface IFDC {

    struct Event {
        uint32 logIndex;
        address emitterAddress;
        bytes32[] topics;
        bytes data;
        bool removed;
    }

    struct ResponseBody {
        uint64 blockNumber;
        uint64 timestamp;
        address sourceAddress;
        bool isDeployment;
        address receivingAddress;
        uint256 value;
        bytes input;
        uint8 status;
        Event[] events;
    }

    struct RequestBody {
        bytes32 transactionHash;
        uint16 requiredConfirmations;
        bool provideInput;
        bool listEvents;
        uint32[] logIndices;
    }

    struct Response {
        bytes32 attestationType;
        bytes32 sourceId;
        uint64 votingRound;
        uint64 lowestUsedTimestamp;
        RequestBody requestBody;
        ResponseBody responseBody;
    }

    struct Proof {
        bytes32[] merkleProof;
        Response data;
    }

    /// @notice Verifies an EVM transaction attestation proof.
    /// @param _proof The EVM transaction proof structure.
    /// @return _proved Boolean indicating if the proof is valid.
    function verifyEVMTransaction(
        Proof calldata _proof
    )
        external
        view
        returns (bool _proved);
}
