// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.Counter";
import "./ISubIdManager.sol";
import "./SubId.sol"; // Assuming SubId.sol is in the same directory
import "./IEmbeddedFrameworks.sol"; 

contract ElaraFramework is IElaraFramework, AccessControl {
    using Counters for Counters.Counter;


    bytes32 public constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");
    bytes32 public constant FRAMEWORK_ADMIN_ROLE = keccak256("FRAMEWORK_ADMIN_ROLE");


    ISubIdManager public subIdManager;


    IEmbeddedFrameworks public embeddedFrameworks;


    Counters.Counter private _totalSubIds;

    constructor(ISubIdManager manager, IEmbeddedFrameworks frameworks) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FRAMEWORK_ADMIN_ROLE, msg.sender);
        subIdManager = manager;
        embeddedFrameworks = frameworks; // Optional: Set the embedded frameworks contract
    }


    function createSubId(bytes32 dataHash, uint256 fee) external payable override returns (uint256 subId) {
        subIdManager.createSubId{value: msg.value}(dataHash, fee);
        _totalSubIds.increment();
        return subId;
    }


    function deploySubId(uint256 subId, bytes memory bytecode) external override onlyRole(subIdManager.getSubIdOwner(subId)) {
        subIdManager.deploySubId(subId, bytecode);
    }


    function deployEmbeddedFramework(uint256 subId, bytes memory bytecode) external payable onlyRole(subIdManager.getSubIdOwner(subId)) returns (address deployedContract) {
        if (address(embeddedFrameworks) != address(0)) {
            deployedContract = embeddedFrameworks.createEmbeddedFramework{value: msg.value}(bytecode, msg.sender);
            subIdManager.setDeployedContract(subId, deployedContract);
            emit EmbeddedFrameworkCreated(deployedContract, msg.sender);
        } else {
            revert("EmbeddedFrameworks contract not set");
        }
    }


    function getSubIdOwner(uint256 subId) external view override returns (address owner) {
        return subIdManager.getSubIdOwner(subId);
    }

    function getSubIdContract(uint256 subId) external view override returns (address deployedSubId) {
        return subIdManager.getSubIdContract(subId);
    }

    function getEmbeddedFrameworkContract(uint256 subId) external view override returns (address deployedContract) {
        return subIdManager.getDeployedContract(subId);
    }
    function getSubIdCreator(uint256 subId) external view override returns (address creator) {
        return subIdManager.getSubIdCreator(subId);
    }

    function getTotalSubIds() external view override returns (uint256 totalSubIds) {
        return subIdManager.getTotalSubIds();
    }

    function subIdExists(uint256 subId) external view override returns (bool exists) {
        return subIdManager.subIdExists(subId);
    }

    function revokeSubId(uint256 subId) external override onlyRole(SUB_ID_MANAGER_ROLE) {
        subIdManager.revokeSubId(subId);
    }

    function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external override onlyRole(SUB_ID_MANAGER_ROLE) {
        subIdManager.updateSubIdDataHash(subId, newDataHash);
    }

    function setSubIdFee(uint256 newFee) external override onlyRole(FRAMEWORK_ADMIN_ROLE) {
        subIdManager.setSubIdFee(newFee);
    }

    function setSubIdLimit(uint256 newLimit) external override onlyRole(FRAMEWORK_ADMIN_ROLE) {
        require(newLimit > _totalSubIds.current(), "New limit must be greater than existing sub-IDs");
        subIdManager.setSubIdLimit(newLimit);
    }

    function getSubIdFee() external view override returns (uint256 fee) {
        return subIdManager.getSubIdFee();
    }

    function getSubIdLimit() external view override returns (uint256 limit) {
        return subIdManager.getSubIdLimit();
    }

    function withdrawFees() external override onlyRole(FRAMEWORK_ADMIN_ROLE) {
        payable(msg.sender).transfer(address(this).balance);
    }

    function callContractFunction(uint256 subId, address contractAddress, string memory functionName, bytes memory data) external payable override {
        (bool success, bytes memory returnData) = contractAddress.call{value: msg.value}(abi.encodeWithSelector(keccak256(functionName), data));
        require(success, "Contract function call failed");
    }
}
