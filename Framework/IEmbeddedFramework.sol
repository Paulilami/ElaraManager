// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEmbeddedFrameworks {
    // Function to create a new embedded framework contract
    function createEmbeddedFramework(bytes memory bytecode, address owner) external payable returns (address deployedContract);

    // Function to call a function on an existing embedded framework contract
    function callFunction(address deployedContract, string memory functionName, bytes memory data) external payable returns (bytes memory returnData);

    // Function to retrieve the owner address of an embedded framework contract
    function getOwner(address deployedContract) external view returns (address owner);

    // Function to check if a specific embedded framework contract exists (optional)
    function exists(address deployedContract) external view returns (bool exists);

    // Function to revoke an embedded framework contract (restricted access, optional)
    function revoke(address deployedContract) external;

    // Function to upgrade an embedded framework contract (restricted access, optional)
    function upgrade(address deployedContract, bytes memory newBytecode) external;

    // Event emitted when a new embedded framework contract is created
    event EmbeddedFrameworkCreated(address deployedContract, address owner);

    // Event emitted when a function call on an embedded framework contract succeeds (optional)
    event FunctionCallSucceeded(address deployedContract, string functionName, bytes returnData);

    // Event emitted when a function call on an embedded framework contract fails (optional)
    event FunctionCallFailed(address deployedContract, string functionName, bytes errorData);

    // Optional events for contract revocation and upgrade (if implemented)
}
