// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILegacyVaultErrors {
    error NotOwner();
    error PolicyNotFound(bytes32 policyId);
    error PolicyAlreadyRevoked(bytes32 policyId);
    error PolicyRootMismatch(bytes32 policyId, bytes32 expectedRoot, bytes32 actualRoot);
    error TriggerNotArmed(bytes32 policyId);
    error TriggerNotSatisfied(bytes32 policyId);
    error CoolingOffActive(bytes32 policyId, uint64 executeAfter);
    error BatchAlreadyExecuted(bytes32 policyId, uint256 batchIndex);
    error CallerNotAuthorized(address caller);
    error InvalidOwner(address owner);
    error AlreadyInitialized();
}
