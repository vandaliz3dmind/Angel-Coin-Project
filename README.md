# AngelCoin Starter Kit

Mission-driven crypto starter kit for AngelCoin. This repository contains a prototype implementation of the AngelCoin ecosystem. It is intended **for experimentation and educational purposes on testnets only**. **It is not suitable for mainnet deployment or fundraising.**

## Overview

AngelCoin is designed to reward real‑world impact rather than speculation. Each token is minted only when a verifiable mission is completed—for example, donating to a charitable cause or performing an approved community action. A separate governance mechanism allows the community to transition the network from a mission‑based proof‑of‑impact model to a capped proof‑of‑work regime in the future. The protocol integrates a tiered impact score registry and mining rewards that are proportional to the impact score.

This repository contains:

- **Smart contracts** written in Solidity that implement the core token (AngelCoin), an impact score registry, a reward distribution contract, and a mission vault.
- **Oracle skeleton** in Python to demonstrate how off‑chain mission verification could trigger token minting and impact score updates.
- **Documentation** including a step‑by‑step guide for deploying and testing the contracts on Ethereum testnets.

## Included Components

### Smart Contracts (Solidity)

* **AngelCoin.sol** – ERC‑20–compatible token with a capped supply and mission‑minting functionality. Only authorized minters (such as the Impact Mining Rewards contract) can mint tokens for verified mission completions. A governance owner can add or remove minters and eventually adjust the token’s future proof‑of‑work parameters.
* **ImpactScoreRegistry.sol** – Maintains a mapping of participant addresses to their accumulated impact scores. Only an authorized role (for example, the oracle or rewards contract) can assign scores. Scores can be queried by anyone.
* **ImpactMiningRewards.sol** – Reads impact scores from the registry and mints AngelCoin rewards proportionally. After distributing rewards it resets the participant’s score, ensuring scores cannot be reused.
* **AngelImpactVault.sol** – Secure vault that holds tokens earmarked for mission rewards or future governance actions. Only the owner can withdraw tokens. Participants deposit ANGEL or other ERC‑20 tokens into the vault via `deposit()`.

### Oracle Skeleton (Python)

A minimal off‑chain script intended as a starting point for building a mission verification oracle. In a real deployment, this oracle would listen for off‑chain events (e.g. completion of a mission or a donation), verify them, and then call the on‑chain `mintForMission()` function on AngelCoin. The provided script logs a message and demonstrates how one might connect to Web3 and invoke contract functions.

### Documentation

* **STEP_BY_STEP.md** – A detailed guide for deploying the contracts on a testnet, running the oracle, and simulating mission minting and reward claims. It includes instructions for compiling the contracts with OpenZeppelin, deploying them via Hardhat or another framework, and interacting with them through scripts or a front‑end.

## Legal and Ethical Disclaimer

AngelCoin is currently a prototype for educational and demonstration purposes. It should not be used to raise funds, manage real donations, or represent a compliant 501(c)(3) nonprofit. The mission‑minting mechanism is experimental and has not undergone a formal security audit. Use it at your own risk. Any real deployment must follow applicable laws and regulations for charitable tokens, including restrictions on fundraising, securities law compliance, and nonprofit governance.