//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is ERC20Burnable {
    address immutable owner;

    mapping(address => bool) useAllowance;

    constructor() ERC20("Service Token", "SRT") {
        owner = msg.sender;
        _mint(msg.sender, 10000 * (10 ** decimals()));
    }
    

    /* 
        1 SRT = 1 * 10 ** 18 base unit tokens
        1 SRT ---> 1 ETH;
        all the operations will be according to the base unit tokens suppose
        you want to transfer 100 SRT, you have to call the transfer function and pass `100 * 10 ** 18`
    */

    uint256 constant _priceOfOneToken = 1 * 1e18;

    modifier checkAmount(uint256 _tokenAmount) {
        require(_tokenAmount  * _priceOfOneToken / 1e18 == msg.value, "notEnoughEth");
        _;
    }

    function buyAndApprove(uint256 _tokenAmount, address _toBeApproved) external payable {
        buyToken(_tokenAmount);
        if (useAllowance[msg.sender] == true) {
            increaseAllowance(_toBeApproved, _tokenAmount);
        } else {
            approve(_toBeApproved, _tokenAmount);
            useAllowance[msg.sender] = true;
        }
    }

    function buyToken(uint256 _tokenAmount) public payable checkAmount(_tokenAmount) {
        _mint(msg.sender, _tokenAmount);
        withdraw(convertTokenToEth(_tokenAmount));
    }

    function withdraw(uint256 _amount) public {
        (bool success,) = payable(owner).call{value: _amount}("");
        require(success, "call failed");
    }

    function convertEthToToken(uint256 _amountOfEth) public pure returns (uint256) {
        uint256 amountOfToken = (_amountOfEth * 1e18) / 1e18;

        /*
            1 SRT ----> 1e18 wei
            1 SRT -----> 1e18 base unit tokens
            1e18 wei ----> 1e18 base unit token
            1 wei ----> 1e18 base unit token / 1e18 
            x wei ----> 1e18 * x / 1e18 
        
        */

        return amountOfToken;
    }

    function convertTokenToEth(uint256 _amountOfToken) public pure returns (uint256) {
        
        uint256 amountOfEth = (_amountOfToken * _priceOfOneToken) / 1e18;
        
        /*
        
            1 SRT ----> 1e18 wei
            1 SRT -----> 1e18 base unit tokens
            1e18 base unit token -----> 1e18 wei
            1 base unit token ---> 1e18 / 1e18;
            x base units -----> (x * 1e18) / 1e18;

         */

        return amountOfEth;
    }

    receive() external payable {
        uint256 amountOfToken = convertEthToToken(msg.value);
        buyToken(amountOfToken);
    }
}
