// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IStargateRouter {

    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint _poolId,         // the stargate poolId representing the specific ERC20 token
        uint256 _amountLD,    // the amount to loan. quantity in local decimals
        address _to           // the address to receive the LP token. ie: shares of the pool
    ) external;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

}
