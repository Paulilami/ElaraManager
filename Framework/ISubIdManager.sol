// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface ISubIdManager is AccessControl {

    // Events emitted for sub-ID lifecycle management
    event SubIdCreated(uint256 subId, address owner, address deployedSubId, uint256 creationTimestamp);
    event SubIdRevoked(uint256 subId, address owner, address revokedBy, uint256 revocationTimestamp);
    event SubIdDataHashUpdated(uint256 subId, address owner, bytes32 oldDataHash, bytes32 newDataHash, uint256 updateTimestamp);

    // Role for managing sub-IDs (separate from ADMIN_ROLE)
    bytes32 constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");

    // Function to create a new sub-ID with optional fee payment
    function createSubId(bytes32 dataHash, uint256 fee) external payable returns (uint256 subId);

    // Function to retrieve the creator address of a sub-ID
    function getSubIdCreator(uint256 subId) external view returns (address creator);

    // Function to retrieve the total number of sub-IDs created
    function getTotalSubIds() external view returns (uint256 totalSubIds);

    // Function to check if a specific sub-ID exists
    function subIdExists(uint256 subId) external view returns (bool exists);

    // Optional functions for advanced management
    function revokeSubId(uint256 subId) external onlyRole(SUB_ID_MANAGER_ROLE);
    function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external onlyRole(SUB_ID_MANAGER_ROLE);
    function setSubIdFee(uint256 newFee) external onlyRole(ADMIN_ROLE); // Allow fee configuration (optional)
    function setSubIdLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE); // Allow setting sub-ID creation limit (optional)
    function getSubIdFee() external view returns (uint256 fee); // Allow retrieving current sub-ID creation fee (optional)
    function getSubIdLimit() external view returns (uint256 limit); // Allow retrieving current sub-ID creation limit (optional)
}

