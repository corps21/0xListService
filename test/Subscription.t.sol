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
    uint256 constant LIST_FEES = 1e18; // 1SRT
    
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

    function test_getCode() external {
     
         bytes32 code = keccak256(abi.encode(addOfUser, blockhash(block.timestamp - 1)));

        (bytes32 _output) = subscription.getCode(addOfUser);

        assertEq(_output, code);
    }

    function test_listService() external {
        
        string memory name = "name";
        string memory description = "description";
        Subscription.Plans plan = Subscription.Plans.MONTHLY;
        uint256 amountOfMonthly = 1e18; // 1 SRT

        bytes32 code;
        deal(address(token), addOfUser, REG_FEES + LIST_FEES);
        
        vm.startPrank(addOfUser);
        token.approve(address(subscription), REG_FEES + LIST_FEES);
        subscription.sellerRegister();
        code = subscription.listService(name, description, plan, amountOfMonthly, uint256(0));
        vm.stopPrank();

        assertEq(token.balanceOf(addOfUser), 0);
        assertEq(subscription.codeToSeller(code), addOfUser);
        
        (string memory _name, string memory _description, bytes32 _code, bool _isMonthlyActive, bool _isYearlyActive, uint256 _priceOfMonthly, uint256 _priceOfYearly) = subscription.codeToService(code);

        assertEq(_name, name);
        assertEq(_description, description);
        assertEq(_code, code);
        assertEq(_isMonthlyActive, true);
        assertEq(_isYearlyActive,false);
        assertEq(_priceOfMonthly, amountOfMonthly);
        assertEq(_priceOfYearly, uint256(0));
    }


    function test_userRegistration() external {
        deal(address(token), addOfUser, REG_FEES_USER);

        vm.startPrank(addOfUser);
        token.approve(address(subscription), REG_FEES_USER);
        subscription.UserRegistration();
        vm.stopPrank();

        (bool data,) = subscription.Userinfo(addOfUser);

        assertEq(data, true);
    }

    function testfails_userRegistration() external {
        deal(address(token), addOfUser, 2 * REG_FEES_USER);

        vm.startPrank(addOfUser);
        token.approve(address(subscription), REG_FEES_USER);
        subscription.UserRegistration();
        vm.expectRevert();
        subscription.UserRegistration();
        vm.stopPrank();
    }

    function test_buySubscription() external {
    }
}