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

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);

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

        emit Staked(msg.sender, msg.value);
    }

    function claimRewards() public {
        StakeInfo storage user = stakes[msg.sender];
        require(user.amount > 0, "No active stake");

        uint256 pending = (block.timestamp - user.lastStakedTime) * rewardRatePerSecond * user.amount / 1 ether;
        uint256 totalReward = user.reward + pending;

        require(totalReward > 0, "No rewards to claim");

        user.reward = 0;
        user.lastStakedTime = block.timestamp;

        (bool sent, ) = payable(msg.sender).call{value: totalReward}("");
        require(sent, "Reward transfer failed");

        emit RewardClaimed(msg.sender, totalReward);
    }

    function unstake() external {
        StakeInfo storage user = stakes[msg.sender];
        require(user.amount > 0, "No stake to withdraw");

        claimRewards(); // Claims before unstaking

        uint256 amountToWithdraw = user.amount;
        user.amount = 0;
        user.lastStakedTime = 0;

        (bool sent, ) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(sent, "Unstake transfer failed");

        emit Unstaked(msg.sender, amountToWithdraw);
    }

    function setRewardRate(uint256 newRate) external onlyOwner {
        rewardRatePerSecond = newRate;
        emit RewardRateUpdated(newRate);
    }

    // Optional: Allow owner to withdraw excess funds
    function withdrawContractBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool sent, ) = payable(owner).call{value: balance}("");
        require(sent, "Withdrawal failed");
    }

    // View helper: Check pending rewards without claiming
    function pendingRewards(address userAddr) external view returns (uint256) {
        StakeInfo storage user = stakes[userAddr];
        if (user.amount == 0) return 0;

        uint256 pending = (block.timestamp - user.lastStakedTime) * rewardRatePerSecond * user.amount / 1 ether;
        return user.reward + pending;
    }
}
