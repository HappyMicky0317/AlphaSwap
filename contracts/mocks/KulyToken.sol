// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KulyToken is ERC20 {
    constructor() ERC20("AlphaToken", "MTK") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }
}