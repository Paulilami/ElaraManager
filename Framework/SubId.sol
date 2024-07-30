// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubId {
    address public immutable subIdManager;

    bytes public data;

    mapping(string => bytes) public userData;

    constructor(bytes memory bytecode, address manager) {
        subIdManager = manager;
        data = "This is an example SubId contract";
    }

    function updateData(bytes memory newData) public onlySubIdManager {
        data = newData;
    }

    function setUserData(string memory key, bytes memory value) public {
        userData[key] = value;
    }

    function getUserData(string memory key) public view returns (bytes memory) {
        return userData[key];
    }

    function getSubIdOwner() public view returns (address) {
        // Leverage SubIdManager functions to retrieve owner information
        return ISubIdManager(subIdManager).getSubIdOwner(tx.origin);
    }

    function callExternalService(string memory url, bytes memory data) public payable {
        //holder
    }


    function transferERC20(address tokenAddress, address recipient, uint256 amount) public {
        IERC20(tokenAddress).transfer(recipient, amount);
    }


    function onERC20Received(address sender, address from, uint256 value, bytes calldata data) public virtual returns (bytes4) {
		//holder
        return this.onERC20Received.selector;
    }

    fallback() external payable {}

    modifier onlySubIdManager() {
        require(msg.sender == subIdManager, "Only SubIdManager can call this function");
        _;
    }
}

