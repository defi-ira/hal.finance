// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IHopPool {
    function getVirtualPrice() external view returns (uint256);
}