// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface ISubIdManager is AccessControl {

    event SubIdCreated(uint256 subId, address owner, address deployedSubId, uint256 creationTimestamp);
    event SubIdRevoked(uint256 subId, address owner, address revokedBy, uint256 revocationTimestamp);
    event SubIdDataHashUpdated(uint256 subId, address owner, bytes32 oldDataHash, bytes32 newDataHash, uint256 updateTimestamp);

    bytes32 constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");

    function createSubId(bytes32 dataHash, uint256 fee) external payable returns (uint256 subId);

    function getSubIdCreator(uint256 subId) external view returns (address creator);

    function getTotalSubIds() external view returns (uint256 totalSubIds);

    function subIdExists(uint256 subId) external view returns (bool exists);

    function revokeSubId(uint256 subId) external onlyRole(SUB_ID_MANAGER_ROLE);
    function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external onlyRole(SUB_ID_MANAGER_ROLE);
    function setSubIdFee(uint256 newFee) external onlyRole(ADMIN_ROLE); // Allow fee configuration (optional)
    function setSubIdLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE); // Allow setting sub-ID creation limit (optional)
    function getSubIdFee() external view returns (uint256 fee); // Allow retrieving current sub-ID creation fee (optional)
    function getSubIdLimit() external view returns (uint256 limit); // Allow retrieving current sub-ID creation limit (optional)
}

