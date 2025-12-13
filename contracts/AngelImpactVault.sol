// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AngelImpactVault
/// @notice Simple vault for holding ERC20 tokens earmarked for mission rewards
///         or future governance actions. Only the owner can withdraw tokens.
///         Participants may deposit tokens into the vault voluntarily.
contract AngelImpactVault is Ownable {
    IERC20 public immutable token;

    /// @param _token The ERC20 token managed by the vault (e.g. AngelCoin).
    constructor(IERC20 _token) {
        require(address(_token) != address(0), "Zero token address");
        token = _token;
    }

    /// @notice Allows any user to deposit tokens into the vault. The user
    ///         must approve the vault beforehand.
    /// @param amount The amount of tokens to deposit.
    function deposit(uint256 amount) external {
        require(amount > 0, "Zero amount");
        bool transferred = token.transferFrom(msg.sender, address(this), amount);
        require(transferred, "Transfer failed");
    }

    /// @notice Withdraws tokens from the vault to a recipient. Only the owner
    ///         (typically a multisig or governance contract) can call this.
    /// @param to The recipient of the withdrawn tokens.
    /// @param amount The amount of tokens to withdraw.
    function withdraw(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero recipient");
        require(amount > 0, "Zero amount");
        bool transferred = token.transfer(to, amount);
        require(transferred, "Transfer failed");
    }
}