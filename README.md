<div align="center">

  <img src="https://raw.githubusercontent.com/ARPAHLS/.github/main/legacy_gh_splash0.png" alt="Legacy Protocol logo" width="400px" />

<p align="center"><strong>Programmable ownership that outlives you.</strong></p>

<p align="center">Set rules now—time, dormancy, attestations, or committee votes—and smart contracts transfer your crypto, NFTs, vault keys, DIDs, or even sanctioned AI agents later. No lawyers, no rumors, no ledger scavengers. Just execution as locked, from inheritance to passive income to unstoppable treasury handoffs.</p>

[![ARPA Hellenic Logical Systems](https://img.shields.io/badge/ARPA-Hellenic%20Logical%20Systems-B39DDB?labelColor=EDE7F6&style=flat)](https://github.com/arpahls)

[![License: MIT](https://img.shields.io/badge/license-MIT-C5CAE9?labelColor=EDE7F6&style=flat)](LICENSE) [![docs contributing](https://img.shields.io/badge/docs-contributing-C5CAE9?labelColor=EDE7F6&style=flat)](CONTRIBUTING.md)

</div>

- **Binds** recipients, assets, and verifiable conditions (timers, dormancy, attestations, committee votes, oracle facts, staged releases, conflict rules)
- **Moves** tokens, NFTs, vault keys, personal data, DID-linked wallets, sanctioned agents—as your deployment enumerates them
- **Resolves** conflicting claims on the same balance deterministically so execution is unambiguous on-chain
- **Executes** without lawyers, surprise relatives, kitchen-table hostage politics, or renegotiating the deal after predicates fire

That's it. The same backbone handles inheritance, dormant treasuries, timed gifts, corporate continuity, or an exit triggered by silence or a data feed—not because laws changed or cousins appeared, but because you decided.

---

## Quick Nav

| Goal | Where to read |
|------|----------------|
| Browse all technical docs (ADR, architecture, schemas, tests) | [**Documentation index**](docs/README.md) |
| Understand the problem and design | [§ Rationale](#rationale), then [**Reference specification**](docs/arpa-legacy-protocol-reference.md) |
| Contribute or propose changes | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Report a vulnerability | [SECURITY.md](SECURITY.md) |
| See work in progress drafts | [`drafts/`](drafts/README.md) |

License: [MIT](LICENSE).

---

## Rationale

Crypto doesn't behave like a bank account. Value sits unreachable after a lost seed, a vanished founder, a wallet that stops signing, or an argument about who was "really" supposed to inherit. The same failure happens off-chain: opportunists, slow process, surprise relatives, and narrative wars ignore the quiet deal you thought everyone understood.

**ARPA Legacy Protocol** treats that as one class of problem: pre-committed, machine-checkable rules for who gets which assets when which conditions fire. Death and disability are major drivers—but not the only ones. The same backbone handles dormancy timers, committee votes, oracle-backed facts, staged releases, and conflict rules when two policies reach for the same balance. You choose scenarios ahead of time: inheritance, yes, but also long-silent treasuries, timed gifts, corporate continuity, or an exit triggered by silence or a data feed.

What stays constant is sovereignty of intent before the storm. You set beneficiaries and predicates while you hold keys. The chain executes when the predicates hold. No lawyers. No surprise cousins. No kitchen-table negotiations. No frozen museums on the ledger. Programmable money finishes the story—because you decided, not because laws changed or someone got loud after you stopped signing.

---

## For builders

Today: reference spec ([`docs/arpa-legacy-protocol-reference.md`](docs/arpa-legacy-protocol-reference.md)), structured implementation docs ([`docs/README.md`](docs/README.md): **Accepted** ADR 001, architecture, MVP scope, ideal-vs-MVP asset coverage, events, policy JSON schema, behaviour matrix, vault spec), **initial Solidity v1 scaffolding** in [`contracts/`](contracts/), and non-canonical sketches ([`drafts/`](drafts/README.md)).

Coming next: Foundry project wiring, executable tests against the behavior matrix, machine-readable policy manifests, and an SDK for encoding commitments and integration proofs.

Pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for norms.

---

## Licensing

Documentation and artifacts in **`arpahls/legacy-protocol`** default to **[MIT](LICENSE)**. Separate packages (when added) declare their own `LICENSE` at their roots if different.

---

## Contributing and trademarks

Use **[CONTRIBUTING.md](CONTRIBUTING.md)** for pull requests and community norms. **ARPA Legacy Protocol** and **ARPA Hellenic Logical Systems** are steward and project identifiers—do **not** imply endorsement by the Ethereum Foundation or other third parties without explicit approval.

---

## Product roadmap (in priority order)

1. **~~Freeze v1 custody model~~ → Done:** [ADR 001](docs/adr/001-v1-custody.md) **Accepted** — vault custody (path A), immutable v1 implementations, hybrid `execute` model. Next: mirror in `contracts/` (Foundry) and behavior tests.

2. **Bootstrap `contracts/` into executable build/tests** — wire Foundry (or Hardhat), then add unit and invariant tests mapped to behaviors in [`docs/arpa-legacy-protocol-reference.md`](docs/arpa-legacy-protocol-reference.md).

3. **Authoring tooling** — policy manifests, CLI/SDK for commitments and regression fixtures.

4. **Testnet deployment and operations** — monitoring, (**v1:** immutable bytecode per deployment; migrations explicit), coordinated disclosure via [SECURITY.md](SECURITY.md).

5. **External audit** — then sober mainnet-adjacent or high-value use only after reviewers sign off.

---

## Development setup

**Clone:**

```powershell
git clone https://github.com/arpahls/legacy-protocol.git
cd legacy-protocol
```

**Track remote and publish** (adapt paths if your checkout lives elsewhere):

```powershell
git remote -v

git add .
git commit -m "Describe your change"
git push -u origin main
```

New repository bootstrap (maintainers initializing an empty `origin`):

```powershell
git init
git branch -m main
git remote add origin https://github.com/arpahls/legacy-protocol.git
git add README.md CONTRIBUTING.md SECURITY.md LICENSE assets/ docs/ drafts/
git commit -m "ARPA Legacy Protocol: initial documentation"
git push -u origin main
```

If `origin` already exists: `git remote set-url origin https://github.com/arpahls/legacy-protocol.git`

---

## Disclaimer

This material is **not** legal advice. **ARPA Legacy Protocol** enables conditional on-chain transfers of assets and control you scope in code—it does **not**, by itself, create a valid will, trust, or testamentary instrument in any jurisdiction unless off-chain law and counsel say otherwise.

Healthcare condition, death, or identity attestations implicate regulated data and regulated claims; they require separate compliance regimes and professional review, not assumptions inside Solidity alone.

Consult qualified counsel before relying on any deployment for **high-value** balances, fiduciary duties, sanctions exposure, tax planning, or other legally binding arrangements.

---

### Why not just write a will?

A conventional will does not move cryptographic keys on its own; it typically does not read oracle-fed facts inside the consensus layer; it does not atomically adjudicate overlapping payout rules the way an explicit conflict policy must; it does **not** self-execute on chain without someone's ongoing permission—and this stack is aiming at deterministic execution when predicates you authored already hold.

---

<div align="center">
    <img src="assets/arpalogo.png" alt="ARPA Logo" width="50" />
    <p><em><strong>ARPA Legacy Protocol</strong> is stewarded by <a href="https://github.com/arpahls">ARPA Hellenic Logical Systems</a> alongside open community contributions.</em></p>
</div>
