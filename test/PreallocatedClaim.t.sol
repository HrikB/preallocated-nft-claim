// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PreallocatedClaim.sol";

contract PreallocatedClaimExposed is PreallocatedClaim {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _preallocationPeriod
    ) PreallocatedClaim(_name, _symbol, _maxSupply, _preallocationPeriod) {}

    function preallocatedClaims(uint256 index) public view returns (uint16) {
        return _preallocatedClaims[index];
    }

    function randomClaimsLeft(uint256 index) public view returns (uint16) {
        return _randomClaimsLeft[index];
    }
}

contract PreallocatedClaimTest is Test {
    PreallocatedClaim public preallocatedClaim;
    uint256 private removedId1;
    uint256 private removedId2;
    uint256 private removedId3;
    uint256 private removedId4;
    uint256 private removedId5;

    function setUp() public {
        preallocatedClaim = new PreallocatedClaim("Test", "TST", 10, 2 days);
    }

    /* INVARIANTS */
}
