// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract{
    address public implementation;

    constructor(address _implementation){
        implementation = _implementation;
    }

    receive() external payable { }

    fallback() external payable { 
        _delegate();
    }

    function _delegate() internal {
        address _implementation = implementation;
        assembly{
            //calldatacopy(t,f,s) 将calldata(输入数据)从位置f开始复制s字节到内存的位置t
            calldatacopy(0,0,calldatasize())

            //delegatecall(g,a,in,insize,out,outsize) 调用地址a的合约，输入为mem[in..(in+insize)],输出位mem[out..(out+outsize)]
            let result := delegatecall(gas(),_implementation,0,calldatasize(),0,0)

            //returndatacopy(t,f,s) 将returndata(输出数据)从位置f开始复制s字节到内存位置t
            returndatacopy(0,0,returndatasize())

            switch result
            case 0{
                // 终止函数执行，回滚状态，返回数据内存[p..(p+s)]
                revert(0,returndatasize())
            }
            default {
                //终止函数执行，返回数据内存[p..(p+s)]
                return(0,returndatasize())
            }
        }
    }
}