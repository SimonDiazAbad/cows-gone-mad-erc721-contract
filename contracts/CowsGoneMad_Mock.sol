// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./CowsGoneMad.sol";

contract CowsGoneMad_Mock is CowsGoneMad {

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    bool _initPause,
    bytes32 _merkleRoot

  ) CowsGoneMad(
    _name,
    _symbol,
    _initBaseURI,
    _initPause,
    _merkleRoot
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

  function setMaxFounderMintAmount(uint32 _maxMintAmount) external {
    maxFounderMintAmount = _maxMintAmount;
  }
}