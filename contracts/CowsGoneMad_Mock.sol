// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./CowsGoneMad.sol";

contract CowsGoneMad_Mock is CowsGoneMad {

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) CowsGoneMad(
    _name,
    _symbol,
    _initBaseURI,
    _initNotRevealedUri
  ) {}

  function isAdmin(address _admin) public view returns (bool) {
    return admin[_admin];
  }

  function getNftPerAddressLimit() public view returns (uint256) {
    return nftPerAddressLimit;
  }

  function getMaxMintAmount() public view returns (uint256) {
    return maxMintAmount;
  }

  function getPauseState() public view returns (bool) {
    return paused;
  }

  function getBaseURI() public view returns (string memory) {
    return baseURI;
  }

  function getBaseExtension() public view returns (string memory) {
    return baseExtension;
  }

}