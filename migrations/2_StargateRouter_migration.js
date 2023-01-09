var stargateRouter = artifacts.require("../contracts/integrations/StargateRouter.sol");

module.exports = function(deployer) {
    /**
     * Deploys the STG router
     */
    deployer.deploy(
        stargateRouter,
        "0x53Bf833A5d6c4ddA888F69c22C88C9f356a41614", 
        0x3,
        0x3
    );
}