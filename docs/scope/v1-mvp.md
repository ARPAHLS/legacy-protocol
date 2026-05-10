# v1 MVP scope

Defines the **first shippable on-chain slice** aligned with [reference §9](../arpa-legacy-protocol-reference.md#9-asset-scope-product-tranches). Broader README marketing (agents, DID, personal data) is **not** all implemented in bytecode v1 unless listed here explicitly.

## In scope (v1 target)

**Assets**

- ERC-20 transfers (non-rebasing initially).
- **Native ETH** in the vault with explicit accounting and a **deployment-defined gas reserve** (minimum retained native balance so further `execute` calls remain possible unless the manifest defines otherwise and the product accepts exhaustion).
- **WETH**: treat as ERC-20; implementations may also wrap/unwrap at boundaries if documented—**no requirement** that users only use WETH for “Ethereum” payouts if native path is implemented.
- ERC-721 and ERC-1155 with safe receiver semantics; **partial batch success**: per–line-item skip / retry cap (e.g. abort one NFT branch after **N** failures) without blocking unrelated items ([ADR 001](../adr/001-v1-custody.md)).

**Custody**

- [ADR 001](../adr/001-v1-custody.md): **Accepted** — **path A vault custody**. Execution applies to assets **deposited** in the vault; “collect everything elsewhere” requires **future connectors** and prior commitments—see [Ideal vs MVP asset coverage](ideal-vs-mvp-asset-coverage.md).

**Policy**

- On-chain **policy root** as a **single commitment digest** over the canonical serialized policy/manifest envelope (v1); Merkle manifests deferred until warranted by gas/design ([ADR 001](../adr/001-v1-custody.md)).
- **Version** and **replay / execution nonces** (exact layout in [legacy-vault-v1.md](../contracts/legacy-vault-v1.md)).
- Off-chain or calldata-supplied **manifest** matching [policy manifest schema](../schemas/policy-manifest-draft.json) (subset allowed in v1).

**Triggers (v1 minimal)**

- **Time / block delay** (absolute timestamp or relative to arming).
- Optional: simple **“deadline passed”** gate.

**Conflict resolution**

- **[Accepted]** **Global policy priority** with a deterministic tie-break (e.g. lower `policyId` or lexical `executionId`) per [reference §5.2](../arpa-legacy-protocol-reference.md#52-overlapping-assets)—document exact ordering in vault spec.

**Execution**

- **Hybrid caller model** ([ADR 001](../adr/001-v1-custody.md)): owner vs named executors vs permissionless `execute` when the state machine and manifest say it is safe (e.g. post–cooling-off time-only policies).
- Single or **staged** batches with idempotent execution IDs (reference §13).
- Explicit **gas reserve** behaviour (minimum native token retention) documented per deployment.
- **Cooling-off:** configurable delay after eligibility before irreversible payout; default **non-zero** for attestation-linked policies.

## Explicitly deferred (post-v1 until specified)

Per reference §9 deferred list:

- Rebasing tokens, complex LP positions, malicious receiver grief NFTs without policy.
- Bridged duplicate identity of same asset across chains without CAIP-aware spec.
- KYC-gated RWA routers.
- Full **inactivity counter** semantics across EOAs vs batched AA (requires ADR on “qualifying activity”).
- Rich **oracle** and **attestation** stacks (interfaces may exist as stubs).

## Out of scope (non-chain or product-legal)

- Probate validity, will formalities, healthcare data compliance—see [README disclaimer](../../README.md#disclaimer).

## Success criteria for “v1 complete”

1. ADR 001 **Accepted** with named pattern.
2. Behaviour rows P0 in [behavior matrix](../testing/behavior-matrix.md) have passing tests.
3. Event set in [events-v1](../indexing/events-v1.md) emitted by implementation for subgraph smoke test.
