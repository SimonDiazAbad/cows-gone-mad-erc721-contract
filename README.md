# Cows Gone Mad Solidity Project

The CGM collection has 9999 NFTs that commemorate the lives of 9999 cows who survived the great culling during the Mad Cow Disease outbreak. MetaPolyclinic specifically selected the Polygon blockchain to mint the CGM Collection due to the platform’s scalability, high transaction throughput and supportive community. 

## Specifications
### Project Overview
Cows Gone Mad NFT (Non-Fungible-Token) is an ERC721 Smart Contract. It allows users to purchase up to 100 NFTs per address, founders can mint up to 5 NFTs for a small gas fee. The Owner can mint unlimited NFTs for a small gas fee.

The Owner (DEFAULT_ADMIN_ROLE) has access to the full scope of project permissions, the admin roles (AUX_ADMIN) have access to all other permissions besides withdrawing funds and adding administrators.

Regular users will have access to mint 100 tokens total for full price.
Whitelisted users will have a discounted price and also 100 tokens total.
Founders will have access to mint 5 total tokens for free.

### Functional, Technical Requirements
Functional and Technical Requirements can be found in the Requirements.md file.

## Getting Started
Recommended:
- Node version is 16.0.0 and above.
- Truffle version 5.0.0 and above.
- Ganache version 7.8.0 and above.
- Solidity version 0.8.19.
- Web3.js version 1.10.0.

### Available commands
```
# Install Dependencies
$ npm install

# Compile (Build) Contracts Only
$ truffle compile

# Run Blockchain Locally
$ truffle develop

# Run Tests
$ truffle test

# Run Deploy Script
$ truffle migrate
```

## Project Structure
This is a truffle javascript project composed of contracts, tests and migrations.
Migrations folders contain the deploy scripts.

This a template hardhat typescript project composed of contracts, tests, and deploy instructions that provides a great starting point for developers to quickly get up and running and deploying smart contracts on the Ethereum blockchain.

## Tests
Tests are found in the ./test/ folder. No additional keys are required to run the tests.

Contract coverage is not checked.

## Contracts
Solidity smart contracts are found in ./contracts/

./contracts/CowsGoneMad_Mock.sol contract is a mock contract that is used for testing purposes.

## Deploy
Deploy script can be found in the ./migrations/1_deploy_contracts.js.

Important: If deploying to testnet or mainnet, make sure to adjust the deploy script to deploy the CowsGoneMad contract and not the Mock contract. Then add the correct arguments into the constructor for your project.

Configure truffle-config.js by 

Rename ./.env.example to ./.env in the project root. To add the mnemonic string of a deployer account, assign the following variables

MNEMONIC=...

MUMBAI_API_KEY=...

### example

- TestNet: $ truffle migrate --network mumbai
- Mainnet: $ truffle migrate --network polygon







### Cows Gone Mad Functionality

- Deployment (Owner)
  - Token Name
  - Token Symbol
  - Initialize Base URI
  - Initialize Not Revealed URI
- Admin (Owner)
  - Add Admin Address
  - Remove Admin Address
- Founder (Admin)
  - Add Founder Address (Admin)
  - Remove Founder Address (Admin)
- Mint
  - Mint Single
  - Mint Batch
- Burn an NFT
- Reveal NFT's (Owner)
- Set NFT per address limit (Admin)
- Set Price (Admin)
- Set Founders Price (Admin)
- Set Whitelist Price (Admin)
- Set max mint amount per session (Admin)
- Set base URI (Owner)
- Set base extension (Owner)
- Set not revealed URI (Owner)
- Pause NFT sale (Admin)
- Whitelist users (Admin)
- Remove whitelisted users (Admin)
- Withdraw from contract wallet (Owner)
##### View
- View Price
- View Founders Price
- View Whitelist Price
- View Token URI with tokenID
- View revealed status
- Check if address is whitelisted
- Check if address is a founder
- View all owner's tokens

#### Additional Functionality provided by openzeppelin

- Ownable contract
  - Check the owner address
  - Transfer Ownership
  - Renounce Ownership









#### Cows Gone Mad Functionality

- Deployment (Owner)
  - Token Name
  - Token Symbol
  - Initialize Base URI
  - Initialize Not Revealed URI
- Admin (Owner)
  - Add Admin Address
  - Remove Admin Address
- Founder (Admin)
  - Add Founder Address (Admin)
  - Remove Founder Address (Admin)
- Mint
  - Mint Single
  - Mint Batch
- Burn an NFT
- Reveal NFT's (Owner)
- Set NFT per address limit (Admin)
- Set Price (Admin)
- Set Founders Price (Admin)
- Set Whitelist Price (Admin)
- Set max mint amount per session (Admin)
- Set base URI (Owner)
- Set base extension (Owner)
- Set not revealed URI (Owner)
- Pause NFT sale (Admin)
- Whitelist users (Admin)
- Remove whitelisted users (Admin)
- Withdraw from contract wallet (Owner)
##### View
- View Price
- View Founders Price
- View Whitelist Price
- View Token URI with tokenID
- View revealed status
- Check if address is whitelisted
- Check if address is a founder
- View all owner's tokens

#### Additional Functionality provided by openzeppelin

- Ownable contract
  - Check the owner address
  - Transfer Ownership
  - Renounce Ownership
