---
name: intent-overlay
description: "Use when creating, refactoring, reviewing code, or running any SDD/OpenSpec phase (explore, propose, spec, design, tasks, apply, verify, archive). Freezes intent before code and keeps scope and clean-code quality intact across the whole chain; scope drift returns to the human instead of being applied silently."
license: Apache-2.0
metadata:
  author: clean-code-lab
  version: "1.0"
---

# Intent Overlay — governance for every phase

A governance layer over the host harness (gentle-ai/SDD). It does not replace the harness; it makes
every phase obey one frozen intent and one quality bar. Two pillars, two gates:

- **Intent (fidelity)** — a frozen Intent Contract, checked at every phase boundary by the **Intent Gate**.
- **Judgment (quality)** — clean-code judgment per phase, checked at refactor-exit by the **Clean Code Gate**.

Full contract and per-phase detail in [`references/`](references): `INTENT-CONTRACT.md` (freeze ritual,
template, change-request flow), `PHASE-LENS.md` (per-phase criteria), `VISION.md` (rationale).

## Compact Rules

- Before writing code, freeze an Intent Contract: objective, in-scope, out-of-scope, frozen decisions, acceptance criteria, and an SDD slice plan. Do not freeze while a critical decision is open.
- When a decision is open, propose 2–3 options and explain each with tradeoffs; do not guess. There is no limit on clarification rounds before freeze.
- Read the frozen Intent Contract at the start of every SDD phase; keep work within in-scope and respect out-of-scope.
- Run the Intent Gate at every phase boundary and emit `Intent Gate: aligned | drift-detected`. On drift, STOP and return a change request to the human; never apply a scope change or a new decision silently.
- A decision not already in the contract is escalated to the human, not decided inside a phase.
- Prefer the smallest maintainable shape; reject unnecessary over-engineering. Working code that raises maintenance cost is insufficient.
- Do not add handlers, wrappers, factories, interfaces, proxies, or lazy-loaders without a current caller; do not mirror a library API with a passthrough wrapper; do not create broad config objects just to pass values around.
- Use semantic domain names; avoid vague names like data, item, handler, or utils unless the domain truly says so.
- Refactor only to reduce or preserve reading complexity; passing tests do not justify harder-to-read code.
- Run the Clean Code Gate at refactor-exit, never at green, and report `Clean Code Gate: passed | blocked`.
- Keep domain rules separate from IO, UI, transport, and persistence.

## Decision Gates

| Situation | Required action |
| --- | --- |
| Phase output would exceed in-scope | Stop; raise a change request to the human |
| Decision not in the contract | Escalate; do not decide inside the phase |
| New abstraction | Only if it removes current complexity and has a caller |
| Refactor | Must reduce or preserve reading complexity |
| Quality at green | Not done; gate fires only at refactor-exit |
