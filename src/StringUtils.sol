// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {StructTypes} from "./Interfaces.sol";

library StringUtils {
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
    function areEqual(string memory stringA, string memory stringB) internal pure returns (bool) {
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

    // function that checks if a single letter exists in a string
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

    // function that generates the hitmap for the target string and controls
    // correct / wrong state;
    function generateHitmap(string memory target) internal pure returns (StructTypes.CharState[] memory) {
        bytes memory bStr = bytes(toLowerCase(target));
        StructTypes.CharState[] memory res = new StructTypes.CharState[](bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            res[i] = StructTypes.CharState({char: string(abi.encodePacked(bStr[i])), state: 0});
        }
        return res;
    }

    // function that updates the hitmap state for a given index
    function updateHitmap(CharState[] memory hitmap, uint256 index, uint256 state)
        internal
        pure
        returns (CharState[] memory)
    {
        if (index >= hitmap.length) {
            revert("Index out of bounds");
        }
        if (state > 2) {
            revert("Invalid state.");
        }
        if (hitmap[index].state < 2) {
            hitmap[index].state = state;
        }
    }

    // function that checks if the hitmap is complete
    function isHitmapComplete(CharState[] memory hitmap) internal pure returns (bool) {
        for (uint256 i = 0; i < hitmap.length; i++) {
            if (hitmap[i].state == 0) {
                return false;
            }
        }
        return true;
    }

    // function that updates the hitmap state for a given index
    function updateHitmap(StructTypes.CharState[] memory hitmap, uint256 index, uint256 state) internal pure {
        if (index >= hitmap.length) {
            revert("Index out of bounds");
        }
        if (state > 2) {
            revert("Invalid state.");
        }
        if (hitmap[index].state < 2) {
            hitmap[index].state = state;
        }
    }

    // function that checks if the hitmap is complete
    function isHitmapComplete(StructTypes.CharState[] memory hitmap) internal pure returns (bool) {
        for (uint256 i = 0; i < hitmap.length; i++) {
            if (hitmap[i].state == 0) {
                return false;
            }
        }
        return true;
    }
}
