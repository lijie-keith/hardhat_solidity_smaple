// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Caller{
    address public proxy;

    constructor(address _proxy){
        proxy = _proxy;
    }

    function increase() external returns(uint){
        (,bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        return abi.decode(data,(uint));
    }
}