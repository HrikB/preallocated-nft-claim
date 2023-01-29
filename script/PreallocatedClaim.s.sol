// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {PreallocatedClaim} from "../src/PreallocatedClaim.sol";

contract PreallocatedClaimScript is Script {
    PreallocatedClaim public pClaim;

    function setUp() public {
        pClaim = new PreallocatedClaim("Test", "TST", 10, 2 days);
    }

    function run() public {
        pClaim.mint(address(this), 7);
    }
}
