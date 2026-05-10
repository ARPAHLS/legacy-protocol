// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILegacyVaultEvents {
    event VaultInitialized(address indexed owner);

    event PolicyCommitted(
        bytes32 indexed policyId,
        address indexed owner,
        bytes32 indexed policyRoot,
        uint256 version
    );
    event PolicyRevoked(bytes32 indexed policyId, uint256 version);

    event TriggerArmed(bytes32 indexed policyId, bytes32 indexed triggerSetId, uint64 eligibleAt);
    event TriggerSatisfied(bytes32 indexed policyId, bytes32 indexed triggerId, bytes32 evidenceHash);
    event CoolingOffStarted(bytes32 indexed policyId, uint64 executeAfter);

    event ExecutionStarted(bytes32 indexed policyId, bytes32 indexed executionId);
    event ExecutionPartial(bytes32 indexed policyId, bytes32 indexed executionId, uint256 nonce);
    event ExecutionCompleted(bytes32 indexed policyId, bytes32 indexed executionId);
    event ExecutionAborted(bytes32 indexed policyId, bytes32 indexed executionId, bytes32 reason);

    event AssetTransferScheduled(bytes32 indexed policyId, bytes32 indexed executionId, bytes32 assetRef);
    event AssetTransferred(bytes32 indexed policyId, bytes32 indexed executionId, bytes32 assetRef);
}
