// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library StringUtils {
    /* 
    Struct used to store a character and its state
    to be used as a hit map by the generateHitmap function
    and functions that will manipulate the generated hitmap    
    */
    struct CharState {
        string char;
        uint256 state; // 0 = miss ; 1 = exists ; 2 = hit
    }

    // certify that a string is ASCII
    function isASCII(string memory word) public pure returns (bool) {
        bytes memory wordBytes = bytes(word);

        for (uint256 i = 0; i < wordBytes.length; i++) {
            if (uint8(wordBytes[i]) > 0x7F) {
                return false;
            }
        }
        return true;
    }

    // function to convert strings to lower case
    // credit to ottodevs (with minor fixes to types)
    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((bStr[i] >= "A") && (bStr[i] <= "Z")) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    // function that compares two strings
    // this will be used to compare letter by letter
    function areEqual(string memory stringA, string memory stringB) internal pure returns (bool) {
        // if (!isASCII(stringB) || !isASCII(stringB)) {
        // 	revert ("Non-ASCII strings are not supported.");
        // }

        bytes memory bStrA = bytes(toLowerCase(stringA));
        bytes memory bStrB = bytes(toLowerCase(stringB));
        if (bStrA.length != bStrB.length) {
            return false;
        }

        for (uint256 i = 0; i < bStrA.length; i++) {
            if (bStrA[i] != bStrB[i]) {
                return false;
            }
        }
        return true;
    }

    // function that checks if a single letter exist in a string
    function contains(string memory target, string memory letter) internal pure returns (bool) {
        if (!isASCII(target) || !isASCII(letter)) {
            revert("Non-ASCII strings are not supported.");
        }

        bytes memory bStr = bytes(toLowerCase(target));
        bytes memory bLetter = bytes(toLowerCase(letter));
        for (uint256 i = 0; i < bStr.length; i++) {
            if (bStr[i] == bLetter[0]) {
                return true;
            }
        }
        return false;
    }

    function generateHitmap(string memory target) internal pure returns (CharState[] memory) {
        bytes memory bStr = bytes(toLowerCase(target));
        CharState[] memory res = new CharState[](bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            res[i] = CharState({char: string(abi.encodePacked((bStr[i]))), state: 0});
        }
        return res;
    }
}
