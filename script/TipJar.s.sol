// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TipJar} from "../src/TipJar.sol";

contract TipJarScript is Script {
    TipJar public tipJar;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // all wrong addresses so do not use
        tipJar = new TipJar(
            0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649,
            0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649,
            0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649
        );

        vm.stopBroadcast();
    }
}
