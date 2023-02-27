async function main() {

  const Factory = await hre.ethers.getContractFactory("AlphaSwapFactory");
  const factory = await Factory.deploy();
  await factory.deployed();
  console.log("Factory deployed to: ", factory.address);


  const Router = await hre.ethers.getContractFactory("AlphaSwapRouter")
  const router = await Router.deploy(factory.address);
  await router.deployed();
  console.log("Router deployed to: ", router.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
