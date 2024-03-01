# Solidity API

## ETHPool

### DepositInfo

```solidity
struct DepositInfo {
  uint256 amount;
  uint256 depositTime;
}
```

### totalDeposits

```solidity
uint256 totalDeposits
```

### totalRewards

```solidity
uint256 totalRewards
```

### deposits

```solidity
mapping(address => struct ETHPool.DepositInfo) deposits
```

### Deposit

```solidity
event Deposit(address user, uint256 amount)
```

### Withdraw

```solidity
event Withdraw(address user, uint256 amount)
```

### RewardAdded

```solidity
event RewardAdded(uint256 amount)
```

### InvalidAmount

```solidity
error InvalidAmount()
```

### InsufficientBalance

```solidity
error InsufficientBalance()
```

### TransferFailed

```solidity
error TransferFailed()
```

### constructor

```solidity
constructor() public
```

### deposit

```solidity
function deposit() external payable
```

存款

### withdraw

```solidity
function withdraw(uint256 amount) external
```

提款

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | 数额 |

### addReward

```solidity
function addReward() external payable
```

添加奖励函数，仅合约所有者调用

