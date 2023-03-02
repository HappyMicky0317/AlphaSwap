// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "./libraries/SMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AlphaSwapERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract AlphaSwapPair is AlphaSwapERC20, ReentrancyGuard {
    address public token0;
    address public token1;
    address public factory;

    uint public balance0;
    uint public balance1;
    uint public token0Fees;
    uint public token1Fees;

    uint256 public constLast;

    event Swap(address _token0, address _token1, uint _amount0, uint _amount1);
    event Burn(address _owner, uint _amount);
    event Mint(address indexed _owner, uint _amountOfLpTokens);

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {
        require(
            msg.sender == factory,
            "Only AlphaSwapFactory can call this function"
        );
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(
        address _provider,
        address _token1,
        address _token0,
        uint _amount1,
        uint _amount0
    ) external nonReentrant {
        require(_amount1 > 0 && _amount0 > 0, "You need to send some tokens");
        require(
            _token0 == token0 || _token0 == token1,
            "You are trying to send wrong tokens"
        );
        require(
            _token1 == token0 || _token1 == token1,
            "You are trying to send wrong tokens"
        );
        if (balance0 == 0 && balance1 == 0) {
            constLast = _amount0 * _amount1;
            balance0 = _amount0;
            balance1 = _amount1;

            // This function will mint initial LP tokens
            _initialMint(_provider);

            // Approve function will have to be called before. That will have to be from the front end
            require(
                IERC20(_token0).transferFrom(
                    _provider,
                    address(this),
                    _amount0
                ),
                "Payment of token0 didn't go through"
            );
            require(
                IERC20(_token1).transferFrom(
                    _provider,
                    address(this),
                    _amount1
                ),
                "Payment of token1 didn't go through"
            );
        } else {
            _mintForProvider(_provider, _amount0, _amount1);

            balance0 += _amount0;
            balance1 += _amount1;
            constLast = balance0 * balance1;

            require(
                IERC20(_token0).transferFrom(
                    _provider,
                    address(this),
                    _amount0
                ),
                "Payment of token0 didn't go through"
            );

            require(
                IERC20(_token1).transferFrom(
                    _provider,
                    address(this),
                    _amount1
                ),
                "Payment of token1 didn't go through"
            );
        }
    }

    function _initialMint(address _provider) private {
        uint liq = SMath.sqrt(balance0 * balance1);
        _mint(_provider, liq);
        emit Mint(_provider, liq);
    }

    function _mintForProvider(
        address _provider,
        uint _amount0,
        uint _amount1
    ) private {
        uint totalSup = totalSupply();
        uint liq = SMath.min(
            (_amount0 * totalSup) / balance0,
            (_amount1 * totalSup) / balance1
        );
        _mint(_provider, liq);
        emit Mint(_provider, liq);
    }

    function swap(
        address _tokenToSwap,
        uint _amountToSwap,
        address _sender
    ) external nonReentrant {
        require(_amountToSwap > 0, "amount can't be 0");
        require(_tokenToSwap == token0 || _tokenToSwap == token1, "wrong pair");
        uint shouldBeInPool;
        uint amountToSendToUser;
        address tokenToSend;
        uint feeToPay = calculateFee(_amountToSwap);
        uint amountToSwap = _amountToSwap - feeToPay;

        if (_tokenToSwap == token0) {
            uint calculation = balance0 + amountToSwap;
            shouldBeInPool = constLast / calculation;
            amountToSendToUser = balance1 - shouldBeInPool;
            tokenToSend = token1;
            balance0 = balance0 + _amountToSwap;
            balance1 = shouldBeInPool;
            token0Fees += feeToPay;
        } else {
            uint calc = balance1 + amountToSwap;
            shouldBeInPool = constLast / calc;
            amountToSendToUser = balance0 - shouldBeInPool;
            tokenToSend = token0;
            balance1 = balance1 + _amountToSwap;
            balance0 = shouldBeInPool;
            token1Fees += feeToPay;
        }
        // Update the Constant or Invariant
        constLast = balance0 * balance1;

        emit Swap(token0, token1, _amountToSwap, amountToSendToUser);

        // Send funds
        require(
            IERC20(_tokenToSwap).transferFrom(
                _sender,
                address(this),
                _amountToSwap
            ),
            "transfer didn't go through"
        );
        require(
            IERC20(tokenToSend).transfer(_sender, amountToSendToUser),
            "transfer didn't go through"
        );
    }

    function calculateFee(uint _amountIn) internal pure returns (uint fee) {
        fee = (_amountIn / 10000) * 300;
    }

    function getBalance()
        public
        view
        returns (
            uint,
            uint,
            address,
            address
        )
    {
        return (balance0, balance1, token0, token1);
    }

    function removeLiquidity(address _provider) external nonReentrant {
        require(balanceOf(_provider) > 0, "you don't own any lp tokens");
        uint lpBalance = balanceOf(_provider);
        uint totalSup = totalSupply();
        uint x = (lpBalance * 100) / totalSup;
        uint y = (x * balance0) / 100;
        uint z = (x * balance1) / 100;

        // Update the balances
        balance0 = balance0 - y;
        balance1 = balance1 - z;

        // Update the constant
        constLast = balance0 * balance1;

        _burn(_provider, lpBalance);
        emit Burn(_provider, lpBalance);
        require(
            IERC20(token0).transfer(_provider, y),
            "transfer didn't go through"
        );
        require(
            IERC20(token1).transfer(_provider, z),
            "transfer didn't go through"
        );
    }
}
