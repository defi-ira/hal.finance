// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./OpenEndVault.sol";
import "./Cooldown.sol";
import "./IVaultBallot.sol";

contract YieldVault is Ownable, OpenEndVault, Cooldown {

    mapping(uint256 => address) _ballotAddress;
    mapping(address => bool) _minted;
    address private _vaultBallot;

    event MintYieldVaultBallot(address addr_, uint256 value_);
    event UpdateYieldVaultBallot(uint256 token_, uint256 value_);

    constructor(address tokenAddr_, address vaultBallot_) OpenEndVault(tokenAddr_) {
        _vaultBallot = vaultBallot_;
    }

    function ballotBalance(uint256 token_) public view returns (uint256 balance_) {
        return getBalance(_ballotAddress[token_]);
    }

    function ballotListBalance(uint256[] calldata token_, uint256 length_) public view returns (uint256 balance_) {
        uint256 total;
        for (uint256 i = 0; i < length_; i++) {
            total += getBalance(_ballotAddress[token_[i]]);
        }
        return total;
    }

    function mintBallot() public depositor(msg.sender) returns (uint256 tokenId) {
        _minted[msg.sender] = true;
        uint256 token = IVaultBallot(_vaultBallot).mint(msg.sender);
        emit MintYieldVaultBallot(msg.sender, getBalance(msg.sender));
        return token;
    }

    function minted(address addr_) public view returns (bool minted_) {
        return _minted[addr_];
    }

    modifier depositor(address addr_) {
        require(getBalance(addr_) > 0, "Caller is not a vault depositor");
        _;
    }


}