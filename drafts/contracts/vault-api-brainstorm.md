# Draft: LegacyVault API brainstorm

**Pre-ADR.** For discussion only. Canonical spec: [docs/contracts/legacy-vault-v1.md](../../docs/contracts/legacy-vault-v1.md).

## Rough shape

- `depositERC20(token, amount)` / `depositNFT(...)` if vault holds custody.
- `commitPolicy(policyId, policyRoot, metadataHash)`.
- `arm(policyId)` transitions to listening state.
- `satisfyTimeTrigger(policyId, ...)` v1 internal or small library.
- `execute(policyId, cumulativeProof, ops[])` where `ops` encodes transfer batch.

## Naming bikeshed

- `LegacyVault` vs `DisbursementVault` vs `ArpaExecutor` — align with product branding before first deploy.

## Questions

- Executor permission: `public` execute vs `role:keeper`?
- Merkle proof vs calldata-heavy full policy for v1 gas tradeoff.
