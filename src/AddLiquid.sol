// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // Calculate the amount of WETH to deposit based on the reserves
        uint256 amountWETH = (1000 * 10 ** 6 * wethReserve) / usdcReserve;

        // Check balances before the transfer
        uint256 contractUSDCBalance = IERC20(usdc).balanceOf(address(this));
        uint256 contractWETHBalance = IERC20(weth).balanceOf(address(this));

        // Require sufficient balances
        require(contractUSDCBalance >= 1000 * 10 ** 6, "Insufficient USDC balance in contract");
        require(contractWETHBalance >= amountWETH, "Insufficient WETH balance in contract");

        // Transfer USDC and WETH to the pool contract
        IERC20(usdc).transfer(pool, 1000 * 10 ** 6);
        IERC20(weth).transfer(pool, amountWETH);

        // Mint the liquidity position
        pair.mint(msg.sender);
    }
}
