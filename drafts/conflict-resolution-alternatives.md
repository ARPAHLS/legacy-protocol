# Draft: conflict resolution alternatives

Source: [reference spec §5.2](../docs/arpa-legacy-protocol-reference.md#52-overlapping-assets). **Pick one for v1** in [v1 MVP scope](../docs/scope/v1-mvp.md) and delete or archive the rest.

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
