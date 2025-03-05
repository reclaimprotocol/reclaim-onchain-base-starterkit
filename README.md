# Reclaim Onchain Starter Kit - EVM

This is a starter kit for building Web3 applications that leverage the Reclaim Protocol for on-chain verification of off-chain data. The project demonstrates how to create an NFT that represents verified GitHub usernames using the Reclaim Protocol.

## Overview

This project consists of two main components:
1. A Solidity smart contract (`GitHubNFT.sol`) that mints NFTs based on GitHub usernames verified via Reclaim protocol
2. A React-based frontend application that interacts with the smart contract and Reclaim JS SDK


## Tech Stack

- **Frontend**:
  - React
  - TypeScript
  - Vite
  - TailwindCSS
  - RainbowKit
  - wagmi
  - viem
  - React Query
  - Reclaim JS SDK

- **Smart Contracts**:
  - Solidity ^0.8.26
  - OpenZeppelin Contracts
  - Reclaim Protocol

## Getting Started

1. Install dependencies:
```bash
yarn install
```

2. Start the development server:
```bash
yarn dev
```

3. Build the project:
```bash
yarn build
```

## Smart Contract

The `GitHubNFT` contract:
- Inherits from OpenZeppelin's ERC721URIStorage
- Verifies GitHub usernames using the Reclaim Protocol
- Mints unique NFTs for verified GitHub usernames
- Generates on-chain SVG metadata for the NFTs

## Frontend

The frontend application provides:
- Wallet connection using RainbowKit
- Interface for minting GitHub NFTs
- Display of minted NFTs
- Integration with Reclaim Protocol for verification