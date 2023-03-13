//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLock{

    using SafeMath for uint256;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockPeriod;

    function deposit() external payable{
        balances[msg.sender] += msg.value;
        lockPeriod[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockPeriod(uint256 _timeToIncrease) public{
        //vulnerable part
        // lockPeriod[msg.sender] += _timeToIncrease;

        //using safemath add function
        lockPeriod[msg.sender] = lockPeriod[msg.sender].add(_timeToIncrease);
    }

    function withdraw() external payable{
        require(balances[msg.sender] > 0,"no funds to withdraw");
        require(block.timestamp >= lockPeriod[msg.sender],"Asset is locked");

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");

    }

}


contract Attack{
    TimeLock timelock;
    constructor(address _timelock){
        timelock = TimeLock(_timelock);
    }

    fallback() external payable {}

    function attack() external payable{
        timelock.deposit{value : msg.value}();
         /*
        if t = current lock time then we need to find x such that
        x + t = 2**256 = 0
        so x = -t
        2**256 = type(uint).max + 1
        so x = type(uint).max + 1 - t
        */

        //real attack
        timelock.increaseLockPeriod(
            type(uint256).max + 1 - timelock.lockPeriod(address(this))
        );

        timelock.withdraw();
    }


}

//to prevent arithmetic overflow and underflow we use safeMath library