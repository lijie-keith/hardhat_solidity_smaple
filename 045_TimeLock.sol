// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * 1. 创建交易，并加入到时间锁队列
 * 2. 在交易期满后，执行交易
 * 3. 可以取消时间锁队列中的某些交易
 */
contract TimeLock{
    event CancelTransaction(bytes32 indexed txHash,address indexed target,uint value,string signature,bytes data,uint executeTime);
    event ExecuteTransaction(bytes32 indexed txHash,address indexed target,uint value,string signature,bytes data,uint executeTime);
    event QueueTransaction(bytes32 indexed txHash,address indexed target,uint value,string signature,bytes data,uint executeTime);
    event NewAdmin(address indexed newAdmin);

    address public admin;
    uint public constant GRACE_PERIOD = 7 days;
    uint public delay;
    mapping(bytes32 => bool) public queuedTransactons;


    modifier onlyOwer(){
        require(msg.sender == admin,"TimeLock:Caller not admin");
        _;
    }

    modifier onlyTimeLock(){
        require(msg.sender == address(this),"TimeLock:Caller not TimeLock");
        _;
    }

    constructor(uint _delay){
        delay = _delay;
        admin = msg.sender;
    }

    function changeAadmin(address newAdmin) public onlyTimeLock{
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

    function queueTransaction(address target ,uint256 value,string memory signature,bytes memory data, uint256 executeTime) public onlyOwer returns(bytes32){
        require(executeTime >= getBlockTimestamp() + delay,"TimeLock::queueTransaction: Estimated execution block must satisfy delay.");
        bytes32 txHash = getTxHash(target,value,signature,data,executeTime);
        queuedTransactons[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    function cancelTransaction(address target,uint256 value ,string memory signature,bytes memory data,uint256 executeTime) public onlyOwer{
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactons[txHash],"TimeLock::cancelTransaction: Transaction hasn't been queud.");
        queuedTransactons[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }

    function executeTransaction(address target,uint256 value,string memory signature,bytes memory data,uint256 executeTime) public payable onlyOwer returns (bytes memory){
        bytes32 txHash = getTxHash(target, value,signature,data,executeTime);
        require(queuedTransactons[txHash],"TimeLock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= executeTime,"TimeLock::executeTransaction: Transaction hasn't surpassed time lock");
        require(getBlockTimestamp() <= executeTime + GRACE_PERIOD,"TimeLock::executeTransaction:Transaction is stale.");
        queuedTransactons[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0){
            callData = data;
        }else{
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))),data);
        }
        (bool success,bytes memory returnData) = target.call{value:value}(callData);
        require(success,"TimeLock::executeTransaction: Transaction execution reverted.");
        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);
        return returnData;
    }

    function getBlockTimestamp() public view returns(uint){
        return block.timestamp;
    }

    function getTxHash(address target,uint value ,string memory signature,bytes memory data,uint executeTime) public pure returns(bytes32){
        return keccak256(abi.encode(target,value,signature,data,executeTime));
    }

}