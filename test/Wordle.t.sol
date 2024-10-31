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

        // can't use more than once
        vm.expectRevert();
        wordle.tokenFaucet(player2);
    }

    function test_initAttempts() public {
        vm.warp(60 minutes);
        wordle.initAttempts(player1);

        // tests if attempts were correctly initialized
        uint256 attempts = wordle.getPlayerAttempts(player1);
        assertEq(attempts, 6);

        // throws error if player tries to play twice
        vm.expectRevert();
        wordle.initAttempts(player1);

        // fails if player tries to play without enough tokens
        vm.expectRevert();
        wordle.initAttempts(player2);
        // but works after using the faucet
        wordle.tokenFaucet(player2);
        wordle.initAttempts(player2);
    }

    function test_initPlayerHitmap() public {
        vm.warp(60 minutes);
        wordle.initAttempts(player1);

        // tests if hitmap was correctly initialized
        StructTypes.CharState[] memory hitmap = wordle.getHiddenWord(player1);
        assertEq(hitmap[0].state, 0);
        assertEq(hitmap[1].state, 0);
        assertEq(hitmap[2].state, 0);
        assertEq(hitmap[3].state, 0);
        assertEq(hitmap[4].state, 0);
    }

    function test_initPlayerAlphabet() public {
        vm.warp(60 minutes);
        wordle.initAttempts(player1);

        // tests if alphabet hitmap was correctly initialized
        StructTypes.CharState[] memory hitmap = wordle.getAlphabet(player1);
        assertEq(hitmap[0].state, 0);
        assertEq(hitmap[13].state, 0);
        assertEq(hitmap[25].state, 0);
    }

    // test word hiding
    function test_hideWord() public {
        // correct input
        wordle = new Wordle("BINGO", address(token));
        // non-ascii input
        vm.expectRevert("Non-ASCII strings are not supported.");
        wordle = new Wordle(unicode"👋", address(token));

        // wrong size
        vm.expectRevert("Word must be 5 characters long.");
        wordle = new Wordle("Banana", address(token));
        vm.expectRevert("Word must be 5 characters long.");
        wordle = new Wordle("Bun", address(token));
    }

    // test guess mechanic
    function test_tryGuess() public {
        vm.warp(60 minutes);
        wordle.initAttempts(player1);

        // test wrong guess
        assertFalse(wordle.tryGuess("olive", player1));

        // test attempt spending
        uint256 attempts = wordle.getPlayerAttempts(player1);
        assertEq(attempts, 5);

        // test hitmap updates
        StructTypes.CharState[] memory hitmap = wordle.getHiddenWord(player1);
        StructTypes.CharState[] memory alphabet = wordle.getAlphabet(player1);
        uint256 oIdx = StringUtils.findIndex(alphabet, "o");
        uint256 vIdx = StringUtils.findIndex(alphabet, "v");
        assertEq(hitmap[0].state, 0);
        assertEq(hitmap[1].state, 1);
        assertEq(hitmap[4].state, 1);
        assertEq(alphabet[oIdx].state, 1);
        assertEq(alphabet[vIdx].state, 3);

        // test correct guess
        assertTrue(wordle.tryGuess("BONGO", player1));
    }
}
