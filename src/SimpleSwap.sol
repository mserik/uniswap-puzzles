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
        uint256 wethAmount = IERC20(weth).balanceOf(address(this));

        // Approve the pool to spend WETH
        IERC20(weth).approve(pool, wethAmount);

        // Get the reserves of the pool
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pool).getReserves();
        (address token0, ) = IUniswapV2Pair(pool).token0() == weth ? (weth, usdc) : (usdc, weth);

        // Calculate the amount of USDC to receive
        uint256 amountOut = getAmountOut(wethAmount, reserve0, reserve1);

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
