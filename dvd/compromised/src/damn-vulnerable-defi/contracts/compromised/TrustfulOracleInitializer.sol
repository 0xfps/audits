// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TrustfulOracle } from "./TrustfulOracle.sol";

/**
 * @title TrustfulOracleInitializer
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrustfulOracleInitializer {
    event NewTrustfulOracle(address oracleAddress);

    TrustfulOracle public oracle;

    constructor(address[] memory sources, string[] memory symbols, uint256[] memory initialPrices) {
        /// @audit Prices should be 999 ETH.
        oracle = new TrustfulOracle(sources, true);
        oracle.setupInitialPrices(sources, symbols, initialPrices);
        emit NewTrustfulOracle(address(oracle));
    }
}
