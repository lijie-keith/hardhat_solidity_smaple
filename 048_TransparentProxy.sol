// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransparentProxy{
    address implementation;
    address admin;
    string public words;

    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    receive() external payable { }

    // 回调函数，将调用委托给逻辑合约
    fallback() external payable { 
        require(msg.sender != admin);
        (bool success,bytes memory data) = implementation.delegatecall(msg.data);
    }

    //只能由admin调用
    function upgrade(address newImplementation) external {
        if (msg.sender != admin){
            revert();
        }
        implementation = newImplementation;
    }
}