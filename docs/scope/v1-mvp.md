# v1 MVP scope

Defines the **first shippable on-chain slice** aligned with [reference §9](../arpa-legacy-protocol-reference.md#9-asset-scope-product-tranches). Broader README marketing (agents, DID, personal data) is **not** all implemented in bytecode v1 unless listed here explicitly.

## In scope (v1 target)

**Assets**

- ERC-20 transfers (non-rebasing initially).
- ERC-721 and ERC-1155 with safe receiver semantics; failures must be definable as skip vs abort (policy-level).

**Custody**

- One primary pattern per [ADR 001](../adr/001-v1-custody.md) (vault vs AA module vs hybrid—**record result in ADR**).

**Policy**

- On-chain **policy root** commitment with **version** and **replay nonces** (exact layout in [legacy-vault-v1.md](../contracts/legacy-vault-v1.md)).
- Off-chain or calldata-supplied **manifest** matching [policy manifest schema](../schemas/policy-manifest-draft.json) (subset allowed in v1).

**Triggers (v1 minimal)**

- **Time / block delay** (absolute timestamp or relative to arming).
- Optional: simple **“deadline passed”** gate.

**Conflict resolution**

- **One** deterministic rule from [reference §5.2](../arpa-legacy-protocol-reference.md#52-overlapping-assets)—e.g. global priority index or first-eligible by `(priority, timestamp)`—**pick one for v1** and document in vault spec.

**Execution**

- Single or **staged** batches with idempotent execution IDs (reference §13).
- Explicit **gas reserve** behaviour (minimum native token retention) documented per deployment.

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
