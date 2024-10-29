pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {StringUtils} from "../src/StringUtils.sol";

contract WordleTest is Test {
    using StringUtils for string;

    // test ascii/non-ascii checker
    function test_isASCII() public {
        // non-ascii words
        string memory asciiString = "Hello, world";
        string memory nonAsciiString = unicode"👋👋";
        assertTrue(asciiString.isASCII());
        assertFalse(nonAsciiString.isASCII());
    }

    // test string method to convert string to lower case
    function test_toLowerCase() public {
        string memory fullCaps = "HELLO";
        assertEq(fullCaps.toLowerCase(), "hello");

        string memory someCaps = "HeLLo";
        assertEq(fullCaps.toLowerCase(), "hello");

        string memory upperAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        assertEq(upperAlphabet.toLowerCase(), "abcdefghijklmnopqrstuvwxyz");
    }

    // test string comparator
    function test_compareStrings() public {
        // accept non-ascii for the timebeing
        assertTrue(StringUtils.areEqual(unicode"👋", unicode"👋"));
        assertTrue(StringUtils.areEqual("HELLO", "hello"));
        assertFalse(StringUtils.areEqual("HELLO", "hello!"));
    }

    // test contains function, to check if a string contains a character
    function test_contains() public {
        // breaks if strings are not ascii
        vm.expectRevert("Non-ASCII strings are not supported.");
        StringUtils.contains("HELLO", unicode"👋");

        // existing letter and whitespace
        assertTrue(StringUtils.contains("HELLO", "l"));
        assertTrue(StringUtils.contains("HELlO", "l"));

        // non-existing letter and whitespace
        assertFalse(StringUtils.contains("HELLO", "Z"));
        assertFalse(StringUtils.contains("HELlO", " "));
    }

    // test generate hitmap function
    function test_generateHitmap() public {
        StringUtils.CharState[] memory hitmap = StringUtils.generateHitmap("HI");

        // test length
        assertEq(hitmap.length, 2);

        // test if each char is correctly mapped
        assertEq(hitmap[0].char, "h");
        assertEq(hitmap[0].state, 0);

        assertEq(hitmap[1].char, "i");
        assertEq(hitmap[1].state, 0);
    }
}
