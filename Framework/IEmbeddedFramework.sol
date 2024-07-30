// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEmbeddedFrameworks {

    function createEmbeddedFramework(bytes memory bytecode, address owner) external payable returns (address deployedContract);

    function callFunction(address deployedContract, string memory functionName, bytes memory data) external payable returns (bytes memory returnData);

    function getOwner(address deployedContract) external view returns (address owner);

    function exists(address deployedContract) external view returns (bool exists);

    function revoke(address deployedContract) external;

    function upgrade(address deployedContract, bytes memory newBytecode) external;

    event EmbeddedFrameworkCreated(address deployedContract, address owner);

    event FunctionCallSucceeded(address deployedContract, string functionName, bytes returnData);

    event FunctionCallFailed(address deployedContract, string functionName, bytes errorData);

}
