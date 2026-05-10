# LegacyVault v1 — contract specification (draft)

**Depends on:** [ADR 001](../adr/001-v1-custody.md) selecting **vault custody** (path A). If ADR chooses smart-account module (B), this document is superseded by an account-module spec.

## Purpose

Single escrow-style **coordinator** that:

1. Holds or routes **ERC-20 / ERC-721 / ERC-1155** per [v1 MVP](../scope/v1-mvp.md).
2. Stores **policy commitments** (`policyId → policyRoot`, version, nonce).
3. Accepts **trigger** outcomes (v1: time-based adapter) and runs **execution** batches with **deterministic conflict** behaviour.

## Roles (storage-level)

| Role | Description |
|------|-------------|
| `owner` | Policy author; arms / updates / revokes per state machine |
| `beneficiary` | Not a single storage role—many addresses from manifest |
| `executor` | Any address allowed to call `execute` when predicates hold (open or gated—**decide in ADR follow-up**) |

## State machine (informative)

Align with [reference §13](../arpa-legacy-protocol-reference.md#13-state-machine-outline-informative):

`UNINITIALIZED → CONFIGURED_ARMED → (optional COOLING) → ELIGIBLE → EXECUTING → {PARTIAL → EXECUTING*} → COMPLETED | ABORTED | REVOKED`

## Core functions (sketch)

| Function | Notes |
|----------|--------|
| `commitPolicy(...)` | Stores `policyRoot`, bumps `version`, emits `PolicyCommitted` |
| `revokePolicy(bytes32 policyId)` | Emits `PolicyRevoked`; blocks new execution |
| `armTrigger(...)` | v1: associate time trigger with `policyId` |
| `markEligible(...)` | Optional: if trigger is external module, callback or oracle |
| `execute(bytes32 policyId, bytes calldata proof, uint256 batchIndex)` | Pulls manifest proof if Merkle; transfers assets; idempotent batch index |

**Exact signatures** wait on: Merkle vs full on-chain policy, and ADR 001.

## Invariants (must hold)

- No successful `execute` without `policyRoot` match and satisfied trigger + conflict rules.
- No double-spend of same **execution nonce** for a `policyId`.
- Token balance accounting: vault balance ≥ sum scheduled out (per cohort) until executed.

## Events

See [events-v1.md](../indexing/events-v1.md).

## Open questions (track in ADR / drafts)

- Upgradeability: proxy vs immutable ([reference §14](../arpa-legacy-protocol-reference.md#14-open-research-and-roadmap-topics)).
- Pull vs push payouts for malicious beneficiaries.
- Executor permissioning and tips ([reference §8](../arpa-legacy-protocol-reference.md#8-gas-and-economics)).

## Related

- [Vault API brainstorm](../../drafts/contracts/vault-api-brainstorm.md)
- [Trust boundaries v1](../security/trust-boundaries-v1.md)
- [Policy manifest schema](../schemas/policy-manifest-draft.json)
