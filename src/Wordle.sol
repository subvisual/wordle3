// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {StringUtils} from "./StringUtils.sol";
import {StructTypes} from "./Interfaces.sol";
import {console} from "forge-std/console.sol";

contract Wordle {
    using StringUtils for string;

    // events
    event NoMoreAttempts(string message);
    event CorrectGuess(string guess, string message);
    event RemainingAttempts(uint256 attempts, string message);

    // declare hidden word variable
    string public HIDDEN_WORD;
    StructTypes.CharState[] public HIDDEN_WORD_HITMAP;
    StructTypes.CharState[] public ALPHABET;
    uint256 public ATTEMPTS = 0;

    // setup hidden word
    // todo: implement obfuscation. would keccak256 be a good approach?
    function hideWord(string calldata word) public {
        if (!word.isASCII()) {
            revert("Non-ASCII strings are not supported.");
        }

        if (bytes(word).length != 5) {
            revert("Word must be 5 characters long.");
        }

        // generates the hitmap of the word and returns it
        HIDDEN_WORD = word;
        HIDDEN_WORD_HITMAP = StringUtils.generateHitmap(word);
    }

    // verify if hidden word was setup correctly
    // todo: remove once tests are finishied
    function getHiddenWord() public view returns (StructTypes.CharState[] memory) {
        return HIDDEN_WORD_HITMAP;
    }

    function getAlphabet() public view returns (StructTypes.CharState[] memory) {
        return ALPHABET;
    }

    function getAttempts() public view returns (uint256) {
        return ATTEMPTS;
    }

    // setup alphabet hitmap
    function setupAlphabet() public {
        ALPHABET = StringUtils.generateHitmap("abcdefghijklmnopqrstuvwxyz");
    }

    /*
    Processes the guess, comparing it to the hidden word and assessing 
    and updating the hitmap and alphabet accordingly.
    */
    function tryGuess(string calldata guess) public returns (bool) {
        if (!guess.isASCII()) {
            revert("Non-ASCII strings are not supported.");
        }

        ATTEMPTS++;
        StructTypes.CharState[] memory guessHitmap = StringUtils.generateHitmap(guess);

        // Check if the guess matches the hidden word immediately.
        if (StringUtils.areEqual(guess, HIDDEN_WORD)) {
            return true;
        }

        /*
        Loop through each character of the guess hitmap. For each character,
        update the hitmap and alphabet states based on the hit/miss/exist logic.
        */
        for (uint256 i = 0; i < guessHitmap.length; i++) {
            // Find the index of the letter in the alphabet for state updates.
            uint256 alphaIdx = StringUtils.findIndex(ALPHABET, guessHitmap[i].char);

            /*
            If the character and its index match the hidden word,
            update both hitmap and alphabet states to indicate a correct guess.
            */
            if (StringUtils.areEqual(guessHitmap[i].char, HIDDEN_WORD_HITMAP[i].char)) {
                HIDDEN_WORD_HITMAP[i].state = 2; // Final state for correct position
                ALPHABET[alphaIdx].state = 2; // Final state in alphabet
                continue;
            }

            /*
            If the character does not match, check if it exists in the hidden word.
            Update the states to indicate existence or discard.
            */
            if (HIDDEN_WORD.contains(guessHitmap[i].char)) {
                // [OPTIONAL?] Update hidden word hitmap to indicate the character exists in an incorrect position.
                uint256[] memory occurrences = StringUtils.findAllOccurences(HIDDEN_WORD, guessHitmap[i].char);
                for (uint256 j = 0; j < occurrences.length; j++) {
                    HIDDEN_WORD_HITMAP[occurrences[j]].state = 1; // Intermediate state for existence
                }
                ALPHABET[alphaIdx].state = 1; // Intermediate state in alphabet
            } else {
                // The character does not exist in the hidden word; mark it as discarded.
                ALPHABET[alphaIdx].state = 3; // Discarded state in alphabet
            }
        }

        // Check for the winning condition after processing all characters.
        return StringUtils.isHitmapComplete(HIDDEN_WORD_HITMAP);
    }

    function game(string calldata guess) public returns (bool) {
        if (ATTEMPTS >= 6) {
            emit NoMoreAttempts("No more attempts remaining.");
            return false;
        }

        ATTEMPTS++;
        bool result = tryGuess(guess);

        if (result) {
            emit CorrectGuess(guess, "Well done!");
            return true;
        } else {
            emit RemainingAttempts(6 - ATTEMPTS, "- Atempts left.");
            return false;
        }
    }
}
