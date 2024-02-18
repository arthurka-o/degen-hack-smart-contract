# CryptoPension Contract Repository

To deploy dummy `ERC20` and `DepositTresure` contracts on Fuse Mainnet:

1. Create `.env` file with PRIVATE_KEY
2. Run `yarn`
3. Run `yarn hardhat run scripts/deploy.js --network fuse`

Local deployment will fail because the oracle address is hardcoded for the Fuse Mainnet.

Tests don't work, I was just curious how GitHub Copilot will generate them from comments (not really good result).
