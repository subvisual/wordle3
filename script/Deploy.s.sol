// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import {WDLToken} from "../src/ERC20.sol";
import {Wordle} from "../src/Wordle.sol";

contract WordleFactory is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the token
        WDLToken token = new WDLToken(10000);
        address tokenAddress = address(token);

        // Deploy Wordle
        string memory word = vm.envString("HIDDEN_WORD");
        Wordle wordle = new Wordle(word, tokenAddress);

        // Create a token pool to be issued as rewards / faucet
        token.transfer(address(wordle), 1000 * 10 ** 18);

        vm.stopBroadcast();
    }
}
