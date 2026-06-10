# Governance Overlay — Vision

A thin governance layer that sits **on top of** a host harness (gentle-ai in v1) and makes every
subagent obey the same intent and the same quality bar. It does not replace the host. It does not
duplicate the quality standard — it points to the one that already exists.

## Two pillars

1. **Judgment lens (quality).** Clean-code judgment, applied through a per-phase lens.
   - Enforceable rules: the `clean-code-standards` skill's `## Compact Rules`
   - Scoring: that skill's `/18` rubric (`references/clean-code-rubric.md`)
   - Per-phase translation: [`PHASE-LENS.md`](PHASE-LENS.md)
   - The overlay does NOT embed a second copy. `clean-code-standards` is installed alongside it and is
     the single source of quality truth; this overlay only governs intent and runs the gates against it.

2. **Intent anchor (fidelity).** SDD's own approved artifacts — `proposal` (objective, scope,
   decisions), `design` (how), `spec` (acceptance) — are the intent. There is no separate contract:
   the human approving the proposal is the freeze, propagated to every phase and checked at every
   phase boundary.
   - Per-phase translation and change-request flow: [`PHASE-LENS.md`](PHASE-LENS.md)

## Two pillars, three gates

| Gate | Fires when | Source | Failure means |
| --- | --- | --- | --- |
| **Clean Code Gate** | at refactor-exit, never at green | rubric `/18`, min pass 16, no blocker | loop back to refactor |
| **Intent Gate** | at every phase boundary | approved `proposal`/`spec` | `drift-detected` → STOP, change request to human |
| **System Gate** | at verify, at apply milestones, and at the end of the no-SDD path | quality pillar at whole-change scope, `clean-code-standards` `references/system-review.md` | `blocked` → halts the chain like a blocked Clean Code Gate |

## Governing principle

**Human-in-the-loop by explicit gates.** Nothing important is left to inference. The intent is frozen
when a human approves the proposal, and any change to scope or an approved decision halts the chain and
returns to the human as an explicit change request (a proposal amendment). Drift is never applied
silently — that is the whole point.

## What this overlay is NOT

- Not a fork of the host harness. It only uses the host's documented seams.
- Not a second source of quality truth. The clean-code skill and rubric remain authoritative.
- Not a place for new code patterns, abstractions, or config. It governs; it does not build.
