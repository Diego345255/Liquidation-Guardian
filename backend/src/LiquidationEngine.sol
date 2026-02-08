// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPositionManager {
    function getCollateral(address user) external view returns (uint256);
    function getDebt(address user) external view returns (uint256);
    function liquidate(address user) external;
}

contract LiquidationEngine {
    IPositionManager public positionManager;

    constructor(address _positionManager) {
        positionManager = IPositionManager(_positionManager);
    }

    function getCollateral(address user) external view returns (uint256) {
        return positionManager.getCollateral(user);
    }

    function getDebt(address user) external view returns (uint256) {
        return positionManager.getDebt(user);
    }

    function liquidate(address user) external {
        positionManager.liquidate(user);
    }
}
