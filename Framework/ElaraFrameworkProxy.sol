// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ElaraFramework.sol"; // Assuming ElaraFramework.sol is in the same directory

contract ElaraFrameworkProxy is TransparentUpgradeableProxy, Ownable {
    constructor(address logicContract, bytes memory data) TransparentUpgradeableProxy(logicContract, data) {}

    function upgradeTo(address newImplementation) public onlyOwner {
        _upgradeTo(newImplementation);
    }
}
