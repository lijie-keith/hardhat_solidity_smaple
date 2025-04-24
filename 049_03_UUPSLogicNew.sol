// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UUPSLogicNew{
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "new";
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}