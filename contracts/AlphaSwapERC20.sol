// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AlphaSwapERC20 is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("AlphaSwap", "APS") {}

    function mint(address to, uint256 amount) internal {
        _mint(to, amount);
    }
}