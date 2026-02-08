// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IFTSO - Interface for Flare FTSOv2 price feeds
/// @notice Function signatures copied exactly from FtsoV2Interface in Flare docs.
interface IFTSO {
    function getFeedById(
        bytes21 _feedId
    ) external payable virtual returns (
        uint256 _value,
        int8 _decimals,
        uint64 _timestamp
    );
}
