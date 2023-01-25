const { assert } = require("chai");

const VaultBallot = artifacts.require("VaultBallot");

contract("VaultBallot", (accounts) => {
    const [owner, user1, user2] = accounts;

    it("should be able to create contract", async() => {
        const contractInstance = await createContractInstance();
        const tokenSymbol = await contractInstance.symbol();
        assert.equal(tokenSymbol, "btpUSDC");
    });

    it("should be able to mint token", async() => {
        const contractInstance = await createContractInstance();
        const mint = await mintToAccount(contractInstance, user1);
        assert.equal(mint.receipt.status, true);
        const balance = await contractInstance.balanceOf(user1);
        assert.equal(balance, 1);
    });


    it("should be able to set minTvl", async() => {
        const contractInstance = await createContractInstance();
        const token = await mintToAccount(contractInstance, user1);
        const tokenId = token.logs[0].args.tokenId;
        const setMinTvl = await contractInstance.setMinTvl(tokenId, 0xFFFF, {from: user1});
        assert.equal(setMinTvl.receipt.status, true);
        const minTvl = await contractInstance.minTvl(tokenId);
        assert.equal(minTvl, 0xFFFF);
    });

    it("should be able to veto a single pool", async() => {
        const contractInstance = await createContractInstance();
        const token = await mintToAccount(contractInstance, user1);
        const tokenId = token.logs[0].args.tokenId;
        const veto = await contractInstance.vetoPool(tokenId, [0x1], {from: user1});
        const vetoArray = await contractInstance.veto(tokenId);
        assert.equal(vetoArray, 0x1);
        const vetoReset = await contractInstance.vetoPool(tokenId, [0x2, 0x3], {from: user1});
        const vetoResetArray = await contractInstance.veto(tokenId);
        assert.equal(vetoResetArray.length, 2);
    });

    async function createContractInstance() {
        return await VaultBallot.new(
            "btpUSDC",
            "btpUSDC"
        );
    }

    async function mintToAccount(contractInstance, acct) {
        return await contractInstance.mint(acct, {from: owner});
    } 

});
