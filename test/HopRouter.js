const { assert } = require("chai");

const HopRouter = artifacts.require("HopRouter");

contract("HopRouter", () => {

    it("should be able to add token pool", async() => {
        const routerInstance = await HopRouter.deployed();
        const addTokenPool = await routerInstance.addTokenPool("USDC", 0x0);
        const getTokenPool = await routerInstance.getTokenPool("USDC");
        assert.equal(getTokenPool, 0x0);
    });

    it("should be able to remove a token pool", async() => {
        const routerInstance = await HopRouter.deployed();
        const addTokenPool = await routerInstance.addTokenPool("USDC", 0x1);
        const removeTokenPool = await routerInstance.removeTokenPool("USDC");
        const getTokenPool = await routerInstance.getTokenPool("USDC");
        assert.notEqual(getTokenPool, 0x1);
    });

});
