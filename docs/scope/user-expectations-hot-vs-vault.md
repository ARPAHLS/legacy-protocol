# User expectations: operational wallet vs vault (v1)

Companion to [ADR 001](../adr/001-v1-custody.md) **path A**. Keeps [README](../../../README.md) promises honest relative to chain mechanics.

## One sentence

The **vault holds what you put in it**; **predicates move only that inventory** unless you adopt a **later** smart-account or delegation design.

## Can I trade or use vaulted NFTs / tokens “normally”?

**Not from the same wallet balance at the same time.** Tokens live in **one place** per chain state: vault contract custody **or** your wallet (or another contract). To use vaulted assets with a dapp that expects your EOA as owner you typically **withdraw** to a hot wallet—or build on a future **smart-account** design ([ADR 001 path B](../adr/001-v1-custody.md)) that intentionally unifies custody and modules.

## What about gas and assets I never deposited?

Policies **cannot** reach into arbitrary EOAs **after** you stop signing unless you already **delegated**, **approved**, or those assets sit under **the same contracted authority** covered by policy. Keep **mining gas / spending cash** wherever you prefer; carve **succession-eligible holdings** into the vault early.

## Practical split

| Intent | Typical placement |
|--------|---------------------|
| Day trading, ticketing, petty cash | **Operational** wallet balance |
| Inheritance-grade / dormant / timelocked | **Vault** (or smart account module when available) |

## Where to read more

- [ADR 001](../adr/001-v1-custody.md) — full rationale and roadmap to path B/C.  
- [v1 MVP](./v1-mvp.md) — what byte code v1 targets.  
- [Reference §4.1](../arpa-legacy-protocol-reference.md#41-custody-and-authority-one-primary-pattern-per-deployment).
