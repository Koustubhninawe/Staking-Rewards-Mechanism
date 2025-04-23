// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingRewards {
    address public owner;
    uint256 public rewardRatePerSecond = 1e16; // Example: 0.01 tokens/second

    struct StakeInfo {
        uint256 amount;
        uint256 lastStakedTime;
        uint256 reward;
    }

    mapping(address => StakeInfo) public stakes;

    constructor() {
        owner = msg.sender;
    }

    function stake() external payable {
        require(msg.value > 0, "Must stake more than 0");

        StakeInfo storage user = stakes[msg.sender];

        // Update any pending rewards
        if (user.amount > 0) {
            user.reward += (block.timestamp - user.lastStakedTime) * rewardRatePerSecond * user.amount / 1 ether;
        }

        user.amount += msg.value;
        user.lastStakedTime = block.timestamp;
    }

    function claimRewards() external {
        StakeInfo storage user = stakes[msg.sender];
        require(user.amount > 0, "No active stake");

        uint256 totalReward = user.reward + (block.timestamp - user.lastStakedTime) * rewardRatePerSecond * user.amount / 1 ether;

        require(totalReward > 0, "No rewards to claim");

        user.reward = 0;
        user.lastStakedTime = block.timestamp;

        payable(msg.sender).transfer(totalReward);
    }
}

