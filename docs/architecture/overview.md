# Architecture overview

This document maps the [reference specification](../arpa-legacy-protocol-reference.md) to deployable modules. It is descriptive until [ADR 001](../adr/001-v1-custody.md) is **Accepted**.

## High-level diagram (logical)

```mermaid
flowchart LR
  subgraph owner [Policy author]
    O[Owner keys]
  end
  subgraph core [Core on-chain]
    V[Vault or account module]
    P[Policy commitment]
    T[Trigger adapters]
    E[Execution / asset router]
  end
  subgraph off [Off-chain]
    W[Watchers / relayers]
    M[Policy manifest JSON]
  end
  O --> V
  M --> P
  P --> V
  T --> V
  W --> T
  V --> E
```

## Modules (reference §15)

| Module | Responsibility | v1 note |
|--------|----------------|---------|
| **Core** | Lifecycle, replay protection, conflict arbitration hooks | Tied to custody choice in ADR 001 |
| **Vault** | Escrow custody API (if path A) | See [legacy-vault-v1.md](../contracts/legacy-vault-v1.md) |
| **Triggers — time / block** | Eligibility from `block.timestamp` or height | First concrete adapter to implement |
| **Triggers — attestation** | EIP-712 verify, registries, freshness | After time-based path proven |
| **Triggers — oracle** | Feed snapshots, staleness | After attestation or in parallel with clear interfaces |
| **Events** | Canonical logs for indexers | [events-v1.md](../indexing/events-v1.md) |

## Data flow (policy minimized on-chain, reference §4.2)

1. Author builds a **policy manifest** ([schema](../schemas/policy-manifest-draft.json)).
2. Manifest is hashed to a **policy root** committed on-chain (`policyId → policyRoot`) with versioning nonces ([reference §15](../arpa-legacy-protocol-reference.md#15-modular-system-map)).
3. **Trigger adapters** write or prove predicates; **core** checks composition (reference §5).
4. **Execution** transfers asset cohorts per committed rules (reference §4.4).

## Related documents

- [ADR 001: v1 custody](../adr/001-v1-custody.md)
- [v1 MVP scope](../scope/v1-mvp.md)
- [Trust boundaries v1](../security/trust-boundaries-v1.md)
