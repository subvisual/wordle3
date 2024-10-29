// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Wordle} from "../src/Wordle.sol";
import {StructTypes} from "../src/Interfaces.sol";

contract WordleTest is Test {
    Wordle wordle;

    function setUp() public {
        wordle = new Wordle();
    }

    // test word hiding
    function test_hideWord() public {
        // correct input
        wordle.hideWord("BINGO");
        StructTypes.CharState[] memory hitmap = wordle.getHiddenWord();

        // test if hitmap is generated correctly

        // check if letters are correctly mapped
        assertEq(hitmap[0].char, "b");
        assertEq(hitmap[1].char, "i");
        assertEq(hitmap[2].char, "n");
        assertEq(hitmap[3].char, "g");
        assertEq(hitmap[4].char, "o");

        // check if states are initialized correctly
        for (uint256 i = 0; i < hitmap.length; i++) {
            assertEq(hitmap[i].state, 0);
        }

        // non-ascii input
        vm.expectRevert("Non-ASCII strings are not supported.");
        wordle.hideWord(unicode"👋");

        // wrong size
        vm.expectRevert("Word bust be 5 characters long.");
        wordle.hideWord("Banana");
        vm.expectRevert("Word bust be 5 characters long.");
        wordle.hideWord("Bun");
    }
}
