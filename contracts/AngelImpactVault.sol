// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AngelImpactVault
/// @notice Vault for holding ERC20 tokens earmarked for mission rewards
///         or future governance actions. Only the owner can withdraw.
///         Anyone may deposit tokens voluntarily.
contract AngelImpactVault is Ownable {
    IERC20 public immutable token;

    /// @param _token The ERC20 token managed by the vault (e.g. AngelCoin).
    constructor(IERC20 _token) Ownable(msg.sender) {
        require(address(_token) != address(0), "Zero token address");
        token = _token;
    }

    /// @notice Deposit tokens into the vault (requires prior approval).
    /// @param amount The amount of tokens to deposit.
    function deposit(uint256 amount) external {
        require(amount > 0, "Zero amount");
        bool transferred = token.transferFrom(msg.sender, address(this), amount);
        require(transferred, "Transfer failed");
    }

    /// @notice Withdraw tokens from the vault.
    /// @dev Only callable by the owner (multisig or governance).
    /// @param to The recipient of the withdrawn tokens.
    /// @param amount The amount of tokens to withdraw.
    function withdraw(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero recipient");
        require(amount > 0, "Zero amount");
        bool transferred = token.transfer(to, amount);
        require(transferred, "Transfer failed");
    }
}
