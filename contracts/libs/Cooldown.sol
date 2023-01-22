// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Cooldown is Ownable {

    uint256 private cooldown;
    uint256 private last;

    function setCooldown(uint256 _seconds) external onlyOwner {
        cooldown = _seconds;
    }

    function isCooldownActive() external view returns (bool active) {
        return (last + (cooldown * 60)) > block.timestamp;
    }

    modifier cooldownActive() {
        require ((last + (cooldown * 60)) > block.timestamp, "Cooldown is active");
        _;
    }

}