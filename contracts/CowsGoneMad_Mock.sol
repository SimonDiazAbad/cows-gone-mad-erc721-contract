// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./CowsGoneMad.sol";

contract CowsGoneMad_Mock is CowsGoneMad {

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri,
    string memory _initPause
  ) CowsGoneMad(
    _name,
    _symbol,
    _initBaseURI,
    _initNotRevealedUri,
    _initPause
  ) {}

  function getNftPerAddressLimit() public view returns (uint256) {
    return nftPerAddressLimit;
  }

  function getMaxMintAmount() public view returns (uint256) {
    return maxMintAmount;
  }

  function getBaseURI() public view returns (string memory) {
    return baseURI;
  }

  function getBaseExtension() public view returns (string memory) {
    return baseExtension;
  }

  function revealedToFalse() external {
    revealed = false;
  }
}