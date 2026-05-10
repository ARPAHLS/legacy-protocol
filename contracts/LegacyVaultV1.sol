// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ILegacyVaultV1} from "./interfaces/ILegacyVaultV1.sol";

contract LegacyVaultV1 is ILegacyVaultV1 {
    address private _owner;
    bool private _initialized;

    mapping(bytes32 policyId => PolicyRecord) private _policies;
    mapping(bytes32 policyId => mapping(uint256 batchIndex => bool executed)) private _executedBatch;

    modifier onlyOwner() {
        if (msg.sender != _owner) revert NotOwner();
        _;
    }

    function initialize(address owner_) external override {
        if (_initialized) revert AlreadyInitialized();
        if (owner_ == address(0)) revert InvalidOwner(owner_);

        _initialized = true;
        _owner = owner_;
        emit VaultInitialized(owner_);
    }

    function owner() external view override returns (address) {
        return _owner;
    }

    function policyOf(bytes32 policyId) external view override returns (PolicyRecord memory) {
        return _policies[policyId];
    }

    function isBatchExecuted(bytes32 policyId, uint256 batchIndex) external view override returns (bool) {
        return _executedBatch[policyId][batchIndex];
    }

    function commitPolicy(bytes32 policyId, bytes32 policyRoot) external override onlyOwner {
        PolicyRecord storage policy = _policies[policyId];

        policy.policyRoot = policyRoot;
        policy.version += 1;
        policy.revoked = false;
        emit PolicyCommitted(policyId, msg.sender, policyRoot, policy.version);
    }

    function revokePolicy(bytes32 policyId) external override onlyOwner {
        PolicyRecord storage policy = _policies[policyId];
        if (policy.version == 0) revert PolicyNotFound(policyId);
        if (policy.revoked) revert PolicyAlreadyRevoked(policyId);

        policy.revoked = true;
        emit PolicyRevoked(policyId, policy.version);
    }

    function armTrigger(
        bytes32 policyId,
        bytes32 triggerSetId,
        uint64 eligibleAt,
        uint64 coolingOffSeconds
    ) external override onlyOwner {
        PolicyRecord storage policy = _policies[policyId];
        if (policy.version == 0) revert PolicyNotFound(policyId);
        if (policy.revoked) revert PolicyAlreadyRevoked(policyId);

        policy.triggerArmed = true;
        policy.triggerSatisfied = false;
        policy.eligibleAt = eligibleAt;
        policy.executeAfter = eligibleAt + coolingOffSeconds;

        emit TriggerArmed(policyId, triggerSetId, eligibleAt);
        if (coolingOffSeconds > 0) emit CoolingOffStarted(policyId, policy.executeAfter);
    }

    function markEligible(bytes32 policyId, bytes32 triggerId, bytes32 evidenceHash) external override {
        PolicyRecord storage policy = _policies[policyId];
        if (policy.version == 0) revert PolicyNotFound(policyId);
        if (!policy.triggerArmed) revert TriggerNotArmed(policyId);
        if (policy.revoked) revert PolicyAlreadyRevoked(policyId);

        policy.triggerSatisfied = true;
        emit TriggerSatisfied(policyId, triggerId, evidenceHash);
    }

    function execute(bytes32 policyId, bytes calldata envelope, uint256 batchIndex) external override {
        PolicyRecord storage policy = _policies[policyId];
        if (policy.version == 0) revert PolicyNotFound(policyId);
        if (policy.revoked) revert PolicyAlreadyRevoked(policyId);
        if (!policy.triggerArmed) revert TriggerNotArmed(policyId);
        if (!policy.triggerSatisfied) revert TriggerNotSatisfied(policyId);
        if (block.timestamp < policy.executeAfter) revert CoolingOffActive(policyId, policy.executeAfter);
        if (_executedBatch[policyId][batchIndex]) revert BatchAlreadyExecuted(policyId, batchIndex);

        bytes32 actualRoot = keccak256(envelope);
        if (actualRoot != policy.policyRoot) revert PolicyRootMismatch(policyId, policy.policyRoot, actualRoot);

        bytes32 executionId = keccak256(abi.encode(policyId, batchIndex, actualRoot));
        _executedBatch[policyId][batchIndex] = true;

        emit ExecutionStarted(policyId, executionId);
        emit ExecutionPartial(policyId, executionId, batchIndex);
        emit ExecutionCompleted(policyId, executionId);
    }
}
