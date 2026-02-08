// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IFTSO.sol";

/// @title PriceOracle
/// @notice Thin wrapper around Flare FTSOv2 to fetch normalized prices.
contract PriceOracle {
    IFTSO public ftso;

    // Optional: mapping from human-readable asset key to feedId
    mapping(bytes32 => bytes21) public feedIds;

    constructor(address _ftso) {
        require(_ftso != address(0), "Invalid FTSO address");
        ftso = IFTSO(_ftso);
    }

    /// @notice Registers a mapping from asset symbol to FTSO feedId.
    /// @dev You can call this in a deployment script or via an admin.
    function setFeedId(bytes32 assetKey, bytes21 feedId) external {
        // In production you’d add access control (onlyOwner).
        feedIds[assetKey] = feedId;
    }

    /// @notice Returns raw FTSO price tuple for a given feedId.
    function getRawPrice(bytes21 feedId)
        public
        returns (uint256 value, int8 decimals, uint64 timestamp)
    {
        (value, decimals, timestamp) = ftso.getFeedById(feedId);
    }

    /// @notice Returns normalized price (scaled to 18 decimals) for a given asset key.
    /// @dev Example assetKey: keccak256("ETH"), keccak256("USDC"), etc.
    function getPrice(bytes32 assetKey)
        external
        virtual
        returns (uint256 price18, uint64 timestamp)
    {
        bytes21 feedId = feedIds[assetKey];
        require(feedId != bytes21(0), "Unknown asset feed");

        (uint256 value, int8 decimals, uint64 ts) = ftso.getFeedById(feedId);

        if (decimals == 18) {
            return (value, ts);
        } else if (decimals > 18) {
            uint8 diff = uint8(uint8(decimals) - 18);
            return (value / (10 ** diff), ts);
        } else {
            uint8 diff = uint8(18 - uint8(decimals));
            return (value * (10 ** diff), ts);
        }
    }
}
