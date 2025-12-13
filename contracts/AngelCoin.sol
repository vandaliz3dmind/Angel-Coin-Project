// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AngelCoin
/// @notice Capped-supply ERC20 token that can only be minted by authorised
///         contracts when a participant completes a verified mission.
///         Intended for testnet / prototype use only.
contract AngelCoin is ERC20, Ownable {
    /// @notice Maximum number of tokens that can ever be minted.
    uint256 public immutable maxSupply;

    /// @dev Mapping of authorised minter addresses.
    mapping(address => bool) public authorisedMinters;

    /// @dev Emitted when a new authorised minter is added.
    event MinterAdded(address indexed minter);

    /// @dev Emitted when an authorised minter is removed.
    event MinterRemoved(address indexed minter);

    /// @param _maxSupply The maximum total supply (in wei) of AngelCoin.
    constructor(uint256 _maxSupply)
        ERC20("AngelCoin", "ANGEL")
        Ownable(msg.sender)
    {
        require(_maxSupply > 0, "Max supply must be positive");
        maxSupply = _maxSupply;
    }

    /// @notice Grants minting rights to a contract.
    /// @param minter The address to authorise.
    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "Zero address");
        authorisedMinters[minter] = true;
        emit MinterAdded(minter);
    }

    /// @notice Revokes minting rights from a contract.
    /// @param minter The address to revoke.
    function removeMinter(address minter) external onlyOwner {
        authorisedMinters[minter] = false;
        emit MinterRemoved(minter);
    }

    /// @notice Mints tokens to a participant when a mission is verified.
    ///         Can only be called by authorised minters.
    /// @param to The participant receiving the newly minted tokens.
    /// @param amount The amount of tokens to mint (in wei).
    function mintForMission(address to, uint256 amount) external {
        require(authorisedMinters[msg.sender], "Not authorised to mint");
        require(totalSupply() + amount <= maxSupply, "Cap exceeded");
        _mint(to, amount);
    }
}
