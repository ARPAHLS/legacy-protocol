# Draft: conflict resolution alternatives

**v1 resolution (frozen):** [ADR 001](../docs/adr/001-v1-custody.md) + [v1 MVP](../docs/scope/v1-mvp.md) use **global policy priority** with a deterministic tie-break (closest to Option A below; tie-break specifics in the manifest / vault spec).

Source: [reference spec §5.2](../docs/arpa-legacy-protocol-reference.md#52-overlapping-assets). This draft is **non-canonical** and kept for comparison / future reconsideration.

## Option A — Global strict priority

Linear order `P1 ≻ P2 ≻ P3` among policies touching overlapping cohorts.

- **Pro:** Simple to reason; deterministic.
- **Con:** Authoring burden to assign priorities globally; easy to misconfigure.

## Option B — First eligible by `(priority, timestamp)`

When multiple policies become eligible, execute the minimal tuple by some total order; ties broken by explicit **hashed tie-break** or `policyId` lexicographic ([reference §5.2](../docs/arpa-legacy-protocol-reference.md#52-overlapping-assets)).

- **Pro:** No global list required up front.
- **Con:** Miner/ordering sensitivity unless design uses commit-reveal or explicit queue timestamps with care.

## Option C — Disjoint cohort keys

Authoring tool enforces **non-overlapping** cohort keys; static analysis rejects bad configs.

- **Pro:** Zero runtime collision in ideal cases.
- **Con:** Rigid; real portfolios often overlap.

## Recommendation (draft)

Start with **A or C** for v1 predictability; document **B** for v2 if users demand dynamic contention.
