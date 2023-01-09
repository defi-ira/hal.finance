var topYieldSwap = artifacts.require("../contracts/instruments/TopYieldSwap.sol");

module.exports = function(deployer) {
    const usdc_testnet = 0xE9eAf0FD93B77AEE1c012E91B4a7653553949b7B;
    deployer.deploy(topYieldSwap, 0x1, usdc_testnet);
}