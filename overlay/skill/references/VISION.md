# Governance Overlay — Vision

A thin governance layer that sits **on top of** a host harness (gentle-ai in v1) and makes every
subagent obey the same intent and the same quality bar. It does not replace the host. It does not
duplicate the quality standard — it points to the one that already exists.

## Two pillars

1. **Judgment lens (quality).** Clean-code judgment, applied through a per-phase lens.
   - Enforceable rules: the parent skill's `## Compact Rules` in [`../SKILL.md`](../SKILL.md)
   - Per-phase translation: [`PHASE-LENS.md`](PHASE-LENS.md)
   - Origin: distilled from the clean-code-lab standard and its `/18` rubric; the enforceable subset
     is embedded here so the skill is self-contained when installed globally.

2. **Intent anchor (fidelity).** A frozen Intent Contract captured before any code is written,
   propagated to every phase, and checked at every phase boundary.
   - Protocol and template: [`INTENT-CONTRACT.md`](INTENT-CONTRACT.md)

## Two gates

| Gate | Fires when | Source | Failure means |
| --- | --- | --- | --- |
| **Clean Code Gate** | at refactor-exit, never at green | rubric `/18`, min pass 16, no blocker | loop back to refactor |
| **Intent Gate** | at every phase boundary | Intent Contract | `drift-detected` → STOP, change request to human |

## Governing principle

**Human-in-the-loop by explicit gates.** Nothing important is left to inference. The intent is frozen
by a human before SDD starts, and any change to scope or a frozen decision halts the chain and returns
to the human as an explicit change request. Drift is never applied silently — that is the whole point.

## What this overlay is NOT

- Not a fork of the host harness. It only uses the host's documented seams.
- Not a second source of quality truth. The clean-code skill and rubric remain authoritative.
- Not a place for new code patterns, abstractions, or config. It governs; it does not build.
