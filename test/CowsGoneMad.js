const {
  expectEvent,
  expectRevert,
} = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');

const CowsGoneMad = artifacts.require('CowsGoneMad_Mock');

contract('CowsGoneMad_Mock', async (accounts) => {
  let cowsgonemad;

  beforeEach(async () => {
    cowsgonemad = await CowsGoneMad.deployed();
  });

  // ==========================
  // TokenURI
  // ==========================
  describe('function tokenURI', () => {
    it('should let us know the token does not exist', async () => {
      await expectRevert(cowsgonemad.tokenURI.call(10000), 'ERC721Metadata: URI query for nonexistent token');
    });
  
    it('should return the notRevealedUri', async () => {
      const nonRevealedUri = 'https://CGM-NotRevealURI.com/';

      await cowsgonemad.pauseStatus("unpause");
      await cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      });

      const result = await cowsgonemad.tokenURI.call(1);
      assert.equal(result, nonRevealedUri);
    });

    it('returns the expected URI for a revealed token with a base URI', async function() {
      const tokenId = 1;
      const baseURI = 'https://CGM-baseURI.com/';
      const baseExtension = '.json';
    
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
      await cowsgonemad.addFounders([accounts[2]]);
      assert.equal(await cowsgonemad.isFounder.call(accounts[1]), false);
    });

    it('should return true', async () => {
      await cowsgonemad.addFounders([accounts[3]]);
      assert.equal(await cowsgonemad.isFounder(accounts[3]), true);
    });
  });

  // =========================
  // RemoveFounders
  // =========================
  describe('function removeFounders', () => {
    it('should return false', async () => {
      await cowsgonemad.addFounders([accounts[4]]);
      await cowsgonemad.removeFounders([accounts[4]]);
      assert.equal(await cowsgonemad.isFounder.call(accounts[4]), false);
    });
  });

  // =========================
  // WhitelistUsers
  // =========================
  describe('function whitelistUsers', () => {
    it('should return false', async () => {
      await cowsgonemad.whitelistUsers([accounts[9]]);
      assert.equal(await cowsgonemad.isWhitelisted.call(accounts[1]), false);
    });

    it('should return false', async () => {
      await cowsgonemad.whitelistUsers([accounts[8]]);
      assert.equal(await cowsgonemad.isWhitelisted(accounts[8]), true);
    });
  });

  // =========================
  // RemoveWhitelistUsers
  // =========================
  describe('function removeWhitelistUsers', () => {
    it('should return false', async () => {
      await cowsgonemad.whitelistUsers([accounts[9]]);
      await cowsgonemad.removeWhitelistedUsers([accounts[9]]);
      assert.equal(await cowsgonemad.isWhitelisted.call(accounts[9]), false);
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