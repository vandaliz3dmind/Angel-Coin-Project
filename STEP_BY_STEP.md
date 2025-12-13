# Step‑by‑Step Testnet Guide

This document walks through deploying and testing the AngelCoin prototype on an Ethereum testnet. These instructions assume some familiarity with Node.js and Hardhat but can be adapted for other frameworks.

## 1. Install Dependencies

1. Install Node.js (v16 or higher) and npm.
2. Create a new project directory and initialise a Hardhat project:

   ```bash
   mkdir angelcoin-test && cd angelcoin-test
   npm init -y
   npm install --save-dev hardhat
   npx hardhat init
   ```

3. Install OpenZeppelin contracts:

   ```bash
   npm install @openzeppelin/contracts
   ```

4. Copy the contracts from this repository into your Hardhat `contracts/` directory.

## 2. Compile the Contracts

Edit `hardhat.config.js` to set the Solidity compiler version to `0.8.20` and enable the optimizer. Then run:

```bash
npx hardhat compile
```

If there are any compilation errors, fix them before proceeding. The contracts in this repository compile successfully with the specified version and dependencies.

## 3. Deploy the Contracts

Create a deployment script in `scripts/deploy.js` similar to the following (simplified):

```js
const { ethers } = require("hardhat");

async function main() {
  const maxSupply = ethers.utils.parseEther("1000000000"); // 1 billion ANGEL
  const AngelCoin = await ethers.getContractFactory("AngelCoin");
  const ImpactScoreRegistry = await ethers.getContractFactory("ImpactScoreRegistry");
  const ImpactMiningRewards = await ethers.getContractFactory("ImpactMiningRewards");
  const AngelImpactVault = await ethers.getContractFactory("AngelImpactVault");

  const angelCoin = await AngelCoin.deploy(maxSupply);
  await angelCoin.deployed();

  const scoreRegistry = await ImpactScoreRegistry.deploy();
  await scoreRegistry.deployed();

  const rewards = await ImpactMiningRewards.deploy(angelCoin.address, scoreRegistry.address, ethers.utils.parseEther("1"));
  await rewards.deployed();

  const vault = await AngelImpactVault.deploy(angelCoin.address);
  await vault.deployed();

  // Authorise the rewards contract to mint AngelCoin
  const tx = await angelCoin.addMinter(rewards.address);
  await tx.wait();

  console.log("AngelCoin deployed to", angelCoin.address);
  console.log("ImpactScoreRegistry deployed to", scoreRegistry.address);
  console.log("ImpactMiningRewards deployed to", rewards.address);
  console.log("AngelImpactVault deployed to", vault.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Run the deployment script on your chosen testnet (e.g. Goerli or Sepolia) by providing an RPC URL and a private key in `hardhat.config.js`.

## 4. Verify Mission Minting and Rewards

After deployment:

1. Use Hardhat console or a front‑end to call `scoreRegistry.setScore(<participant>, <score>)` as the contract owner. In a real system the oracle would perform this step.
2. Then have the participant call `rewards.claim()` from their wallet. The contract will calculate `score * rewardRate` tokens, mint them via `angelCoin.mintForMission()`, and reset their score to zero.
3. Check the participant’s AngelCoin balance and confirm that the supply does not exceed `maxSupply`.

## 5. Running the Oracle Skeleton

The `oracle/main.py` script is a placeholder for an off‑chain process that verifies missions and triggers on‑chain minting. To run it:

1. Install Python 3.10 or higher and pip.
2. Install the Web3 library:

   ```bash
   pip install web3
   ```

3. Edit `oracle/main.py` to add your RPC endpoint, private key, contract ABI, and addresses. The provided script contains only a skeleton `main()` function. Extend it to:
   - Connect to the Ethereum testnet via Web3.
   - Load the ABI and create a contract instance for `AngelCoin`.
   - Monitor off‑chain events (e.g. using an API or manual input).
   - Call `mintForMission()` on the contract when a mission is verified.

4. Run the oracle script:

   ```bash
   python oracle/main.py
   ```

## 6. Future Enhancements

The current prototype is intentionally simple. Possible improvements include:

- **Access control:** replace the owner model with roles (e.g. using OpenZeppelin’s AccessControl) so that only designated oracles and reward contracts can set scores and mint tokens.
- **Impact tiers:** implement tier‑based rewards in `ImpactMiningRewards.sol` to provide multiplicative bonuses for higher impact scores.
- **Automated vault disbursements:** modify the vault to release funds based on governance proposals or time‑locked contracts.
- **Auditing and testing:** write unit tests to cover edge cases and run static analysis tools (e.g. Slither) to identify vulnerabilities before deployment.

**Note:** All operations described here should be performed on testnets. Do not use this system on mainnet without a professional audit and compliance review.