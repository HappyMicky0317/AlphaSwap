// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AlphaSwapFactory {
    function checkIfPairExists(address _token0, address _token1) external view returns (bool, address);
    function createPair(address _token0, address _token1) external returns(address); 
}