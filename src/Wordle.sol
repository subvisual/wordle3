// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {StringUtils} from "./StringUtils.sol";
import {StructTypes} from "./Interfaces.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wordle {
    // libraries
    using StringUtils for string;

    // ERC20 token interface
    IERC20 public token;

    // events
    event NoMoreAttempts(string message);
    event CorrectGuess(string guess, string message);
    event RemainingAttempts(uint256 attemptsLeft, string message);

    // player-related mappings
    mapping(address => bool) public usedFaucet;
    mapping(address => uint256) public lastAttemptTime;
    mapping(address => StructTypes.CharState[]) public HIDDEN_WORD_HITMAP;
    mapping(address => StructTypes.CharState[]) public ALPHABET;
    mapping(address => uint256) public ATTEMPTS;

    // declare hidden word variable
    string public HIDDEN_WORD;

    // declare the owner
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor(string memory word, address tokenAddress) {
        if (!word.isASCII()) {
            revert("Non-ASCII strings are not supported.");
        }

        if (bytes(word).length != 5) {
            revert("Word must be 5 characters long.");
        }
        token = IERC20(tokenAddress);
        owner = msg.sender;
        HIDDEN_WORD = word;
    }

    // method to hide a new word if needed
    function changeWord(string memory word) public onlyOwner {
        HIDDEN_WORD = word;
    }

    function initAttempts(address player) public {
        require(canPlay(player), "You don't have enough tokens to play.");

        // Calculate the start of today
        uint256 todayStart = block.timestamp - (block.timestamp % 1 days);

        // Ensure the player hasn't played today
        require(lastAttemptTime[player] <= todayStart, "You can only play once per day.");

        // Update last attempt time to current time
        lastAttemptTime[player] = block.timestamp;

        // Initialize player data
        ATTEMPTS[player] = 6; // Setting the initial number of attempts
        HIDDEN_WORD_HITMAP[player] = StringUtils.generateHitmap(HIDDEN_WORD);
        ALPHABET[player] = StringUtils.generateHitmap("abcdefghijklmnopqrstuvwxyz");
    }

    function canPlay(address player) public view returns (bool) {
        uint256 playCost = 1 * (10 ** 18);
        uint256 balance = token.balanceOf(player);
        return balance >= playCost;
    }

    function tokenFaucet(address player) public {
        require(!usedFaucet[player], "You have already used the faucet.");
        usedFaucet[player] = true;
        token.transfer(player, 10 * 10 ** 18);
    }

    // get methods
    // verify if hidden word was setup correctly
    function getHiddenWord(address player) public view returns (StructTypes.CharState[] memory) {
        return HIDDEN_WORD_HITMAP[player];
    }

    function getAlphabet(address player) public view returns (StructTypes.CharState[] memory) {
        return ALPHABET[player];
    }

    function getPlayerAttempts(address player) public view returns (uint256) {
        return ATTEMPTS[player];
    }

    /*
    Processes the guess, comparing it to the hidden word and assessing
    and updating the hitmap and alphabet accordingly.
    */
    function tryGuess(string calldata guess, address player) public returns (bool) {
        if (!guess.isASCII()) {
            revert("Non-ASCII strings are not supported.");
        }

        if (bytes(guess).length != 5) {
            revert("Word must be 5 characters long.");
        }

        if (ATTEMPTS[player] == 0) {
            emit NoMoreAttempts("You have no more attempts left.");
            return false;
        }

        if (StringUtils.areEqual(guess, HIDDEN_WORD)) {
            emit CorrectGuess(guess, "Well done!");
            return true;
        }

        emit RemainingAttempts(ATTEMPTS[player], "Attempts left.");
        ATTEMPTS[player]--;

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
            uint256 alphaIdx = StringUtils.findIndex(ALPHABET[player], guessHitmap[i].char);

            /*
            If the character and its index match the hidden word,
            update both hitmap and alphabet states to indicate a correct guess.
            */
            if (StringUtils.areEqual(guessHitmap[i].char, HIDDEN_WORD_HITMAP[player][i].char)) {
                HIDDEN_WORD_HITMAP[player][i].state = 2; // Final state for correct position
                ALPHABET[player][alphaIdx].state = 2; // Final state in alphabet
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
                    HIDDEN_WORD_HITMAP[player][occurrences[j]].state = 1; // Intermediate state for existence
                }
                ALPHABET[player][alphaIdx].state = 1; // Intermediate state in alphabet
            } else {
                // The character does not exist in the hidden word; mark it as discarded.
                ALPHABET[player][alphaIdx].state = 3; // Discarded state in alphabet
            }
        }

        // Check for the winning condition after processing all characters.
        // emits a message if the player wins
        if (!StringUtils.isHitmapComplete(HIDDEN_WORD_HITMAP[player])) {
            emit RemainingAttempts(ATTEMPTS[player], "Attempts left.");
            return false;
        }

        emit CorrectGuess(guess, "Well done!");
        return true;
    }
}
