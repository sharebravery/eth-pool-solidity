// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ETHPool is Ownable, ReentrancyGuard {
    struct DepositInfo {
        uint256 amount;
        uint256 depositTime;
    }

    uint256 public totalDeposits; // Total deposit amount
    uint256 public totalRewards; // Total reward amount

    uint256 private constant WEEK = 7 days;

    mapping(address => DepositInfo) public deposits; // User deposit mapping

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardAdded(uint256 amount);
    error InvalidAmount();
    error InsufficientBalance();
    error TransferFailed();

    constructor() Ownable(msg.sender) {}

    /**
     * Deposit
     */
    function deposit() external payable nonReentrant {
        if (msg.value == 0) {
            revert InvalidAmount();
        }

        deposits[msg.sender].amount += msg.value;
        deposits[msg.sender].depositTime = block.timestamp; // Record deposit time

        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * Withdraw
     * @param amount Amount
     */
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (amount > deposits[msg.sender].amount) {
            revert InsufficientBalance();
        }

        // Calculate user deposit ratio
        uint256 userDepositRatio = (deposits[msg.sender].amount * 100) /
            totalDeposits;

        // Calculate the reward amount that the user should receive, according to the deposit ratio
        uint256 userRewardAmount = (totalRewards * userDepositRatio) / 100;

        // Calculate the reward on a weekly basis
        uint256 rewardPerDay = userRewardAmount / 7;
        uint256 timeDiff = block.timestamp - deposits[msg.sender].depositTime;
        uint256 userReward = timeDiff >= WEEK
            ? userRewardAmount
            : (timeDiff * rewardPerDay) / WEEK;

        // Update user deposit and reward amount
        totalDeposits -= amount;
        totalRewards -= userReward;
        deposits[msg.sender].amount -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount + userReward}(
            ""
        );
        if (!success) {
            revert TransferFailed();
        }

        emit Withdraw(msg.sender, amount);
    }

    /**
     * Add reward function, only callable by contract owner
     */
    function addReward() external payable onlyOwner {
        if (msg.value == 0) {
            revert InvalidAmount();
        }
        totalRewards += msg.value;
        emit RewardAdded(msg.value);
    }
}
