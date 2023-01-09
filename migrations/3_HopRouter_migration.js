var hopRouter = artifacts.require("../contracts/integrations/HopRouter.sol");

module.exports = function(deployer) {
    /**
     * Deploys the HOP Router
     */
    deployer.deploy(
        hopRouter,
        "0x10541b07d8Ad2647Dc6cD67abd4c03575dade261",
        0x2,
        0x2, 
        0x0     // token index of USDC on Arb HOP is 0
    );
}