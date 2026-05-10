# ADR 001: v1 custody and authority model

| Field | Value |
|-------|--------|
| Status | **Accepted** |
| Date | 2026-05-09 |
| Deciders | ARPA Legacy Protocol maintainers / project stewards; **rosspeili** |
| References | [Reference spec §4.1](../arpa-legacy-protocol-reference.md#41-custody-and-authority-one-primary-pattern-per-deployment), [§4.4–4.5](../arpa-legacy-protocol-reference.md#44-execution-plane), [v1 MVP scope](../scope/v1-mvp.md), [Vault v1 spec](../contracts/legacy-vault-v1.md), [Trust boundaries v1](../security/trust-boundaries-v1.md), [Ideal vs MVP asset coverage](../scope/ideal-vs-mvp-asset-coverage.md) |

## Context (reference + product)

The [reference spec §4.1](../arpa-legacy-protocol-reference.md#41-custody-and-authority-one-primary-pattern-per-deployment) names three **primary** patterns: **vault custody**, **smart-account module**, and **allowance / delegation choreography** (hybrid). The [README](../../README.md) promises programmable handoffs for tokens, NFTs, vault keys, DIDs, agents—**execution is always over assets and authorities the chain can see** under a **committed policy**. Nothing in the EVM can move balances that were **never** placed under that policy’s control without **some prior** on-chain delegation.

### User questions this ADR must resolve

1. **If assets sit in a vault, can the user still “use” them (trade on a DEX, gate an event with an NFT)?**  
   On Ethereum, a token is **either** in the vault contract’s balance **or** in an EOA/smart-account balance—not both at full custody at once. So **by default**, an NFT or ERC-20 **inside** a classic escrow vault is **not** simultaneously in the user’s wallet for everyday DEX or ticket-gating UX **unless** you add extra layers (wrapper shares, router hooks, or the vault itself exposes curated “user ops”). **Practical pattern:** treat the vault as **estate / long-hold** inventory; keep a **separate hot balance** (or withdraw from vault when you want active use) for trading and access passes.

2. **User holds “live” assets only in a wallet (gas, NFTs never deposited). They die or stop signing—can the protocol still transfer those?**  
   **Not without prior arrangement.** A policy stored in your product **cannot** pull arbitrary ERC-20s/NFTs from an EOA post-facto. Options that **do** work on-chain: (a) assets were **in** the vault or smart account governed by the policy; (b) the user pre-granted **revocable or irrevocable allowance / Permit** to an executor contract with strict scope (hybrid—see pattern C and risks); (c) the “wallet” is already a **smart account** whose module runs the policy (pattern B). **README / reference alignment:** “programmable ownership that outlives you” applies to **what you pre-committed**—not to every asset that happens to exist at the same address unless that address is **under** the policy.

3. **Can the same economic exposure be “in the vault” and “usable” like normal?**  
   **Not as identical tokens in two places** without financial engineering (LP positions, receipt tokens, credit lines). The honest product story is **tiering**: **vault cohort** (policy-bound, clear execution) vs **operational cohort** (user wallet, not covered until deposited or delegated). Optional later: **smart account** (B) unifies “one account, modular rules” so fewer mental buckets, at the cost of more validation complexity.

### Modern stack (best-practice orientation)

- **[ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) account abstraction:** validation + execution bundles; good fit for **pattern B** (policy as validation module / plugin) and for UX (session flows), with clear security review of the validation surface.  
- **Modular smart accounts** (e.g. plugin/module ecosystems, Safe modules): policy as an **optional module** with upgrade and timelock discipline—aligns with reference §6 (recovery, rotation).  
- **Foundry** for implementation and invariant tests ([README roadmap](../../README.md#product-roadmap-in-priority-order)).  
- **EIP-712** policy and attestation signing ([reference §12](../arpa-legacy-protocol-reference.md#12-interoperability-with-existing-evm-standards)) when manifests move off-chain.  
- **Upgrade stance:** v1 is **immutable implementation** (no upgrade proxy); see [recorded decisions](#recorded-decisions-supplementary-qa) and [trust boundaries](../security/trust-boundaries-v1.md). Future versions may revisit proxy patterns under a new ADR if needed.

**Security note (reference §4.1):** each pattern shifts MEV, censorship, and **who can race** `execute`—document executor model in the vault or account spec.

## Decision options (recap)

- **A — Vault custody:** users move **estate-bound** assets into a dedicated escrow; clearest invariants; explicit deposit/withdraw; **simplest story** for “what the policy can pay.”  
- **B — Smart-account module:** policy embedded in **ERC-4337-style** (or equivalent) account logic; **single locus** for “all account-held assets” subject to module rules; no monolithic `LegacyVault` holding everyone’s tokens.  
- **C — Hybrid / choreographed allowances:** split **vault-held** vs **wallet-held** cohorts with **non-ambiguous** delegation (reference: **must** forbid partial-authority ambiguity). Typically: **limited, time-bounded, or revocable** allowances to an executor—**higher** user-error and griefing surface.

## Accepted v1 decision

**Selected:** **A — Vault custody (v1)** as the **first shipped** on-chain track, with **explicit product documentation**:

- **In scope for v1 execution:** assets **deposited** into the vault (including **native ETH** held by the vault with explicit accounting—see [recorded decisions](#recorded-decisions-supplementary-qa) below).  
- **Out of scope for v1 unless separately specified:** pulling **unspecified** EOA residue after death with no prior deposit or delegation; universal sweep of third-party staking/lending/vault positions without **connectors** or prior commitment—see [Ideal vs MVP asset coverage](../scope/ideal-vs-mvp-asset-coverage.md).  
- **“Active use” guidance:** users who want DEX/event liquidity keep **operational balances outside** the vault **or** withdraw from vault when needed; **estate** balances stay inside for deterministic triggers.  
- **Path B** remains the **documented successor** for deployments that want **one smart account** holding both day-to-day and succession logic (new spec when ADR is extended or superseded).  
- **Path C** remains **deferred** until a concrete **allowance + scope + revocation** story is specified and audited—reference requirement on **no ambiguous authority**.

### Recorded decisions (supplementary Q&A)

The following narrows implementation and product wording; details live in [v1 MVP](../scope/v1-mvp.md) and [legacy-vault-v1](../contracts/legacy-vault-v1.md).

| Topic | Decision |
|-------|-----------|
| **Native ETH vs WETH in vault** | **Native ETH supported in-vault** for policies like “send 99% of ETH after trigger,” with a **deployment-defined gas reserve** (minimum retained for further execution txs). Policies cannot move ETH that was **never** deposited into the vault. **WETH** remains a normal ERC-20 transfer path alongside native handling where the implementation exposes both. |
| **Conflict resolution** | **Global policy priority** with a deterministic tie-break (e.g. lower `policyId` or lexical `executionId`)—single rule for v1; document exact ordering in vault spec. |
| **Who may call `execute`** | **Hybrid model:** owner may execute where the state machine allows (e.g. early voluntary payout windows); **named executors** when predicates require attestations / liveness; **permissionless** calls where the manifest and state machine declare it safe (e.g. pure time lock fully satisfied)—see vault spec gates. |
| **Upgrades** | **Immutable implementation** deployments for a given vault version (**no proxy** in v1 ship); **new versions** deployed separately; users **migrate** only when able and willing; **old deployments keep executing** under their committed policy. |
| **`policyRoot` encoding (v1)** | **Single commitment digest** (hash of canonical serialized manifest / policy envelope) for v1 simplicity; Merkle proofs are **deferred** until calldata gas or partial on-chain manifests justify them. |
| **Vault topology (v1 direction)** | **Per-user vault instance** via **factory-deployed clones** sharing one **immutable implementation**—clear balance isolation versus one multi-tenant vault. Soulbound NFTs (**optional**) are identity/registry hints, **not** a substitute for a vault contract boundary. |
| **Cooling-off** | **Configurable per policy deployment:** delay after eligibility before irreversible payouts, so owners can disprove false positives (e.g. bad attestation). **Non-zero default** recommended for **attestation-linked** payouts; pure time-delay policies may allow **zero** cooling-off only if product accepts the risk. |
| **Batch failures (e.g. one NFT)** | **Non-blocking batches:** retry/skip semantics per line item with a **policy-defined max attempts**, then skip or abort **that branch** without blocking unrelated assets—see vault spec / behavior matrix. |
| **Marketing vs chain** | “All assets everywhere” is a **north star** needing **connectors + prior commitment**; v1 sells **vault-committed assets** honestly—see [Ideal vs MVP asset coverage](../scope/ideal-vs-mvp-asset-coverage.md). |

_If changing any row, either amend this ADR with date + rationale or supersede with a new ADR._

## Consequences

### Positive (v1 path A)

- Matches [legacy-vault-v1.md](../contracts/legacy-vault-v1.md) and minimizes “magical succession” expectations relative to README marketing.  
- Clear audit boundary: escrow balance sheet + policy root + triggers + execution.  
- Transparent answer to NFT/DEX/event questions: **vaulted ≠ in same wallet UI** unless you withdraw or adopt a future B/C design.

### Tradeoffs

- **UX:** migration cost (deposit) and **mental model** hot vs cold.  
- **Gap:** residue on EOA not auto-inherited—in product copy, steer users to **deposit estate portion** or adopt **smart account** (B) in a later release.

### If B chosen later instead

- Update architecture diagram and replace vault-centric spec with **account-module spec**; revisit trust boundaries and indexer events (`PolicyCommitted` may attach to account address not vault).

### If C chosen later

- Require **explicit** delegation contract, allowance caps, optional revocability windows, and conflict rules with policy—no hand-wavy “sweep everything.”

## Follow-up actions

1. ~~Accept this ADR~~ **Done** (Accepted 2026-05-09).  
2. Update [architecture/overview.md](../architecture/overview.md) for **path A** diagram (vault + watchers + manifests).  
3. Add a short **User guide** subsection (README or `docs/scope/user-expectations-hot-vs-vault.md`) summarizing **vault vs operational wallet** so marketing and implementation stay aligned.  
4. Optional: draft **ADR 002 — smart-account policy module (path B)** without blocking v1 vault delivery.  
5. Optional: **`policyRoot`**, **execute** gates, **cooling-off**, **partial failure**: cross-check [legacy-vault-v1](../contracts/legacy-vault-v1.md), [behavior matrix](../testing/behavior-matrix.md), [events](../indexing/events-v1.md) when Solidity ships.  
6. Reject or archive superseded hybrid sketches under [`drafts/`](../../drafts/README.md) if useful.
