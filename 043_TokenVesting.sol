// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * 1. 项目方规定线性释放的起始时间、归属期和受益人
 * 2. 项目方将锁仓的ERC20代币转账给TokenVesting合约
 * 3. 受益人可以调用release函数，从合约中取出释放代码
 */
contract TokenVesting{
    event ERC20Released(address indexed token,uint256 amount);

    mapping(address => uint256) public erc20Released;
    address public immutable beneficiary;//受益人地址
    uint256 public immutable start;//起始时间戳
    uint256 public immutable duration;//归属期

    constructor(address _beneficiary,uint256 _duration){
        require(_beneficiary != address(0),"VestingWallet: beneficiary is zero address");
        beneficiary = _beneficiary;
        start = block.timestamp;
        duration = _duration;
    }

    function release(address token) public payable {
        uint256 releasable = vestedAdmount(token,uint256(block.timestamp)) - erc20Released[token];
        erc20Released[token] += releasable;
        emit  ERC20Released(token, releasable);
        IERC20(token).transfer(beneficiary,releasable);
    }

    function vestedAdmount(address token,uint256 timestamp) public view  returns(uint256){
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        if (timestamp < start){
            return 0;
        } else if (timestamp > start + duration){
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}