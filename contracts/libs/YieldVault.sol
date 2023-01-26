// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./OpenEndVault.sol";
import "./Cooldown.sol";
import "./IVaultBallot.sol";

contract YieldVault is Ownable, OpenEndVault, Cooldown {

    mapping(uint256 => uint256) _ballotBalance;
    mapping(address => bool) _minted;
    address private _vaultBallot;

    constructor(address tokenAddr_, address vaultBallot_) OpenEndVault(tokenAddr_) {
        _vaultBallot = vaultBallot_;
    }

    function ballotBalance(uint256 token_) public view returns (uint256 balance_) {
        return _ballotBalance[token_];
    }

    function ballotBalance(uint256[] calldata token_, uint256 length_) public view returns (uint256 balance_) {
        uint256 total;
        for (uint256 i = 0; i < length_; i++) {
            total += _ballotBalance[token_[i]];
        }
        return total;
    }

    function mintBallot() public depositor(msg.sender) returns (uint256 token_) {
        _minted[msg.sender];
        uint256 token = IVaultBallot(_vaultBallot).mint(msg.sender);
        updateBalance(token_);
        return token;
    }

    function updateBalance(uint256 token_) public {
        _ballotBalance[token_] = this.balanceOf(msg.sender);
    }

    function minted(address addr_) public view returns (bool minted_) {
        return _minted[addr_];
    }

    modifier depositor(address addr_) {
        require(getBalance(addr_) > 0, "Caller is not a vault depositor");
        _;
    }


}