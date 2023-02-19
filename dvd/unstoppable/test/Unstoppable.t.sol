// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import {DamnValuableToken} from "../src/damn-vulnerable-defi/contracts/DamnValuableToken.sol";
import {ReceiverUnstoppable} from "../src/damn-vulnerable-defi/contracts/unstoppable/ReceiverUnstoppable.sol";
import {UnstoppableVault} from "../src/damn-vulnerable-defi/contracts/unstoppable/UnstoppableVault.sol";
import "forge-std/Test.sol";

contract MaliciousContractTest is Test {
    DamnValuableToken token;
    UnstoppableVault vault;
    ReceiverUnstoppable hack;

    address alice = vm.addr(1);

    uint256 hackerBalance = 10e18;
    uint256 vaultBalance = 1_000_000e18;

    function setUp() public {
        /// @dev Mints all to alice.
        vm.startPrank(alice);
        token = new DamnValuableToken();
        vault = new UnstoppableVault(token, msg.sender, msg.sender);
        hack = new ReceiverUnstoppable(address(vault));

        token.transfer(address(vault), uint256(vaultBalance));
        token.transfer(address(hack), uint256(hackerBalance));

        vm.stopPrank();
    }

    function testVerify() public {
        assertEq(token.balanceOf(address(vault)), uint256(vaultBalance));
        assertEq(token.balanceOf(address(hack)), uint256(hackerBalance));

        console.log(msg.sender);
    }

    function testFlashFee() public {
        vm.prank(alice);
        uint256 fee = vault.flashFee(address(token), 5);
        console.log(fee);
        console.log(vault.flashFee(address(token), 0));
    }

    function testCheckTotalAssetsAndConvertToShares() public {
        console.log(token.balanceOf(address(vault)));
        console.log(vault.convertToShares(token.totalSupply()));
    }

    function testFlash() public  {
        vm.expectRevert();
        vm.prank(alice);
        hack.executeFlashLoan(5);
    }
}