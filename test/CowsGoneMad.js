const {
  expectEvent,
  expectRevert,
} = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');
const { createWhitelist } = require('../scripts/merkle-create');
const { findMerkleProof } = require('../scripts/merkle-proof');
const fs = require('fs');

const CowsGoneMad = artifacts.require('CowsGoneMad_Mock');

contract('CowsGoneMad_Mock', async (accounts) => {
  let cowsgonemad;

  beforeEach(async () => {
    cowsgonemad = await CowsGoneMad.deployed();
  });

  after(async () => {
    // we delete the test tree file if it exists
    if (fs.existsSync('test_tree.json')) {
      fs.unlinkSync('test_tree.json');
    }
  })

  // ==========================
  // TokenURI
  // ==========================
  describe('function tokenURI', () => {
    it('should let us know the token does not exist', async () => {
      await expectRevert(cowsgonemad.tokenURI.call(10000), 'ERC721Metadata: URI query for nonexistent token');
    });
  
    it('returns the expected URI for a revealed token with a base URI', async function() {
      const tokenId = 1;
      const baseURI = 'https://CGM-baseURI.com/';
      const baseExtension = '.json';
    
      await cowsgonemad.pauseStatus("unpause");
      
      await cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      });
      await cowsgonemad.reveal();
    
      const result = await cowsgonemad.tokenURI.call(tokenId);
      assert.equal(result, baseURI + tokenId.toString() + baseExtension);
    });

    it('returns an empty string for a revealed token with no base URI', async function() {
      const tokenId = 1;
    
      await cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      });
      await cowsgonemad.reveal();
      await cowsgonemad.setBaseURI('');
    
      const result = await cowsgonemad.tokenURI(tokenId);
    
      assert.equal(result, '');
    });
  })

  // ==========================
  // IsRevealed & Reveal
  // ==========================
  describe('function isRevealed & reveal', () => {
    it('should show as false', async () => {
      await cowsgonemad.revealedToFalse();
      assert.equal(await cowsgonemad.isRevealed.call(), false);
    });
  
    it('should show as true', async () => {
      await cowsgonemad.reveal();
      assert.equal(await cowsgonemad.isRevealed.call(), true);
    });
  });

  // =========================
  // Mint
  // =========================
  describe('function mint', () => {
    it('should let us know the contract is paused', async () => {
      await cowsgonemad.pauseStatus("pause");
      await expectRevert(cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      }),
      'VM Exception while processing transaction: revert Pausable: paused -- Reason given: Pausable: paused.');
    });
  
    it('reverts when trying to mint 0 NFTs', async () => {
      await cowsgonemad.pauseStatus("unpause")
      await expectRevert(cowsgonemad.mint(0, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      }), 'You need to mint atleast 1 NFT');
    });
  
    it('reverts when trying to mint more than maxMintAmount NFTs', async () => {
      const maxMintAmount = 100;
      await expectRevert(cowsgonemad.mint(maxMintAmount + 1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      }), 'Max mint amount per session exceeded');
    });

    it('should let us know that there are insufficient funds', async () => {
      await expectRevert(cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.00", "ether")
      }), 'Insufficient funds');
    });

    it('should revert when msg.sender is not "to" address or approvedForAll', async () => {
      await expectRevert(cowsgonemad.mint(1, accounts[1], {
        from: accounts[2],
        value: web3.utils.toWei("0.02", "ether")
      }), "caller is not token owner or approved")
    })

    it('should mint when msg.sender is approvedForAll', async () => {
      await cowsgonemad.setApprovalForAll(accounts[3], true, {
        from: accounts[2]
      });

      await cowsgonemad.mint(1, accounts[2], {
        from: accounts[3],
        value: web3.utils.toWei("0.02", "ether")
      });

      assert.equal(await cowsgonemad.balanceOf(accounts[2]), 1);
    })

    it('should revert when over max founder mint', async () => {
      const maxFounderMint = await cowsgonemad.maxFounderMintAmount();
      await cowsgonemad.setFounderNftLimit(maxFounderMint * 2);

      await cowsgonemad.grantRole(await cowsgonemad.FOUNDER_ROLE(), accounts[2], { from: accounts[0] });

      for(let i = 0; i < 2; i++) {
        await cowsgonemad.mint(100, accounts[2], {
          from: accounts[2],
        });
      }

      await expectRevert(cowsgonemad.mint(1, accounts[2], {
        from: accounts[2],
      }), 'Max founder mint amount exceeded');
    })

    it('should revert when over ownerNftLimit', async () => {
      const ownerNftLimit = await cowsgonemad.ownerNftLimit();

      await cowsgonemad.setMaxMintAmount(ownerNftLimit + 1);

      await expectRevert(cowsgonemad.mint(ownerNftLimit + 1, accounts[0], {
        from: accounts[0],
      }), 'Owner Nft limit has been reached')
    })

    it('should mint for whitelist users', async () => {
      let whitelist = [];
      for (let i = 0; i < 9; i++) {
        whitelist.push([accounts[i], 1]);
      }

      const merkleRoot = createWhitelist(whitelist, 'test_tree.json');
      const merkleProof = findMerkleProof('test_tree.json', accounts[2]);

      await cowsgonemad.setMerkleRoot(merkleRoot);
      await cowsgonemad.setWhitelistMintingStatus(true);

      // await expectRevert(cowsgonemad.verifyMerkle(merkleProof, accounts[9], 1), 'VM Exception while processing transaction: revert Invalid proof');
      
      console.log(whitelist[2][1] * await cowsgonemad.whitelistPrice())
      await cowsgonemad.mintWhitelist(whitelist[2][1], merkleProof, {
        from: whitelist[2][0],
        // price is whitelist[2][1] * await cowsgonemad.whitelistPrice()
        value: String(whitelist[2][1] * await cowsgonemad.whitelistPrice())
      });

      assert.equal(await cowsgonemad.balanceOf(whitelist[2][0]), whitelist[2][1]);
    })
  });

  // ==========================
  // Pause
  // ==========================
  describe('function pause', () => {
    it('should give us a pause state of true', async () => {
      await cowsgonemad.pauseStatus("pause");
      assert.equal(await cowsgonemad.paused.call(), true);
    });

    it('should give us a pause state of false', async () => {
      await cowsgonemad.pauseStatus("unpause");
      assert.equal(await cowsgonemad.paused.call(), false);
    });
  });

  // =========================
  // AddFounders
  // =========================
  describe('function addFounders', () => {
    it('should return false', async () => {
      await cowsgonemad.grantRole(await cowsgonemad.FOUNDER_ROLE(), accounts[2], { from: accounts[0] });
      assert.equal(await cowsgonemad.hasRole(await cowsgonemad.FOUNDER_ROLE(), accounts[1]), false);
    });

    it('should return true', async () => {
      await cowsgonemad.grantRole(await cowsgonemad.FOUNDER_ROLE(), accounts[2], { from: accounts[0] });
      assert.equal(await cowsgonemad.hasRole(await cowsgonemad.FOUNDER_ROLE(), accounts[2]), true);
    });
  });

  // =========================
  // RemoveFounders
  // =========================
  describe('function removeFounders', () => {
    it('should return false', async () => {
      await cowsgonemad.grantRole(await cowsgonemad.FOUNDER_ROLE(), accounts[4], { from: accounts[0] });
      await cowsgonemad.revokeRole(await cowsgonemad.FOUNDER_ROLE(), accounts[4], { from: accounts[0] });
      assert.equal(await cowsgonemad.hasRole(await cowsgonemad.FOUNDER_ROLE(), accounts[4]), false);
    });
  });

  // =========================
  // WhitelistUsers
  // =========================
  describe('function whitelistUsers', () => {
    it('should return false', async () => {
      let whitelist = [];
      for (let i = 0; i < 9; i++) {
        whitelist.push([accounts[i], 1]);
      }

      const merkleRoot = createWhitelist(whitelist, 'test_tree.json');
      const merkleProof = findMerkleProof('test_tree.json', accounts[1]);

      await cowsgonemad.setMerkleRoot(merkleRoot);

      // await expectRevert(cowsgonemad.verifyMerkle(merkleProof, accounts[9], 1), 'VM Exception while processing transaction: revert Invalid proof');
      
      assert.equal(await cowsgonemad.verifyMerkle(merkleProof, accounts[9], 1), false);

    });

    it('should return true', async () => {
      let whitelist = [];
      for (let i = 0; i < 9; i++) {
        whitelist.push([accounts[i], 1]);
      }

      const merkleRoot = createWhitelist(whitelist, 'test_tree.json');
      const merkleProof = findMerkleProof('test_tree.json', accounts[1]);

      await cowsgonemad.setMerkleRoot(merkleRoot);

      assert.equal(await cowsgonemad.verifyMerkle(merkleProof, whitelist[1][0], whitelist[1][1]), true);
    });
  });

  // =========================
  // SetNFTPerAddressLimit
  // =========================
  describe('function setNFTPerAddressLimit', () => {
    it('should show us a limit of 200', async () => {
      await cowsgonemad.setNftPerAddressLimit(200);
      assert.equal(await cowsgonemad.getNftPerAddressLimit.call(), 200);
      await cowsgonemad.setNftPerAddressLimit(100);
    });
  });

  // =========================
  // SetPrice
  // =========================
  describe('function setPrice', () => {
    it('should show us a price of 0.50 ETH', async () => {
      await cowsgonemad.setPrice(web3.utils.toWei("0.50", "ether"));
      assert.equal(
        await cowsgonemad.getPrice.call(),
        web3.utils.toWei("0.50", "ether")
      );
      await cowsgonemad.setPrice(web3.utils.toWei("0.02", "ether"));
    });
  });

  // =========================
  // SetFoundersPrice
  // =========================
  describe('function setFoundersPrice', () => {
    it('should show us a price of 2.50 ETH', async () => {
      await cowsgonemad.setFoundersPrice(web3.utils.toWei("2.50", "ether"));
      assert.equal(
        await cowsgonemad.getFoundersPrice.call(),
        web3.utils.toWei("2.50", "ether")
      );
      await cowsgonemad.setFoundersPrice(web3.utils.toWei("0.0", "ether"));
    });
  });

  // =========================
  // SetWhitelistPrice
  // =========================
  describe('function setWhitelistPrice', () => {
    it('should show us a price of 1.50 ETH', async () => {
      const auxAdmin = accounts[0]; // assuming accounts[1] is AUX_ADMIN
      const initialPrice = web3.utils.toWei("1.50", "ether");
      const updatedPrice = web3.utils.toWei("0.01", "ether");
  
      // set initial price
      await cowsgonemad.setWhitelistPrice(initialPrice, {from: auxAdmin});
      let whitelistPrice = await cowsgonemad.getWhitelistPrice.call();
      assert.equal(whitelistPrice.toString(), initialPrice, "Initial price not set correctly");
  
      // update price
      await cowsgonemad.setWhitelistPrice(updatedPrice, {from: auxAdmin});
      whitelistPrice = await cowsgonemad.getWhitelistPrice.call();
      assert.equal(whitelistPrice.toString(), updatedPrice, "Updated price not set correctly");
    });

    it('should revert if not called by AUX_ADMIN', async () => {
      const nonAdmin = accounts[1];
      const auxAdmin = '0xb73fa0cb2416690a6547825d5ccf9cedab6a4cd328635df925e1dfd86cf94c21';
      const price = web3.utils.toWei("1.50", "ether");
    
      await expectRevert(
        cowsgonemad.setWhitelistPrice(price, {from: nonAdmin}),
        `VM Exception while processing transaction: revert AccessControl: account ${nonAdmin.toLowerCase()} is missing role ${auxAdmin} -- Reason given: AccessControl: account ${nonAdmin.toLowerCase()} is missing role ${auxAdmin}.`
      );
    });

    it('should emit SetWhitelistPrice event on price change', async () => {
      const auxAdmin = accounts[0];
      const updatedPrice = web3.utils.toWei("0.01", "ether");
    
      const tx = await cowsgonemad.setWhitelistPrice(updatedPrice, {from: auxAdmin});
      expectEvent(tx, 'SetWhitelistPrice', { _newPrice: updatedPrice, _admin: auxAdmin });
    });
  });

  // =========================
  // SetMaxMintAmount
  // =========================
  describe('function setMaxMintAmount', () => {
    it('should show us 50', async () => {
      await cowsgonemad.setMaxMintAmount(50);
      assert.equal(await cowsgonemad.getMaxMintAmount.call(), 50);
      await cowsgonemad.setMaxMintAmount(100);
    });
  });

  // =========================
  // SetBaseURI
  // =========================
  describe('function setBaseURI', () => {
    it('should show us the mynewbaseuri', async () => {
      await cowsgonemad.setBaseURI("https://mynewbaseuri.com/");
      assert.equal(await cowsgonemad.getBaseURI.call(), "https://mynewbaseuri.com/");
      await cowsgonemad.setBaseURI("https://CGM-baseURI.com/");
    });
  });

  // =========================
  // SetBaseExtension
  // =========================
  describe('function setBaseExtension', () => {
    it('should give us .csv as base extension', async () => {
      await cowsgonemad.setBaseExtension(".csv");
      assert.equal(await cowsgonemad.getBaseExtension.call(), ".csv");
      await cowsgonemad.setBaseExtension(".json");
    });
  });

});