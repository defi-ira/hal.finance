// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIntegration is IERC20 {

    event PoolAddLiquidityEvent(uint8 projectId, uint _poolId, uint256 _amountLD, address _to);
    event PoolRemoveLiquidity(uint8 projectId, uint256 _srcPoolId, uint256 _amountLP, address _to);
    event PoolAdded(uint8 projectId, string token, uint8 id);
    event PoolRemoved(uint8 projectId, string token);

    struct TokenId {
        string ticker;
        uint id;
    }

    function addLiquidity(
        string memory _token,         // the token string mapped to Stargate specific ERC20 token poolId
        uint256 _amountLD,            // the amount to loan. quantity in local decimals
        address _to                   // the address to receive the LP token. ie: shares of the pool
    ) external;

    function removeLiquidity(
        string memory token,
        uint256 _amountLP,
        address _to
    ) external;


}