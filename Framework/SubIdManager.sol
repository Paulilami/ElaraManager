// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SubIdManager is ISubIdManager {
    using Counters for Counters.Counter;

    // Counter for tracking the total number of sub-IDs created
    Counters.Counter private _totalSubIds;

    // Mapping to store sub-ID information
    mapping(uint256 => SubIdInfo) private _subIds;

    // Current fee for creating a sub-ID (optional, can be removed)
    uint256 private _subIdFee;

    // Optional limit on the number of sub-IDs a user can create
    uint256 private _subIdLimit;

    // Roles for access control
    bytes32 public constant SUB_ID_MANAGER_ROLE = keccak256("SUB_ID_MANAGER_ROLE");

    struct SubIdInfo {
        address owner;
        address deployedSubId;
        bytes32 dataHash;
        uint256 creationTimestamp;
    }

    constructor(uint256 initialFee, uint256 initialLimit) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SUB_ID_MANAGER_ROLE, msg.sender);
        _subIdFee = initialFee;
        _subIdLimit = initialLimit;
    }

    // Function to create a new sub-ID
    function createSubId(bytes32 dataHash, uint256 fee) external payable override returns (uint256 subId) {
        require(fee >= _subIdFee, "Insufficient fee provided for sub-ID creation");
        if (_subIdLimit > 0) {
            require(balanceOf(msg.sender) < _subIdLimit, "Sub-ID creation limit reached");
        }

        uint256 newSubId = _totalSubIds.current();
        _subIds[newSubId] = SubIdInfo(msg.sender, address(0), dataHash, block.timestamp);
        _totalSubIds.increment();

        // Handle optional fee collection (can be modified for specific fee management)
        if (fee > 0) {
            payable(address(this)).transfer(fee);
        }

        emit SubIdCreated(newSubId, msg.sender, address(0), block.timestamp);
        return newSubId;
    }

    // Function to deploy the custom framework logic for a sub-ID (callable by owner)
    function deploySubId(uint256 subId, bytes memory bytecode) external {
        require(_subIds[subId].owner == msg.sender, "Only owner can deploy sub-ID logic");
        require(_subIds[subId].deployedSubId == address(0), "Sub-ID logic already deployed");

        address deployedSubId = address(new ContractInstance(bytecode));
        _subIds[subId].deployedSubId = deployedSubId;

        emit SubIdCreated(subId, msg.sender, deployedSubId, block.timestamp);
    }

    // Function to retrieve the owner address of a sub-ID
    function getSubIdOwner(uint256 subId) external view override returns (address owner) {
        return _subIds[subId].owner;
    }

    // Function to retrieve the deployed sub-ID contract address for a sub-ID
    function getSubIdContract(uint256 subId) external view override returns (address deployedSubId) {
        return _subIds[subId].deployedSubId;
    }

    // Function to retrieve the creator address of a sub-ID
    function getSubIdCreator(uint256 subId) external view override returns (address creator) {
        return _subIds[subId].owner; // In this implementation, creator is the same as owner
    }

    // Function to retrieve the total number of sub-IDs created
    function getTotalSubIds() external view override returns (uint256 totalSubIds) {
        return _totalSubIds.current();
    }

    // Function to check if a specific sub-ID exists
    function subIdExists(uint256 subId) external view override returns (bool exists) {
        return _subIds[subId].owner != address(0);
    }

    // Function to revoke a sub-ID (only accessible by SUB_ID_MANAGER_ROLE)
function revokeSubId(uint256 subId) external override onlyRole(SUB_ID_MANAGER_ROLE) {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
    emit SubIdRevoked(subId, _subIds[subId].owner, msg.sender, block.timestamp);
    delete _subIds[subId];
}

// Function to update the data hash of a sub-ID (only accessible by SUB_ID_MANAGER_ROLE)
function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external override onlyRole(SUB_ID_MANAGER_ROLE) {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
    bytes32 oldDataHash = _subIds[subId].dataHash;
    _subIds[subId].dataHash = newDataHash;
    emit SubIdDataHashUpdated(subId, _subIds[subId].owner, oldDataHash, newDataHash, block.timestamp);
}

// Function to set the sub-ID creation fee (only accessible by ADMIN_ROLE)
function setSubIdFee(uint256 newFee) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _subIdFee = newFee;
}

// Function to set the sub-ID creation limit (only accessible by ADMIN_ROLE)
function setSubIdLimit(uint256 newLimit) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _subIdLimit = newLimit;
}

// Function to retrieve the current sub-ID creation fee
function getSubIdFee() external view override returns (uint256 fee) {
    return _subIdFee;
}

// Function to retrieve the current sub-ID creation limit
function getSubIdLimit() external view override returns (uint256 limit) {
    return _subIdLimit;
}

// Function to allow users to withdraw collected fees (optional, can be modified)
function withdrawFees() external onlyRole(DEFAULT_ADMIN_ROLE) {
    payable(msg.sender).transfer(address(this).balance);
    }

 //Helpers 

 function hasRole(address account, bytes32 role) public view returns (bool) {
    return hasRole(role, account);
}
function getTimestamp() public view returns (uint256) {
    return block.timestamp;
}
function safeTransfer(address to, uint256 value) internal {
    (bool success, ) = payable(to).call{value: value}("");
    require(success, "Transfer failed");
}
function getContractAddress(uint256 subId) public view returns (address) {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
    return _subIds[subId].deployedSubId;
}
function validateSubId(uint256 subId) public view {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
}
function getSubIdInfo(uint256 subId) public view returns (SubIdInfo memory) {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
    return _subIds[subId];
    }

}



contract ContractInstance {
    // Address of the SubIdManager that deployed this contract
    address public immutable subIdManager;

    // Optional data associated with the sub-ID (can be customized)
    bytes public data;

    constructor(bytes memory bytecode, address manager) {
        subIdManager = manager;

        // Deploy the actual sub-ID logic using provided bytecode
        assembly {
            let ptr := add(bytecode, 0x20)
            let size := mload(bytecode)
            call(gas(), create(0), 0, ptr, size)
            pop
        }
    }

    // Function to receive incoming funds (optional, can be customized)
    fallback() external payable {}

    // Function to receive incoming funds and data (optional, can be customized)
    receive() external payable {
        data = msg.data;
    }
}
