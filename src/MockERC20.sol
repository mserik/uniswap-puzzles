// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MockERC20 {
    function name() external pure returns (string memory) {
        return "Hello World";
    }
}
