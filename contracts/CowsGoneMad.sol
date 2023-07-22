// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CowsGoneMad is ERC721Enumerable, Pausable, AccessControl, ReentrancyGuard {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public price = 0.02 ether;
  uint256 public foundersPrice = 0.00 ether;
  uint256 public whitelistPrice = 0.01 ether;
  uint32 public maxMintAmount = 100;
  uint32 public founderNftPerAddressLimit = 5;
  uint32 public nftPerAddressLimit = 100;
  uint256 public constant maxSupply = 9999;
  uint32 public constant ownerNftLimit = 300;
  uint32 public ownerNftPool;
  string public notRevealedUri;
  bool public revealed;

  bytes32 public constant AUX_ADMIN = keccak256("AUX_ADMIN");

  mapping(address => bool) public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;
  mapping(address => bool) public founders;
  mapping(address => uint256) public foundersMintedBalance;

  event Reveal(bool _status, address _admin);
  event SetNftPerAddressLimit(uint32 _limit, address _admin);
  event SetPrice(uint256 _newPrice, address _admin);
  event SetFoundersPrice(uint256 _newPrice, address _admin);
  event SetFoundersNftLimit(uint32 _limit, address _admin);
  event SetMaxMintAmount(uint32 _limit, address _admin);
  event SetBaseURI(string _message, address _admin);
  event SetBaseExtension(string _message, address _admin);
  event SetNotRevealedURI(string _message, address _admin);
  event Pause(string _status, address _admin);
  event AddFounders(address[] _founders, address _admin);
  event RemoveFounders(address[] _founders, address _admin);
  event WhitelistUsers(address[] _users, address _admin);
  event RemoveWhitelistUsers(address[] _users, address _admin);
  event SetWhitelistPrice(uint256 _newPrice, address _admin);
  event Mint(uint16 _mintAmount, uint256 _price, address _user);
  event Burn(uint256 _tokenId, address _user);

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri,
    string memory _initPause
  ) ERC721(_name, _symbol)
  {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(AUX_ADMIN, msg.sender);
    _setRoleAdmin(AUX_ADMIN, DEFAULT_ADMIN_ROLE);
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
    pauseStatus(_initPause);
  }

  // EXTERNAL
  function mint(uint16 _mintAmount, address to) external payable whenNotPaused()
  {
    require(_mintAmount > 0, "You need to mint atleast 1 NFT");
    require(_mintAmount <= maxMintAmount, "Max mint amount per session exceeded");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");
    if (isFounder(to)) {
      require(foundersMintedBalance[to] + _mintAmount <= founderNftPerAddressLimit, "Founder address NFT limit reached");
    } else if (hasRole(DEFAULT_ADMIN_ROLE, to)) {
      require(ownerNftPool + _mintAmount <= ownerNftLimit, "Owner Nft limit has been reached");
    } else {
      require(addressMintedBalance[to] + _mintAmount <= nftPerAddressLimit, "This address has reached its NFT limit");
    }

    uint256 _price;

    if (isFounder(to)) {
      _price = foundersPrice;
    } else if (isWhitelisted(to)) {
      _price = whitelistPrice;
    } else {
      _price = price;
    }

    if (!hasRole(DEFAULT_ADMIN_ROLE, to)) {
      require(msg.value == _price * _mintAmount, "Insufficient funds");
    }

    for (uint32 i = 1; i <= _mintAmount;) {
      if (isFounder(to)) {
        unchecked {
          foundersMintedBalance[to]++;
        }
      } else if (hasRole(DEFAULT_ADMIN_ROLE, to)) {
        unchecked {
          ownerNftPool++;
        }
      } else {
        unchecked {
          addressMintedBalance[to]++;
        }
      }
      unchecked {
        _safeMint(to, supply + i);
        i++;
      }
    }
    emit Mint(_mintAmount, _price, to);
  }

  function burn(uint256 tokenId) external whenNotPaused()
  {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: caller is not token owner or approved"
    );
    _burn(tokenId);
    emit Burn(tokenId, msg.sender);
  }
  
  // Views
  function isRevealed() external view returns (bool)
  {
    return revealed;
  }

  function getPrice() external view returns (uint256)
  {
    return price;
  }

  function getFoundersPrice() external view returns (uint256)
  {
    return foundersPrice;
  }

  function getWhitelistPrice() external view returns (uint256)
  {
    return whitelistPrice;
  }

  function walletOfOwner(address _owner) external view returns (uint256[] memory)
  {
    require(_owner != address(0), "walletOfOwner: Invalid zero address.");
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount;) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
      unchecked {
        i++;
      }
    }
    return tokenIds;
  }

  // Only Admin
  function reveal() external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
      revealed = true;
      emit Reveal(revealed, msg.sender);
  }
  
  function setNftPerAddressLimit(uint32 _limit) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    nftPerAddressLimit = _limit;
    emit SetNftPerAddressLimit(_limit, msg.sender);
  }
  
  function setPrice(uint256 _newPrice) external nonReentrant()
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    price = _newPrice;
    emit SetPrice(_newPrice, msg.sender);
  }

  function setFoundersPrice(uint256 _newPrice) external nonReentrant()
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    foundersPrice = _newPrice;
    emit SetFoundersPrice(_newPrice, msg.sender);
  }

  function setWhitelistPrice(uint256 _price) external nonReentrant()
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    whitelistPrice = _price;
    emit SetWhitelistPrice(_price, msg.sender);
  }

  function setFounderNftLimit(uint32 _nftAmount) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    founderNftPerAddressLimit = _nftAmount;
    emit SetFoundersNftLimit(_nftAmount, msg.sender);
  }

  function setMaxMintAmount(uint32 _newmaxMintAmount) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    maxMintAmount = _newmaxMintAmount;
    emit SetMaxMintAmount(_newmaxMintAmount, msg.sender);
  }

  function setBaseExtension(string memory _newBaseExtension) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    baseExtension = _newBaseExtension;
    emit SetBaseExtension("The base extension has been changed.", msg.sender);
  }

  function addFounders(address[] calldata _users) external nonReentrant()
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    for (uint256 i = 0; i < _users.length;) {
    require(_users[i] != address(0), "addFounders: Invalid zero address.");
      founders[_users[i]] = true;
      unchecked {
        i++;
      }
    }
    emit AddFounders(_users, msg.sender);
  }

  function removeFounders(address[] calldata _users) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    for (uint256 i = 0; i < _users.length;) {
      require(_users[i] != address(0), "removeFounders: Invalid zero address.");
      founders[_users[i]] = false;
      unchecked {
        i++;
      }
    }
    emit RemoveFounders(_users, msg.sender);
  }
  
  function whitelistUsers(address[] calldata _users) external nonReentrant()
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    for (uint256 i = 0; i < _users.length;) {
      require(_users[i] != address(0), "whitelistUsers: Invalid zero address.");
      whitelistedAddresses[_users[i]] = true;
      unchecked {
        i++;
      }
    }
    emit WhitelistUsers(_users, msg.sender);
  }

  function removeWhitelistedUsers(address[] calldata _users) external 
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    for (uint256 i = 0; i < _users.length;) {
      require(_users[i] != address(0), "removeWhitelistedUsers: Invalid zero address.");
      whitelistedAddresses[_users[i]] = false;
      unchecked {
        i++;
      }
    }
    emit RemoveWhitelistUsers(_users, msg.sender);
  }

  // This will payout the owner 100% of the contract balance.
  function withdraw() external payable nonReentrant()
  onlyRole(DEFAULT_ADMIN_ROLE)
  {
    // =============================================================================
    (bool os, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }

  // PUBLIC
  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    require(
      _exists(tokenId), "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(!revealed) {
      return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  function pauseStatus(string memory _state) public
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    if (keccak256(abi.encodePacked(_state)) == keccak256(abi.encodePacked("pause")))
    {
      _pause();
      emit Pause(_state, msg.sender);
    }
    else if (keccak256(abi.encodePacked(_state)) == keccak256(abi.encodePacked("unpause")))
    {
      _unpause();
      emit Pause(_state, msg.sender);
    } 
  }
  
  function setBaseURI(string memory _newBaseURI) public
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    baseURI = _newBaseURI;
    emit SetBaseURI("The Base URI has changed.", msg.sender);
  }

  function setNotRevealedURI(string memory _notRevealedURI) public
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    notRevealedUri = _notRevealedURI;
    emit SetNotRevealedURI("The Not revealed URI has been changed.", msg.sender);
  }

  // Views
  function isWhitelisted(address _user) public view returns (bool)
  {
    require(_user != address(0), "isWhitelisted: Invalid zero address.");
    return whitelistedAddresses[_user];
  }

  function isFounder(address _user) public view returns (bool)
  {
    require(_user != address(0), "isFounder: Invalid zero address.");
    return founders[_user];
  }

  // The following functions are overrides required by Solidity.
  function supportsInterface(bytes4 interfaceId) public view
  override(ERC721Enumerable, AccessControl) returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  // INTERNAL
  function _baseURI() internal view override returns (string memory)
  {
    return baseURI;
  }
}
