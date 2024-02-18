const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("DepositTreasure", function () {
  // Deploy ERC20Test
  // Deploy DepositTreasure with ERC20Test address
  // Mint 1000 WBTC to the deployer
  // Approve DepositTreasure to spend 1000 WBTC
  // Deposit 1000 WBTC to DepositTreasure
  // Skip 5 years
  // Withdraw 1000 WBTC from DepositTreasure

  it("Should deposit and withdraw", async function () {
    async function deployContracts() {
      const ERC20Test = await ethers.getContractFactory("ERC20Test");
      const erc20Test = await ERC20Test.deploy("Wrapped BTC", "WBTC");
      await erc20Test.waitForDeployment();

      const DepositTreasure = await ethers.getContractFactory(
        "DepositTreasure"
      );
      const depositTreasure = await DepositTreasure.deploy(erc20Test.address);
      await depositTreasure.waitForDeployment();

      return { erc20Test, depositTreasure };
    }

    const { erc20Test, depositTreasure } = await loadFixture(deployContracts);

    await erc20Test.mint(await ethers.getSigners()[0].getAddress(), 1000);
    await erc20Test.approve(depositTreasure.address, 1000);
    await depositTreasure.deposit(1000);

    await time.increase(60 * 60 * 24 * 365 * 5);

    await depositTreasure.withdraw(0);

    expect(
      await erc20Test.balanceOf(await ethers.getSigners()[0].getAddress())
    ).to.equal(1000);
  });
});
