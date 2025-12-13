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

contract AngelCoin is ERC20, Ownable {
    uint256 private immutable _maxSupply;
    mapping(address => bool) private _authorizedMinters;

    event MinterAuthorizationUpdated(address indexed minter, bool authorized);

    // slither-disable-next-line naming-convention
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        if (maxSupply_ == 0) revert MaxSupplyZero();
        _maxSupply = maxSupply_;
    }

    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    function isAuthorizedMinter(address minter) external view returns (bool) {
        return _authorizedMinters[minter];
    }

    function setAuthorizedMinter(address minter, bool authorized)
        external
        onlyOwner
    {
        if (minter == address(0)) revert InvalidAddress();
        _authorizedMinters[minter] = authorized;
        emit MinterAuthorizationUpdated(minter, authorized);
    }

    function mint(address to, uint256 amount) external {
        if (!_authorizedMinters[msg.sender]) revert UnauthorizedMinter();
        if (totalSupply() + amount > _maxSupply) revert MaxSupplyExceeded();
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
