const { assert } = require("chai");

const Cooldown = artifacts.require("Cooldown");

contract("Cooldown", (accounts) => {
    const [owner] = accounts;

    it("should be able to set cooldown", async() => {
        const contractInstance = await createContractInstance();

        const setCooldown = await contractInstance.setCooldown(0x0, {from: owner});
        const isCooldownActiveFalse = await contractInstance.isCooldownActive();
        assert.equal(isCooldownActiveFalse, false);

        const setCooldownHigher = await contractInstance.setCooldown(0xFFFFFFF, {from: owner});
        const isCooldownActiveTrue = await contractInstance.isCooldownActive();
        assert.equal(isCooldownActiveTrue, true);
    });

    async function createContractInstance() {
        return await Cooldown.new();
    }



});
