// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {StringUtils} from "../src/StringUtils.sol";
import {StructTypes} from "../src/Interfaces.sol";

contract TestStringMethods is Test {
    using StringUtils for string;

    // test ascii/non-ascii checker
    function test_isASCII() public pure {
        // non-ascii words
        string memory asciiString = "Hello, world";
        string memory nonAsciiString = unicode"👋👋";
        assertTrue(asciiString.isASCII());
        assertFalse(nonAsciiString.isASCII());
    }

    // test string method to convert string to lower case
    function test_toLowerCase() public pure {
        string memory fullCaps = "HELLO";
        assertEq(fullCaps.toLowerCase(), "hello");

        string memory someCaps = "HeLLo";
        assertEq(someCaps.toLowerCase(), "hello");

        string memory upperAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        assertEq(upperAlphabet.toLowerCase(), "abcdefghijklmnopqrstuvwxyz");
    }

    // test string comparator
    function test_compareStrings() public pure {
        // accept non-ascii for the time being
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
    function test_generateHitmap() public pure {
        StructTypes.CharState[] memory hitmap = StringUtils.generateHitmap("HI");

        // test length
        assertEq(hitmap.length, 2);

        // test if each char is correctly mapped
        assertEq(hitmap[0].char, "h");
        assertEq(hitmap[0].state, 0);

        assertEq(hitmap[1].char, "i");
        assertEq(hitmap[1].state, 0);
    }

    // test update hitmap function
    function test_updateHitmap() public {
        StructTypes.CharState[] memory hitmap = StringUtils.generateHitmap("HI");
        StringUtils.updateHitmap(hitmap, 0, 1);
        assertEq(hitmap[0].state, 1);

        StringUtils.updateHitmap(hitmap, 1, 2);
        assertEq(hitmap[1].state, 2);

        // test out maxed state
        vm.expectRevert("Invalid state.");
        StringUtils.updateHitmap(hitmap, 0, 3);

        // test index out of bounds
        vm.expectRevert("Index out of bounds");
        StringUtils.updateHitmap(hitmap, 3, 2);
    }

    // test hitmap completion checker
    function test_isHitmapComplete() public pure {
        StructTypes.CharState[] memory hitmap = StringUtils.generateHitmap("HI");
        assertFalse(StringUtils.isHitmapComplete(hitmap));

        // test for completion
        StringUtils.updateHitmap(hitmap, 0, 2);
        StringUtils.updateHitmap(hitmap, 1, 2);
        assertTrue(StringUtils.isHitmapComplete(hitmap));
    }
}
