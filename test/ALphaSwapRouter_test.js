const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AlphaSwapRouter", function (){

    let Factory;
    let factory;
    let Router;
    let router;
    let kToken;
    let aToken;
    let owner;
    let owner2;



    before(async function () {
        [owner, owner2, ...addrs] = await ethers.getSigners();
        Factory = await ethers.getContractFactory("AlphaSwapFactory")
        factory = await Factory.deploy();
        await factory.deployed();

        Router = await ethers.getContractFactory("AlphaSwapRouter")
        router = await Router.deploy(factory.address);
        await router.deployed();

        const TOKEN = await ethers.getContractFactory("KulyToken")
        kToken = await TOKEN.deploy();
        await kToken.deployed();

        const TOKENA = await ethers.getContractFactory("AlphaToken")
        aToken = await TOKENA.deploy();
        await aToken.deployed();
    })

    describe("Deploy contracts", function () {

        it("Should deploy contracts succesfuly", async function () {

            await router.createPair(kToken.address, aToken.address);

            expect(await factory.pairAddress(
                kToken.address, aToken.address)).to.not.equal('0x0000000000000000000000000000000000000000');

        })

        it("Should revert when I will try to create a same pair again", async function () {
            await expect(router.createPair(aToken.address, kToken.address)).to.be.revertedWith("This pair alredy exists");
        })

        it("Should revert when trying to init the pair", async function () {

            const addrOfPair = await factory.pairAddress(kToken.address, aToken.address);
            const pairContract = await (await ethers.getContractFactory("AlphaSwapPair")).attach(addrOfPair);

            await expect(pairContract.initialize(aToken.address, kToken.address)
                ).to.be.revertedWith("Only AlphaSwapFactory can call this function")

        })

        it("Should add liquidity through router", async function () {
            
            const addr = await factory.pairAddress(kToken.address, aToken.address);
            const contr = await (await ethers.getContractFactory("AlphaSwapPair")).attach(addr);

            const balOfkToken = await kToken.balanceOf(owner.address);
            const balOfaToken = await aToken.balanceOf(owner.address);

            await kToken.connect(owner).approve(contr.address, balOfkToken);
            await aToken.connect(owner).approve(contr.address, balOfaToken);

            await router.connect(owner).provideLiquidity(
                kToken.address, 
                aToken.address, 
                ethers.utils.parseEther("10"),
                ethers.utils.parseEther("10")
            );

            expect((await contr.balance0()).toString()).to.equal(ethers.utils.parseEther("10"));
            expect((await contr.balance1()).toString()).to.equal(ethers.utils.parseEther("10"));
            expect(await contr.balanceOf(owner.address)).to.equal(ethers.utils.parseEther("10"));
            expect(await contr.constLast()).to.equal("100000000000000000000000000000000000000");
        });

        it("Should swap tokens", async function () {

            const addr = await factory.pairAddress(kToken.address, aToken.address);
            const contr = await (await ethers.getContractFactory("AlphaSwapPair")).attach(addr);

            await router.connect(owner).swap(kToken.address, aToken.address, ethers.utils.parseEther("1.0"));

            expect((await contr.balance0()).toString()).to.equal(ethers.utils.parseEther("11"));
            expect((await contr.balance1()).toString()).to.equal("9115770282588878760");
            expect((await contr.constLast()).toString()).to.equal("100273473108477666360000000000000000000")
        });

        it("Should remove liquidity and burn lp tokens", async function () {
            const addr = await factory.pairAddress(kToken.address, aToken.address);
            const contr = await (await ethers.getContractFactory("AlphaSwapPair")).attach(addr);

            await router.remove(aToken.address, kToken.address);

            expect(await contr.balanceOf(owner.address)).to.equal("0");
            expect(await contr.balance0()).to.equal("0");
            expect(await contr.balance1()).to.equal("0");
            expect(await kToken.balanceOf(contr.address)).to.equal("0");
            expect(await aToken.balanceOf(contr.address)).to.equal("0");

        });
    });

















})