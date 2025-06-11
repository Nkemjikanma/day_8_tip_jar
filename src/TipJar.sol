// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract TipJar {
    error TipJar__NotAuthorized();

    addresss public owner;

    // currency to rate mapping
    mapping(string => uint256) public exchangeRate;

    // contributions by address
    mapping(address => uint256) public contributions;

    // contributions by address to currency;
    mapping(address => mapping(string => uint256)) contributionsByCurrency;

    // total tips recieved
    uint256 public totalTips;

    modifier onlyOnwer() {
        if (msg.sender != owner) {
            revert TipJar__NotAuthorized();
        }
    }
}
