//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {Subscription} from "../src/Subscription.sol";
import {Token} from "../src/Token.sol";

contract TestSubscription is Test {
    
    address addOfOwner = makeAddr("Owner");
    address addOfAttacker = makeAddr("Attacker");
    address addOfUser = makeAddr("User");

    Subscription subscription;
    Token token;

    uint256 constant REG_FEES_USER = 1e18; // 1SRT
    uint256 constant REG_FEES = 5 * 1e18; // 5SRT
    
    function setUp() public {
        vm.startPrank(addOfOwner);
        token = new Token();
        subscription = new Subscription(address(token));
        vm.stopPrank();
    }

    function test_SellerRegistration() external {
        deal(address(token), addOfUser, REG_FEES);
        

        vm.startPrank(addOfUser);
        token.approve(address(subscription),REG_FEES);
        subscription.sellerRegister();
        vm.stopPrank();
        

        (bool data,,) = subscription.SellerLogs(addOfUser);
        assertEq(data, true);
        assertEq(token.balanceOf(addOfUser), 0);
    }

    function testfails_sellerRegistration() external {
        deal(address(token), addOfUser, 2 * REG_FEES);

        vm.startPrank(addOfUser);
        token.approve(address(subscription),REG_FEES);
        subscription.sellerRegister();

        vm.expectRevert();
        subscription.sellerRegister();

        vm.stopPrank();
    }
}