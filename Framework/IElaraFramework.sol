// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IElaraFramework {
    // Roles for access control within the framework
    bytes32 constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");
    bytes32 constant FRAMEWORK_ADMIN_ROLE = keccak256("FRAMEWORK_ADMIN_ROLE");

    // Function to create a new sub-ID
    function createSubId(bytes32 dataHash, uint256 fee) external payable returns (uint256 subId);

    // Function to deploy the custom framework logic for a sub-ID (callable by owner)
    function deploySubId(uint256 subId, bytes memory bytecode) external;

    // Function to retrieve the owner address of a sub-ID
    function getSubIdOwner(uint256 subId) external view returns (address owner);

    // Function to retrieve the deployed sub-ID contract address for a sub-ID
    function getSubIdContract(uint256 subId) external view returns (address deployedSubId);

    // Function to retrieve the creator address of a sub-ID
    function getSubIdCreator(uint256 subId) external view returns (address creator);

    // Function to retrieve the total number of sub-IDs created
    function getTotalSubIds() external view returns (uint256 totalSubIds);

    // Function to check if a specific sub-ID exists
    function subIdExists(uint256 subId) external view returns (bool exists);

    // Function to revoke a sub-ID (only accessible by SUB_ID_MANAGER_ROLE)
    function revokeSubId(uint256 subId) external;

    // Function to update the data hash of a sub-ID (only accessible by SUB_ID_MANAGER_ROLE)
    function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external;

    // Function to set the sub-ID creation fee (only accessible by FRAMEWORK_ADMIN_ROLE)
    function setSubIdFee(uint256 newFee) external;

    // Function to set the sub-ID creation limit (only accessible by FRAMEWORK_ADMIN_ROLE)
    function setSubIdLimit(uint256 newLimit) external;

    // Function to retrieve the current sub-ID creation fee
    function getSubIdFee() external view returns (uint256 fee);

    // Function to retrieve the current sub-ID creation limit
    function getSubIdLimit() external view returns (uint256 limit);

    // Function to allow users to withdraw collected fees (optional, can be modified)
    function withdrawFees() external;

    // Example function demonstrating interaction with a sub-ID contract (optional)
    function callSubIdFunction(uint256 subId, string memory functionName, bytes memory data) external payable;
}
