//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {Token} from "../src/Token.sol";

contract TestToken is Test {
    address addOfOwner = makeAddr("Owner");
    address addOfAttacker = makeAddr("Attacker");
    address addOfUser = makeAddr("User");
    address addOfSubscription = makeAddr("Subscription");

    Token token;

    uint256 constant TOKEN_AMOUNT = 10;
    uint256 constant PRICE = 1e18;

    function setUp() public {
        vm.startPrank(addOfOwner);
        token = new Token();
        vm.stopPrank();
    }

    function test_failsIfCalledByOthers() external {
        vm.startPrank(addOfAttacker);
        vm.expectRevert();
        token.withdraw();
        vm.stopPrank();
    }

    function test_Withdraw() external {
        address Contract = address(token);
        deal(Contract, 10 * 1e18);
        vm.prank(addOfOwner);
        token.withdraw();
        assertEq(token.balanceOfOwner(), 0);
    }

    function test_BuyToken() external {
        uint256 balanceOfUser = TOKEN_AMOUNT * PRICE;
        deal(addOfUser, balanceOfUser);
        
        vm.startPrank(addOfUser);
        token.buyToken{value:balanceOfUser}(TOKEN_AMOUNT);
        vm.stopPrank();

        assertEq(token.balanceOf(addOfUser),TOKEN_AMOUNT * (10 ** token.decimals()));
    }

    function test_failsForWrongValue() external {
         //changing the price of Token (1e18) to (1e16) cause revert("notEnoughEth")
        uint256 priceOfToken = 1e16;
        
        uint256 balanceOfUser = TOKEN_AMOUNT * priceOfToken;
        deal(addOfUser, balanceOfUser);
        
        vm.startPrank(addOfUser);
        vm.expectRevert();
        token.buyToken{value:balanceOfUser}(TOKEN_AMOUNT);
        vm.stopPrank();   
    }

    function test_buyAndApprove() external {
        uint256 balanceOfUser = TOKEN_AMOUNT * PRICE;
        deal(addOfUser, balanceOfUser);

        vm.startPrank(addOfUser);
        token.buyAndApprove{value:balanceOfUser}(TOKEN_AMOUNT, addOfSubscription);
        vm.stopPrank();

        assertEq(token.allowance(addOfUser, addOfSubscription), TOKEN_AMOUNT * (10 ** token.decimals()) );
    }

    function test_failsbuyAndApproveForWrongValue() external {
        uint256 price = 1e16; //changing the price of token to cause revert
        uint256 balanceOfUser = TOKEN_AMOUNT * price;
        deal(addOfUser, balanceOfUser);

        vm.startPrank(addOfUser);
        vm.expectRevert();
        token.buyAndApprove{value:balanceOfUser}(TOKEN_AMOUNT, addOfSubscription);
        vm.stopPrank();
    }
}
