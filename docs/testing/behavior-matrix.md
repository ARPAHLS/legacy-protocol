# Behaviour matrix (v1)

Maps product behaviours to the [reference spec](../arpa-legacy-protocol-reference.md) and future tests. **Status** values: `deferred` | `specified` | `implemented` | `tested`.

## Priority P0 (blocking v1)

| ID | Behaviour | Ref | Status |
|----|-----------|-----|--------|
| B-001 | Policy root commit + monotonic version | §4.2, §10 | deferred |
| B-002 | Revoke / amend policy only in allowed lifecycle states | §2, §10 | deferred |
| B-003 | Time-based trigger arms and fires at configured boundary | §4.3 | deferred |
| B-004 | Execute ERC-20 transfer to beneficiary per distribution | §4.4, §9 | deferred |
| B-005 | Execute ERC-721 `safeTransferFrom` with failure mode (skip vs abort) | §4.4 | deferred |
| B-006 | **Global priority** (+ tie-break) when two claims overlap | §5.2, [v1-mvp](../scope/v1-mvp.md), [ADR 001](../adr/001-v1-custody.md) | deferred |
| B-007 | Replay-safe execution id / nonce (no double drain) | §15, §10 | deferred |
| B-008 | Reentrancy resistance on external token callbacks | §4.4, §10 | deferred |
| B-009 | Emit core lifecycle events per [events-v1](../indexing/events-v1.md) | §13 | deferred |

## Priority P1

| ID | Behaviour | Ref | Status |
|----|-----------|-----|--------|
| B-010 | Staged / partial execution with resumable batches | §3.6, §13 | deferred |
| B-011 | Native token gas reserve policy | §8 | deferred |
| B-012 | ERC-1155 batch semantics | §9 | deferred |
| B-013 | Cooling-off window after trigger satisfied | §2, §6 | deferred |

## Priority P2 (post-v1)

| ID | Behaviour | Ref | Status |
|----|-----------|-----|--------|
| B-020 | Inactivity counter definition (EOA vs AA) | §4.3, §14 | deferred |
| B-021 | EIP-712 attestation verify + registry | §4.3 | deferred |
| B-022 | Oracle snapshot + staleness | §4.3 | deferred |

## Test ID convention (future)

`test_B00X_description` in Foundry—align when `contracts/` lands.
