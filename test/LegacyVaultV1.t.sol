// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import {LegacyVaultV1} from "../contracts/LegacyVaultV1.sol";
import {ILegacyVaultV1} from "../contracts/interfaces/ILegacyVaultV1.sol";
import {ILegacyVaultErrors} from "../contracts/interfaces/ILegacyVaultErrors.sol";
import {ILegacyVaultEvents} from "../contracts/interfaces/ILegacyVaultEvents.sol";

contract LegacyVaultV1CoolingOffTest is Test {
    ILegacyVaultV1 internal vault;

    address internal owner = address(0xA11CE);
    address internal stranger = address(0xB0B);

    bytes32 internal constant POLICY_ID = keccak256("policy-1");
    bytes32 internal constant TRIGGER_SET_ID = keccak256("trigger-set-1");
    bytes32 internal constant TRIGGER_ID = keccak256("trigger-1");
    bytes32 internal constant EVIDENCE_HASH = keccak256("evidence-1");
    bytes internal constant ENVELOPE = bytes("canonical-envelope-v1");
    uint64 internal constant COOLING_OFF_SECONDS = 1 days;

    bytes32 internal policyRoot;

    function setUp() public {
        vm.warp(1_000_000);
        vault = ILegacyVaultV1(address(new LegacyVaultV1()));
        vault.initialize(owner);
        policyRoot = keccak256(ENVELOPE);
        vm.prank(owner);
        vault.commitPolicy(POLICY_ID, policyRoot);
    }

    function _arm(uint64 eligibleAt, uint64 coolingOff) internal {
        vm.prank(owner);
        vault.armTrigger(POLICY_ID, TRIGGER_SET_ID, eligibleAt, coolingOff);
    }

    function _now() internal view returns (uint64) {
        return uint64(vm.getBlockTimestamp());
    }

    function _satisfyTrigger() internal {
        vm.prank(stranger);
        vault.markEligible(POLICY_ID, TRIGGER_ID, EVIDENCE_HASH);
    }

    function _executeExpectingRevert(uint64 expectedExecuteAfter) internal {
        vm.expectRevert(
            abi.encodeWithSelector(ILegacyVaultErrors.CoolingOffActive.selector, POLICY_ID, expectedExecuteAfter)
        );
        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_B013_executeAfter_zero_window_equals_eligibleAt() public {
        uint64 eligibleAt = _now() + 1 hours;
        _arm(eligibleAt, 0);

        ILegacyVaultV1.PolicyRecord memory record = vault.policyOf(POLICY_ID);
        assertEq(record.eligibleAt, eligibleAt);
        assertEq(record.executeAfter, eligibleAt);
    }

    function test_B013_executeAfter_nonZero_window_equals_eligibleAt_plus_coolingOff() public {
        uint64 eligibleAt = _now() + 1 hours;
        _arm(eligibleAt, COOLING_OFF_SECONDS);

        ILegacyVaultV1.PolicyRecord memory record = vault.policyOf(POLICY_ID);
        assertEq(record.eligibleAt, eligibleAt);
        assertEq(record.executeAfter, eligibleAt + COOLING_OFF_SECONDS);
    }

    function test_B013_zero_window_blocks_execution_before_eligibleAt() public {
        uint64 eligibleAt = _now() + 1 days;
        _arm(eligibleAt, 0);
        _satisfyTrigger();

        _executeExpectingRevert(eligibleAt);
    }

    function test_B013_zero_window_allows_execution_at_eligibleAt() public {
        uint64 eligibleAt = _now() + 1 days;
        _arm(eligibleAt, 0);
        _satisfyTrigger();

        vm.warp(eligibleAt);
        vault.execute(POLICY_ID, ENVELOPE, 0);

        assertTrue(vault.isBatchExecuted(POLICY_ID, 0));
    }

    function test_B013_nonZero_window_blocks_execution_one_second_before_deadline() public {
        uint64 eligibleAt = _now() + 1 days;
        uint64 executeAfter = eligibleAt + COOLING_OFF_SECONDS;
        _arm(eligibleAt, COOLING_OFF_SECONDS);
        _satisfyTrigger();

        vm.warp(executeAfter - 1);
        _executeExpectingRevert(executeAfter);
    }

    function test_B013_nonZero_window_allows_execution_exactly_at_deadline() public {
        uint64 eligibleAt = _now() + 1 days;
        uint64 executeAfter = eligibleAt + COOLING_OFF_SECONDS;
        _arm(eligibleAt, COOLING_OFF_SECONDS);
        _satisfyTrigger();

        vm.warp(executeAfter);
        vault.execute(POLICY_ID, ENVELOPE, 0);

        assertTrue(vault.isBatchExecuted(POLICY_ID, 0));
    }

    function test_B013_nonZero_window_allows_execution_after_deadline() public {
        uint64 eligibleAt = _now() + 1 days;
        uint64 executeAfter = eligibleAt + COOLING_OFF_SECONDS;
        _arm(eligibleAt, COOLING_OFF_SECONDS);
        _satisfyTrigger();

        vm.warp(executeAfter + 1 hours);
        vault.execute(POLICY_ID, ENVELOPE, 0);

        assertTrue(vault.isBatchExecuted(POLICY_ID, 0));
    }

    function test_B013_coolingOffStarted_emitted_for_zero_window() public {
        uint64 eligibleAt = _now() + 1 hours;

        vm.expectEmit(true, false, false, true, address(vault));
        emit ILegacyVaultEvents.CoolingOffStarted(POLICY_ID, eligibleAt);

        _arm(eligibleAt, 0);
    }

    function test_B013_coolingOffStarted_emitted_for_nonZero_window() public {
        uint64 eligibleAt = _now() + 1 hours;
        uint64 executeAfter = eligibleAt + COOLING_OFF_SECONDS;

        vm.expectEmit(true, false, false, true, address(vault));
        emit ILegacyVaultEvents.CoolingOffStarted(POLICY_ID, executeAfter);

        _arm(eligibleAt, COOLING_OFF_SECONDS);
    }

    function test_armTrigger_reverts_on_executeAfter_overflow() public {
        vm.prank(owner);
        vm.expectRevert(stdError.arithmeticError);
        vault.armTrigger(POLICY_ID, TRIGGER_SET_ID, type(uint64).max, 1);
    }

    function test_execute_success_emits_execution_lifecycle_events() public {
        uint64 eligibleAt = _now();
        _arm(eligibleAt, 0);
        _satisfyTrigger();

        bytes32 executionId = keccak256(abi.encode(POLICY_ID, uint256(0), policyRoot));

        vm.expectEmit(true, true, false, true, address(vault));
        emit ILegacyVaultEvents.ExecutionStarted(POLICY_ID, executionId);
        vm.expectEmit(true, true, false, true, address(vault));
        emit ILegacyVaultEvents.ExecutionPartial(POLICY_ID, executionId, 0);
        vm.expectEmit(true, true, false, true, address(vault));
        emit ILegacyVaultEvents.ExecutionCompleted(POLICY_ID, executionId);

        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_execute_reverts_before_deadline_even_when_trigger_satisfied() public {
        uint64 eligibleAt = _now() + 1 days;
        uint64 executeAfter = eligibleAt + COOLING_OFF_SECONDS;
        _arm(eligibleAt, COOLING_OFF_SECONDS);
        _satisfyTrigger();

        assertTrue(vault.policyOf(POLICY_ID).triggerSatisfied);

        vm.warp(eligibleAt);
        _executeExpectingRevert(executeAfter);
    }

    function test_rearm_resets_trigger_and_extends_executeAfter() public {
        uint64 firstEligible = _now() + 1 hours;
        _arm(firstEligible, 0);
        _satisfyTrigger();
        assertTrue(vault.policyOf(POLICY_ID).triggerSatisfied);

        uint64 secondEligible = _now() + 2 days;
        uint64 secondExecuteAfter = secondEligible + COOLING_OFF_SECONDS;
        _arm(secondEligible, COOLING_OFF_SECONDS);

        ILegacyVaultV1.PolicyRecord memory record = vault.policyOf(POLICY_ID);
        assertFalse(record.triggerSatisfied);
        assertEq(record.executeAfter, secondExecuteAfter);

        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.TriggerNotSatisfied.selector, POLICY_ID));
        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_execute_reverts_when_policy_revoked() public {
        _arm(_now(), 0);
        _satisfyTrigger();
        vm.prank(owner);
        vault.revokePolicy(POLICY_ID);

        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.PolicyAlreadyRevoked.selector, POLICY_ID));
        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_execute_reverts_when_trigger_not_armed() public {
        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.TriggerNotArmed.selector, POLICY_ID));
        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_execute_reverts_when_trigger_not_satisfied() public {
        _arm(_now(), 0);

        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.TriggerNotSatisfied.selector, POLICY_ID));
        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_execute_reverts_on_policy_root_mismatch() public {
        _arm(_now(), 0);
        _satisfyTrigger();

        bytes memory tampered = bytes("tampered-envelope");
        vm.expectRevert(
            abi.encodeWithSelector(
                ILegacyVaultErrors.PolicyRootMismatch.selector, POLICY_ID, policyRoot, keccak256(tampered)
            )
        );
        vault.execute(POLICY_ID, tampered, 0);
    }

    function test_execute_reverts_on_batch_replay() public {
        _arm(_now(), 0);
        _satisfyTrigger();
        vault.execute(POLICY_ID, ENVELOPE, 0);

        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.BatchAlreadyExecuted.selector, POLICY_ID, 0));
        vault.execute(POLICY_ID, ENVELOPE, 0);
    }

    function test_execute_allows_distinct_batch_index_after_first_execution() public {
        _arm(_now(), 0);
        _satisfyTrigger();
        vault.execute(POLICY_ID, ENVELOPE, 0);
        vault.execute(POLICY_ID, ENVELOPE, 1);

        assertTrue(vault.isBatchExecuted(POLICY_ID, 0));
        assertTrue(vault.isBatchExecuted(POLICY_ID, 1));
    }

    function test_execute_reverts_for_unknown_policy() public {
        bytes32 unknownPolicy = keccak256("unknown");
        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.PolicyNotFound.selector, unknownPolicy));
        vault.execute(unknownPolicy, ENVELOPE, 0);
    }

    function test_markEligible_reverts_when_trigger_not_armed() public {
        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.TriggerNotArmed.selector, POLICY_ID));
        vault.markEligible(POLICY_ID, TRIGGER_ID, EVIDENCE_HASH);
    }

    function test_markEligible_reverts_when_policy_revoked() public {
        _arm(_now(), 0);
        vm.prank(owner);
        vault.revokePolicy(POLICY_ID);

        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.PolicyAlreadyRevoked.selector, POLICY_ID));
        vault.markEligible(POLICY_ID, TRIGGER_ID, EVIDENCE_HASH);
    }

    function test_armTrigger_reverts_for_revoked_policy() public {
        vm.prank(owner);
        vault.revokePolicy(POLICY_ID);

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.PolicyAlreadyRevoked.selector, POLICY_ID));
        vault.armTrigger(POLICY_ID, TRIGGER_SET_ID, _now(), 0);
    }

    function test_armTrigger_reverts_for_unknown_policy() public {
        bytes32 unknownPolicy = keccak256("unknown");
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(ILegacyVaultErrors.PolicyNotFound.selector, unknownPolicy));
        vault.armTrigger(unknownPolicy, TRIGGER_SET_ID, _now(), 0);
    }

    function test_onlyOwner_guards_commit_revoke_arm() public {
        vm.startPrank(stranger);

        vm.expectRevert(ILegacyVaultErrors.NotOwner.selector);
        vault.commitPolicy(keccak256("policy-2"), policyRoot);

        vm.expectRevert(ILegacyVaultErrors.NotOwner.selector);
        vault.revokePolicy(POLICY_ID);

        vm.expectRevert(ILegacyVaultErrors.NotOwner.selector);
        vault.armTrigger(POLICY_ID, TRIGGER_SET_ID, _now(), 0);

        vm.stopPrank();
    }

    function test_commitPolicy_recommit_unrevokes_and_bumps_version() public {
        vm.prank(owner);
        vault.revokePolicy(POLICY_ID);

        bytes32 newRoot = keccak256(bytes("canonical-envelope-v2"));
        vm.prank(owner);
        vault.commitPolicy(POLICY_ID, newRoot);

        ILegacyVaultV1.PolicyRecord memory record = vault.policyOf(POLICY_ID);
        assertFalse(record.revoked);
        assertEq(record.policyRoot, newRoot);
        assertEq(record.version, 2);
    }
}
