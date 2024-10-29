// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {StringUtils} from "./StringUtils.sol";
import {StructTypes} from "./Interfaces.sol";

contract Wordle {
    using StringUtils for string;

    // declare hidden word variable
    StructTypes.CharState[] private HIDDEN_WORD;
    StructTypes.CharState[] private ALPHABET;

    // setup hidden word
    // todo: implement obfuscation. would keccak256 be a good approach?
    function hideWord(string calldata word) public {
        if (!word.isASCII()) {
            revert("Non-ASCII strings are not supported.");
        }

        if (bytes(word).length != 5) {
            revert("Word bust be 5 characters long.");
        }

        // generates the hitmap of the word and returns it
        HIDDEN_WORD = StringUtils.generateHitmap(word);
    }

    // verify if hidden word was setup correctly
    // todo: remove once tests are finishied
    function getHiddenWord() public view returns (StructTypes.CharState[] memory) {
        return HIDDEN_WORD;
    }

    function getAlhabet() public view returns (StructTypes.CharState[] memory) {
        return ALPHABET;
    }

    // setup alphabet hitmap
    function setupAlphabet() public {
        ALPHABET = StringUtils.generateHitmap("abcdefghijklmnopqrstuvwxyz");
    }
}
