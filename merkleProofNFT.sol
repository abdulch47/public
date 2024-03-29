// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.5.0/utils/cryptography/MerkleProof.sol";

contract MyToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    bytes32 public root;

    Counters.Counter private _tokenIdCounter;

    constructor(bytes32 _root) ERC721("MyToken", "MTK") {
        root = _root;
    }

    function safeMint(address to, bytes32[] memory proof) public {
        require(isValid(proof, keccak256(abi.encodePacked(msg.sender))), "Not a part of Allowlist");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function isValid(bytes32[] memory proof, bytes32 leaf) public view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}
