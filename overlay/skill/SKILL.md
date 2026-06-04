---
name: intent-overlay
description: "Governance overlay for all code creation, refactoring, review, and SDD phases. Freezes intent; scope drift returns to the human, never applied silently."
when_to_use: |
  Use when creating, refactoring, or reviewing any code, or running any SDD/OpenSpec phase
  (explore → archive). Critical when architectural decisions arise, when the change is
  substantial enough for SDD, or at any refactor-exit where the Clean Code Gate fires.
license: Apache-2.0
metadata:
  author: clean-code-lab
  version: "1.1"
---

# Intent Overlay — governance for every phase

A governance layer over the host harness (gentle-ai/SDD). It does not replace the harness; it makes
every phase obey one frozen intent and one quality bar. Two pillars, two gates:

- **Intent (fidelity)** — the approved SDD `proposal`/`spec`, checked at every phase boundary by the **Intent Gate**.
- **Judgment (quality)** — the `clean-code-standards` skill (its Compact Rules + `/18` rubric), checked at refactor-exit by the **Clean Code Gate**.

Per-phase detail in [`references/`](references): `PHASE-LENS.md` (per-phase criteria and the
change-request flow) and `VISION.md` (rationale).

## Compact Rules

- Match ceremony to change size: trivial/small changes skip SDD — apply clean-code judgment inline and stop. Run SDD (and these gates) only for substantial changes. Never create planning documents the work does not need. No SDD ⇒ no verify phase, so YOU still run the Clean Code Gate at refactor-exit and self-check against the rubric, and use the host's plan/approval step as the human gate. Skipping SDD never skips the quality bar.
- The intent lives in SDD's own artifacts, not a separate document: objective + in-scope/out-of-scope + decisions in the `proposal` (elaborated in `design`); acceptance criteria in the `spec`. The human approving the proposal is the freeze; code (`apply`) starts only after that approval.
- Architecture-shaping decisions (move scope, costly to reverse, change observable behavior, or fix shape — pattern, dependency direction, interface, data model, library) are never made silently: always surfaced with 2–3 options and tradeoffs, never guessed. Who chooses depends on the mode (next rule).
- Read the approved proposal/spec/design at the start of every SDD phase; keep work within in-scope and respect out-of-scope.
- Run the Intent Gate at every phase boundary and emit `Intent Gate: aligned | drift-detected`. On drift, STOP and return a change request (a proposal amendment) to the human; never apply a scope change or a new decision silently.
- Decision Ledger, mode-aware: every phase emits what it **Decided** (with rationale + rejected alternatives) and what it **Defers**. **Interactive** SDD → `propose`/`design` STOP and defer architecture-shaping decisions to the human. **Automatic** SDD → the agent decides them (smallest maintainable option) but records each in the ledger; never silently. Either way `design` elaborates only within the agreed decisions and returns a genuinely new architecture-shaping decision as a change request. Rules, gates, and verification stay in force in both modes.
- The quality bar is the `clean-code-standards` skill — its `## Compact Rules` plus the `/18` rubric. This overlay governs intent and runs the gates; it does not define a second quality standard.
- Run the Clean Code Gate at refactor-exit, never at green, and report `Clean Code Gate: passed | blocked` (scored against the clean-code-standards rubric).

## Decision Gates

| Situation | Required action |
| --- | --- |
| Phase output would exceed in-scope | Stop; raise a change request (proposal amendment) to the human |
| Architecture-shaping decision, interactive mode | Surface with options; defer to the human; log in the ledger |
| Architecture-shaping decision, automatic mode | Agent picks the smallest maintainable option; log it (with rationale + rejected) in the ledger; never silently |
| Local, reversible detail inside a slice | The phase may decide it, but logs it in the Decision Ledger |
| Decision not covered by the proposal | Escalate as a change request; do not decide inside the phase |
| Change is trivial/small (no SDD) | Skip SDD; apply clean-code judgment inline; still run the Clean Code Gate + self-check (no verify phase will) |
| Quality rule needed | Defer to the `clean-code-standards` skill (its Compact Rules + rubric) |
| Quality at green | Not done; the Clean Code Gate fires only at refactor-exit |
