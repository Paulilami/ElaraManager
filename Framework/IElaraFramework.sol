// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IElaraFramework {

    bytes32 constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");
    bytes32 constant FRAMEWORK_ADMIN_ROLE = keccak256("FRAMEWORK_ADMIN_ROLE");


    function createSubId(bytes32 dataHash, uint256 fee) external payable returns (uint256 subId);

    function deploySubId(uint256 subId, bytes memory bytecode) external;

    function getSubIdOwner(uint256 subId) external view returns (address owner);

    function getSubIdContract(uint256 subId) external view returns (address deployedSubId);

    function getSubIdCreator(uint256 subId) external view returns (address creator);

    function getTotalSubIds() external view returns (uint256 totalSubIds);

    function subIdExists(uint256 subId) external view returns (bool exists);

    function revokeSubId(uint256 subId) external;

    function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external;

    function setSubIdFee(uint256 newFee) external;

    function setSubIdLimit(uint256 newLimit) external;

    function getSubIdFee() external view returns (uint256 fee);

    function getSubIdLimit() external view returns (uint256 limit);

    function withdrawFees() external;

    function callSubIdFunction(uint256 subId, string memory functionName, bytes memory data) external payable;
}
