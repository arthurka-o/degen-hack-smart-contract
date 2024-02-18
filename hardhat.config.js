require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    fuse: {
      url: "https://rpc.fuse.io/",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};
