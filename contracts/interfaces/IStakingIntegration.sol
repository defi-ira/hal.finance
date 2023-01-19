// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IIntegration.sol";

interface IStakingIntegration is IIntegration {

    function getStakedBalance(
        address _poolAddress
    ) external view returns (uint256 notionalBalance);

    function getRewardsBalance(
        address _poolAddress
    ) external view returns (uint256 rewardsBalance);

}