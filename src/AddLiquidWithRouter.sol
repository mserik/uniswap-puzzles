// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract AddLiquidWithRouter {
    address public immutable router;
    address public immutable pool;

    constructor(address _router, address _pool) {
        router = _router;
        pool = _pool;
    }

    function addLiquidityWithRouter(address usdcAddress) public {
        // Fetch the pool's reserves
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pool).getReserves();

        uint256 ethReserve;
        uint256 usdcReserve;

        if (IUniswapV2Pair(pool).token0() == usdcAddress) {
            usdcReserve = reserve0;
            ethReserve = reserve1;
        } else {
            usdcReserve = reserve1;
            ethReserve = reserve0;
        }

        // Calculate the amount of USDC to match 1 ETH worth
        uint256 amountTokenDesired = 1000 * 10 ** 6; // 1000 USDC
        uint256 amountTokenMin = (amountTokenDesired * 99) / 100;
        uint256 amountETHMin = ((amountTokenDesired * ethReserve) / usdcReserve) * 99 / 100;

        // Approve the router to spend USDC on behalf of this contract
        IERC20(usdcAddress).approve(router, amountTokenDesired);

        // Parameters for the addLiquidityETH function
        address to = msg.sender; // Recipient of the liquidity tokens
        uint256 deadline = block.timestamp + 15 minutes; // 15 minutes from now

        // Call addLiquidityETH on the Uniswap V2 router
        IUniswapV2Router(router).addLiquidityETH{value: 1 ether}(
            usdcAddress,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    receive() external payable {}
}
