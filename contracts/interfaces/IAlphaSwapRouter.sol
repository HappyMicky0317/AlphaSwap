// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AlphaSwapRouter {

    event ProvideLiquidity (address indexed _provider, address _pairAddress);
    event Swap (address indexed _user, address indexed _pair);
    event RemoveLiquidity(address indexed _provider, address indexed _pair);
    event CreatePair(address indexed _creator, address indexed _pairAddress);

    function getAddress(address _token0, address _token1) external view returns (bool, address);
    function swap(address _tokenToSwap, address _tokenToReceive,  uint _amountToSwap) external;
    function provideLiquidity(address _token0, address _token1, uint _amount0, uint _amount1) external;
    function remove(address _token0, address _token1) external;
    function createPair(address _token0, address _token1) external returns(address);
}