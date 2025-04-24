// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleUpgrade{
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implementation){
        implementation = _implementation;
        admin = msg.sender;
    }

    receive() external payable { }

    fallback() external payable { 
        (bool success,) = implementation.delegatecall(msg.data);
        require(success);
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}