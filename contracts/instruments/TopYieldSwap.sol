// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "../interfaces/IIntegration.sol";

contract TopYieldSwap is Ownable {

    uint16 private chainId;
    address private tokenAddr;
    uint16 private activePool;

    struct YieldPool {
        uint16 id;              // unique pool id
        string project;         // project name
        string token;           // ERC20 name
        address addr;           // pool address
        uint16 currentYield;    // pool yield
    }

    event YieldPoolAdded(string _project, string _token, address _addr);
    event YieldPoolRemoved(uint16 _id);

    event EnterPool(uint16 _poolId, uint256 _amount, uint256 _balance);
    event ExitPool(uint16 _poolId, uint256 _amount);

    mapping (uint16 => YieldPool) private yieldPools;
    mapping (uint16 => IIntegration) private integrations;

    constructor(uint16 _chainId, address _tokenAddr) {
        chainId = _chainId;
        tokenAddr = _tokenAddr;
        activePool = 0x0;
    }

    /**
     * @dev rebalance will exclusively: do nothing, exit current pool, or enter top pool
     * should therefore be called again if exit current pool was the performed action.
     */
    function rebalance(uint16[] calldata _poolIds, uint16 _length) public onlyOwner returns(uint16 _yield) {
        uint256 tokenBalance = getTokenBalance();
        if (shouldSwap(_poolIds, _length) && tokenBalance > 0) {
            exitCurrentPool();
            return 0x0;
        } else if (shouldSwap(_poolIds, _length) && tokenBalance == 0) {
            enterPool(selectPool(_poolIds, _length));
            return yieldPools[activePool].currentYield;
        }
    }

    function getCurrentYield() public view returns (uint16 _apy) {
        return yieldPools[activePool].currentYield;
    }

    function approve(address spender, uint256 _amount) public gtZero(_amount) {
        IERC20 tokenContract = IERC20(tokenAddr);
        tokenContract.approve(spender, _amount);
    }

    function deposit(uint256 _amount) payable public gtZero(_amount) {
        IERC20 tokenContract = IERC20(tokenAddr);
        tokenContract.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawal(address _to, uint256 _amount) public gtZero(_amount) {
        IERC20 tokenContract = IERC20(tokenAddr);
        tokenContract.transferFrom(address(this), _to, _amount);
    }

    function getTokenBalance() public view returns (uint256 tokenBalance) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    function enterPool(YieldPool memory _yieldPool) internal {
        IIntegration integration = IIntegration(_yieldPool.addr);
        integration.addLiquidity(_yieldPool.token, address(this).balance, address(this));
        activePool = _yieldPool.id;
    }

    function exitCurrentPool() internal {
        YieldPool memory currentPool = yieldPools[activePool];
        IIntegration integration = IIntegration(yieldPools[activePool].addr);
        uint256 balance = IERC20(currentPool.addr).balanceOf(address(this));
        integration.removeLiquidity(currentPool.token, balance, address(this));
        activePool = 0x0;
    }

    function shouldSwap(uint16[] calldata _poolIds, uint16 _length) internal view returns(bool _bool) {
        YieldPool memory topPool = selectPool(_poolIds, _length);
        if (topPool.id == activePool) {
            return false;
        }
        return true;
    }

    function selectPool(uint16[] calldata _poolIds, uint16 _length) public view returns (YieldPool memory yieldPool) {
        uint16 _topYield = 0x0;
        uint16 _poolId = 0;
        for (uint16 i = 0; i < _length; i++) {
            if (yieldPools[_poolIds[i]].currentYield >= _topYield) {
                _topYield = yieldPools[_poolIds[i]].currentYield;
                _poolId = i;
            }
        }
        return yieldPools[_poolId];
    }

    function addYieldPool(
        uint16 id,
        string memory _project,
        string memory _token,
        address _addr
    ) public onlyOwner returns(IIntegration integration) {
        yieldPools[id] = YieldPool(id, _project, _token, _addr, 0x0);
        integrations[id] = IIntegration(_addr);
        emit YieldPoolAdded(_project, _token, _addr);
        return integrations[id];
    }

    function removeYieldPool(
        uint16 _id
    ) public onlyOwner {
        delete yieldPools[_id];
        delete integrations[_id];
        emit YieldPoolRemoved(_id);
    }

    function setYieldPoolYield(uint16 _id, uint16 _yield) public onlyOwner {
        yieldPools[_id].currentYield = _yield; 
    }

    function getYieldPool(uint16 _id) public view onlyOwner returns(YieldPool memory yieldPool) {
        return yieldPools[_id];
    }

    modifier gtZero (uint256 _amount) {
        require(_amount > 0, "Amount should be greater than zero.");
        _;
    }

}
