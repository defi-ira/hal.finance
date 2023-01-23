const { assert } = require("chai");

const ParamToken = artifacts.require("ParamToken");

contract("ParamToken", (accounts) => {
    const [owner] = accounts;

    it("should be able to create token", async() => {
        const tokenInstance = await createTokenInstance(0xFFFF);
        const tokenSymbol = await tokenInstance.symbol();
        assert.equal(tokenSymbol, "btpUSDC");
        const vetoNew = await tokenInstance.vetoNew();
        assert.equal(vetoNew, false);
    });

    it("should be able to set minTvl", async() => {
        const tokenInstance = await createTokenInstance(0xFFFF);
        const setMinTvl = await tokenInstance.setMinTvl(0xAAAA);
        const minTvl = await tokenInstance.minTvl();
        assert.equal(minTvl, 0xAAAA);
    });

    it("should be able to set vetoNew", async() => {
        const tokenInstance = await createTokenInstance(0xFFFF);
        const setVetoNew = await tokenInstance.setVetoNew(true);
        const vetoNew = await tokenInstance.vetoNew();
        assert.equal(vetoNew, true);
    });

    it("should be able to veto a single pool", async() => {
        const tokenInstance = await createTokenInstance(0xFFFF);
        const vetoSinglePool = await tokenInstance.vetoPool([0x1], 1, true);
        const poolVeto = await tokenInstance.veto(0x1);
        assert.equal(poolVeto, true);
    });

    it("should be able to veto a many pools", async() => {
        const tokenInstance = await createTokenInstance(0xFFFF);
        const vetoSinglePool = await tokenInstance.vetoPool([0x1, 0x2, 0x3], 3, true);
        const poolVeto1 = await tokenInstance.veto(0x1);
        assert.equal(poolVeto1, true);
        const poolVeto2 = await tokenInstance.veto(0x2);
        assert.equal(poolVeto2, true);
        const poolVeto3 = await tokenInstance.veto(0x3);
        assert.equal(poolVeto3, true);
    });



    async function createTokenInstance(minTvl) {
        return await ParamToken.new(
            minTvl,
            false,
            "btpUSDC",
            "btpUSDC"
        );
    }

});
