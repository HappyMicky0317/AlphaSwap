// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AlphaSwapPair {
    event Swap(address _token0, address _token1, uint _amount0, uint _amount1);
    event Burn(address _owner, uint _amount);
    event Mint(address indexed _owner, uint _amountOfLpTokens);

    function initialize(address _token0, address _token1) external;
    function addLiquidity(address _provider, address _token1, address _token0, uint _amount1, uint _amount0) external;
    function swap(address _tokenToSwap, uint _amountToSwap, address _sender) external;
    function getBalance() external view returns (uint, uint, address, address);
    function removeLiquidity(address _provider) external;
}