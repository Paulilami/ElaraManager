// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.Counter";
import "./ISubIdManager.sol";
import "./SubId.sol"; // Assuming SubId.sol is in the same directory

contract ElaraFramework is IElaraFramework, AccessControl {
    using Counters for Counters.Counter;

    // Roles for access control
    bytes32 public constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");
    bytes32 public constant FRAMEWORK_ADMIN_ROLE = keccak256("FRAMEWORK_ADMIN_ROLE");

    // Instance of the SubIdManager contract
    ISubIdManager public subIdManager;

    // Counter for tracking the total number of sub-IDs created
    Counters.Counter private _totalSubIds;

    constructor(ISubIdManager manager) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FRAMEWORK_ADMIN_ROLE, msg.sender);
        subIdManager = manager;
    }

    // Function to create a new sub-ID
    function createSubId(bytes32 dataHash, uint256 fee) external payable override returns (uint256 subId) {
        subIdManager.createSubId{value: msg.value}(dataHash, fee);
        _totalSubIds.increment();
        return subId;
    }

    // Function to deploy the custom framework logic for a sub-ID (callable by owner)
    function deploySubId(uint256 subId, bytes memory bytecode) external override onlyRole(subIdManager.getSubIdOwner(subId)) {
        subIdManager.deploySubId(subId, bytecode);
    }

    // Function to retrieve the owner address of a sub-ID (delegated to SubIdManager)
    function getSubIdOwner(uint256 subId) external view override returns (address owner) {
        return subIdManager.getSubIdOwner(subId);
    }

    // Function to retrieve the deployed sub-ID contract address for a sub-ID (delegated to SubIdManager)
    function getSubIdContract(uint256 subId) external view override returns (address deployedSubId) {
        return subIdManager.getSubIdContract(subId);
    }

    // Function to retrieve the creator address of a sub-ID (delegated to SubIdManager)
    function getSubIdCreator(uint256 subId) external view override returns (address creator) {
        return subIdManager.getSubIdCreator(subId);
    }

    // Function to retrieve the total number of sub-IDs created (delegated to SubIdManager)
    function getTotalSubIds() external view override returns (uint256 totalSubIds) {
        return subIdManager.getTotalSubIds();
    }

    // Function to check if a specific sub-ID exists (delegated to SubIdManager)
    function subIdExists(uint256 subId) external view override returns (bool exists) {
        return subIdManager.subIdExists(subId);
    }

    // Function to revoke a sub-ID (only accessible by SUB_ID_MANAGER_ROLE)
    function revokeSubId(uint256 subId) external override onlyRole(SUB_ID_MANAGER_ROLE) {
        subIdManager.revokeSubId(subId);
    }

    // Function to update the data hash of a sub-ID (only accessible by SUB_ID_MANAGER_ROLE)
    function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external override onlyRole(SUB_ID_MANAGER_ROLE) {
        subIdManager.updateSubIdDataHash(subId, newDataHash);
    }

    // Function to set the sub-ID creation fee (only accessible by FRAMEWORK_ADMIN_ROLE)
    function setSubIdFee(uint256 newFee) external override onlyRole(FRAMEWORK_ADMIN_ROLE) {
        subIdManager.setSubIdFee(newFee);
    }

    // Function to set the sub-ID creation limit (only accessible by FRAMEWORK_ADMIN_ROLE)
    function setSubIdLimit(uint256 newLimit) external override onlyRole(FRAMEWORK_ADMIN_ROLE) {
        require(newLimit > _totalSubIds.current(), "New limit must be greater than existing sub-IDs");
        subIdManager.setSubIdLimit(newLimit);
    }

    // Function to retrieve the current sub-ID creation fee
    function getSubIdFee() external view override returns (uint256 fee) {
        return subIdManager.getSubIdFee();
    }

    // Function to retrieve the current sub-ID creation limit
    function getSubIdLimit() external view override returns (uint256 limit) {
        return subIdManager.getSubIdLimit();
    }

    // Function to allow users to withdraw collected fees (optional, can be modified)
    function withdrawFees() external override onlyRole(FRAMEWORK_ADMIN_ROLE) {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Example function demonstrating interaction with a sub-ID contract (optional)
    function callSubIdFunction(uint256 subId, string memory functionName, bytes memory data) external payable override {
        address deployedSubId = getSubIdContract(subId);
        require(deployedSubId != address(0), "Sub-ID contract not deployed");

        (bool success, bytes memory returnData) = deployedSubId.call{value: msg.value}(abi.encodeWithSelector(keccak256(functionName), data));
        require(success, "Sub-ID function call failed");
    }
}
