var topYieldSwap = artifacts.require("../contracts/instruments/TopYieldSwap.sol");
var vaultBallot = artifacts.require("../contracts/libs/VaultBallot.sol");
var stargateRouter = artifacts.require("../contracts/integrations/StargateRouter.sol");
var hopRouter = artifacts.require("../contracts/integrations/HopRouter.sol");

module.exports = async function(deployer) {
    /**
     * Deploys the TopYieldSwap instrument with the chain id 1 and the address of USDC on Arbitrum
     */
    await deployer.deploy(vaultBallot, "banUSDI", "banUSDI");
    const vaultBallotInstance = await vaultBallot.deployed();

    await deployer.deploy(
        topYieldSwap, 
        0x1,
        "0xff970a61a04b1ca14834a43f5de4533ebddb5cc8",
        vaultBallotInstance.address,
        0x20,
    );
    const instance = await topYieldSwap.deployed();

    await deployer.deploy(
        stargateRouter,
        "0x53Bf833A5d6c4ddA888F69c22C88C9f356a41614", 
        0x2,
        0x2
    );
    const stg = await stargateRouter.deployed();


    await deployer.deploy(
        hopRouter,
        "0x10541b07d8Ad2647Dc6cD67abd4c03575dade261",
        0x2,
        0x2, 
        0x0
    );
    const hop = await hopRouter.deployed();

    const stgYieldPool = await instance.addYieldPool(0x1, "STG", "USDC", stg.address, "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
    const addTokenToStg = await stg.addTokenPool("USDC", 0x1);

    // const hopYieldPool = await instance.addYieldPool(0x2, "HOP", "USDC", hop.address);
    // const addTokenToHop = await hop.addTokenPool("USDC", 0x0);
}