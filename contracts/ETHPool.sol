// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ETHPool is Ownable, ReentrancyGuard {
    struct DepositInfo {
        uint256 amount;
        uint256 depositTime;
    }

    uint256 public totalDeposits; // 总存款金额
    uint256 public totalRewards; // 总奖励金额

    uint256 private constant WEEK = 7 days;

    mapping(address => DepositInfo) public deposits; // 用户存款映射

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardAdded(uint256 amount);
    error InvalidAmount();
    error InsufficientBalance();
    error TransferFailed();

    constructor() Ownable(msg.sender) {}

    /**
     * 存款
     */
    function deposit() external payable nonReentrant {
        if (msg.value == 0) {
            revert InvalidAmount();
        }

        deposits[msg.sender].amount += msg.value;
        deposits[msg.sender].depositTime = block.timestamp; // 记录存款时间

        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * 提款
     * @param amount 数额
     */
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (amount > deposits[msg.sender].amount) {
            revert InsufficientBalance();
        }

        // 计算用户存款占总存款的比例
        uint256 userDepositRatio = (deposits[msg.sender].amount * 100) /
            totalDeposits;

        // 计算用户应该获得的奖励份额，按照存款占比
        uint256 userRewardAmount = (totalRewards * userDepositRatio) / 100;

        // 计算奖励按照一周分的情况
        uint256 rewardPerDay = userRewardAmount / 7;
        uint256 timeDiff = block.timestamp - deposits[msg.sender].depositTime;
        uint256 userReward = timeDiff >= WEEK
            ? userRewardAmount
            : (timeDiff * rewardPerDay) / WEEK;

        // 更新用户存款和奖励金额
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
     * 添加奖励函数，仅合约所有者调用
     */
    function addReward() external payable onlyOwner {
        if (msg.value == 0) {
            revert InvalidAmount();
        }
        totalRewards += msg.value;
        emit RewardAdded(msg.value);
    }
}
