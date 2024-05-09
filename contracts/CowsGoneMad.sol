// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract CowsGoneMad is ERC721Enumerable, Pausable, AccessControl, ReentrancyGuard {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public price = 0.02 ether;
  uint256 public foundersPrice = 0.00 ether;
  uint256 public whitelistPrice = 0.01 ether;
  uint32 public maxMintAmount = 100;
  uint32 public founderNftPerAddressLimit = 5;
  uint32 public maxFounderMintAmount = 200;
  uint32 public currentFounderMint = 0;
  uint32 public nftPerAddressLimit = 100;
  uint256 public maxSupply = 9999;
  uint32 public constant ownerNftLimit = 300;
  uint32 public ownerNftPool;
  bytes32 public merkleRoot;
  bool public revealed;
  bool public lockedSupply = false;
  bool public isWhitelistMintingActive = false;

  bytes32 public constant AUX_ADMIN = keccak256("AUX_ADMIN");
  bytes32 public constant FOUNDER_ROLE = keccak256("FOUNDER");

  mapping(address => uint256) public addressMintedBalance;
  mapping(address => uint256) public foundersMintedBalance;
  mapping(address => bool) public claimedWhitelist;

  event Reveal(bool _status, address _admin);
  event SetMerkleRoot(bytes32 _root, address _admin);
  event SetNftPerAddressLimit(uint32 _limit, address _admin);
  event SetPrice(uint256 _newPrice, address _admin);
  event SetFoundersPrice(uint256 _newPrice, address _admin);
  event SetFoundersNftLimit(uint32 _limit, address _admin);
  event SetMaxMintAmount(uint32 _limit, address _admin);
  event SetBaseURI(string _newBaseURI, address _admin);
  event SetBaseExtension(string _newBaseExtension, address _admin);
  event SetMaxSupply(uint256 _newMaxSupply, address _admin);
  event Pause(bool _status, address _admin);
  event SetWhitelistPrice(uint256 _newPrice, address _admin);
  event LockSupply(bool _status, address _admin);
  event Mint(uint16 _mintAmount, uint256 _price, address _user);
  event Burn(uint256 _tokenId, address _user);
  event ChangedWhitelistMintingStatus(bool _status, address _admin);


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    bool _initPause,
    bytes32 _merkleRoot
  ) ERC721(_name, _symbol)
  {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(AUX_ADMIN, msg.sender);
    _setRoleAdmin(AUX_ADMIN, DEFAULT_ADMIN_ROLE);
    _setRoleAdmin(FOUNDER_ROLE, DEFAULT_ADMIN_ROLE);

    setBaseURI(_initBaseURI);
    pauseStatus(_initPause);
    merkleRoot = _merkleRoot;
  }

  // EXTERNAL
  function mint(uint16 _mintAmount, address to) external payable whenNotPaused()
  {
    require(msg.sender == to || isApprovedForAll(to, msg.sender), "caller is not token owner or approved");
    require(_mintAmount > 0, "You need to mint atleast 1 NFT");
    require(_mintAmount <= maxMintAmount, "Max mint amount per session exceeded");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");
    if (hasRole(FOUNDER_ROLE, to)) {
      require(foundersMintedBalance[to] + _mintAmount <= founderNftPerAddressLimit, "Founder address NFT limit reached");
    } else if (hasRole(DEFAULT_ADMIN_ROLE, to)) {
      require(ownerNftPool + _mintAmount <= ownerNftLimit, "Owner Nft limit has been reached");
    } else {
      require(addressMintedBalance[to] + _mintAmount <= nftPerAddressLimit, "This address has reached its NFT limit");
    }

    uint256 _price;

    if (hasRole(FOUNDER_ROLE, to)) {
      require(currentFounderMint + _mintAmount <= maxFounderMintAmount, "Max founder mint amount exceeded");
      currentFounderMint += _mintAmount;
      _price = foundersPrice;
    } else {
      _price = price;
    }

    if (!hasRole(DEFAULT_ADMIN_ROLE, to)) {
      require(msg.value == _price * _mintAmount, "Insufficient funds");
    }

    for (uint32 i = 1; i <= _mintAmount;) {
      if (hasRole(FOUNDER_ROLE, to)) {
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

  function mintWhitelist(uint16 _mintAmount, bytes32[] calldata merkleProof) external payable whenNotPaused {
    require(isWhitelistMintingActive, "Whitelist minting is not active");
    require(!claimedWhitelist[msg.sender], "Already claimed");
    require(msg.value == whitelistPrice * _mintAmount, "Insufficient funds");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");
    require(verifyMerkle(merkleProof, msg.sender, _mintAmount), 'Invalid proof');

    addressMintedBalance[msg.sender] += _mintAmount;
    claimedWhitelist[msg.sender] = true;

    for (uint32 i = 1; i <= _mintAmount; i++) {
      unchecked {
        _safeMint(msg.sender, supply + i);
      }
    }

    emit Mint(_mintAmount, whitelistPrice, msg.sender);
  }

  function verifyMerkle(
        bytes32[] memory proof,
        address addr,
        uint16 amount
    ) public view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, amount))));

        return MerkleProof.verify(proof, merkleRoot, leaf);
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
  function setMerkleRoot(bytes32 _merkleRoot) external 
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    merkleRoot = _merkleRoot;
    emit SetMerkleRoot(_merkleRoot, msg.sender);
  }

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
    emit SetBaseExtension(_newBaseExtension, msg.sender);
  }

  function setMaxSupply(uint256 _newMaxSupply) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    require(!lockedSupply, "ERC721: cannot set max supply when supply is locked");

    require(
      _newMaxSupply >= totalSupply(),
      "ERC721: new max supply must be greater than current supply"
    );

    require(
      _newMaxSupply <= maxSupply,
      "ERC721: new max supply must be less than current supply"
    );

    maxSupply = _newMaxSupply;
    emit SetMaxSupply(_newMaxSupply, msg.sender);
  }

  function lockSupply() external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    lockedSupply = true;
    emit LockSupply(lockedSupply, msg.sender);
  }

  function setWhitelistMintingStatus(bool _status) external
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    isWhitelistMintingActive = _status;
    emit ChangedWhitelistMintingStatus(isWhitelistMintingActive, msg.sender);
  }

  // This will payout the owner 100% of the contract balance.
  function withdrawAmount(uint256 amount) external payable nonReentrant()
  onlyRole(DEFAULT_ADMIN_ROLE)
  {
    // =============================================================================
    (bool os, ) = payable(msg.sender).call{value: amount}("");
    require(os, "Withdraw failed");
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
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  function pauseStatus(bool _state) public
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    //change this to bool
    if (_state) {
      _pause();
      emit Pause(_state, msg.sender);
    }  else {
      _unpause();
      emit Pause(_state, msg.sender);
    }
  }
  
  function setBaseURI(string memory _newBaseURI) public
  onlyRole(AUX_ADMIN) onlyRole(DEFAULT_ADMIN_ROLE)
  {
    baseURI = _newBaseURI;
    emit SetBaseURI(_newBaseURI, msg.sender);
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
