// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AngelCoin
 * @notice Capped-supply ERC20 token.
 *         Tokens may ONLY be minted by authorized minter contracts
 *         (e.g. mission verifiers, impact vaults, bridge contracts).
 */
contract AngelCoin is ERC20, Ownable {
    /// @notice Maximum total supply (immutable after deployment)
    uint256 public immutable MAX_SUPPLY;

    /// @notice Authorized minter contracts
    mapping(address => bool) public authorizedMinters;

    /// @notice Emitted when a minter is authorized or revoked
    event MinterAuthorizationUpdated(address indexed minter, bool authorized);

    /**
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param maxSupply_ Hard cap (in wei units, e.g. 1e18 decimals)
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(maxSupply_ > 0, "Max supply must be > 0");
        MAX_SUPPLY = maxSupply_;
    }

    /**
     * @notice Authorize or revoke a minter contract
     * @param minter Address of the minter contract
     * @param authorized True to authorize, false to revoke
     */
    function setAuthorizedMinter(
        address minter,
        bool authorized
    ) external onlyOwner {
        require(minter != address(0), "Invalid minter address");
        authorizedMinters[minter] = authorized;
        emit MinterAuthorizationUpdated(minter, authorized);
    }

    /**
     * @notice Mint AngelCoin (only callable by authorized minters)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(
        address to,
        uint256 amount
    ) external {
        require(authorizedMinters[msg.sender], "Caller not authorized to mint");
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply exceeded");
        _mint(to, amount);
    }

    /**
     * @notice Burn tokens from caller
     *         (used for donation burns, NFT proof minting, tier upgrades, etc.)
     * @param amount Amount to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
