// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./AngelCoin.sol";
import "./ImpactScoreRegistry.sol";

/// @title ImpactMiningRewards
/// @notice Distributes AngelCoin rewards based on a participant's impact score.
///         This contract reads scores from ImpactScoreRegistry, mints ANGEL
///         tokens via AngelCoin, and resets the score to zero to prevent
///         double‑claiming. Only the owner can change the reward rate.
contract ImpactMiningRewards is Ownable {
    AngelCoin public immutable angelCoin;
    ImpactScoreRegistry public immutable scoreRegistry;
    uint256 public rewardRate; // tokens minted per impact point (scaled by 1e18)

    /// @param _angelCoin The AngelCoin token contract.
    /// @param _scoreRegistry The impact score registry contract.
    /// @param _rewardRate The initial reward rate (e.g. 1e18 for 1 ANGEL per point).
    constructor(AngelCoin _angelCoin, ImpactScoreRegistry _scoreRegistry, uint256 _rewardRate) {
        require(address(_angelCoin) != address(0), "Zero token");
        require(address(_scoreRegistry) != address(0), "Zero registry");
        angelCoin = _angelCoin;
        scoreRegistry = _scoreRegistry;
        rewardRate = _rewardRate;
    }

    /// @notice Sets a new reward rate. Only the owner can call this. The
    ///         reward rate determines how many ANGEL tokens are minted per
    ///         impact point.
    /// @param newRate The new reward rate (scaled by 1e18).
    function setRewardRate(uint256 newRate) external onlyOwner {
        rewardRate = newRate;
    }

    /// @notice Claims rewards based on the caller's impact score. The score
    ///         is multiplied by the reward rate and minted via AngelCoin.
    ///         Afterwards the score is reset to zero to prevent reuse.
    function claim() external {
        uint256 score = scoreRegistry.getScore(msg.sender);
        require(score > 0, "No impact score");
        // compute reward = score * rewardRate
        uint256 reward = score * rewardRate;
        // reset score first to prevent reentrancy/double claim via callback
        scoreRegistry.setScore(msg.sender, 0);
        // mint tokens via AngelCoin
        angelCoin.mintForMission(msg.sender, reward);
    }
}