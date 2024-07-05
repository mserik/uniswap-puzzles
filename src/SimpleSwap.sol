// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract SimpleSwap {
    address public weth;
    address public usdc;

    constructor(address _weth, address _usdc) {
        weth = _weth;
        usdc = _usdc;
    }

    function performSwap(address pool) public {
        // Use a very small fraction of WETH for the swap to ensure liquidity
        uint256 wethAmount = IERC20(weth).balanceOf(address(this)) / 10000;

        // Approve the pool to spend WETH
        IERC20(weth).approve(pool, wethAmount);

        // Get the reserves of the pool
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pool).getReserves();
        address token0 = IUniswapV2Pair(pool).token0();

        // Ensure weth and usdc are in the correct order
        if (token0 == usdc) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }

        // Log the reserves and swap amounts
        console.log("WETH amount:", wethAmount);
        console.log("Reserve0 (USDC):", reserve0);
        console.log("Reserve1 (WETH):", reserve1);

        // Calculate the amount of USDC to receive
        uint256 amountOut = getAmountOut(wethAmount, reserve1, reserve0);

        // Log the calculated amountOut
        console.log("Calculated amountOut (USDC):", amountOut);

        // Perform the swap
        IUniswapV2Pair(pool).swap(
            token0 == weth ? 0 : amountOut,
            token0 == weth ? amountOut : 0,
            address(this),
            new bytes(0)
        );
    }

    function getAmountOut(uint256 amountIn, uint112 reserveIn, uint112 reserveOut) public pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
