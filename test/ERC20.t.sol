// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {WDLToken} from "../src/ERC20.sol";

contract ERC20Test is Test {
    WDLToken token;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new WDLToken(1000);
    }

    function test_Mint() public {
        // Check the initial balance of the deployer
        assertEq(token.balanceOf(address(this)), 1000);
    }

    function test_Transfer() public {
        // not enough supply
        vm.expectRevert();
        token.transfer(user1, 1001);

        // transfer some
        token.transfer(user1, 100);
        assertEq(token.balanceOf(user1), 100);
        assertEq(token.balanceOf(address(this)), 900);

        // transfer between
        vm.prank(user1);
        token.approve(address(this), 50);
        token.transferFrom(user1, user2, 50);
        assertEq(token.balanceOf(user1), 50);
        assertEq(token.balanceOf(user2), 50);
    }
}
