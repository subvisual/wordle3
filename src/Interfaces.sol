// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface StructTypes {
    /* 
    Struct used to store a character and its state
    to be used as a hit map by the generateHitmap function
    and functions that will manipulate the generated hitmap    
    */
    struct CharState {
        string char;
        uint256 state; // 0 = miss ; 1 = exists ; 2 = hit ; 3 = wrong
    }
}
