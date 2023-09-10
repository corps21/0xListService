//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is ERC20Burnable {
    address immutable owner;
    uint256 public balanceOfOwner;

    mapping(address => bool) useAllowance;

    constructor() ERC20("Service Token", "SRT") {
        owner = msg.sender;
        _mint(msg.sender, 10000000 * 1e18);
    }

    //1 SRT ---> 1 ETH;
    uint256 constant _priceOfToken = 1e18;

    modifier checkAmount(uint256 _tokenAmount) {
        require(_tokenAmount * _priceOfToken == msg.value, "notEnoughEth");
        _;
    }

    function buyAndApprove(uint256 _tokenAmount, address _toBeApproved) external payable {
        buyToken(_tokenAmount);
        if (useAllowance[msg.sender] == true) {
            increaseAllowance(_toBeApproved, _tokenAmount * (10 ** decimals()));
        } else {
            approve(_toBeApproved, _tokenAmount * (10 ** decimals()));
            useAllowance[msg.sender] = true;
        }
    }

    function buyToken(uint256 _tokenAmount) public payable checkAmount(_tokenAmount) {
        _mint(msg.sender, _tokenAmount * (10 ** decimals()));
        balanceOfOwner += 1e18;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not Owner");
        (bool success,) = payable(owner).call{value: balanceOfOwner}("");
        require(success, "call failed");
        balanceOfOwner = 0;
    }

    function convertEthToToken(uint256 _amount) public pure returns (uint256) {
        uint256 amountofToken = (_amount * 1e18) / 1e18;
        return amountofToken;
    }

    receive() external payable {
        buyToken(convertEthToToken(msg.value));
    }
}
