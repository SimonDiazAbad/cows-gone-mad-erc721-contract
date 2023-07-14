// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @dev Contract module which provides a multiple access control mechanism, where
 * the owner can grant access to admin accounts.
 *
 * This module is used through inheritance. It will make available the modifier
 * `adminAdmin`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Admin is Ownable {

  mapping(address => bool) public admin;

  modifier onlyAdmin() {
    require(admin[msg.sender] || owner() == msg.sender);
    _;
  }

  function addAdmin(address _toAdd) onlyAdmin public {
    require(_toAdd != address(0));
    admin[_toAdd] = true;
  }

  function removeAdmin(address _toRemove) onlyAdmin public {
    require(_toRemove != address(0));
    require(_toRemove != msg.sender);
    admin[_toRemove] = false;
  }

}

pragma solidity >=0.8.0 <0.9.0;

contract CowsGoneMad is ERC721Enumerable, Ownable, Admin {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public price = 0.02 ether;
  uint256 public foundersPrice = 0.00 ether;
  uint256 public whitelistPrice = 0.01 ether;
  uint256 public maxSupply = 9999;
  uint256 public maxMintAmount = 100;
  uint256 public nftPerAddressLimit = 100;
  uint256 public founderNftPerAddressLimit = 5;
  bool public paused = true;
  bool public revealed = false;
  mapping(address => bool) public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;
  mapping(address => bool) public founders;
  mapping(address => uint256) public foundersMintedBalance;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  //=================
  // MINT
  //=================
  function mint(uint256 _mintAmount, address to) public payable {
    require(!paused, "The contract is paused");
    require(_mintAmount > 0, "You need to mint atleast 1 NFT");
    require(_mintAmount <= maxMintAmount, "Max mint amount per session exceeded");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");
    if (isFounder(to)) {
      require(foundersMintedBalance[to] + _mintAmount <= founderNftPerAddressLimit, "Founder address NFT limit reached");
    } else if (to != owner()) {
      require(addressMintedBalance[to] + _mintAmount <= nftPerAddressLimit, "This address has reached its NFT limit");
    }
    uint _price;

    if (isFounder(to)) {
      _price = foundersPrice;
    } else if (isWhitelisted(to)) {
      _price = whitelistPrice;
    } else {
      _price = price;
    }

    if (to != owner()) {
      require(msg.value >= _price * _mintAmount, "Insufficient funds");
    }

    for (uint256 i = 1; i <= _mintAmount;) {
      if (isFounder(to)) {
        unchecked {
          _safeMint(to, supply + i);
          foundersMintedBalance[to]++;
          i++;
        }
      } else {
        unchecked {
          _safeMint(to, supply + i);
          addressMintedBalance[to]++;
          i++;
        }
      }
    }
  }

  function burn(uint256 tokenId) public virtual {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: caller is not token owner or approved"
    );
    _burn(tokenId);
  }
  
  // VIEW FUNCTIONS
  function isWhitelisted(address _user) public view returns (bool) {
    return whitelistedAddresses[_user];
  }

  function isFounder(address _user) public view returns (bool) {
    return founders[_user];
  }

  function isRevealed() public view returns (bool) {
    return revealed;
  }

  function getPrice() public view returns (uint256) {
    return price;
  }

  function getFoundersPrice() public view returns (uint256) {
    return foundersPrice;
  }

  function getWhitelistPrice() public view returns (uint256) {
    return whitelistPrice;
  }

  function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
      unchecked {
        i++;
      }
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId), "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyAdmin {
      revealed = true;
  }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyAdmin {
    nftPerAddressLimit = _limit;
  }
  
  function setPrice(uint256 _newPrice) public onlyAdmin {
    price = _newPrice;
  }

  function setFoundersPrice(uint256 _newPrice) public onlyAdmin {
    foundersPrice = _newPrice;
  }

  function setFounderNftLimit(uint256 _nftAmount) public onlyAdmin {
    founderNftPerAddressLimit = _nftAmount;
  }

  function setMaxMintAmount(uint256 _newmaxMintAmount) public onlyAdmin {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyAdmin {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyAdmin {
    baseExtension = _newBaseExtension;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyAdmin {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyAdmin {
    paused = _state;
  }

  function addFounders(address[] calldata _users) public onlyAdmin {
    for (uint256 i = 0; i < _users.length; ) {
      founders[_users[i]] = true;
      unchecked {
        i++;
      }
    }
  }

  function removeFounders(address[] calldata _users) public onlyAdmin {
    for (uint256 i = 0; i < _users.length; ) {
      founders[_users[i]] = false;
      unchecked {
        i++;
      }
    }
  }
  
  function whitelistUsers(address[] calldata _users) public onlyAdmin {
    for (uint256 i = 0; i < _users.length; ) {
      whitelistedAddresses[_users[i]] = true;
      unchecked {
        i++;
      }
    }
  }

  function removeWhitelistedUsers(address[] calldata _users) public onlyAdmin {
    for (uint256 i = 0; i < _users.length; ) {
      whitelistedAddresses[_users[i]] = false;
      unchecked {
        i++;
      }
    }
  }

  function setWhitelistPrice(uint256 _price) public onlyAdmin {
    whitelistPrice = _price;
  }
 
  function withdraw() public payable onlyOwner {
    // This will payout the owner 95% of the contract balance.
    // Do Not Remove
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}
