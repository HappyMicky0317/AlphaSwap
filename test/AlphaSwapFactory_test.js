const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("AlphaSwapFactory", function () {

    let kToken;
    let aToken;
    let Factory;
    let factory;
    let owner;
    let owner2;

    before(async function () {
        [owner, owner2, ...addrs] = await ethers.getSigners();
        Factory = await ethers.getContractFactory("AlphaSwapFactory");
        factory = await Factory.deploy();
        await factory.deployed();

        const TOKEN = await ethers.getContractFactory("AlphaToken")
        aToken = await TOKEN.deploy();
        await aToken.deployed();

        const TOKENK = await ethers.getContractFactory("KulyToken");
        kToken = await TOKENK.deploy();
        await kToken.deployed();


    })

    describe("AlphaSwapFactory Tests", function () {


        it("Should create a pair and call the contract", async function () {
            await factory.createPair(
                aToken.address,
                kToken.address
            );

            const thing = await factory.pairAddress(aToken.address, kToken.address);
            const pair = await (await ethers.getContractFactory("AlphaSwapPair")).attach(thing);


            await expect(factory.createPair(kToken.address, aToken.address)
                ).to.be.revertedWith("this pair already exists")
            
            await expect(pair.initialize(aToken.address, kToken.address)
                ).to.be.revertedWith("Only AlphaSwapFactory can call this function");
        });

        it("Should try to deposit some tokens", async function () {
            const thing = await factory.pairAddress(aToken.address, kToken.address);
            const pair = await (await ethers.getContractFactory("AlphaSwapPair")).attach(thing);


            await aToken.approve(pair.address, ethers.utils.parseEther("1000"))
            await kToken.approve(pair.address, ethers.utils.parseEther("1000"))

            await pair.connect(owner).addLiquidity(
                owner.address,
                aToken.address,
                kToken.address,
                ethers.utils.parseEther("100"),
                ethers.utils.parseEther("100")
            );

            expect(await pair.balanceOf(owner.address)).to.be.above("0");
            expect(await pair.balance0()).to.equal(ethers.utils.parseEther("100"));
            expect(await pair.token0()).to.equal(aToken.address);
            expect(await pair.token1()).to.equal(kToken.address);
        });
    });
})
