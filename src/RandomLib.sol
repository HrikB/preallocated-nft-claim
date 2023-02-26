// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library RandomLib {
    function psuedoRandom(uint256 _seed) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, _seed)));
    }
}
