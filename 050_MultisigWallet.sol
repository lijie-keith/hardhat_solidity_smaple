// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultisigWallet{
    event ExecutionSuccess(bytes32 txHash);
    event ExecutionFailure(bytes32 txHash);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public ownerCount;
    //多签执行门槛,交易至少有n个多人签名才被执行
    uint256 public threshold;
    uint256 public nonce;

    constructor(address[] memory _owners,uint256 _threshold){
        _setupOwners(_owners,_threshold);
    }

    function _setupOwners(address[] memory _owners,uint256 _threshold) internal {
        require(threshold == 0,"WTF5000");
        require(_threshold < _owners.length,"WTF5001");
        require(_threshold >=1 ,"WTF5002");

        for (uint256 i = 0; i < _owners.length; i++){
            address owner = _owners[i];
            require(owner != address(0) && owner != address(this) && !isOwner[owner],"WTF5003");
            owners.push(owner);
            isOwner[owner] = true;
        }
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    function execTransaction(address to,uint256 value, bytes memory data,bytes memory signatures) public payable virtual returns(bool success){
        bytes32 txHash = encodeTransactionData(to,value,data,nonce,block.chainid);
        nonce++;
        checkSignatures(txHash,signatures);
        (success,) = to.call{value:value}(data);
        require(success,"WTF5004");
        if (success){
            emit ExecutionSuccess(txHash);
        }else{
            emit ExecutionFailure(txHash);
        }
    }

    function checkSignatures(bytes32 dataHash,bytes memory signatures) public view {
        uint256 _threshold = threshold;
        require(_threshold > 0,"WTF5005");
        require(signatures.length >= _threshold * 65,"WTF5006");

        // 通过一个循环，检查收集的签名是否有效
        // 大概思路：
        // 1. 用ecdsa先验证签名是否有效
        // 2. 利用 currentOwner > lastOwner 确定签名来自不同多签（多签地址递增）
        // 3. 利用 isOwner[currentOwner] 确定签名者为多签持有人
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;

        for (i = 0; i < _threshold; i++) 
        {
            (v,r,s) = signatureSplit(signatures,i);
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v, r, s);
            require(currentOwner > lastOwner && isOwner[currentOwner],"WTF5006");
            lastOwner = currentOwner;
        }
    }    

    function signatureSplit(bytes memory signatures,uint256 pos)internal pure returns(uint8 v,bytes32 r,bytes32 s){
        // 签名的格式：{bytes32 r}{bytes32 s}{uint8 v}
        assembly{
            //mul 是汇编中的乘法操作符。由于每个签名占用 65 字节（即 0x41 字节），所以通过 mul(0x41, pos) 计算出指定位置 pos 的签名在 signatures 数组中的起始偏移量。
            let signaturePos := mul(0x41,pos)
            //mload 用于从内存中加载 32 字节的数据。add 是汇编中的加法操作符。add(signatures, add(signaturePos, 0x20)) 计算出 r 值在内存中的地址，然后使用 mload 加载该地址处的 32 字节数据作为 r 值
            r := mload(add(signatures,add(signaturePos,0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    function encodeTransactionData(address to,uint256 value, bytes memory data,uint256 _nonce,uint256 chainId) public pure returns(bytes32){
        bytes32 safeTxhash = keccak256(abi.encode(to,value,keccak256(data),_nonce,chainId));
        return safeTxhash;
    }
}