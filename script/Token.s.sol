//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {Token} from "src/Token.sol";
import {Subscription} from "src/Subscription.sol";

contract DeployToken is Script {
    function run() external {
        vm.broadcast();
        Token token = new Token();
        new Subscription(address(token));
    }
}
