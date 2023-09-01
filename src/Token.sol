//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import { ERC20 } from "lib/openzepplin-contracts/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract Token is ERC20Burnable {
    address immutable NETFLIX;
    uint256 balanceOfOwner;

    constructor() ERC20("Netflix Token", "NTFLX"){
        NETFLIX = msg.sender;
        _mint(msg.sender, 10000000 * 1e18);
    }


    //1 NTFLX ---> 1 ETH;
    uint256 constant _priceOfToken = 1e18;

    modifier checkAmount(uint256 _tokenAmount){
        require(_tokenAmount * _priceOfToken == msg.value,"notEnoughEth");
        _;
    }

    function buyToken(uint256 _tokenAmount) external payable checkAmount(_tokenAmount){
        _mint(msg.sender, _tokenAmount * (10 ** decimals()));
        balanceOfOwner += 1e18;
    }

    function withdraw() external {
        require(msg.sender == NETFLIX,"Not Owner");
        (bool success, ) = payable(NETFLIX).call{value:balanceOfOwner}("");
        require(success,"call failed");
        balanceOfOwner=0;
    } 
}
