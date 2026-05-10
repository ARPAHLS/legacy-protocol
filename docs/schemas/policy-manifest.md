# Policy manifest (draft JSON schema)

**Schema file:** [policy-manifest-draft.json](policy-manifest-draft.json)

## Purpose

Implements the direction in [reference §4.2](../arpa-legacy-protocol-reference.md#42-policy-representation) and [§7](../arpa-legacy-protocol-reference.md#7-ux-and-authoring): a **portable** description of beneficiaries, asset cohorts, triggers, and conflict rules. The on-chain system commits a **hash** (policy root) and verifies execution against that commitment plus supplied proofs or expanded on-chain state.

## Versioning

- `schemaVersion` is **draft** (`0.1.0-draft`). Breaking changes increment minor/major per project convention once RFC 2119-style norms exist beside contracts.

## Canonical encoding (required before mainnet)

The JSON file is **not** automatically what is hashed. You must document in [legacy-vault-v1.md](../contracts/legacy-vault-v1.md):

1. Field order and types for `keccak256(abi.encode(...))` or Merkle leaf layout.
2. Whether **full manifest** or **Merkle root** is committed.
3. How `distribution` basis points sum to 10000 per cohort (validation rules).

## Extensibility

- New `triggers[].type` values require schema + spec updates.
- **Personal data** should not appear in plaintext; use **hashes** or off-chain references until a dedicated privacy addendum exists ([trust boundaries](../security/trust-boundaries-v1.md)).

## Related

- [v1 MVP scope](../scope/v1-mvp.md) — which trigger types are valid in v1.
- [behavior matrix](../testing/behavior-matrix.md) — manifest validation behaviours.
