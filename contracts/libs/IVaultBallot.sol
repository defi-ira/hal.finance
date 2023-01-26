// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IVaultBallot {

    function vetoPool(uint256 token_, uint16[] calldata poolId_) external;

    function setMinTvl(uint256 token_, uint256 minTvl_) external;
    
    function veto(uint256 token_) external view returns (uint16[] memory veto_);

    function minTvl(uint256 token_) external view returns (uint256 minTvl_);

    function mint(address to_) external returns (uint256 tokenId_);

}