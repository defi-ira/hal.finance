const { assert } = require("chai");

const YieldVault = artifacts.require("YieldVault");
const VaultBallot = artifacts.require("VaultBallot");
const ERC20 = artifacts.require("ERC20PresetMinterPauser");

contract("YieldVault", (accounts) => {
    const [owner, user1, user2] = accounts;


    it("should be able to create contract", async() => {
        const vaultBallot = await createVaultBallot();
        const erc20 = await createERC20Instance();
        const contractInstance = await initContractInstance(vaultBallot, erc20);
        const ballotBalance = await contractInstance.ballotBalance(0x0);
        assert.notEqual(ballotBalance, 0x1000);
    });

    it("should be able to mint ballot", async() => {
        const vaultBallot = await createVaultBallot();
        const erc20 = await createERC20Instance();
        const contractInstance = await initContractInstance(vaultBallot, erc20);

        const mintPoolToken = await mintERC20ToAccount(erc20, 0x5FFF, user1, {from: owner});
        const approve = await erc20.approve(contractInstance.address, 0x5FFF, {from: user1});
        const depositToVault = await contractInstance.deposit(0x5FFF, {from: user1});
        
        const mintBallot = await contractInstance.mintBallot({from: user1});
        const minted = await contractInstance.minted(user1);

        assert.equal(minted, true);
    });

    async function initContractInstance(vaultBallot, erc20) {
        yieldVault = await YieldVault.new(
            erc20.address,
            vaultBallot.address,
            0x20,
            {from: owner}
        );
        const resetOwner = vaultBallot.transferOwnership(yieldVault.address);
        return yieldVault;
    }

    async function createERC20Instance() {
        return await ERC20.new("USDI", "USDI", {from: owner});
    }

    async function createVaultBallot() {
        return await VaultBallot.new("banUSDI", "banUSDI", {from: owner});
    }

    async function mintERC20ToAccount(erc20, amount, address) {
        return await erc20.mint(address, amount);
    }

});
