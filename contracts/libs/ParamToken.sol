// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ParamToken is ERC721, Ownable {

    uint256 private _minTvl;
    mapping(uint16 => bool) private poolVeto;
    bool private _vetoNew;

    constructor(uint256 minTvl_, bool vetoNew_, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _minTvl = minTvl_;
        _vetoNew = vetoNew_;
    }

    function vetoPool(uint16[] calldata _poolId, uint8 _length, bool veto_) public onlyOwner {
        for (uint8 i = 0; i < _length; i++) {
            poolVeto[_poolId[i]] = veto_;
        }
    }

    function setMinTvl(uint256 minTvl_) public onlyOwner {
        _minTvl = minTvl_;
    }

    function veto(uint16 _poolId) public view returns (bool veto_) {
        return poolVeto[_poolId];
    }

    function minTvl() public view returns (uint256 minTvl_) {
        return _minTvl;
    }

    function setVetoNew(bool vetoNew_) public onlyOwner {
        _vetoNew = vetoNew_;
    }

    function vetoNew() public view returns (bool vetoNew_) {
        return _vetoNew;
    }

}