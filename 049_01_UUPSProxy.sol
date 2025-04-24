// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UUPSProxy{
    address public implementation;

    address public admin;
    string public words;

    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable {
        (bool success,bytes memory data) = implementation.delegatecall(msg.data);
    }
}