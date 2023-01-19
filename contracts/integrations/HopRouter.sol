// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IHopRouter.sol";
import "../interfaces/IStakingIntegration.sol";
import "../interfaces/IHopPool.sol";
import "../interfaces/IHopRewards.sol";

contract HopRouter is IStakingIntegration, Ownable {

    uint8 projectId;
    address private addr;
    uint256 private hopChainId;
    uint8 private hopTokenIndex;
    IHopRouter private router;

    mapping(string => uint8) private tokenId;
    
    constructor(address _addr, uint8 _projectId, uint16 _chainId, uint8 _hopTokenIndex) {
        addr = _addr;
        projectId = _projectId;
        hopChainId = _chainId;
        hopTokenIndex = _hopTokenIndex;
    }

    function getBalance(address _poolAddress) public view returns (uint256 balance) {
        return IERC20(_poolAddress).balanceOf(address(this));
    }

    function getNotionalBalance(
        address _poolAddress, 
        address _stakingAddress
    ) external view returns (uint256 notionalBalance) {
        return (IERC20(_poolAddress).balanceOf(address(this)) + IERC20(_stakingAddress).balanceOf(address(this))) * getVirtualPrice(_poolAddress);
    }

    function getStakedBalance(address _stakingAddress) external view returns (uint256 stakedBalance) {
        return IERC20(_stakingAddress).balanceOf(address(this));
    }

    function getRewardsBalance(address _rewardsAddress) external view returns (uint256 rewardsBalance) {
        return IHopRewards(_rewardsAddress).earned(address(this));
    }

    function getVirtualPrice(address _poolAddress) public view returns (uint256) {
        return IHopPool(_poolAddress).getVirtualPrice();
    }

    function addTokenPool(string memory token, uint8 id) public onlyOwner {
        tokenId[token] = id;
        emit PoolAdded(projectId, token, id);
    }

    function removeTokenPool(string memory token) public onlyOwner {
        delete tokenId[token];
        emit PoolRemoved(projectId, token);
    }

    function getTokenPool(string memory token) public view returns (uint8 _tokenId) {
        return tokenId[token];
    }

    function addLiquidity(
        string memory _token,
        uint256 _amountLD,
        address _to
    ) external {
        router = IHopRouter(addr);
        router.addLiquidity(new uint256[](_amountLD), _amountLD, _to);
        emit PoolAddLiquidityEvent(projectId, tokenId[_token], _amountLD, _to);
        // TODO: stake via the rewards contract
        // https://arbiscan.io/address/0xb0cabfe930642ad3e7decdc741884d8c3f7ebc70#writeContract
    }

    function removeLiquidity(
        string memory token,
        uint256 _amountLP,
        address _to
    ) external {
        router = IHopRouter(addr);
        router.removeLiquidityOneToken(_amountLP, hopTokenIndex, _amountLP, getDeadline(0x500000));
        emit PoolRemoveLiquidity(projectId, tokenId[token], _amountLP, _to);
    }

    function getDeadline(uint256 _timeBuffer) internal view returns (uint256 timestamp) {
        return block.timestamp + _timeBuffer;
    }
    
}
