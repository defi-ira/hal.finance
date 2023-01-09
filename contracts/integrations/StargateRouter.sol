// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IStargateRouter.sol";
import "../interfaces/IIntegration.sol";

contract StargateRouter is IIntegration, Ownable {

    uint8 projectId;                    // protocol project identifier
    address private addr;               // router contract address
    uint256 private stgChainId;         // STG chain identifier
    IStargateRouter private router;     // STG router interface

    mapping(string => uint8) private tokenId;
    
    constructor(address _addr, uint8 _projectId, uint16 _chainId) {
        addr = _addr;
        projectId = _projectId;
        stgChainId = _chainId;
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
        router = IStargateRouter(addr);
        uint _poolId = tokenId[_token];
        router.addLiquidity(_poolId, _amountLD, _to);
        emit PoolAddLiquidityEvent(projectId, _poolId, _amountLD, _to);
    }

    function removeLiquidity(
        string memory token,
        uint256 _amountLP,
        address _to
    ) external {
        router = IStargateRouter(addr);
        uint16 _srcPoolId = tokenId[token];
        router.instantRedeemLocal(_srcPoolId, _amountLP, _to);
        emit PoolRemoveLiquidity(projectId, _srcPoolId, _amountLP, _to);
    }

}
