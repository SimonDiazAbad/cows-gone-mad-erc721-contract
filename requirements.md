# Cows Gone Mad NFT Smart Contract

## Index
- Project Overview
- Functional Requirements
  - Roles
  - Features
  - Use Cases
- Technical Requirements
  - Architecture Overview
  - Contract Information
    - CowsGoneMad.sol
      - Assets
      - Events
      - Modifiers
      - Functions
  - Use Cases


## Project Overview
Cows Gone Mad NFT (Non-Fungible-Token) is an ERC721 Smart Contract. It allows users to purchase up to 100 NFTs per address, founders can mint up to 5 NFTs for a small gas fee. The Owner can mint unlimited NFTs for a small gas fee.

The Owner (DEFAULT_ADMIN_ROLE) has access to the full scope of project permissions, the admin roles (AUX_ADMIN) have access to all other permissions besides withdrawing funds and adding administrators.

## 1. Functional Requirements
 ### 1.1. Roles
 
 Cows Gone Mad has 4 roles.
 - **Owner(DEFAULT_ADMIN_ROLE):** Has access to all functions in the smart contract, The Owner can also add another Owner(DEFAULT_ADMIN_ROLE), add and remove Admins(AUX_ADMIN), add and remove whitelisted users, add and remove founders. The Owner can also transfer ownership.
 The Owner can mint 300 tokens at his/her price.
 The Owner also is the only one to have access to the withdraw function.

 - **Admin(AUX_ADMIN):** Has access to all functions excluding the withdraw function. Add and remove whitelisted users, add and remove founders.

 - **Founder:** Has access to mint only 5 tokens at their price.

 - **Whitelisted User:** Has access to mint at a discounted price.

 - **User:** Has access to mint.

 ### Features

- Deployment
  - Token Name
  - Token Symbol
  - Initialize Base URI
  - Initialize Not Revealed URI
  - Setup Owner(DEFAULT_ADMIN_ROLE)
- Admin
  - Grant AUX_ADMIN Role (DEFAULT_ADMIN_ROLE)
  - Remove AUX_ADMIN Role (DEFAULT_ADMIN_ROLE)
- Founder
  - Add Founder Address (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
  - Remove Founder Address (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Mint
  - Mint Single
  - Mint Batch
- Burn an NFT
- Reveal NFT's (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set NFT per address limit (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set Price (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set Founders Price (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set Whitelist Price (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set max mint amount per session (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set base URI (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set base extension (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Set not revealed URI (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Pause NFT sale (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Whitelist users (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Remove whitelisted users (AUX_ADMIN, DEFAULT_ADMIN_ROLE)
- Withdraw from contract wallet (DEFAULT_ADMIN_ROLE)
#### View
- View Price
- View Founders Price
- View Whitelist Price
- View Token URI with tokenID
- View revealed status
- Check if address is whitelisted
- Check if address is a founder
- View all owner's tokens
