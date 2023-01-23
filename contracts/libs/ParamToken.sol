// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ParamToken is ERC721, Ownable {

    uint256 private minTvl;
    mapping(uint16 => bool) poolVeto;
    bool private vetoNew;

    constructor(uint256 _minTvl, bool _vetoNew, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        minTvl = _minTvl;
        vetoNew = _vetoNew;
    }

    function vetoPool(uint16[] calldata _poolId, uint8 _length, bool veto) public onlyOwner {
        for (uint8 i = 0; i < _length; i++) {
            poolVeto[_poolId[i]] = veto;
        }
    }

    function setMinTvl(uint256 _minTvl) public onlyOwner {
        minTvl = _minTvl;
    }

    function getVeto(uint16 _poolId) public view returns (bool veto) {
        return poolVeto[_poolId];
    }

}