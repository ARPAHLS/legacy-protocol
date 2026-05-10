# Contributing to ARPA Legacy Protocol

Thank you for helping build **ARPA Legacy Protocol**. This work is stewarded by [ARPA — Hellenic Logical Systems](https://github.com/arpahls); contributions are **[MIT-licensed](LICENSE)** unless a subdirectory states otherwise.

## Ground rules

- Be constructive and specific in issues and pull requests.
- For **security-sensitive** findings (fund loss, unauthorized disbursement, trigger bypass), follow **[SECURITY.md](SECURITY.md)**—do not publish a full exploit publicly before coordination.
- Examples and docs should use **neutral example domains** (e.g. `example.com`) where third-party HTTP or identity services are illustrated.

## What to contribute

| Area | How |
|------|-----|
| **Protocol narrative** | Edit [`docs/arpa-legacy-protocol-reference.md`](docs/arpa-legacy-protocol-reference.md); open a PR with a short rationale. |
| **Implementation docs** | See [`docs/README.md`](docs/README.md); keep ADR / contract specs / schema in sync when behaviour changes. |
| **Exploratory writes** | Start in [`drafts/`](drafts/README.md); fold into `docs/` when stable. |
| **Smart contracts & tests** | Prefer small, focused PRs once `contracts/` exists; include tests and NatSpec aligned with behaviors described in docs. |
| **Tooling / SDK** | Match layout and licensing of sibling packages under this repository root. |

## Pull request checklist

1. One focused topic per pull request where possible.
2. Update [`README.md`](README.md) if you add **top-level** resources or materially change onboarding.
3. You certify you have the right to contribute the material under this repository’s license; sign commits with `git commit -s` if you use the **Developer Certificate of Origin** (see below).

## Developer Certificate of Origin

By submitting a pull request, you agree to the [Developer Certificate of Origin](https://developercertificate.org/) version 1.1. Use `git commit -s` to add a `Signed-off-by` trailer automatically.

```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
