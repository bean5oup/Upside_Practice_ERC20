// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/ERC20.sol";

contract UpsideTokenTest is Test {
    address internal constant alice = address(1);
    address internal constant bob = address(2);

    ERC20 upside_token;

    function setUp() public {
        upside_token = new ERC20("UPSIDE", "UPS");
        upside_token.transfer(alice, 50 ether);
        upside_token.transfer(bob, 50 ether);
    }
    
    // function testFailPauseNotOwner() public {
    function test_RevertWhen_PauseNotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        upside_token.pause();
    }

    // function testFailTransfer() public {
    function test_RevertWhen_Transfer() public {
        upside_token.pause();
        vm.prank(alice);
        vm.expectRevert();
        upside_token.transfer(bob, 10 ether);
    }

    // function testFailTransferFrom() public {
    function test_RevertWhen_TransferFrom() public {
        upside_token.pause();
        vm.prank(alice);
        upside_token.approve(msg.sender, 10 ether);
        vm.expectRevert();
        upside_token.transferFrom(alice, bob, 10 ether);
    }
}