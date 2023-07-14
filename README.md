## Cows Gone Mad Solidity Project

The CGM collection has 9999 NFTs that commemorate the lives of 9999 cows who survived the great culling during the Mad Cow Disease outbreak. MetaPolyclinic specifically selected the Polygon blockchain to mint the CGM Collection due to the platform’s scalability, high transaction throughput and supportive community. 

## Specifications
# Project Overview
Cows Gone Mad NFT (Non-Fungible-Token) is an ERC721 Smart Contract. It allows users to purchase up to 100 NFTs per address, founders can mint up to 5 NFTs for a small gas fee. The Owner can mint unlimited NFTs for a small gas fee.

The Owner has access to the full scope of project permissions, the admin roles have access to all other permissions besides withdrawing funds and adding administrators.

# Functional, Technical Requirements
Functional and Technical Requirements can be found in the Requirements.md file.

## Getting Started
Recommended Node version is 18.0.0 and above.

# Available commands
```
# install dependencies
$ npm install

# build for production
$ npm run build

# clean, build, run tests
$ npm run rebuild

# run tests
$ npm run test

# compute tests coverage
$ npm run coverage

# eslint automatically fix problems
$ npm run lint

# run pretty-quick on .ts , .tsx files
$ npm run lint-quick
```

## Project Structure
This is a truffle javascript project 

This a template hardhat typescript project composed of contracts, tests, and deploy instructions that provides a great starting point for developers to quickly get up and running and deploying smart contracts on the Ethereum blockchain.

Tests
Tests are found in the ./test/ folder. ./test/shared/ contains various test helpers. No additional keys are required to run the tests.

Both positive and negative cases are covered, and test coverage is 100%.

Contracts
Solidity smart contracts are found in ./contracts/

./contracts/mocks folder contains contracts mocks that are used for testing purposes.

Deploy
Deploy script can be found in the deploy.ts folder.

Rename ./.env.example to ./.env in the project root. To add the private key of a deployer account, assign the following variables

PRIVATE_KEY=...
TOKEN_ADDRESS=...
example:

$ npm run deploy -- mumbai

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
