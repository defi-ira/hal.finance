var topYieldSwap = artifacts.require("../contracts/instruments/TopYieldSwap.sol");

module.exports = function(deployer) {
    /**
     * Deploys the TopYieldSwap instrument with the chain id 1 and the address of USDC on Arbitrum
     */
    deployer.deploy(topYieldSwap, 0x1, "0xff970a61a04b1ca14834a43f5de4533ebddb5cc8");
}