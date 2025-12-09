# AngelCoin Starter Kit

Mission-driven crypto starter kit for AngelCoin. Includes Solidity contracts, an oracle skeleton, and a full testnet deployment guide. Build and test mission minting, impact scoring, and PoW-transition logic on EVM testnets ahead of mainnet launch.

---

## 🚀 Overview
This repository contains the prototype implementation of the AngelCoin ecosystem, designed for experimentation, education, and testnet deployment. AngelCoin rewards real-world impact through mission-based minting and integrates a future governance-controlled Proof-of-Work transition.

**Status:** Prototype — testnet only, not for mainnet deployment.

---

## 📦 Included Components

### **Smart Contracts (Solidity)**
- `AngelCoin.sol` — capped-supply token, mission minting, PoW-transition governance.
- `ImpactScoreRegistry.sol` — impact scoring + tiering system.
- `ImpactMiningRewards.sol` — rewards based on impact score.
- `AngelImpactVault.sol` — secure mission vault for reward distribution.

### **Oracle Skeleton (Python)**
A minimal off-chain validator for mission claims.  
Validates payloads → triggers `mintForMission()` → updates impact scores.

### **Documentation**
- Step-by-step testnet deployment guide  
- Mission minting walkthrough  
- Impact reward simulation  
- PoW governance transition demo  

---

## 🛠 Getting Started

### **1. Clone the repository**
```bash
git clone https://github.com/<vandaliz3dmind>/<Angel-Coin-Project>.git
cd <repo-name>
