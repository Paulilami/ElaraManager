// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ElaraRoles is AccessControl {


    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    constructor(address initialAdmin) {
        _setupRole(ADMIN_ROLE, initialAdmin);
    }
    bytes32 public constant ROLE_MANAGER_ROLE = keccak256("ROLE_MANAGER_ROLE");

    constructor(address initialAdmin) {
        _setupRole(ADMIN_ROLE, initialAdmin);

        _setupRole(ROLE_MANAGER_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public onlyRole(ROLE_MANAGER_ROLE) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public onlyRole(ROLE_MANAGER_ROLE) {
        _revokeRole(role, account);
    }
    
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return hasRole(role, account);
    }
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed grantor, uint256 timestamp);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed revoker, uint256 timestamp);
}



