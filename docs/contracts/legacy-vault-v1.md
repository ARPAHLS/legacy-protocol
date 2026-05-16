# LegacyVault v1 — contract specification (draft)

**Depends on:** [ADR 001](../adr/001-v1-custody.md) (**Accepted**) — **vault custody** (path A). If a deployment later adopts smart-account module (B), supersede this file with an account-module spec.

## Deployment shape (v1 direction)

- **Factory + minimal proxy (clone) per user vault** over one **immutable implementation** contract: clear **balance isolation** per owner/estate.  
- Optional **soulbound / non-transferable registry NFT** may map an identity to `vaultAddress` for UX and discovery; custody and execution remain on the **vault** contract, not the NFT.

## Purpose

Per-user escrow-style **coordinator** that:

1. Holds or routes **ERC-20 / ERC-721 / ERC-1155 / native ETH** per [v1 MVP](../scope/v1-mvp.md) (ETH with explicit vault balance + **gas reserve**).
2. Stores **policy commitments** (`policyId → policyRoot`, version, nonce) where **`policyRoot` is a single digest** over the canonical serialized policy/manifest envelope (v1; Merkle proofs deferred).
3. Accepts **trigger** outcomes (v1: time-based; optional stubs for richer attestation modules) and runs **execution** batches with **global priority + tie-break** conflict resolution.
4. Supports **cooling-off** (configurable delay after eligibility before finalizing sensitive payouts) and **partial batch success** (per-line-item retries / max attempts).

## Roles (storage-level)

| Role | Description |
|------|-------------|
| `owner` | Policy author; arms / updates / revokes per state machine; may call `execute` in phases the manifest allows (e.g. voluntary early windows) |
| `beneficiary` | Not a single storage role—many addresses from manifest |
| `executor` | One or more named addresses allowed to call `execute` when predicates require **human or institutional attestation** / liveness workflows |
| *permissionless* | Anyone may call `execute` when the committed policy + on-chain state machine deem it safe (e.g. time lock + cooling-off satisfied)—enables keepers without central allowlists |

## State machine (informative)

Align with [reference §13](../arpa-legacy-protocol-reference.md#13-state-machine-outline-informative):

`UNINITIALIZED → CONFIGURED_ARMED → ELIGIBLE → (optional COOLING) → EXECUTABLE → EXECUTING → {PARTIAL → EXECUTING*} → COMPLETED | ABORTED | REVOKED`

**Cooling-off:** after triggers are satisfied and the policy is **eligible**, an optional **timer** must elapse before transfers that are marked “irreversible” or “high impact” in the manifest. Lets a live owner contest false attestations off-chain/on-chain revokes according to policy. **Attestation-linked** payouts should default to **non-zero** cooling-off; pure time-delay only may use **zero** if product accepts it.

## `policyRoot` (v1)

- Commit **`keccak256` (or chosen hash) of a canonical serialization** of the policy envelope tied to `policyId` (exact encoding TBD at implementation—not “Merkle root of leaves” unless upgraded in a future version).

## Conflict resolution

- **Global policy priority**: lower priority number executes first among competing ready policies unless manifest defines a cohort rule; ties broken by deterministic rule (document `tieBreak` in manifest—e.g. `policyId`, `executionId`).

## Partial execution / NFT failure

- Batches iterate **lines** independently where the manifest declares `failureMode`: e.g. **retry** transient reverts up to **`maxAttempts`**, then **skip** line (emit event) **or** **abort cohort** — must not deadlock unrelated ERC-20/ETH lines unless policy groups them as atomic.

## Core functions (sketch)

| Function | Notes |
|----------|--------|
| `commitPolicy(...)` | Stores `policyRoot`, bumps `version`, emits `PolicyCommitted` |
| `revokePolicy(bytes32 policyId)` | Emits `PolicyRevoked`; blocks new execution |
| `armTrigger(...)` | v1: associate time trigger with `policyId` |
| `markEligible(...)` | Optional: if trigger is external module, callback or oracle |
| `execute(bytes32 policyId, bytes calldata envelope, uint256 batchIndex)` | Verifies envelope matches committed `policyRoot`; checks trigger + cooling-off + caller role; transfers assets; idempotent batch index |

**Exact signatures** wait on Solidity types for the canonical envelope encoding; **Merkle proofs are not required for v1** per [ADR 001](../adr/001-v1-custody.md).

## Invariants (must hold)

- No successful `execute` without `policyRoot` match and satisfied trigger + conflict rules.
- No double-spend of same **execution nonce** for a `policyId`.
- Token balance accounting: vault balance ≥ sum scheduled out (per cohort) until executed.

## Events

See [events-v1.md](../indexing/events-v1.md).

## Open questions (track in ADR / drafts)

- ~~Upgradeability~~ **v1:** **immutable implementation**; new versions are new deploys; users migrate explicitly—[ADR 001](../adr/001-v1-custody.md).
- **Cancel / liveness / guardian veto** — [#22](https://github.com/ARPAHLS/legacy-protocol/issues/22), [#25](https://github.com/ARPAHLS/legacy-protocol/issues/25); **adapters / profiles** — [#23](https://github.com/ARPAHLS/legacy-protocol/issues/23); **predicate safety** — [#24](https://github.com/ARPAHLS/legacy-protocol/issues/24).
- Pull vs push payouts for malicious beneficiaries.
- Executor **incentives** / tips ([reference §8](../arpa-legacy-protocol-reference.md#8-gas-and-economics)).

## Related

- [Vault API brainstorm](../../drafts/contracts/vault-api-brainstorm.md)
- [Trust boundaries v1](../security/trust-boundaries-v1.md)
- [Policy manifest schema](../schemas/policy-manifest-draft.json)
