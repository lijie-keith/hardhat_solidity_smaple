// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logic{
    address public implementation;

    address public admin;

    string public words;

    function foo() public {
        words = "old";
    }
}