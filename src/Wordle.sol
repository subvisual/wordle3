// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Wordle {
    // setup the hidden word here
    string private HIDDEN_WORD = "birdy";

    // certify that string is ASCII
    function isASCII(string memory word) public pure returns (bool) {
        bytes memory wordBytes = bytes(word);

        for (uint256 i = 0; i < wordBytes.length; i++) {
            if (uint8(wordBytes[i]) > 0x7F) {
                return false;
            }
        }
        return true;
    }

    // string comparator
    function compareWords(string calldata target, string calldata guess) public returns (bool) {
        if (!isASCII(target) || !isASCII(guess)) {
            revert("Non-ASCII word detected.");
        }

        if (bytes(target).length != bytes(guess).length) {
            revert("Target and Guess aren ot the same size.");
        }

        // uint memory targetSize = bytes(target).length;
        // bytes memory targetBytes = bytes(target);
        // bytes memory guessBytes = bytes(target);

        // for (uint i; i < targetSize; i++) {

        // }

        return false;
    }
}
