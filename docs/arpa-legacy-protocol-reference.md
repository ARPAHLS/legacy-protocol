# ARPA Legacy Protocol — Reference Specification

This document defines **ARPA Legacy Protocol**: programmable **conditional disbursement** (including “self‑executable” payout after authorized conditions), **scheduled and dormancy-triggered transfers**, and **estate-style** routing of crypto-assets on **EVM-compatible chains**. It is the **authoritative narrative specification** for the [`arpahls/legacy-protocol`](https://github.com/arpahls/legacy-protocol) repository and informs implementation, tests, audits, and product documentation.

The document consolidates **intent, mechanisms, motivations, terminology, conflicts, integrations, UX goals, operational constraints, risks**, and **architectural separations** for the protocol product.

**Legal framing.** On-chain disbursement tooling **does not** equate to a valid will or probate outcome in any jurisdiction unless off-chain law says otherwise. On-chain behavior is described here as **conditional asset disposition** and **vault-policy execution** built on cryptography and programmable assets.

---

## 1. Elevator pitch

**What it is.** A protocol whereby an owner configures **deterministic**, **delayed**, optionally **oracle-driven** disbursement policies over groups of crypto-assets held in vaults, smart accounts, or coordinated allowances—**executed on-chain** when authorized **trigger conditions** are satisfied.

**Problem addressed.** Survivorship, abandonment, dormant keys, orderly transfer without manual intervention, programmable generosity, and mitigation of indefinite lock‑up—while handling **custody**, **off-chain attestations**, and **adversarial ordering**.

**Why EVM chains.** Transparent rules, composability with existing token and account standards, account-abstraction modules where applicable, and automation via keepers, relays, and attestors.

---

## 2. Core concepts and terminology

| Term | Definition |
|------|-------------|
| **Owner / policy author** | Entity that configures rules before arm/liveness conditions are met; may revoke or amend depending on maturity state. |
| **Vault / disbursement executor** | On-chain coordinator holding assets or exercising delegated authority to transfer under policy rules. |
| **Policy bundle** | A named set of disbursement intents, priorities, predicates, and timeouts, with versioning guardrails where needed. |
| **Asset cohort** | A logical grouping (“stablecoins matching filter Y”; “NFTs from contract Z”; tokenId ranges; enumerated fungible tokens). |
| **Beneficiary** | Recipient address or contract that supports required receiver hooks for the asset types in use. |
| **Trigger** | A Boolean gate moving policy from *armed idle* toward *eligible for execution*; combines **signals** and **evaluation rules**. |
| **Signal sources** | On-chain time, keeper calls, structured signed attestations (for example [EIP-712](https://eips.ethereum.org/EIPS/eip-712)), multisig votes, oracle contracts, dormancy counters, smart-account validation hooks, bridge or rollup events, etc. |
| **Execution** | Atomic or staged transfer of cohorts subject to gas policy, approvals, callback safety, decimals, royalties, and off-chain compliance rules where applicable. |
| **Cooling-off / veto window** | Delay after a trigger is tentatively satisfied before irreversible disbursement; owner can prove liveness or invoke revocation. |

---

## 3. Intended user scenarios

1. **Dormancy / inactivity.** If the owner has not performed `N` qualifying user-intent transactions over `24` months (plus optional grace signals), disburse fungibles per rules; route NFTs by explicit map or default recipient.  

2. **Layered attestations.** A registered **attestor set** signs periodic “alive” signals; missing freshness plus dormancy can escalate—while **recent owner activity** blocks or delays payout to reduce false positives.  

3. **Oracle-backed conditions.** Policies depend on **verifiable on-chain facts** (feeds, lending health factors, etc.), not raw HTTP inside the EVM.  

4. **Heterogeneous splits.** Fungible cohort A → one heir; NFT collection B → another; stablecoin cohort C → a third; remainder → residual bucket.  

5. **Gas-aware execution.** Retain `K` wei of native gas token; cap spendable share; delay execution until fee conditions or batching allow safe completion.  

6. **Progressive release.** After trigger T1 release a fraction; after T2 and further delay release the rest—with global idempotency and conflict rules.

---

## 4. System architecture (high level)

Modular **design** separates these concerns for implementation and testing:

### 4.1 Custody and authority (one primary pattern per deployment)

- **Vault custody:** assets held in escrow; clearest invariants; requires user migration into the vault.  
- **Smart-account module:** policy embedded in account logic (for example [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337)-style accounts) with dedicated storage for policy roots and execution nonces.  
- **Allowance / delegation choreography:** split between vault-held and wallet-held assets; the protocol **must** forbid ambiguous partial-authority states.  

**Security note.** Each model changes MEV exposure, builder censorship risk, and who can race execution.

### 4.2 Policy representation

| Layer | Description |
|-------|-------------|
| **On-chain minimized** | Contract stores `policyId → policyRoot` (Merkle, single full-manifest digest, or SNARK-friendly commitment—**v1 commits a digest** over canonical serialization per [ADR 001](adr/001-v1-custody.md)) with off-chain manifest and supplied envelope at execution. |
| **On-chain expansive** | Explicit structs for small policies; higher audibility; higher gas. |

The **protocol specification** for a given release **defines** replay protection, version bumps, revocation precedence, hash algorithms, and canonical serialization so independent implementers stay compatible.

### 4.3 Trigger plane

The EVM **does not** read arbitrary HTTPS. The protocol **defines verifiable surfaces**:

| Trigger class | Role |
|---------------|------|
| **Time / block** | Clocks, delays, windows. |
| **Inactivity** | Counters over qualifying owner actions; needs precise definition for EOAs, smart accounts, and batching. |
| **Heartbeat** | Cheap periodic owner signals; bound spam and griefing. |
| **Multisig / threshold** | Committee attests state transitions. |
| **Structured attestations** | Registered keys and rotation; verify with agreed signing schemes (for example EIP-712). |
| **Oracles** | Snapshot IDs, TTL, staleness bounds. |
| **ZK bridges** | Optional; separate circuit and trust assumptions. |

Expose small **trigger interfaces** and **events** so indexers, wallets, and compliance tooling integrate consistently.

### 4.4 Execution plane

Handles cohort iteration with attention to approval races, reentrancy and `onERC721Received`-style failures, partial-failure modes, and odd token behaviors (fee-on-transfer, rebasing) declared in or out of scope per release.

### 4.5 Observation and automation (off-chain)

Watchers and bots **observe** eligibility and **submit** transactions; they **do not** define truth for medical or price facts unless those facts are already verified on-chain.

---

## 5. Multi-trigger composition and conflict resolution

### 5.1 Predicate composition

Eligibility is built from Boolean structure over primitive conditions (for example: at least one of several trigger groups, each group requiring all of its clauses). Composition grammar and execution safety during veto windows are under discussion in GitHub [#24](https://github.com/ARPAHLS/legacy-protocol/issues/24).

### 5.2 Overlapping assets

For overlapping cohorts, pick **one** deterministic rule system, for example:

- **Global priority list** among policies, or  
- **First eligible by `(priority, timestamp)`** with an explicit tie-break, or  
- **Disjoint cohort keys** enforced at authoring time.

**v1:** global policy priority plus explicit tie-break—[ADR 001](adr/001-v1-custody.md) and [v1 MVP scope](scope/v1-mvp.md).

Define **dust**, **skipped transfers**, and **blacklisted recipients**.

---

## 6. Cooling-off, accident mitigation, recovery

For sensitive attestations, combine signals (for example attestation + dormancy + recovery veto). Document **revocation**, **key rotation**, interaction with **social recovery**, and any **pause** roles with clear capture risks.

**Open normative work:** distinguish **prove liveness**, **cancel handoff**, and **revoke policy**, and whether cancel resets long-horizon dormancy clocks—see GitHub [#22](https://github.com/ARPAHLS/legacy-protocol/issues/22) (related: [#23](https://github.com/ARPAHLS/legacy-protocol/issues/23), [#25](https://github.com/ARPAHLS/legacy-protocol/issues/25)). Implementation of dormancy and attestation triggers should follow accepted outcomes there.

---

## 7. UX and authoring

| Concern | Direction |
|---------|-----------|
| **Progressive complexity** | Presets to advanced rule builders. |
| **Simulation** | Timelines and inventory impact before commit. |
| **Conflict detection** | Static overlap warnings. |
| **Trust surfacing** | Explicit who can lie, censor, or reorder. |
| **Attestor UX** | Registration, rotation, clear non-legal copy. |

Optional **JSON manifests** can carry portable policy definitions for tooling; on-chain truth remains the contracts you deploy.

---

## 8. Gas and economics

Reserve native token, percentage caps, fee ceilings, optional **executor tips**, and behavior when the owner has stripped gas—each **specified** per release to avoid stuck or griefed execution.

---

## 9. Asset scope (product tranches)

**Initial tranche (typical):**

- Common fungible tokens (non-rebasing).  
- NFTs with standard receiver expectations.

**Explicitly out of scope or deferred until specified:**

- Rebasing tokens, complex LP or derivative positions, blocking NFT callbacks, fragmented vault shares, dual bridged representations, KYC-gated RWA routers—unless a release adds a concrete, tested path.

---

## 10. Security and trust analysis

| Threat | Mitigation direction |
|--------|----------------------|
| **Bad or coerced attestor** | Quorum, cooling-off, contradiction with owner activity, revocation. |
| **Censorship / racing executors** | Transparent events, batching, MEV-aware patterns where appropriate. |
| **Policy tampering mid-flight** | Version locks and commitment timelines. |
| **Malicious beneficiaries** | Pull vs push tradeoffs, callback controls. |
| **Bad oracle data** | Deviation checks, staleness, fallback behavior. |
| **Compliance** | Off-chain policy and screening where required. |
| **Key compromise** | Separate cold, hot, and attestor key roles. |

Targets for formal methods and fuzzing: monotonic state, idempotent execution IDs, bounded drainage.

---

## 11. Regulatory, privacy, ethics

Minimize sensitive data on-chain; prefer attestations that carry only what execution needs. Key rotation and data protection sit **off-chain** with counsel.

---

## 12. Interoperability with existing EVM standards

Implementations are expected to compose with common **Ethereum application standards** (names are conventional, not project branding):

| Standard family | Role |
|-----------------|------|
| **ERC-20 / ERC-721 / ERC-1155** | Token semantics and transfers. |
| **EIP-712** | Typed structured data signing for policies and attestations. |
| **ERC-4337** | Account abstraction flows, where used. |
| **ERC-2612 (Permit)** | Optional gasless approvals when safe with policy lifetimes. |

---

## 13. State machine outline (informative)

```
UNINITIALIZED --> CONFIGURED_ARMED --> (optional cooling) ELIGIBLE --> EXECUTING -->
  PARTIAL_SUCCESS --> (loop) EXECUTING
                 --> COMPLETED_TERMINAL | ABORT_FAILURE | REVOKED
```

Illustrative events: `PolicyUpdated`, `TriggerSatisfied`, `ExecutionStarted`, `ExecutionPartial`, `ExecutionCompleted`, `PolicyRevoked` (subject to exact product design).

---

## 14. Open research and roadmap topics

1. ~~Canonical **v1 custody** choice and upgrade story.~~ **Resolved:** [ADR 001](adr/001-v1-custody.md) — vault custody (path A), **immutable** v1 implementation; document supersession when path B ships.  
2. **Cancel / liveness / handoff abort** — [#22](https://github.com/ARPAHLS/legacy-protocol/issues/22).  
3. **Pluggable triggers, policy profiles, shared veto core** — [#23](https://github.com/ARPAHLS/legacy-protocol/issues/23).  
4. **Predicate composition and safe queued execution** — [#24](https://github.com/ARPAHLS/legacy-protocol/issues/24).  
5. **Guardian set design and rotation** — [#25](https://github.com/ARPAHLS/legacy-protocol/issues/25).  
6. **Inactivity** definition across EOA vs smart-account UX (blocked on #22 / #23).  
7. **Oracle adapter** surface for multi-chain deployments ([CAIP](https://github.com/ChainAgnostic/CAIPs)-style references if needed).  
8. **Indexing** event schema for subgraphs and explorers — [events-v1.md](indexing/events-v1.md) (draft).  
9. **Upgrade patterns** beyond v1 immutable vaults (proxies, module registries)—only if future ADRs introduce them.

---

## 15. Modular system map

Product work can follow **independent modules** with stable internal boundaries:

| Module | Focus |
|--------|--------|
| **Core** | State machine, arbitration, replay protection, security posture. |
| **Vault** | Escrow custody API as implemented. |
| **Triggers — attestation** | Signing schemes, registries, freshness, revocation. |
| **Triggers — oracle** | Feeds, staleness, manipulation resistance. |
| **Events** | Logging contract for indexers. |

Use consistent **`salt`**, **`policyCommitment`**, **nonces**, and **execution-proof** hashing across modules so commitments and witnesses stay aligned.

---

## 16. Glossary

**Self-executable** means **no further owner-signed intent is required** for the **on-chain** payout path once conditions are met—**not** that legal probate is automatic. **Trigger** is an on-chain-verifiable condition, not ad hoc API polling inside the EVM.

---

## 17. License and normative documents

Repository documentation default: **[MIT](../LICENSE)**. If the project publishes **versioned interface specs** (for example `SPEC.md` next to contracts), those documents may use **RFC 2119** keywords (**MUST**, **SHOULD**, **MAY**) in **normative sections only** so engineers and auditors share one reading of obligations—this is ordinary technical writing practice and independent of any standards body submission.

---

## 18. Implementation documentation index

Structured artifacts that narrow the narrative spec into buildable and auditable scope:

- **Docs hub:** [docs/README.md](README.md)
- **ADR (custody):** [docs/adr/001-v1-custody.md](adr/001-v1-custody.md)
- **Architecture:** [docs/architecture/overview.md](architecture/overview.md)
- **v1 MVP scope:** [docs/scope/v1-mvp.md](scope/v1-mvp.md)
- **Ideal vs MVP asset coverage (north star vs vault-only):** [docs/scope/ideal-vs-mvp-asset-coverage.md](scope/ideal-vs-mvp-asset-coverage.md)
- **Trust boundaries:** [docs/security/trust-boundaries-v1.md](security/trust-boundaries-v1.md)
- **Events / indexing:** [docs/indexing/events-v1.md](indexing/events-v1.md)
- **Policy manifest:** [docs/schemas/policy-manifest.md](schemas/policy-manifest.md) · [docs/schemas/policy-manifest-draft.json](schemas/policy-manifest-draft.json)
- **Behaviour matrix:** [docs/testing/behavior-matrix.md](testing/behavior-matrix.md)
- **Vault v1 contract spec (draft):** [docs/contracts/legacy-vault-v1.md](contracts/legacy-vault-v1.md)
- **Drafts (non-canonical):** [drafts/README.md](../drafts/README.md)
