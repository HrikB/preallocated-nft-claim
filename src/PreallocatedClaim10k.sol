// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "solmate/tokens/ERC721.sol";

/**
 * @dev tokenIds must be a set of sequential integers from 0 to MAX_SUPPLY - 1
 */
contract PreallocatedClaim is ERC721 {
    uint256 internal constant MAX_SUPPLY = 10000;
    uint256 internal constant PREALLOCATION_PERIOD = 2 days;

    uint256 private _preallocationEnd; //timestamp
    uint256 private _randomClaimsCount = MAX_SUPPLY;
    uint16[MAX_SUPPLY] private _preallocatedClaims;
    uint16[MAX_SUPPLY] private _randomClaimsLeft;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        _preallocationEnd = block.timestamp + PREALLOCATION_PERIOD;
    }

    function mint(address to, uint16 claimId) external {
        require(
            block.timestamp < _preallocationEnd,
            "Preallocation period has ended"
        );
        // Cases to consider:
        // 1) claimId >= MAX_SUPPLY
        // 2) claimId is already claimed; mint will fail because already minted
        // 3) claimId = tokensLeft (last token in array)
        // 4) claimId = 0
        // 5) claimId < tokensLeft (general case)
        require(
            claimId < MAX_SUPPLY,
            "PreallocatedClaim: claimId is greater than the maximum supply"
        );

        uint256 tokensLeft = --_randomClaimsCount; // Amount of tokens left after this transaction's success
        if (claimId <= tokensLeft)
            _randomClaimsLeft[claimId] = uint16(tokensLeft);
        else
            _randomClaimsLeft[_preallocatedClaims[claimId]] = uint16(
                tokensLeft
            );

        _preallocatedClaims[tokensLeft] = claimId;

        _safeMint(to, claimId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {}
}
