// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "../interfaces/IIntegration.sol";
import "../interfaces/IStakingIntegration.sol";
import "../libs/Cooldown.sol";
import "../libs/OpenEndVault.sol";

contract TopYieldSwap is Ownable, OpenEndVault, Cooldown {

    uint16 private chainId;
    address private tokenAddr;
    uint16 private activePool;
    uint256 private minTvl;

    struct YieldPool {
        uint16 id;              // unique pool id
        string project;         // project name
        string token;           // ERC20 name
        address addr;           // router address
        address poolAddr;       // pool address
        address stakingAddr;    // staking address
        uint16 currentYield;    // pool yield
        uint256 tvl;            // tvl
    }

    event YieldPoolAdded(string _project, string _token, address _addr);
    event YieldPoolRemoved(uint16 _id);

    event YieldPoolYieldSet(uint16 _poolId, uint16 _newYield);
    event YieldPoolTvlSet(uint16 _poolId, uint256 _tvl);

    event EnterPool(uint16 _poolId, uint256 _amount, uint256 _balance);
    event ExitPool(uint16 _poolId, uint256 _amount);

    mapping (uint16 => YieldPool) private yieldPools;
    mapping (uint16 => IIntegration) private integrations;
    mapping (uint16 => bool) private tokensStaked;

    constructor(uint16 _chainId, address _tokenAddr) OpenEndVault(_tokenAddr) {
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

    function getTokenBalance() public view returns (uint256 tokenBalance) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    function getDepositBalance() public view returns (uint256 depositBalance) {
        YieldPool memory yieldPool = yieldPools[activePool];
        return IERC20(yieldPool.poolAddr).balanceOf(address(this));
    }

    function enterPool(YieldPool memory _yieldPool) internal {
        IIntegration integration = IIntegration(_yieldPool.addr);
        integration.addLiquidity(_yieldPool.token, address(this).balance, address(this));
        activePool = _yieldPool.id;
    }

    function exitCurrentPool() public onlyOwner {
        YieldPool memory currentPool = yieldPools[activePool];
        IIntegration integration = IIntegration(yieldPools[activePool].addr);
        uint256 balance = IERC20(currentPool.addr).balanceOf(address(this));
        integration.removeLiquidity(currentPool.token, balance, address(this));
        activePool = 0x0;
    }

    function stakePool(uint16 _poolId) public isStakingPool(_poolId) unstaked(_poolId) {
        IStakingIntegration integration = IStakingIntegration(yieldPools[_poolId].addr);
        integration.stake(yieldPools[_poolId].addr, yieldPools[_poolId].stakingAddr);
        tokensStaked[_poolId] = true;
    }

    function unstakePool(uint16 _poolId) public isStakingPool(_poolId) staked(_poolId) {
        IStakingIntegration integration = IStakingIntegration(yieldPools[_poolId].addr);
        integration.unstake(yieldPools[_poolId].stakingAddr);
        tokensStaked[_poolId] = false;
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
            if (yieldPools[_poolIds[i]].currentYield > _topYield && yieldPools[_poolIds[i]].tvl >= minTvl) {
                _topYield = yieldPools[_poolIds[i]].currentYield;
                _poolId = _poolIds[i];
            }
        }
        return yieldPools[_poolId];
    }

    function addYieldPool(
        uint16 id,
        string memory _project,
        string memory _token,
        address _addr,
        address _tokenAddr,
        address _stakingAddr
    ) public onlyOwner returns(IIntegration integration) {
        yieldPools[id] = YieldPool(id, _project, _token, _addr, _tokenAddr, _stakingAddr, 0x0, 0x0);
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
        emit YieldPoolYieldSet(_id, _yield);
    }

    function setYieldPoolTvl(uint16 _id, uint256 _tvl) public onlyOwner {
        yieldPools[_id].tvl = _tvl; 
        emit YieldPoolTvlSet(_id, _tvl);
    }

    function getYieldPool(uint16 _id) public view onlyOwner returns(YieldPool memory yieldPool) {
        return yieldPools[_id];
    }

    function setMinTvl(uint256 _minTvl) external onlyOwner {
        minTvl = _minTvl;
    }

    modifier isStakingPool(uint16 _poolId) {
        require (yieldPools[_poolId].stakingAddr != address(0x0), "Current pool does not support staking");
        _;
    }

    modifier staked(uint16 _poolId) {
        require (tokensStaked[_poolId] == true, "Pool tokens are not staked");
        _;
    }

    modifier unstaked(uint16 _poolId) {
        require (tokensStaked[_poolId] == false, "Pool tokens are staked");
        _;
    }

    modifier gtZero (uint256 _amount) {
        require(_amount > 0, "Amount should be greater than zero.");
        _;
    }

}
