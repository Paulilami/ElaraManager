// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SubIdManager is ISubIdManager {
    using Counters for Counters.Counter;

    Counters.Counter private _totalSubIds;

    mapping(uint256 => SubIdInfo) private _subIds;

    uint256 private _subIdFee;
    uint256 private _subIdLimit;
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

    function createSubId(bytes32 dataHash, uint256 fee) external payable override returns (uint256 subId) {
        require(fee >= _subIdFee, "Insufficient fee provided for sub-ID creation");
        if (_subIdLimit > 0) {
            require(balanceOf(msg.sender) < _subIdLimit, "Sub-ID creation limit reached");
        }

        uint256 newSubId = _totalSubIds.current();
        _subIds[newSubId] = SubIdInfo(msg.sender, address(0), dataHash, block.timestamp);
        _totalSubIds.increment();

        if (fee > 0) {
            payable(address(this)).transfer(fee);
        }

        emit SubIdCreated(newSubId, msg.sender, address(0), block.timestamp);
        return newSubId;
    }

    function deploySubId(uint256 subId, bytes memory bytecode) external {
        require(_subIds[subId].owner == msg.sender, "Only owner can deploy sub-ID logic");
        require(_subIds[subId].deployedSubId == address(0), "Sub-ID logic already deployed");

        address deployedSubId = address(new ContractInstance(bytecode));
        _subIds[subId].deployedSubId = deployedSubId;

        emit SubIdCreated(subId, msg.sender, deployedSubId, block.timestamp);
    }

    function getSubIdOwner(uint256 subId) external view override returns (address owner) {
        return _subIds[subId].owner;
    }

    function getSubIdContract(uint256 subId) external view override returns (address deployedSubId) {
        return _subIds[subId].deployedSubId;
    }

    function getSubIdCreator(uint256 subId) external view override returns (address creator) {
        return _subIds[subId].owner; // In this implementation, creator is the same as owner
    }

    function getTotalSubIds() external view override returns (uint256 totalSubIds) {
        return _totalSubIds.current();
    }

    function subIdExists(uint256 subId) external view override returns (bool exists) {
        return _subIds[subId].owner != address(0);
    }

function revokeSubId(uint256 subId) external override onlyRole(SUB_ID_MANAGER_ROLE) {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
    emit SubIdRevoked(subId, _subIds[subId].owner, msg.sender, block.timestamp);
    delete _subIds[subId];
}

function updateSubIdDataHash(uint256 subId, bytes32 newDataHash) external override onlyRole(SUB_ID_MANAGER_ROLE) {
    require(_subIds[subId].owner != address(0), "Sub-ID does not exist");
    bytes32 oldDataHash = _subIds[subId].dataHash;
    _subIds[subId].dataHash = newDataHash;
    emit SubIdDataHashUpdated(subId, _subIds[subId].owner, oldDataHash, newDataHash, block.timestamp);
}

function setSubIdFee(uint256 newFee) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _subIdFee = newFee;
}

function setSubIdLimit(uint256 newLimit) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _subIdLimit = newLimit;
}

function getSubIdFee() external view override returns (uint256 fee) {
    return _subIdFee;
}

function getSubIdLimit() external view override returns (uint256 limit) {
    return _subIdLimit;
}

function withdrawFees() external onlyRole(DEFAULT_ADMIN_ROLE) {
    payable(msg.sender).transfer(address(this).balance);
    }

//helpers 

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
