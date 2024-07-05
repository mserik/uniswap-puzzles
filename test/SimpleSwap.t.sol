// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SimpleSwap} from "../src/SimpleSwap.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/interfaces/IERC20.sol";

contract SimpleSwapTest is Test {
    SimpleSwap public simpleSwap;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;

    function setUp() public {
        simpleSwap = new SimpleSwap(weth, usdc);

        // Transfers 1 WETH to simpleSwap contract
        deal(weth, address(simpleSwap), 1 ether);
    }

    function test_PerformSwap() public {
        vm.prank(address(0xb0b));

        uint256 initialWETHBalance = IERC20(weth).balanceOf(address(simpleSwap));
        uint256 initialUSDCBalance = IERC20(usdc).balanceOf(address(simpleSwap));

        console2.log("Initial WETH balance:", initialWETHBalance);
        console2.log("Initial USDC balance:", initialUSDCBalance);

        simpleSwap.performSwap(pool);

        uint256 finalWETHBalance = IERC20(weth).balanceOf(address(simpleSwap));
        uint256 finalUSDCBalance = IERC20(usdc).balanceOf(address(simpleSwap));

        console2.log("Final WETH balance:", finalWETHBalance);
        console2.log("Final USDC balance:", finalUSDCBalance);

        require(finalUSDCBalance > 0, "Swap failed, USDC balance is 0");
    }
}
