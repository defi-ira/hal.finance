// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IHopRouter.sol";
import "../interfaces/IIntegration.sol";

contract HopRouter is IIntegration, Ownable {

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

    function addTokenPool(string memory token, uint8 id) public onlyOwner {
        tokenId[token] = id;
        emit PoolAdded(projectId, token, id);
    }

    function removeTokenPool(string memory token) public onlyOwner {
        delete tokenId[token];
        emit PoolRemoved(projectId, token);
    }

    function addLiquidity(
        string memory _token,
        uint256 _amountLD,
        address _to
    ) external {
        router = IHopRouter(addr);
        uint _poolId = tokenId[_token];
        router.addLiquidity(new uint256[](_amountLD), _amountLD, _to);
        emit PoolAddLiquidityEvent(projectId, _poolId, _amountLD, _to);
    }

    function removeLiquidity(
        string memory token,
        uint256 _amountLP,
        address _to
    ) external {
        router = IHopRouter(addr);
        uint16 _srcPoolId = tokenId[token];
        router.removeLiquidityOneToken(_amountLP, hopTokenIndex, _amountLP, getDeadline(0x500000));
        emit PoolRemoveLiquidity(projectId, _srcPoolId, _amountLP, _to);
    }

    function getDeadline(uint256 _timeBuffer) internal view returns (uint256 timestamp) {
        return block.timestamp + _timeBuffer;
    }
}
