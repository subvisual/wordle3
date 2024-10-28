// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Wordle {
    // setup the hidden word here
    string private HIDDEN_WORD = "birdy";

    // string comparator
    function compareWords(string calldata wordA, string calldata wordB) public returns (bool) {
        return keccak256(abi.encodePacked(wordA)) == keccak256(abi.encodePacked(wordB));
    }
}
