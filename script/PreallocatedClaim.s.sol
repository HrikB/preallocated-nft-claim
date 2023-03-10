// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {PreallocatedClaim} from "../src/PreallocatedClaim.sol";

contract PreallocatedClaimScript is Script {
    PreallocatedClaim public pClaim;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        pClaim = new PreallocatedClaim("Test", "TST", 10000, 0);
        for (uint256 i = 0; i < 10; i++) {
            pClaim.mintRandom(address(1));
        }

        vm.stopBroadcast();
    }
}
