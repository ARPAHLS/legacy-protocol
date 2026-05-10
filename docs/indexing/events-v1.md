# Events and indexing (v1 draft)

Candidate **event surface** for indexers, explorers, and wallets. Names and parameters are **draft** until Solidity exists; keep in sync with [reference §13](../arpa-legacy-protocol-reference.md#13-state-machine-outline-informative).

## Lifecycle events

| Event | When | Key indexed fields (suggested) |
|-------|------|--------------------------------|
| `PolicyCommitted` | New policy root stored | `policyId`, `owner`, `policyRoot`, `version` |
| `PolicyRevoked` | Policy voided | `policyId`, `version` |
| `TriggerArmed` | Policy moves to armed / watching | `policyId`, `triggerSetId` |
| `TriggerSatisfied` | Predicate set satisfied (may be provisional) | `policyId`, `triggerId`, `evidenceHash` |
| `CoolingOffStarted` | Optional delay before execution | `policyId`, `executeAfter` |
| `ExecutionStarted` | First transfer batch | `policyId`, `executionId` |
| `ExecutionPartial` | Batch completed; more remain | `policyId`, `executionId`, `nonce` |
| `ExecutionCompleted` | Terminal success | `policyId`, `executionId` |
| `ExecutionAborted` | Terminal failure | `policyId`, `executionId`, `reason` |

## Asset movement

| Event | When |
|-------|------|
| `AssetTransferScheduled` | Optional: per-cohort schedule before send |
| `AssetTransferred` | After successful ERC-20 / ERC-721 / ERC-1155 move |

Use **ERC-20 / ERC-721 Transfer** events from token contracts for double-entry style indexing; protocol events carry **intent** and **execution IDs**.

## Subgraph notes

- Index `policyId` and `executionId` as primary correlation keys.
- Store `policyRoot` and link off-chain manifest IPFS hash if used (not required by core spec).

## Changelog

- **Draft** — align with first Foundry `LegacyVault` (or chosen module) implementation.
