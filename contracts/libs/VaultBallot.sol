// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721//ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultBallot is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter  public _tokenId;
    
    mapping(uint256 => uint256) private _minTvl;
    mapping(uint256 => uint16[]) private _veto;
    mapping(address => uint256) private _owners;

    constructor(string memory name_, string memory symbol_) 
        ERC721(name_, symbol_) { }

    event VaultBallotMinTvlUpdate(uint256 token_, uint256 minTvl_);
    event VaultBallotVeto(uint256 token_, uint16[] poolId_);

    function vetoPool(uint256 token_, uint16[] calldata poolId_) public isOwner(token_, msg.sender) {
        _veto[token_] = poolId_;
        emit VaultBallotVeto(token_, poolId_);
    }

    function setMinTvl(uint256 token_, uint256 minTvl_) public isOwner(token_, msg.sender) {
        _minTvl[token_] = minTvl_;
        emit VaultBallotMinTvlUpdate(token_, minTvl_);
    }

    function veto(uint256 token_) public view returns (uint16[] memory veto_) {
        return _veto[token_];
    }

    function minTvl(uint256 token_) public view returns (uint256 minTvl_) {
        return _minTvl[token_];
    }

    function mint(address to_) public onlyOwner returns (uint256 tokenId_) {
        _tokenId.increment();
        uint256 tokenId = _tokenId.current();
        _safeMint(to_, tokenId);
        return tokenId;
    }

    modifier isOwner(uint256 token_, address addr_) {
        require(ownerOf(token_) == addr_, "Contract caller is not the owner of token.");
        _;
    }


}