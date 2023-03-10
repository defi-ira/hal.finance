// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IHopRewards {
    function earned(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getRewardForDuration() external view returns (uint256);
    function rewardPerToken() external view returns (uint256);  
}