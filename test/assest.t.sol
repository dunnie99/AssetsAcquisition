// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/tradeAsset.sol";
import "../src/Property.sol";

contract AssetTest is Test{
    Assets public property;
    tradeAsset public tradeContract;



    address Bob = vm.addr(0x1);
    address Alice = vm.addr(0x2);
    address Idogwu = vm.addr(0x3);
    address Faith = vm.addr(0x4);
    address Femi = vm.addr(0x5);
    address Nonso = vm.addr(0x6);

    function setUp() internal{
        vm.startPrank(Bob);
        property = new Assets(Alice);
        tradeContract = new tradeAsset();
        vm.stopPrank();
    }



    
}
