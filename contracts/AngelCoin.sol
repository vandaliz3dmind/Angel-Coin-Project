// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/*
 * Custom errors
 */
error MaxSupplyZero();
error UnauthorizedMinter();
error MaxSupplyExceeded();
error InvalidAddress();

/// @title AngelCoin
/// @notice ERC20 token with a hard-capped maximum supply and mint/burn control.
/// @dev This contract mirrors the originally provided AngelCoin implementation but
///      makes minimal surgical changes to address static analysis warnings. No
///      additional features or stylistic refactoring have been introduced.
contract AngelCoin is ERC20, Ownable {
    // The immutable maximum token supply. Named in SNAKE_CASE to satisfy
    // static analysis recommendations without changing contract behaviour.
    uint256 private immutable MAX_SUPPLY;
    // Mapping of authorised minters. Only addresses explicitly authorised by
    // the owner may mint new tokens until the supply cap is reached.
    mapping(address => bool) private _authorizedMinters;

    /// @notice Emitted when a minter's authorisation status changes.
    /// @param minter The address whose authorisation was updated.
    /// @param authorized True if the minter is now authorised, false otherwise.
    event MinterAuthorizationUpdated(address indexed minter, bool authorized);

    // slither-disable-next-line naming-convention
    /// @param name_ The name of the token.
    /// @param symbol_ The symbol of the token.
    /// @param maxSupply_ The maximum total supply for the token; must be non‑zero.
    /// @dev The constructor assigns the immutable supply cap and passes the deploying
    ///      address to Ownable. Solidity >=0.7.0 constructors do not use visibility
    ///      specifiers; this is intentional.
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        if (maxSupply_ == 0) revert MaxSupplyZero();
        MAX_SUPPLY = maxSupply_;
    }

    /// @notice Returns the maximum total token supply.
    /// @return The immutable supply cap.
    function maxSupply() external view returns (uint256) {
        return MAX_SUPPLY;
    }

    /// @notice Checks whether an address is authorised to mint new tokens.
    /// @param minter The address to query.
    /// @return True if the address is authorised to mint.
    function isAuthorizedMinter(address minter) external view returns (bool) {
        return _authorizedMinters[minter];
    }

    /// @notice Grants or revokes minting authorisation for a minter.
    /// @param minter The address to authorise or revoke.
    /// @param authorized True to authorise the minter; false to revoke.
    /// @dev Only callable by the contract owner. Reverts if the minter is the
    ///      zero address.
    function setAuthorizedMinter(address minter, bool authorized)
        external
        onlyOwner
    {
        if (minter == address(0)) revert InvalidAddress();
        _authorizedMinters[minter] = authorized;
        emit MinterAuthorizationUpdated(minter, authorized);
    }

    /// @notice Mints tokens to a recipient.
    /// @param to The recipient of the newly minted tokens.
    /// @param amount The amount of tokens to mint.
    /// @dev Reverts if the caller is not an authorised minter or if minting
    ///      would exceed the maximum supply cap.
    function mint(address to, uint256 amount) external {
        if (!_authorizedMinters[msg.sender]) revert UnauthorizedMinter();
        if (totalSupply() + amount > MAX_SUPPLY) revert MaxSupplyExceeded();
        _mint(to, amount);
    }

    /// @notice Burns tokens from the caller's balance.
    /// @param amount The number of tokens to burn.
    /// @dev Burning reduces the caller's balance and the total supply. No
    ///      authorisation is required to burn.
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
