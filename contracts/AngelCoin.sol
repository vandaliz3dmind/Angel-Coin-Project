// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ────────────────────────────── */
/*        Named Imports ONLY       */
/* ────────────────────────────── */
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/* ────────────────────────────── */
/*          Custom Errors          */
/* ────────────────────────────── */
error MaxSupplyZero();
error UnauthorizedMinter();
error MaxSupplyExceeded();
error InvalidAddress();

/* ────────────────────────────── */
/*            Contract             */
/* ────────────────────────────── */
contract AngelCoin is ERC20, Ownable {
    /* ───────────── Storage ───────────── */

    uint256 private immutable _MAX_SUPPLY;
    mapping(address => bool) private _authorizedMinters;

    /* ───────────── Events ───────────── */

    event MinterAuthorizationUpdated(address indexed minter, bool authorized);

    /* ───────────── Constructor ───────────── */

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        if (maxSupply_ == 0) revert MaxSupplyZero();
        _MAX_SUPPLY = maxSupply_;
    }

    /* ───────────── Views ───────────── */

    function maxSupply() external view returns (uint256) {
        return _MAX_SUPPLY;
    }

    function isAuthorizedMinter(address minter) external view returns (bool) {
        return _authorizedMinters[minter];
    }

    /* ───────────── Admin ───────────── */

    function setAuthorizedMinter(
        address minter,
        bool authorized
    ) external onlyOwner {
        if (minter == address(0)) revert InvalidAddress();
        _authorizedMinters[minter] = authorized;
        emit MinterAuthorizationUpdated(minter, authorized);
    }

    /* ───────────── Mint / Burn ───────────── */

    function mint(address to, uint256 amount) external {
        if (!_authorizedMinters[msg.sender]) revert UnauthorizedMinter();
        if (totalSupply() + amount > _MAX_SUPPLY) revert MaxSupplyExceeded();
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
