// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Wordle} from "../src/Wordle.sol";
import {StructTypes} from "../src/Interfaces.sol";
import {StringUtils} from "../src/StringUtils.sol";

contract WordleTest is Test {
    using StringUtils for string;

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
        vm.expectRevert("Word must be 5 characters long.");
        wordle.hideWord("Banana");
        vm.expectRevert("Word must be 5 characters long.");
        wordle.hideWord("Bun");
    }

    // test alphabet initialization
    function test_alphabet() public {
        wordle.setupAlphabet();
        StructTypes.CharState[] memory alphabet = wordle.getAlphabet();
        assertEq(alphabet[0].char, "a");
        assertEq(alphabet[1].char, "b");
        assertEq(alphabet[2].char, "c");
        assertEq(alphabet[3].char, "d");
        assertEq(alphabet[4].char, "e");
        assertEq(alphabet[5].char, "f");
        assertEq(alphabet[6].char, "g");
        assertEq(alphabet[7].char, "h");
        assertEq(alphabet[8].char, "i");
        assertEq(alphabet[9].char, "j");
        assertEq(alphabet[10].char, "k");
        assertEq(alphabet[11].char, "l");
        assertEq(alphabet[12].char, "m");
        assertEq(alphabet[13].char, "n");
        assertEq(alphabet[14].char, "o");
        assertEq(alphabet[15].char, "p");
        assertEq(alphabet[16].char, "q");
        assertEq(alphabet[17].char, "r");
        assertEq(alphabet[18].char, "s");
        assertEq(alphabet[19].char, "t");
        assertEq(alphabet[20].char, "u");
        assertEq(alphabet[21].char, "v");
        assertEq(alphabet[22].char, "w");
        assertEq(alphabet[23].char, "x");
        assertEq(alphabet[24].char, "y");
        assertEq(alphabet[25].char, "z");
        // check if states are initialized correctly
        for (uint256 i = 0; i < alphabet.length; i++) {
            assertEq(alphabet[i].state, 0);
        }
    }

    // test guess mechanic
    function test_tryGuess() public {
        wordle.setupAlphabet();

        // setup hidden word
        wordle.hideWord("BONGO");

        // test wrong guess
        assertFalse(wordle.tryGuess("olive"));

        // test attempt increment
        uint256 attempts = wordle.getAttempts();
        assertEq(attempts, 1);

        // test hitmap updates
        StructTypes.CharState[] memory hitmap = wordle.getHiddenWord();
        StructTypes.CharState[] memory alphabet = wordle.getAlphabet();
        uint256 oIdx = StringUtils.findIndex(alphabet, "o");
        uint256 vIdx = StringUtils.findIndex(alphabet, "v");
        assertEq(hitmap[0].state, 0);
        assertEq(hitmap[1].state, 1);
        assertEq(hitmap[4].state, 1);
        assertEq(alphabet[oIdx].state, 1);
        assertEq(alphabet[vIdx].state, 3);

        // test correct guess
        assertTrue(wordle.tryGuess("BONGO"));
    }
}
