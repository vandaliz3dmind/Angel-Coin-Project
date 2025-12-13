// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AngelCoin
/// @notice Capped-supply ERC20 token minted only by authorised mission contracts.
/// @dev Testnet / prototype implementation.
contract AngelCoin is ERC20, Ownable {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error ZeroAddress();
    error NotAuthorisedMinter();
    error CapExceeded();
    error InvalidMaxSupply();

    /*//////////////////////////////////////////////////////////////
                             STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @notice Maximum number of tokens that can ever be minted.
    uint256 public immutable MAX_SUPPLY;

    /// @notice Mapping of authorised minter contracts.
    mapping(address => bool) public authorisedMinters;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(uint256 maxSupply_)
        ERC20("AngelCoin", "ANGEL")
        Ownable(msg.sender)
    {
        if (maxSupply_ == 0) revert InvalidMaxSupply();
        MAX_SUPPLY = maxSupply_;
    }

    /*//////////////////////////////////////////////////////////////
                         OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function addMinter(address minter) external onlyOwner {
        if (minter == address(0)) revert ZeroAddress();
        authorisedMinters[minter] = true;
        emit MinterAdded(minter);
    }

    function removeMinter(address minter) external onlyOwner {
        authorisedMinters[minter] = false;
        emit MinterRemoved(minter);
    }

    /*//////////////////////////////////////////////////////////////
                         MINTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function mintForMission(address to, uint256 amount) external {
        if (!authorisedMinters[msg.sender]) revert NotAuthorisedMinter();
        if (totalSupply() + amount > MAX_SUPPLY) revert CapExceeded();
        _mint(to, amount);
    }
}
