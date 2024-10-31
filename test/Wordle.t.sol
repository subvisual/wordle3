// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Wordle} from "../src/Wordle.sol";
import {WDLToken} from "../src/ERC20.sol";
import {StructTypes} from "../src/Interfaces.sol";
import {StringUtils} from "../src/StringUtils.sol";

contract WordleTest is Test {
    using StringUtils for string;

    Wordle wordle;
    WDLToken token;
    address player1 = address(0x2);
    address player2 = address(0x3);

    function setUp() public {
        token = new WDLToken(1000);
        wordle = new Wordle("BONGO", address(token));
        token.transfer(address(wordle), 500 * 10 ** 18);
        token.transfer(player1, 20 * 10 ** 18);
    }

    // test if player balance checking through can play
    function test_canPlay() public {
        assertTrue(wordle.canPlay(player1));
        assertFalse(wordle.canPlay(player2));
    }

    function test_faucet() public {
        assertEq(token.balanceOf(player2), 0);
        wordle.tokenFaucet(player2);
        assertEq(token.balanceOf(player2), 10 * 10 ** 18);
    }

    // test word hiding
    function test_hideWord() public {
        // correct input
        wordle = new Wordle("BINGO", address(token));

        // test if hitmap is generated correctly
        StructTypes.CharState[] memory hitmap = wordle.getHiddenWord();

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
        wordle = new Wordle(unicode"👋", address(token));

        // wrong size
        vm.expectRevert("Word must be 5 characters long.");
        wordle = new Wordle("Banana", address(token));
        vm.expectRevert("Word must be 5 characters long.");
        wordle = new Wordle("Bun", address(token));
    }

    // test alphabet initialization
    function test_alphabet() public {
        wordle = new Wordle("HELLO", address(token));
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
        wordle = new Wordle("BONGO", address(token));

        // test wrong guess
        assertFalse(wordle.tryGuess("olive"));

        // test attempt spending
        uint256 attempts = wordle.getAttempts();
        assertEq(attempts, 5);

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
