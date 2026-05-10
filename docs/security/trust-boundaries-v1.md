# Trust boundaries and threat notes (v1)

Companion to [reference §10](../arpa-legacy-protocol-reference.md#10-security-and-trust-analysis). **Not** a substitute for a full audit.

## Roles (conceptual)

| Role | Capability | Misbehavior model |
|------|-------------|-------------------|
| **Policy owner** | Arm, update (within rules), revoke while allowed | Competent vs compromised key |
| **Beneficiary** | Receive transfers; may be malicious callback contract | NFT/push-pattern grief |
| **Executor / keeper** | Submit `execute*` when predicates hold | Cannot authorize false predicates alone |
| **Attestor (future)** | Sign structured attestations | Collusion / coercion |
| **Oracle feed (future)** | Provide signed / aggregated values | Manipulation / staleness |

## What the chain **does** trust

- **Cryptographic signatures** and **consensus time** as exposed by the EVM.
- **Oracle contracts** only as configured in policy (v1 may omit or use mock).

## What the chain **does not** trust

- Raw HTTP callbacks.
- Narratives from heirs or solicitors—only **predicate satisfaction** tied to commitments.

## Implementation lifecycle (v1)

- Vault **implementations are immutable** ([ADR 001](../adr/001-v1-custody.md)): no upgrade proxy in the shipped v1 pattern; newer versions are separate deploys. Users who never migrate retain **prior** bytecode behaviour under their commitment.

## v1-focused risks

| Risk | Mitigation direction (design) |
|------|-------------------------------|
| Reentrancy through ERC-721 receiver | Guards, checks-effects-interactions, optional pull payouts |
| Policy downgraded after partial trigger | Version locks / hash timelines (reference §10) |
| Two policies drain same ERC-20 | Single conflict strategy from MVP scope ([v1-mvp §](../scope/v1-mvp.md#conflict-resolution)) |
| Owner rug-pull before trigger | Transparent policy semantics; disclosures in UI—not a protocol “bug” |
| Executor censorship | Hybrid `execute`: permissionless phases where manifest allows ([ADR 001](../adr/001-v1-custody.md)); named executors where attestations gate; document liveness / keeper incentives |

## Personal data, DIDs, agents (README language)

- **Personal data** on-chain should default to **hashes** or **opaque commitments** until a separate data spec exists.
- **DID-linked wallets** resolve to addresses the policy references; DID layer is largely off-chain.
- **Sanctioned agents** are **addresses** granted bounded roles in policy—nothing magic about “AI”; scope is contract permissions.

## Related

- [legacy-vault-v1.md](../contracts/legacy-vault-v1.md) — concrete role storage.
- [behavior matrix](../testing/behavior-matrix.md) — P0 security rows.
