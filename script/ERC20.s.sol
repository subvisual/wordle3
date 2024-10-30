// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import {WDLToken} from "../src/ERC20.sol";

contract ERC20Script is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the token
        WDLToken token = new WDLToken(1000); // Corrected this line

        vm.stopBroadcast();
    }
}
