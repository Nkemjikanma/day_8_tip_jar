// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Converter} from "./Converter.sol";

contract TipJar {
    // using Converter for uint256;

    error TipJar__NotAuthorized();
    error TipJar__InvalidCurrency();
    error TipJar__InvalidAddress();
    error TipJar__InvalidAmount();
    error TipJar__CurrencyExists();
    error TipJar__WithdrawFailed();

    // enum Currency {
    //     ETH,
    //     USD,
    //     EUR,
    //     GBP
    // }

    struct CurrencyInfo {
        string symbol;
        AggregatorV3Interface priceFeed;
        bool isActive;
    }

    string[] public supportedCurrencies;

    // Mapping from currency symbol to its info
    mapping(string => CurrencyInfo) public currencies;

    address public owner;
    // mapping(Currency => AggregatorV3Interface) public priceFeedByCurrency;

    // contributions by address
    mapping(address => uint256) public contributions;

    // contributions by address to currency to amount;
    mapping(address => mapping(string => uint256)) contributionsByCurrency;

    // total tips recieved
    uint256 public totalTipsReceived;

    modifier onlyOnwer() {
        if (msg.sender != owner) {
            revert TipJar__NotAuthorized();
        }

        _;
    }

    event CurrencyAdded(string _currency);
    event TipReceived(address indexed _donor, string _currency, uint256 _amount);

    constructor(address _gbp, address _eur, address _usd) {
        owner = msg.sender;

        currencies["ETH"] = CurrencyInfo({
            symbol: "ETH",
            priceFeed: AggregatorV3Interface(address(0)), // ETH doesn't need a price feed
            isActive: true
        });
        currencies["GBP"] = CurrencyInfo({symbol: "GBP", priceFeed: AggregatorV3Interface(_gbp), isActive: true});

        currencies["EUR"] = CurrencyInfo({symbol: "EUR", priceFeed: AggregatorV3Interface(_eur), isActive: true});
        currencies["USD"] = CurrencyInfo({symbol: "USD", priceFeed: AggregatorV3Interface(_usd), isActive: true});

        supportedCurrencies.push("ETH");
        supportedCurrencies.push("GBP");
        supportedCurrencies.push("EUR");
        supportedCurrencies.push("USD");
    }

    function addCurrencyAndPriceFeed(string memory _currency, address _priceFeedAddress) public onlyOnwer {
        if (currencies[_currency].isActive) {
            revert TipJar__CurrencyExists();
        }

        currencies[_currency] =
            CurrencyInfo({symbol: _currency, priceFeed: AggregatorV3Interface(_priceFeedAddress), isActive: true});

        supportedCurrencies.push(_currency);

        emit CurrencyAdded(_currency);
    }

    function receiveInEther() public payable {
        if (msg.value <= 0) {
            revert TipJar__InvalidAmount();
        }

        contributions[msg.sender] += msg.value;
        contributionsByCurrency[msg.sender]["ETH"] += msg.value;
        totalTipsReceived += msg.value;

        emit TipReceived(msg.sender, "ETH", msg.value);
    }

    function receiveInCurrency(string memory _currency, uint256 _amount) public payable {
        CurrencyInfo storage currencyInfo = currencies[_currency];

        if (!currencyInfo.isActive) {
            revert TipJar__InvalidCurrency();
        }

        if (address(currencyInfo.priceFeed) == address(0)) {
            revert TipJar__InvalidAddress();
        }

        // msg.value.getConversion(_amount);
        //
        uint256 ethAmount = Converter.getConversion(_amount, currencyInfo.priceFeed);

        if (msg.value < ethAmount) {
            revert TipJar__InvalidAmount();
        }

        contributions[msg.sender] += ethAmount;
        contributionsByCurrency[msg.sender][_currency] += _amount;
        totalTipsReceived += ethAmount;

        emit TipReceived(msg.sender, _currency, msg.value);
    }

    function withdraw() public onlyOnwer {
        uint256 balance = address(this).balance;
        if (balance <= 0) {
            revert TipJar__InvalidAmount();
        }

        (bool success,) = payable(owner).call{value: balance}("");

        if (!success) {
            revert TipJar__WithdrawFailed();
        }
    }

    function getContributionByTipper(address _tipper) public view onlyOnwer returns (uint256) {
        return contributions[_tipper];
    }
}
