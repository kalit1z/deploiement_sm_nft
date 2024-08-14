// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @author Sergei Pushkin

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721A, Ownable {

    using Strings for uint;

    // The total number of NFTs
    uint private constant MAX_SUPPLY = 499;

    // The price of one NFT
    uint private constant PRICE = 50 ether;

    // When the presale (dutch auction) starts
    uint public saleStartTime = 1721280804;

    // base URI of the NFTs
    string public baseURI;

    // Amount NFTs/Wallet
    uint private constant MAX_NFTS_PER_ADDRESS = 3;
    mapping(address => uint) public amountNFTsPerWallet;

    constructor() ERC721A("Nom", "symbole") {
        // Mint 50 NFTs directly to the contract owner's wallet
        _safeMint(msg.sender, 50);
        amountNFTsPerWallet[msg.sender] = 50;
    }

    /**
    * @notice Mint function
    *
    * @param _quantity Amount of NFTs the user wants to mint
    **/
    function mint(uint _quantity) external payable {
        require(currentTime() >= saleStartTime, "Sale has not started yet");
        require(totalSupply() + _quantity <= MAX_SUPPLY, "Max supply exceeded");
        require(msg.value >= PRICE * _quantity, "Not enough funds");
        require(amountNFTsPerWallet[msg.sender] + _quantity <= MAX_NFTS_PER_ADDRESS, "Only 3 NFTs per Wallet");
        amountNFTsPerWallet[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    /**
    * @notice Get the current timestamp
    *
    * @return the current timestamp
    **/
    function currentTime() internal view returns(uint) {
        return block.timestamp;
    }

    /**
    * @notice Get the token URI of an NFT by its ID
    *
    * @param _tokenId The ID of the NFT you want to have the URI
    **/
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

    /**
    * @notice Change the base URI of the NFTs
    *
    * @param _baseURI The new base URI of the NFTs
    **/
    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    /**
    * @notice Change the saleStartTime
    *
    * @param _saleStartTime The new saleStartTime
    **/
    function setSaleStartTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }

    /**
    * @notice Get paid :D !
    **/
    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    /**
    * @notice Get all token IDs owned by a specific address
    *
    * @param _owner The address to query
    * @return An array with the token IDs owned by the address
    **/
    function walletOfOwner(address _owner) external view returns (uint[] memory) {
        uint ownerTokenCount = balanceOf(_owner);
        uint[] memory ownedTokenIds = new uint[](ownerTokenCount);
        uint currentIndex = 0;

        for (uint i = 0; i < totalSupply(); i++) {
            if (ownerOf(i) == _owner) {
                ownedTokenIds[currentIndex] = i;
                currentIndex++;
            }
        }
        return ownedTokenIds;
    }
}
