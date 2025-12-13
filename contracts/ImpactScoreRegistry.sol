// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ImpactScoreRegistry
/// @notice Maintains impact scores for participants. Only the owner
///         (e.g. an oracle or reward contract) can assign scores. Anyone
///         can query scores. Scores are reset when rewards are claimed.
contract ImpactScoreRegistry is Ownable {
    // mapping of addresses to their accumulated impact scores
    mapping(address => uint256) private _scores;

    /// @dev Emitted when a participant's score is updated.
    event ScoreUpdated(address indexed account, uint256 score);

    /// @notice Sets the impact score for a participant.
    /// @param account The participant whose score is being set.
    /// @param score The new impact score.
    function setScore(address account, uint256 score) external onlyOwner {
        _scores[account] = score;
        emit ScoreUpdated(account, score);
    }

    /// @notice Returns the impact score of a participant.
    /// @param account The participant's address.
    /// @return The participant's impact score.
    function getScore(address account) external view returns (uint256) {
        return _scores[account];
    }
}