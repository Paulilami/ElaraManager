// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ElaraRoles is AccessControl {

    // Define initial universal roles for the Elara Framework ecosystem
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    constructor(address initialAdmin) {
        // Grant the ADMIN_ROLE to the specified address during deployment
        _setupRole(ADMIN_ROLE, initialAdmin);
    }
    // Define a role for managing other roles (optional)
    bytes32 public constant ROLE_MANAGER_ROLE = keccak256("ROLE_MANAGER_ROLE");

    constructor(address initialAdmin) {
        // Grant the ADMIN_ROLE to the specified address during deployment
        _setupRole(ADMIN_ROLE, initialAdmin);

        // Grant the ROLE_MANAGER_ROLE to the deployer by default (can be adjusted)
        _setupRole(ROLE_MANAGER_ROLE, msg.sender);
    }

    // Function to grant a specific role to an address (with permission check)
    function grantRole(bytes32 role, address account) public onlyRole(ROLE_MANAGER_ROLE) {
        _grantRole(role, account);
    }

    // Function to revoke a specific role from an address (with permission check)
    function revokeRole(bytes32 role, address account) public onlyRole(ROLE_MANAGER_ROLE) {
        _revokeRole(role, account);
    }
    
    // Function to check if an address has a specific role
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return hasRole(role, account);
    }

    // Emitted when a role is granted or revoked (with additional information)
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed grantor, uint256 timestamp);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed revoker, uint256 timestamp);
}



