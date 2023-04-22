// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SBT_UniversityDegreeNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Degree {
        string universityName;
        string courseName;
        string studentName;
        string typeOfDegree;
    }

    mapping (uint256 => Degree) public tokenToDegree;
    mapping (address => bool) private _authorizedMinters;

    constructor() ERC721("SoulboundUniversityDegreeNFT", "SUDNFT") {}

    function setMinterStatus(address minter, bool status) public onlyOwner {
        _authorizedMinters[minter] = status;
    }

    function mintDegreeNFT(
        address recipient,
        string memory degreeTokenURI,
        string memory universityName,
        string memory studentName,
        string memory courseName,
        string memory typeOfDegree
    ) public returns (uint256) {
        require(_authorizedMinters[msg.sender], "SoulboundNFT: caller is not an authorized minter");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, degreeTokenURI);

        tokenToDegree[newItemId] = Degree({
            universityName: universityName,
            courseName: courseName,
            studentName: studentName,
            typeOfDegree: typeOfDegree
        });

        return newItemId;
    }

    function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
) internal virtual override(ERC721) {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);

    // Disallow transfers by reverting if the "from" address is not the zero address
    // Allow burning by checking if the "to" address is the zero address
    if (from != address(0) && to != address(0)) {
        revert("SoulboundNFT: token transfers are disallowed");
    }
}


    function burnDegreeNFT(uint256 tokenId) public {
        // Only allow the owner, those with the contract address, or the contract owner (the university) to burn the diploma
        require(
            _isApprovedOrOwner(msg.sender, tokenId) || msg.sender == address(this) || msg.sender == owner(),
            "SoulboundNFT: caller is not owner nor approved, not the contract address, nor the contract owner"
        );
        _burn(tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
