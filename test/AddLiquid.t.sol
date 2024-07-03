// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {AddLiquid} from "../src/AddLiquid.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/interfaces/IERC20.sol";

contract AddLiquidTest is Test {
    AddLiquid public addLiquid;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address public senderWETH = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
    address public senderUSDC = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

    function setUp() public {
        addLiquid = new AddLiquid();

        // Check balances before transfer
        uint256 initialWETHBalance = IERC20(weth).balanceOf(senderWETH);
        uint256 initialUSDCBalance = IERC20(usdc).balanceOf(senderUSDC);

        console2.log("WETH balance of senderWETH before transfer:", initialWETHBalance);
        console2.log("USDC balance of senderUSDC before transfer:", initialUSDCBalance);

        require(initialWETHBalance >= 1 ether, "Insufficient WETH balance");
        require(initialUSDCBalance >= 1000 * 10 ** 6, "Insufficient USDC balance");

        // Check allowances before setting
        uint256 initialWETHAllowance = IERC20(weth).allowance(senderWETH, address(addLiquid));
        uint256 initialUSDCAllowance = IERC20(usdc).allowance(senderUSDC, address(addLiquid));

        console2.log("WETH allowance for AddLiquid before transfer:", initialWETHAllowance);
        console2.log("USDC allowance for AddLiquid before transfer:", initialUSDCAllowance);

        // Set allowances if insufficient
        if (initialWETHAllowance < 1 ether) {
            vm.startPrank(senderWETH);
            IERC20(weth).approve(address(addLiquid), 1 ether);
            vm.stopPrank();
        }

        if (initialUSDCAllowance < 1000 * 10 ** 6) {
            vm.startPrank(senderUSDC);
            IERC20(usdc).approve(address(addLiquid), 1000 * 10 ** 6);
            vm.stopPrank();
        }

        // Log allowances after setting
        uint256 finalWETHAllowance = IERC20(weth).allowance(senderWETH, address(addLiquid));
        uint256 finalUSDCAllowance = IERC20(usdc).allowance(senderUSDC, address(addLiquid));

        console2.log("WETH allowance for AddLiquid after transfer:", finalWETHAllowance);
        console2.log("USDC allowance for AddLiquid after transfer:", finalUSDCAllowance);

        // Transfer tokens to AddLiquid contract
        vm.startPrank(senderWETH);
        IERC20(weth).transfer(address(addLiquid), 1 ether);
        vm.stopPrank();

        vm.startPrank(senderUSDC);
        IERC20(usdc).transfer(address(addLiquid), 1000 * 10 ** 6);
        vm.stopPrank();

        // Log balances after transfer
        uint256 finalWETHBalance = IERC20(weth).balanceOf(address(addLiquid));
        uint256 finalUSDCBalance = IERC20(usdc).balanceOf(address(addLiquid));

        console2.log("WETH balance of AddLiquid after transfer:", finalWETHBalance);
        console2.log("USDC balance of AddLiquid after transfer:", finalUSDCBalance);

        require(finalWETHBalance == 1 ether, "WETH transfer failed");
        require(finalUSDCBalance == 1000 * 10 ** 6, "USDC transfer failed");
    }

    function test_AddLiquidity() public {
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pool).getReserves();
        uint256 _totalSupply = IUniswapV2Pair(pool).totalSupply();

        vm.prank(address(0xb0b));
        addLiquid.addLiquidity(usdc, weth, pool, reserve0, reserve1);

        uint256 foo = (1000 * 10 ** 6) - (IERC20(usdc).balanceOf(address(addLiquid)));

        uint256 puzzleBal = IUniswapV2Pair(pool).balanceOf(address(0xb0b));

        uint256 bar = (foo * reserve1) / reserve0;

        uint256 expectBal = min((foo * _totalSupply) / (reserve0), (bar * _totalSupply) / (reserve1));

        require(puzzleBal > 0);
        assertEq(puzzleBal, expectBal);
    }

    // Internal function
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
}
