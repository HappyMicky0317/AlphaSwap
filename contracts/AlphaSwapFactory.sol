// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./AlphaSwapPair.sol";
// import "hardhat/console.sol";

contract AlphaSwapFactory {
    event PairCreated(address indexed _addressOfPair);

    mapping(address => mapping(address => address)) public pairAddress;
    AlphaSwapPair[] public alphaSwapArray;

    function checkIfPairExists(address _token0, address _token1)
        public
        view
        returns (bool, address)
    {
        if (
            pairAddress[_token0][_token1] == address(0) &&
            pairAddress[_token1][_token0] == address(0)
        ) {
            address addrOfPair = pairAddress[_token0][_token1];
            return (false, addrOfPair);
        } else {
            address addr = pairAddress[_token0][_token1];
            return (true, addr);
        }
    }

    function createPair(address _token0, address _token1)
        external
        returns (address)
    {
        require(
            _token0 != address(0) && _token1 != address(0),
            "toknes can't equal to the zero address"
        );

        (bool exists, ) = checkIfPairExists(_token0, _token1);
        require(!exists, "this pair already exists");
        AlphaSwapPair pair = new AlphaSwapPair();
        alphaSwapArray.push(pair);
        uint index = alphaSwapArray.length - 1;
        address lastAddress = address(alphaSwapArray[index]);
        pairAddress[_token0][_token1] = lastAddress;
        pairAddress[_token1][_token0] = lastAddress;
        emit PairCreated(lastAddress);
        AlphaSwapPair(lastAddress).initialize(_token0, _token1);
        return lastAddress;
    }
}
