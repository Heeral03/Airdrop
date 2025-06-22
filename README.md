# Merkle Airdrop with Signature Verification (Foundry)

A gas-efficient, secure airdrop system built with [Foundry](https://book.getfoundry.sh/), using Merkle Trees, ECDSA cryptographic signatures, and mock hardcoded allowlists. This smart contract allows a third party (relayer) to airdrop tokens on behalf of eligible users — without requiring users to directly interact with the blockchain.

---

## Features

- Efficient eligibility verification using Merkle Trees  
- Secure token claims using ECDSA-based signatures  
- Relayer support — enables third-party airdrops on behalf of recipients  
- Built and tested with Foundry  
- Hardcoded mock allowlist for demo/local testing  
- Modular structure for easy integration with real-world projects

---

## How It Works

### 1. Allowlist (Mocked)

- A list of allowed addresses and their airdrop token amounts is hardcoded in the script (e.g., inside `MakeMerkel.s.sol` or `GenerateInput.s.sol`).
- Each `(address, amount)` pair is converted to a leaf using `keccak256`.
- A Merkle Tree is generated using these leaves.
- The Merkle Root is deployed in the `MerkelAirdrop` contract.

### 2. Claiming via Relayer (Third-Party)

- A third party (e.g., frontend, backend relayer) can call the `claim()` function on behalf of a user.
- Required inputs:
  - User address
  - Token amount
  - Merkle proof (matching hardcoded tree)
  - ECDSA signature signed by a known signer or the user

- The contract verifies:
  - Merkle proof validity
  - Signature authenticity (via `ECDSA.recover`)
  - Whether the user has already claimed

If all checks pass — tokens are transferred.

---

## Security Measures

- Single-claim enforcement — each user can only claim once  
- ECDSA-based signature verification — prevents spoofed claims  
- Merkle Proof validation — ensures the user is in the allowlist

---

## Tech Stack

- Foundry — for development, scripting & testing  
- Solidity — smart contract language  
- OpenZeppelin — for ECDSA utilities  
- Merkle Trees — off-chain inclusion proofs  
- forge-std — Foundry’s standard test library

---

## Project Structure

├── src/
│ ├── BagelToken.sol # ERC20 token used for airdrops
│ └── MerkelAirdrop.sol # Main contract
├── script/
│ ├── DeployMerkelAirdrop.s.sol # Deploy contract with Merkle root
│ ├── Interact.s.sol # Relayer/claim simulation
│ ├── MakeMerkel.s.sol # Script to create Merkle tree
│ ├── GenerateInput.s.sol # Mock data generator
│ └── target/
│ ├── input.json # Hardcoded allowlist
│ └── output.json # Merkle tree with proof info
├── test/
│ └── TestAirdrop.t.sol # Unit tests
├── lib/ # External dependencies
├── foundry.toml # Foundry config
├── .gitignore
└── README.md

---


## Getting Started

1. Clone and Install

cd Airdrop
foundryup
forge install

2. Build & Test

forge build
forge test

3. Run Local Blockchain

anvil

4. Deploy Contract

forge script script/DeployMerkelAirdrop.s.sol --rpc-url http://localhost:8545 --private-key YOUR_PRIVATE_KEY --broadcast

---

Example Use Case

Say we hardcoded this entry:
{
  "address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "amount": 25
}

- A Merkle proof is generated for this pair.

- The backend signs a message hash(address, amount) using its private key.

- A relayer calls claim() with the proof and signature.

- If valid, 25 BAGEL tokens are sent to the recipient.

--- 

Future Improvements

- Replace hardcoded allowlist with off-chain JSON input

- Merkle proof generation via frontend tool

- IPFS-hosted proof metadata for larger lists

