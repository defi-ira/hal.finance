const { assert } = require("chai");

const TopYieldSwap = artifacts.require("TopYieldSwap");
const ERC20 = artifacts.require("ERC20PresetMinterPauser");

contract("TopYieldSwap", (accounts) => {
    const [owner, user1, user2] = accounts;
    const txParams = { from: owner };

    it("should be able to add yield pool", async() => {
        const contractInstance = await createContractInstance1();
        const integration = await addYieldPool1(contractInstance);
        assert.equal(integration.receipt.status, true);

        const yieldPool = await contractInstance.getYieldPool(0x1);
        assert.equal(yieldPool.project, "HOP");
    });

    it("should be able to remove a yield pool", async() => {
        const contractInstance = await createContractInstance1();
        const integration = await addYieldPool1(contractInstance);
        assert.equal(integration.receipt.status, true);

        const yieldPool = await contractInstance.getYieldPool(0x1);
        assert.equal(yieldPool.project, "HOP");
        const removeYieldPool = await contractInstance.removeYieldPool(0x1);
        assert.equal(removeYieldPool.receipt.status, true);
        const removedYieldPool = await contractInstance.getYieldPool(0x1);
        assert.notEqual(removedYieldPool.id, 0x1);        
    });

    it("should be able to set YieldPool current yield", async() => {
        const contractInstance = await createContractInstance1();
        const integration = await addYieldPool1(contractInstance);
        assert.equal(integration.receipt.status, true);

        const setYield1 = await contractInstance.setYieldPoolYield(0x1, 0xFF);
        assert.equal(setYield1.receipt.status, true);
        const yieldPool1 = await contractInstance.getYieldPool(0x1);
        assert.equal(yieldPool1.currentYield, 0xFF);

        const setYield2 = await contractInstance.setYieldPoolYield(0x1, 0xCC);
        assert.equal(setYield2.receipt.status, true);
        const yieldPool2 = await contractInstance.getYieldPool(0x1);
        assert.equal(yieldPool2.currentYield, 0xCC);
    });

    it("should be able to deposit ERC20 tokens to TopYieldSwap", async() => {
        const contractInstance = await createContractInstance1();

        // ERC20PresetMinterPauser models the constraints of fiat-backed stablecoins
        const ERC20Instance = await createERC20Instance();

        const mint = await ERC20Instance.mint(user1, 0x4FFFF);
        assert.equal(mint.receipt.status, true);
        const transfer = await ERC20Instance.transfer(contractInstance.address, 0xFFFF, {from: user1});
        assert.equal(transfer.receipt.status, true);
        const despositBalance = await ERC20Instance.balanceOf(contractInstance.address);
        assert.equal(despositBalance, 0xFFFF);
    });

    it("should be able to withdrawal ERC20 token from TopYieldSwap", async() => {
        const ERC20Instance = await createERC20Instance();
        const contractInstance = await createContractInstance2(ERC20Instance);
        // ERC20PresetMinterPauser models the constraints of fiat-backed stablecoins

        const mint = await ERC20Instance.mint(user1, 0x4FFFF);
        const transfer = await ERC20Instance.transfer(contractInstance.address, 0xFFFF, {from: user1});
        
        const approve = await contractInstance.approve(contractInstance.address, 0xFFFF, {from: user1});
        const withdrawal = await contractInstance.withdrawal(user1, 0xFFFF, {from: owner});
        assert.equal(withdrawal.receipt.status, true);

        const balance = await ERC20Instance.balanceOf(user1);
        assert.equal(balance, 0x4FFFF);
    });

    it("should select the pool with the top yield", async() => {
        const contractInstance = await createContractInstance1();
        const hopIntegration = await addYieldPool1(contractInstance);
        const stgIntegration = await addYieldPool2(contractInstance);
        const acxIntegration = await addYieldPool3(contractInstance);

        const setYield1 = await contractInstance.setYieldPoolYield(0x1, 0x9);
        const setYield2 = await contractInstance.setYieldPoolYield(0x2, 0xFF);
        const setYield3 = await contractInstance.setYieldPoolYield(0x3, 0x7);

        const selectPool = await contractInstance.selectPool([0x1, 0x2, 0x3], 3);
        assert.equal(selectPool.id, 0x2);
    });

    // 1.8.23 TODO: Mock yield pool interfacing contracts and test deposit, 
    // withdrawal, and rebalance - make FSM in Miro


    // HELPERS //

    async function createContractInstance1() {
        return await TopYieldSwap.new(
            0x1,    // chain id
            "0xff970a61a04b1ca14834a43f5de4533ebddb5cc8", // token address,
            txParams 
        );
    }

    async function createContractInstance2(erc20) {
        return await TopYieldSwap.new(
            0x1,    // chain id
            erc20.address, // token address,
            txParams 
        );
    }

    async function addYieldPool1(contractInstance) {
        return await contractInstance.addYieldPool(
            0x1,    // id 
            "HOP",  // project
            "USDC", // token
            "0x10541b07d8Ad2647Dc6cD67abd4c03575dade261"
        );
    }

    async function addYieldPool2(contractInstance) {
        return await contractInstance.addYieldPool(
            0x2,    // id 
            "STG",  // project
            "USDC", // token
            "0x53Bf833A5d6c4ddA888F69c22C88C9f356a41614"
        );
    }

    async function addYieldPool3(contractInstance) {
        return await contractInstance.addYieldPool(
            0x3,    // id 
            "ACX",  // project
            "USDC", // token
            "0xc186fA914353c44b2E33eBE05f21846F1048bEda"
        );
    }

    async function createERC20Instance() {
        return await ERC20.new("USDI", "USDI");
    }

    async function mintERC20ToAccount(erc20, address) {
        return await erc20.mint(0x4FFFF, address);
    }

});