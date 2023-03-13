// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract MyContract{
    bool private mutex = false;
    function testFunction() public {
        require(!mutex);
        mutex = true;

        //code


        mutex = false;
    }
}

//after once execution of testFunction if called again while the mutex is true !mutext => false and the function cannot be executed hence mutext prevents reentrancy.