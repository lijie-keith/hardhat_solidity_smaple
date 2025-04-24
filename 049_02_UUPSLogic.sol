// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UUPSLogic{
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "old";
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}