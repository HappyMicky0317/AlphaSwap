// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../AlphaSwapPair.sol";
import "../AlphaSwapFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AlphaSwapRouter is ReentrancyGuard {
    event ProvideLiquidity(address indexed _provider, address _pairAddress);
    event Swap(address indexed _user, address indexed _pair);
    event RemoveLiquidity(address indexed _provider, address indexed _pair);
    event CreatePair(address indexed _creator, address indexed _pairAddress);

    AlphaSwapFactory public factory;

    constructor(address _factory) {
        factory = AlphaSwapFactory(_factory);
    }

    function getAddress(address _token0, address _token1)
        public
        view
        returns (bool, address)
    {
        (bool exists, address pairAddress) = factory.checkIfPairExists(
            _token0,
            _token1
        );
        return (exists, pairAddress);
    }

    function swap(
        address _tokenToSwap,
        address _tokenToReceive,
        uint _amountToSwap
    ) public {
        (bool exists, address pairAddress) = getAddress(
            _tokenToSwap,
            _tokenToReceive
        );
        require(exists, "This pair doesn't exist");
        emit Swap(msg.sender, pairAddress);
        AlphaSwapPair(pairAddress).swap(
            _tokenToSwap,
            _amountToSwap,
            msg.sender
        );
    }

    function provideLiquidity(
        address _token0,
        address _token1,
        uint _amount0,
        uint _amount1
    ) public {
        // before calling this function the user will ahve to approve the pair contract so it can transfer from.
        (bool exists, address pairAddress) = getAddress(_token0, _token1);
        require(exists, "This pair doesn't exist you need to create it");
        AlphaSwapPair(pairAddress).addLiquidity(
            msg.sender,
            _token1,
            _token0,
            _amount1,
            _amount0
        );
        emit ProvideLiquidity(msg.sender, pairAddress);
    }

    function remove(address _token0, address _token1) public {
        (bool exists, address pairAddress) = getAddress(_token0, _token1);
        require(exists, "This pair doesn't exist");
        emit RemoveLiquidity(msg.sender, pairAddress);
        AlphaSwapPair(pairAddress).removeLiquidity(msg.sender);
    }

    function createPair(address _token0, address _token1)
        public
        nonReentrant
        returns (address)
    {
        require(
            _token0 != address(0) && _token1 != address(0),
            "token can't be a zero address"
        );
        (bool exists, ) = factory.checkIfPairExists(_token0, _token1);
        require(!exists, "This pair alredy exists");
        address pairAddress = factory.createPair(_token0, _token1);
        emit CreatePair(msg.sender, pairAddress);
        return pairAddress;
    }
}
