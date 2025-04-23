// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * 1. 开发者在部署合约时规定锁仓的时间，受益人地址，以及代币合约
 * 2. 开发者将代币转入TokenLocker合约
 * 3. 在锁仓期满，受益人可以取走合约里的代币
 */
contract TokenLocker{
    event TokenLockStart(address indexed beneficiary,address indexed token,uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary,address indexed  token,uint256 releaseTime,uint256 amount);

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable lockTime;
    uint256 public immutable startTime;

    constructor(IERC20 _token,address _benefciary,uint256 _lockTime){
        require(_lockTime > 0,"TokenLock: lock time should greater than 0");
        token = _token;
        beneficiary = _benefciary;
        lockTime = _lockTime;
        startTime = block.timestamp;
        emit TokenLockStart(beneficiary, address(token), startTime, lockTime);
    }

    function release() public {
        require(block.timestamp >= startTime + lockTime,"TokenLock: current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0,"TokenLock: no tokens to release.");
        token.transfer(beneficiary,amount);
        emit Release(msg.sender,address(token),block.timestamp,amount);
    }
}