// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TipJar} from "../src/TipJar.sol";

contract TipJarTest is Test {
    TipJar public tipJar;

    function setUp() public {
        tipJar = new TipJar(
            0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1,
            0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1,
            0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1
        );
    }
}
