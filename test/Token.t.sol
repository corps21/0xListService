//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {Token} from "../src/Token.sol";

contract TestToken is Test {
    address addOfOwner = makeAddr("Owner");
    address addOfAttacker = makeAddr("Attacker");
    address addOfUser = makeAddr("User");

    Token token;

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
        uint256 tokenAmount = 10;
        uint256 priceOfToken = 1e18;
        uint256 balanceOfUser = tokenAmount * priceOfToken;
        deal(addOfUser, balanceOfUser);
        console.log(address(addOfUser).balance);
        
        vm.startPrank(addOfUser);
        token.buyToken{value:balanceOfUser}(tokenAmount);
        vm.stopPrank();

        assertEq(token.balanceOf(addOfUser),tokenAmount * (10 ** token.decimals()));
    }
}
