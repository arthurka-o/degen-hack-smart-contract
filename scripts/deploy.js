const hre = require("hardhat");

async function main() {
  // Deploy ERC20Test
  const erc20Test = await hre.ethers.deployContract(
    "ERC20Test",
    ["Wrapped BTC", "WBTC"],
    {}
  );

  const erc20TestAddress = await erc20Test.getAddress();

  await erc20Test.waitForDeployment();
  console.log("ERC20Test deployed to:", erc20TestAddress);

  // Deploy DepositTreasure with ERC20Test address
  const depositTreasure = await hre.ethers.deployContract(
    "DepositTreasure",
    [erc20TestAddress],
    {}
  );
  await depositTreasure.waitForDeployment();

  const depositTreasureAddress = await depositTreasure.getAddress();

  console.log("DepositTreasure deployed to:", depositTreasureAddress);

  const deployerAddress = (await hre.ethers.getSigners())[0].address;

  // Mint 1000 WBTC to the deployer
  await erc20Test.mint(deployerAddress, ethers.parseEther("1000"));
  // Approve DepositTreasure to spend 1000 WBTC
  await erc20Test.approve(depositTreasureAddress, ethers.parseEther("1000"));

  await new Promise((r) => setTimeout(r, 5000));

  // Deposit 1000 WBTC to DepositTreasure
  await depositTreasure.deposit(ethers.parseEther("1000"));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
