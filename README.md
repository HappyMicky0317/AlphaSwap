# AlphaSwap - AMM Swap Project For Resume

## Description

This is a decentralized swap based on AMM algorithm. It will always book your order no matter how low the liquidity is. This is possible thanks to the AMM algorithm. 

This project is divided into three separate contracts: AlphaSwapFactory.sol, AlphaSwapPair.sol, AlphaSwapRouter.sol

## Outline

To use any functions of this project, the users should always use the AlphaSwapRouter.sol. Through this router, the user can call any function that he needs.

e.g. The user wants to add liquidity to pair aToken and bToken. He will have to call the `provideLiquidity()` function to do this. This function will check if the pair exists and if it does, it will add the liquidity, but in this case, for the sake of the example, the contract for this pair doesn't exist.

So he calls the `createPair()` function. This will call the AlphaSwapFactory.sol and create an AlphaSwapPair specifically for these two tokens. 

After the contract is created, the user will call the `provideLiquidity()` function. The address will be stored in the contract, so the user doesn't have to do anything manually. 

After the deposit, the AlphaSwapPair will mint lp tokens which will be sent to the user. 

To remove liquidity from the pool, the user will have to call the `remove()` function through the router. This function will calculate how much of the pool he owns. After that, the AlphaSwapPair will burn the lp tokens and send both tokens he was providing back to the caller.



### AlphaSwapFactory.sol

This contract will create a separate AlphaSwapPair for each new pair. 


### AlphaSwapPair.sol

This is the contract where all the tokens will be stored and swapped. This contract is also ERC20 contract so for every provider it will mint lp tokens.

### AlphaSwapRouter.sol

This is the only contract that the user will interact with. It will route all the orders to the proper contracts.

# Instalation

This project uses HardHat, so to install HardHat, run:

```bash
npm init --yes
npm install --save-dev hardhat
```

The clone this repository and run:

```bash
npm install
```

This will install all the dependencies.

This project has a lot of tests if you want to run them on your own type into the terminal.

```bash
npx hardhat test
```
This will run all the tests on your local machine.

The result should look like this

![test screenshot](https://github.com/Kuly14/AlphaSwap/blob/93ae2b19469e7cc88ae5401f7f3768fdae1badf6/Screenshot%20from%202022-02-20%2014-21-19.png)


Thanks for reading. This was one of my first projects in this scale all the code combined it is almost 750 lines of code.

The development was pretty smooth, but in the future, I would love to make Version 2 also introduce routing so there won't have to be a separate contract for every pair but it will be able to hop from one to another to swap user’s tokens even if there is not that exact pool.


I took a lot of inspiration from Uniswap V2, mainly the math but I wrote all the code myself.


