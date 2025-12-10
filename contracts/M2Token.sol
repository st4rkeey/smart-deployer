// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract M2Token is ERC20, ERC20Permit {
    constructor(address recipient) payable ERC20("M2Token", "M2T") ERC20Permit("M2Token") {
        _mint(recipient, 10000 * 10 ** decimals());
    }
}
