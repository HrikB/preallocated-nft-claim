// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import "forge-std/console.sol";

/**
 * @dev tokenIds must be a set of sequential integers from 0 to MAX_SUPPLY - 1
 */
contract PreallocatedClaim is ERC721 {
    uint256 internal immutable maxSupply;

    uint256 public claimsLeftCount;

    uint16[] internal _claimsLeft;

    uint256 private _preallocationEnd; //timestamp

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _preallocationPeriod
    ) ERC721(_name, _symbol) {
        _preallocationEnd = block.timestamp + _preallocationPeriod;
        maxSupply = _maxSupply;
        claimsLeftCount = _maxSupply;

        _claimsLeft = new uint16[](_maxSupply);
    }

    function mint(address to, uint16 claimId) external {
        require(
            block.timestamp < _preallocationEnd,
            "Preallocation period has ended"
        );

        // Cases to consider:
        // 1) claimId >= maxSupply
        // 2) claimId is already claimed; mint will fail because already minted
        // 3) claimId = tokensLeft (last token in array)
        // 4) claimId = 0
        // 5) claimId < tokensLeft (general case)
        require(
            claimId < maxSupply,
            "PreallocatedClaim: claimId is greater than the maximum supply"
        );

        uint16 tokensLeft = uint16(--claimsLeftCount); // Amount of tokens left after this transaction's success
        uint16 derivedValue = getDerivedValue(tokensLeft);

        if (claimId <= tokensLeft) {
            uint16 claimIdEncode = claimId == 0 ? uint16(maxSupply) : claimId;
            _claimsLeft[claimId] = derivedValue;
            _claimsLeft[derivedValue] = claimIdEncode;
        } else {
            uint16 indexToSwitch = _claimsLeft[claimId];
            uint16 indexToSwitchDecode = indexToSwitch == maxSupply
                ? 0
                : indexToSwitch;
            _claimsLeft[indexToSwitchDecode] = derivedValue;
            _claimsLeft[derivedValue] = indexToSwitch;
        }

        _safeMint(to, claimId);
    }

    function mintRandom(address to) external {
        require(
            block.timestamp >= _preallocationEnd,
            "Preallocation period has not ended"
        );

        uint256 claimId = 0;

        _safeMint(to, claimId);
    }

    function getDerivedValue(uint16 index) public view returns (uint16) {
        uint16 val = _claimsLeft[index];

        if (val == 0) return index;
        if (val == maxSupply) return 0;
        return val;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {}
}
