//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Token} from "src/Token.sol";

contract Subscription {

    Token token;

    constructor(address _addrOfToken) {
        token = Token(payable(_addrOfToken));
    }

    mapping(bytes32 => Service) codeToService;

    mapping(bytes32 => address) codeToSeller;

    modifier BurnToken(uint256 _fees) {
        token.burnFrom(msg.sender, _fees);
        _;
    }

    uint256 constant REG_FEES = 5 * 1e18;

    function sellerRegister() external BurnToken(REG_FEES) {
        require(SellerLogs[msg.sender].isActive == false, "Already Registered");
        SellerLogs[msg.sender].isActive = true;
    }

    function getCode(address _caller) internal view returns (bytes32) {
        bytes32 code = keccak256(abi.encode(_caller, blockhash(block.timestamp - 1)));
        return code;
    }

    //All the price should be set on the basis of SRT Token

    struct Seller {
        mapping(uint256 => Service) listOfService;
        bool isActive;
        uint256 noOfService;
        uint256 balance;
    }

    mapping(address => Seller) public SellerLogs;

    uint256 constant LIST_FEES = 1e18;

    function listService(
        string calldata _name,
        string calldata _description,
        Plans plan,
        uint256 _priceOfMonthly,
        uint256 _priceOfYearly
    ) external BurnToken(LIST_FEES) returns (bytes32) {

        require(SellerLogs[msg.sender].isActive == true, "Not a Seller");
        require(_priceOfMonthly != uint256(0), "Price can't be Zero");
        require(_priceOfYearly != uint256(0), "Price can't be Zero");

        bytes32 code = getCode(msg.sender);
        Service storage service = codeToService[code];

        if (plan == Plans.BOTH) {
            service.priceOfMonthly = _priceOfMonthly;
            service.priceOfYearly = _priceOfYearly;
        } else if (plan == Plans.MONTHLY) {
            service.priceOfMonthly = _priceOfMonthly;
        } else if (plan == Plans.YEARLY) {
            service.priceOfYearly = _priceOfYearly;
        } else if (plan == Plans.NONE) {
            revert("Plan is not Selected");
        }

        service.name = _name;
        service.description = _description;
        service.code = code;

        Seller storage seller = SellerLogs[msg.sender];
        seller.listOfService[seller.noOfService] = service;

        seller.noOfService++;

        codeToSeller[code] = msg.sender;

        return code;
    }

    enum Plans {
        NONE,
        BOTH,
        MONTHLY,
        YEARLY
    }

    mapping(address => User) Userinfo;

    struct User {
        bool isActive;
        mapping(uint256 => ServiceStatus) serviceLogs;
        uint256 noOfServices;
    }

    struct ServiceStatus {
        Service service;
        uint256 boughtServiceOn;
        uint256 ServiceAvailableTill;
    }

    struct Service {
        string name;
        string description;
        bytes32 code;
        uint256 priceOfMonthly;
        uint256 priceOfYearly;
    }

    uint256 constant REG_FEES_USER = 1e18;

    function UserRegistration() external BurnToken(REG_FEES_USER) {
        require(Userinfo[msg.sender].isActive == false, "Already Registered");
        Userinfo[msg.sender].isActive = true;
    }

    function buySubscription(bytes32 code, Plans plan) external {
        
        require(Userinfo[msg.sender].isActive == true, "Not a user");
        require(code != bytes32(0),"invalid code");
        require(plan == Plans.MONTHLY || plan == Plans.YEARLY,"Choose a valid Plan");

        User storage user = Userinfo[msg.sender];
        uint256 id = user.noOfServices;
        uint256 duration;
        uint256 tokenToTransfer;

        Service memory service = codeToService[code];

        if (plan == Plans.YEARLY) {
            duration = 52 weeks;
            tokenToTransfer = service.priceOfYearly;
        } else if (plan == Plans.MONTHLY) {
            duration = 4 weeks;
            tokenToTransfer = service.priceOfMonthly;
        }

        ServiceStatus storage serviceStatus = user.serviceLogs[id];
        serviceStatus.service = service;
        serviceStatus.boughtServiceOn = block.timestamp;
        serviceStatus.ServiceAvailableTill = block.timestamp + duration;

        address seller = codeToSeller[code];

        token.transferFrom(msg.sender, seller, tokenToTransfer);
        user.noOfServices++;
    }
}
