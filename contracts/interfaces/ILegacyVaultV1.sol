// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ILegacyVaultErrors} from "./ILegacyVaultErrors.sol";
import {ILegacyVaultEvents} from "./ILegacyVaultEvents.sol";

interface ILegacyVaultV1 is ILegacyVaultErrors, ILegacyVaultEvents {
    struct PolicyRecord {
        bytes32 policyRoot;
        uint256 version;
        uint64 eligibleAt;
        uint64 executeAfter;
        bool triggerArmed;
        bool triggerSatisfied;
        bool revoked;
    }

    function initialize(address owner_) external;

    function owner() external view returns (address);
    function policyOf(bytes32 policyId) external view returns (PolicyRecord memory);
    function isBatchExecuted(bytes32 policyId, uint256 batchIndex) external view returns (bool);

    function commitPolicy(bytes32 policyId, bytes32 policyRoot) external;
    function revokePolicy(bytes32 policyId) external;

    function armTrigger(bytes32 policyId, bytes32 triggerSetId, uint64 eligibleAt, uint64 coolingOffSeconds) external;
    function markEligible(bytes32 policyId, bytes32 triggerId, bytes32 evidenceHash) external;

    function execute(bytes32 policyId, bytes calldata envelope, uint256 batchIndex) external;
}
