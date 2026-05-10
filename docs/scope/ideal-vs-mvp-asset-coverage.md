# Ideal vs v1 MVP: asset coverage and “collect everything”

This document answers the product question: *can every user asset everywhere (staking, lending, EOAs, external vaults) be automatically collected into inheritance execution?* It separates a **north-star architecture** from what **vault-only v1** can honestly promise.

## North star (ideal, permissioned by design)

There is **no single EVM contract** that can move *arbitrary* third-party positions (staking schedules, lending collateral, NFTs in external protocols) **without**:

1. **Prior commitment** — the user (or their smart account) already granted the right path: deposit to your vault, approve a scoped router, delegate control to a module, etc.
2. **Per-protocol integration** — each external system has different `unlock`, `claim`, `withdraw`, `repay`, or `safeTransferFrom` surfaces; some need **keeper** calls at specific times; some are **only** callable by the position owner’s key at a future block.
3. **Optional off-chain or keeper orchestration** — when “claim becomes possible,” something must **observe** and **call** the right contract; that can be permissionless relayers, your backend, or the beneficiary—still bounded by (1) and (2).

So the **ideal path** is an **orchestration graph**: policies name **destinations** and **rules**; **connectors** (adapters) know how to move value from protocol X into a wallet or into your vault; **triggers** (time, inactivity, attestation) decide *when* those steps are allowed. **v1** intentionally ships **only** the vault + policy + trigger + execute core; **connectors** are a documented **post-v1** track unless a minimal adapter is explicitly scoped.

### Post-unlock staking example (30 months, manual claim)

If the staking contract **only** allows the **user’s EOA** to call `claim()` and there was **no** prior delegation or smart-account module, **no protocol** can guarantee posthumous claim without that key. Realistic options:

- User **stakes through** a smart account / vault that **can** call `claim` under policy (path B or wrapped position).  
- User **pre-approves** a scoped executor that may call `claim` when conditions hold (hybrid; higher risk and spec surface).  
- Product documents **manual** beneficiary step with written instructions (not “fully automatic on-chain only”).

## v1 MVP (honest boundary)

**In scope:** assets **in** the Legacy vault (and **native ETH** held by the vault with explicit accounting, if the implementation supports it per [v1 MVP](v1-mvp.md)). Execution respects **policy priority**, **cooling-off** where configured, and **per-item failure** behavior (skip / retry cap).

**Out of scope unless added as a named connector:** balances only on EOAs, positions in external staking/lending/vaults, NFTs not transferred to the vault, and “sweep everything” without prior commitment.

This keeps marketing aligned with [ADR 001](../adr/001-v1-custody.md): succession applies to **what was pre-committed** to the policy’s custody model.

## Related

- [ADR 001 — v1 custody](../adr/001-v1-custody.md)  
- [Trust boundaries v1](../security/trust-boundaries-v1.md)  
- Optional future: ADR or doc on **connector** interfaces and keeper responsibilities.
