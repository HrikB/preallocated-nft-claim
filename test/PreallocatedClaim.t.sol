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

    function claimsLeft(uint256 index) public view returns (uint16) {
        return _claimsLeft[index];
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _ownerOf[tokenId] != address(0);
    }
}

contract PreallocatedClaimTest is Test {
    PreallocatedClaimExposed public preallocatedClaim;
    uint256 private constant totalSupply = 20;

    address user = vm.addr(1);

    function setUp() public {
        preallocatedClaim = new PreallocatedClaimExposed(
            "Test",
            "TST",
            totalSupply,
            2 days
        );
    }

    function testZeroIndexMint() external {
        uint256[] memory expectedArr = new uint256[](totalSupply);
        for (uint256 i = 0; i < expectedArr.length; i++) {
            expectedArr[i] = i;
        }

        uint16 tokenIdToMint = 0;

        vm.expectRevert(bytes("NOT_MINTED"));
        preallocatedClaim.ownerOf(tokenIdToMint);
        checkClaimsArrayState(expectedArr);

        preallocatedClaim.mint(user, tokenIdToMint);

        expectedArr[tokenIdToMint] = totalSupply - 1;
        expectedArr[totalSupply - 1] = tokenIdToMint;

        assertEq(preallocatedClaim.ownerOf(tokenIdToMint), user);
        checkClaimsArrayState(expectedArr);
    }

    function testMiddleIndexMint() external {
        uint256[] memory expectedArr = new uint256[](totalSupply);
        for (uint256 i = 0; i < expectedArr.length; i++) {
            expectedArr[i] = i;
        }

        uint16 tokenIdToMint = 5;

        vm.expectRevert(bytes("NOT_MINTED"));
        preallocatedClaim.ownerOf(tokenIdToMint);
        checkClaimsArrayState(expectedArr);

        preallocatedClaim.mint(user, tokenIdToMint);

        expectedArr[tokenIdToMint] = totalSupply - 1;
        expectedArr[totalSupply - 1] = tokenIdToMint;

        assertEq(preallocatedClaim.ownerOf(tokenIdToMint), user);
        checkClaimsArrayState(expectedArr);
    }

    function testFinalIndexMint() external {
        uint256[] memory expectedArr = new uint256[](totalSupply);
        for (uint256 i = 0; i < expectedArr.length; i++) {
            expectedArr[i] = i;
        }

        uint16 tokenIdToMint = uint16(totalSupply) - 1;

        vm.expectRevert(bytes("NOT_MINTED"));
        preallocatedClaim.ownerOf(tokenIdToMint);
        checkClaimsArrayState(expectedArr);

        preallocatedClaim.mint(user, tokenIdToMint);

        expectedArr[tokenIdToMint] = totalSupply - 1;
        expectedArr[totalSupply - 1] = tokenIdToMint;

        assertEq(preallocatedClaim.ownerOf(tokenIdToMint), user);
        checkClaimsArrayState(expectedArr);
    }

    function testMintAll() external {
        uint256[] memory expectedArr = new uint256[](totalSupply);
        for (uint256 i = 0; i < expectedArr.length; i++) {
            expectedArr[i] = i;
        }
        checkClaimsArrayState(expectedArr);
        checkRemainingTokensPresent();
        checkValidMappings();

        for (uint16 i = 0; i < totalSupply; i++) {
            uint16 tokenIdToMint = i;
            uint16 tokensLeft = uint16(preallocatedClaim.claimsLeftCount() - 1);

            vm.expectRevert(bytes("NOT_MINTED"));
            preallocatedClaim.ownerOf(tokenIdToMint);

            uint16 derivedValue = uint16(
                preallocatedClaim.getDerivedValue(tokensLeft)
            );

            preallocatedClaim.mint(user, tokenIdToMint);

            if (tokenIdToMint <= tokensLeft) {
                expectedArr[tokenIdToMint] = derivedValue;
                expectedArr[derivedValue] = tokenIdToMint;
            } else {
                uint16 indexToSwitch = uint16(expectedArr[tokenIdToMint]);
                expectedArr[indexToSwitch] = derivedValue;
                expectedArr[derivedValue] = indexToSwitch;
            }

            assertEq(preallocatedClaim.ownerOf(tokenIdToMint), user);
            checkClaimsArrayState(expectedArr);
            checkRemainingTokensPresent();
            checkValidMappings();
        }
    }

    function testMintAllReverse() external {
        uint256[] memory expectedArr = new uint256[](totalSupply);
        for (uint256 i = 0; i < expectedArr.length; i++) {
            expectedArr[i] = i;
        }
        checkClaimsArrayState(expectedArr);
        checkRemainingTokensPresent();
        checkValidMappings();

        // i-- underflows
        for (int16 i = (int16(uint16(totalSupply)) - 1); i >= 0; i--) {
            uint16 tokenIdToMint = uint16(i);
            uint16 tokensLeft = uint16(preallocatedClaim.claimsLeftCount() - 1);

            vm.expectRevert(bytes("NOT_MINTED"));
            preallocatedClaim.ownerOf(tokenIdToMint);

            uint16 derivedValue = uint16(
                preallocatedClaim.getDerivedValue(tokensLeft)
            );

            preallocatedClaim.mint(user, tokenIdToMint);

            if (tokenIdToMint <= tokensLeft) {
                expectedArr[tokenIdToMint] = derivedValue;
                expectedArr[derivedValue] = tokenIdToMint;
            } else {
                uint16 indexToSwitch = uint16(expectedArr[tokenIdToMint]);
                expectedArr[indexToSwitch] = derivedValue;
                expectedArr[derivedValue] = indexToSwitch;
            }

            assertEq(preallocatedClaim.ownerOf(tokenIdToMint), user);
            checkClaimsArrayState(expectedArr);
            checkRemainingTokensPresent();
            checkValidMappings();
        }
    }

    function testMintAllFuzz(uint16[totalSupply] memory arr) external {
        uint256[] memory expectedArr = new uint256[](totalSupply);
        for (uint256 i = 0; i < expectedArr.length; i++) {
            expectedArr[i] = i;
        }
        checkClaimsArrayState(expectedArr);
        checkRemainingTokensPresent();
        checkValidMappings();

        uint16[] memory allTokenIds = new uint16[](totalSupply);
        for (uint16 i = 0; i < allTokenIds.length; i++) {
            allTokenIds[i] = i;
        }

        for (uint16 i = 0; i < allTokenIds.length; i++) {
            uint16 tokensLeft = uint16(preallocatedClaim.claimsLeftCount());
            uint16 indexToMint = arr[i] % uint16(tokensLeft);
            uint16 tokenIdToMint = allTokenIds[indexToMint];

            --tokensLeft;
            allTokenIds[indexToMint] = allTokenIds[tokensLeft];

            vm.expectRevert(bytes("NOT_MINTED"));
            preallocatedClaim.ownerOf(tokenIdToMint);

            uint16 derivedValue = uint16(
                preallocatedClaim.getDerivedValue(tokensLeft)
            );

            preallocatedClaim.mint(user, tokenIdToMint);

            if (tokenIdToMint <= tokensLeft) {
                expectedArr[tokenIdToMint] = derivedValue;
                expectedArr[derivedValue] = tokenIdToMint;
            } else {
                uint16 indexToSwitch = uint16(expectedArr[tokenIdToMint]);
                expectedArr[indexToSwitch] = derivedValue;
                expectedArr[derivedValue] = indexToSwitch;
            }

            assertEq(preallocatedClaim.ownerOf(tokenIdToMint), user);
            checkClaimsArrayState(expectedArr);
            checkRemainingTokensPresent();
            checkValidMappings();
        }
    }

    /* INVARIANTS */
    function checkClaimsArrayState(uint256[] memory expectedState) private {
        uint256 claimsLeft = preallocatedClaim.claimsLeftCount();

        for (uint16 i = 0; i < expectedState.length; i++) {
            if (claimsLeft == 0 && i == 0) console.log("---------");
            console.log(
                expectedState[i],
                preallocatedClaim.getDerivedValue(i),
                preallocatedClaim.claimsLeft(i)
            );
            if (i + 1 == claimsLeft) console.log("---------");
            assertEq(expectedState[i], preallocatedClaim.getDerivedValue(i));
        }
        console.log();
    }

    function checkRemainingTokensPresent() private {
        uint256 claimsLeft = preallocatedClaim.claimsLeftCount();
        uint256[totalSupply] memory presenceTracker;

        // Mark all tokens that have been minted as 1
        for (uint16 i = 0; i < totalSupply; i++)
            if (preallocatedClaim.exists(i)) presenceTracker[i] = 1;

        // If token is unminted, check for its presence in the remaining set
        for (uint16 i = 0; i < presenceTracker.length; i++) {
            if (presenceTracker[i] == 0) {
                bool found = false;
                for (uint16 j = 0; j < claimsLeft; j++) {
                    // console.log(preallocatedClaim.getDerivedValue(j), i);
                    if (preallocatedClaim.getDerivedValue(j) == i) {
                        found = true;
                        break;
                    }
                }
                assertTrue(found, "Missing unminted token in remaining set");
            }
        }
        // console.log();
    }

    /**
     * 8 8
     * 1 0
     * 2 0
     * 3 0
     * 9 9
     * 5 0
     * 6 0
     * 7 0
     *-------
     * 0 10
     * 4 4
     *
     * Let the right side be the actual state on-chain of `claimsLeft` and
     * the left side be the derived state we interpret from the array. Numbers
     * above the line are `tokenIds` still remaining the be distributed. The
     * derivation comes from taking the value in `claimsLeft` if it isn't
     * zero, otherwise, taking the index as the value. We must ensure that if
     * the value at an index `i` is not zero, then
     * `claimsLeft[claimsLeft[i]] = i`. The maintenance of this
     * invariant is integral to functioning of the distribution algorithm.
     */
    function checkValidMappings() private {
        uint256 claimsLeft = preallocatedClaim.claimsLeftCount();
        for (uint16 i = 0; i < claimsLeft; i++) {
            uint16 val = preallocatedClaim.claimsLeft(i);
            if (val == 0) continue;
            uint16 iEncode = i == 0 ? uint16(totalSupply) : i;
            assertEq(preallocatedClaim.claimsLeft(val), iEncode);
            assertEq(preallocatedClaim.getDerivedValue(val), i);
        }
    }
}
