// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Flashloan {
    constructor() payable {
        if (msg.value < 100 ether) {
            revert();
        }
    }

    receive() external payable {}

    function takeLoan(uint256 amount, bytes calldata data) external {
        uint256 prevBalance = address(this).balance;
        if (amount > address (this).balance) revert();

        (bool success, ) = payable(msg.sender).call{value: amount}(data);
        require(success);

        uint256 newBal = address(this).balance;
        require(newBal >= prevBalance, "Flashloan not paid");
    }
}
