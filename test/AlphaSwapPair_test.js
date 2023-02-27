const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Pair Contract", function () {


    let AlphaSwapPair;
    let pair;
    let KulyToken;
    let AlphaToken;
    let aToken;
    let kToken;
    let owner;
    let owner2;


    before(async function () {
        [owner, owner2, ...addrs] = await ethers.getSigners();
        AlphaSwapPair = await ethers.getContractFactory("AlphaSwapPair");
        pair = await AlphaSwapPair.deploy();
        await pair.deployed();

        KulyToken = await ethers.getContractFactory("KulyToken")
        kToken = await KulyToken.deploy();
        await kToken.deployed();

        AlphaToken = await ethers.getContractFactory("AlphaToken");
        aToken = await AlphaToken.deploy();
        await aToken.deployed();

    });



    describe("AlphaSwapPair Tests", function () {

        it("Should create the pool and deposit", async function () {
            await pair.initialize(aToken.address, kToken.address);

            await kToken.connect(owner).transfer(owner2.address, ethers.utils.parseEther("1000"))
            await aToken.connect(owner).transfer(owner2.address, ethers.utils.parseEther("1000"))

            const balOfkToken = await kToken.balanceOf(owner.address);
            const balOfaToken = await aToken.balanceOf(owner.address);

            const balOfkToken1 = await kToken.balanceOf(owner2.address);
            const balOfaToken1 = await aToken.balanceOf(owner2.address);

            await kToken.connect(owner).approve(pair.address, balOfkToken);
            await aToken.connect(owner).approve(pair.address, balOfaToken);

            await kToken.connect(owner2).approve(pair.address, balOfkToken1);
            await aToken.connect(owner2).approve(pair.address, balOfaToken1);


            await pair.addLiquidity(
                owner.address, 
                kToken.address,
                aToken.address,
                ethers.utils.parseEther('100'),
                ethers.utils.parseEther('10')
            );


            await pair.connect(owner2).addLiquidity(
                owner2.address,
                kToken.address,
                aToken.address, 
                ethers.utils.parseEther("500"),
                ethers.utils.parseEther("100")
            );

            // Check balances
            expect(await kToken.balanceOf(owner2.address)).to.equal(ethers.utils.parseEther("500"));
            expect(await aToken.balanceOf(owner2.address)).to.equal(ethers.utils.parseEther("900"));

            expect(await kToken.balanceOf(pair.address)).to.equal(ethers.utils.parseEther("600"));
            expect(await aToken.balanceOf(pair.address)).to.equal(ethers.utils.parseEther("110"));

            // LP Tokens
            expect(await pair.balanceOf(owner.address)).to.equal('31622776601683793319');
            expect(await pair.balanceOf(owner2.address)).to.equal('158113883008418966595');
        });

        it("Should swap tokens successfuly", async function () {

            await pair.connect(owner).swap(
                kToken.address,
                ethers.utils.parseEther("20.0"),
                owner.address
            );
            

            // // This is the best way I found to verify big numbers.
            expect((await aToken.balanceOf(pair.address)).toString()).to.include('106554730384242815628');
            expect((await kToken.balanceOf(pair.address)).toString()).to.include('620000000000000000000');
            expect(await pair.token0Fees()).to.equal('0');
            expect(await pair.token1Fees()).to.equal('600000000000000000');

            // Check if the constant is increasing after each swap
            expect(await pair.constLast()).to.be.above(ethers.utils.parseEther("66000"));

            // aToken = token0 || balance = 110;
            // kToken = token1 || balance = 600;

        });

        it("Should swap tokens again to verify", async function () {

            await pair.connect(owner2).swap(
                aToken.address,
                ethers.utils.parseEther("10.0"),
                owner2.address
            );


            expect((await aToken.balanceOf(pair.address)).toString()).to.include('116554730384242815628');
            expect((await kToken.balanceOf(pair.address)).toString()).to.include('568268771686772252819');

            expect((await kToken.balanceOf(owner2.address)).toString()).to.include('551731228313227747181');
            expect((await aToken.balanceOf(owner2.address)).toString()).to.include('890000000000000000000');
            

            expect(await pair.token0Fees()).to.equal('300000000000000000');
            expect(await pair.token1Fees()).to.equal('600000000000000000');

            expect((await pair.constLast()).toString()).to.equal("66234413469736577365200741176357220255332");

        });

        it("Should remove liquidity", async function () {
            await pair.connect(owner).removeLiquidity(owner.address);


            await pair.getBalance();


            expect((await pair.balance0()).toString()).to.equal("97905973522763965128")
            expect((await pair.balance1()).toString()).to.equal("477345768216888692368")

            expect((await pair.constLast()).toString()).to.equal("46735002144246128989118685181722671743104");

            expect(await pair.balanceOf(owner.address)).to.equal("0");

        });
    });
});