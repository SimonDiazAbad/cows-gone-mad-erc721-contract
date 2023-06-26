const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
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
      await cowsgonemad.pause(false);
      await cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      });
      assert.equal(await cowsgonemad.tokenURI.call(1), 'https://CGM-NotRevealURI.com/');
    });
  })

  // ==========================
  // IsRevealed & Reveal
  // ==========================
  describe('function isRevealed & reveal', () => {
    it('should show as false', async () => {
      assert.equal(await cowsgonemad.isRevealed.call(), false);
    });
  
    it('should show as true', async () => {
      await cowsgonemad.reveal()
      assert.equal(await cowsgonemad.isRevealed.call(), true);
    });
  });

  // =========================
  // Mint
  // =========================
  describe('function mint', () => {
    it('should let us know the contract is paused', async () => {
      await cowsgonemad.pause(true);
      await expectRevert(cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      }), 'The contract is paused');
    });
  
    it('should let us know to mint atleast 1 NFT', async () => {
      await cowsgonemad.pause(false)
      await expectRevert(cowsgonemad.mint(0, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      }), 'You need to mint atleast 1 NFT');
    });
  
    it('should let us know the max mint amount per session was exceeded', async () => {
      await cowsgonemad.pause(false)
      await expectRevert(cowsgonemad.mint(101, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.02", "ether")
      }), 'Max mint amount per session exceeded');
    });

    it('should let us know that there are insufficient funds', async () => {
      await cowsgonemad.pause(false)
      await expectRevert(cowsgonemad.mint(1, accounts[1], {
        from: accounts[1],
        value: web3.utils.toWei("0.00", "ether")
      }), 'Insufficient funds');
    });
  });

  // =========================
  // AddAdmin & RemoveAdmin
  // =========================

  describe('function addAdmin & removeAdmin', () => {
    it('should return true', async () => {
      await cowsgonemad.addAdmin(accounts[5]);
      assert.equal(await cowsgonemad.isAdmin.call(accounts[5]), true);
    });

    it('should return false', async () => {
      await cowsgonemad.removeAdmin(accounts[5]);
      assert.equal(await cowsgonemad.isAdmin.call(accounts[5]), false);
    });
  });

  // ==========================
  // Pause
  // ==========================
  describe('function pause', () => {
    it('should give us a pause state of false', async () => {
      await cowsgonemad.pause(false);
      assert.equal(await cowsgonemad.getPauseState.call(), false);
    });

    it('should give us a pause state of true', async () => {
      await cowsgonemad.pause(true);
      assert.equal(await cowsgonemad.getPauseState.call(), true);
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
      await cowsgonemad.setWhitelistPrice(web3.utils.toWei("1.50", "ether"));
      assert.equal(
        await cowsgonemad.getWhitelistPrice.call(),
        web3.utils.toWei("1.50", "ether")
      );
      await cowsgonemad.setWhitelistPrice(web3.utils.toWei("0.01", "ether"));
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