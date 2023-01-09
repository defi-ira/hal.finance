// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IHopRouter {
    
    function addLiquidity(
        uint256[] calldata amounts,     // amounts the amounts of each token to add, in their native precision
        uint256 minToMint,              // minToMint the minimum LP tokens adding this amount of liquidity should mint, otherwise revert. Handy for front-running mitigation
        address deadline                // deadline latest timestamp to accept this transaction
    ) external;

    function removeLiquidityOneToken(
        uint256 tokenAmount,            // tokenAmount the amount of the token you want to receive
        uint8 tokenIndex,               // tokenIndex the index of the token you want to receive
        uint256 minAmount,              // minAmount the minimum amount to withdraw, otherwise revert
        uint256 deadline                // deadline latest timestamp to accept this transaction
    ) external;
    
}
