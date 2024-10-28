pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Wordle} from "../src/Wordle.sol";

contract WordleTest is Test {
    Wordle wordle;

    function setUp() public {
        wordle = new Wordle();
    }

    function test_isASCII() public {
        bool fail = wordle.isASCII(unicode"にっぽん");
        bool success = wordle.isASCII("Hello");
        assertEq(fail, false);
        assertEq(success, true);
    }

    function test_compareWords() public {
        // non-ascii words
        vm.expectRevert("Non-ASCII word detected.");
        wordle.compareWords("hello", unicode"はいい");

        // different sizes
        vm.expectRevert("Target and Guess are not the same size.");
        wordle.compareWords("hello ", "hellooo");
    }
}
