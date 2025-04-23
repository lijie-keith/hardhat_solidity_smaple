// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Logic{
    address public implementation;

    uint public x = 99;

    event CallSuccess();

    function increment() external returns(uint){
        emit CallSuccess();
        return x + 1;
    }
}