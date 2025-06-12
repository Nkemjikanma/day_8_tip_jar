//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library Converter {
    function getPriceFeed(AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = _priceFeed.latestRoundData();
        uint8 decimals = _priceFeed.decimals();

        // Convert to 18 decimals standard
        return uint256(price) * 10 ** (18 - decimals);
    }

    function getConversion(uint256 _amount, AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPriceFeed(_priceFeed);

        // If price is ETH/USD, then to convert USD to ETH: amount_in_eth =  (amount_in_usd * 10^18) / price
        return (_amount * 1e18) / ethPrice;
    }
}
