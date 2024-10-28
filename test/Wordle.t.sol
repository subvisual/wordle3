pragma solidity ^0.8.28;

import {Test} from "forge-std/test.sol";
import {Wordle} from "../src/Wordle.sol";

contract WordleTest is Test {
    Wordle wordle;

    function setUp() public {
        wordle = new Wordle();
    }

    function test_compareWords() public {
        bool fail = wordle.compareWords("hello", "world");
        bool success = wordle.compareWords("hello", "hello");
        assertEq(fail, false);
        assertEq(success, true);
    }
}
