// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

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
        property = new Assets();
        property.mintProperty(0x59813797f658893361210D4Ad0B86706702E6a2c, 1, 20);
        tradeContract = new tradeAsset();
        vm.stopPrank();
    }



    function testlistProperty() public{
        vm.startPrank(0x59813797f658893361210D4Ad0B86706702E6a2c);
        bool approved = true;
        property.setApprovalForAll(address(tradeContract, approved));
        tradeContract.listProperty(9, "The Genesis", "A house", "The moon", IERC1155(property), 1);

    }
}
