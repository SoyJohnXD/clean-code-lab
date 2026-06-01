# Phase Lens — the vision, translated per SDD phase

Each gentle-ai SDD phase reads the FROZEN [`INTENT-CONTRACT.md`](INTENT-CONTRACT.md) and applies the
[`VISION.md`](VISION.md) through the lens below. Every phase emits its `Intent Gate` line; phases that
produce or touch code also run the Clean Code Gate at refactor-exit.

The quality lens is sourced from the parent skill's `## Compact Rules` in [`../SKILL.md`](../SKILL.md);
this table is not a second standard, it is where each rule bites per phase.

| Phase | Quality lens (clean-code) | Fidelity lens (intent) | Gate |
| --- | --- | --- | --- |
| **explore** | Bias toward the simplest viable shape. Flag over-engineering risk early. Do not invent abstractions while exploring. | Explore only within the frozen Objective. Do not widen the question beyond the contract. | Intent Gate |
| **propose** | Smallest vertical slice. No speculative architecture. | Restate the Objective verbatim from the contract. Proposal scope ⊆ In-scope. | Intent Gate |
| **spec** | Requirements stay concrete and minimal. | Every requirement maps to In-scope. No new scope smuggled in as a "requirement". | Intent Gate |
| **design** | Justify the minimal structure. No handlers/wrappers/factories/interfaces without a current caller (hard rules). Keep domain separate from IO/UI/transport. | Elaborate the *how* within frozen decisions. A decision not in the contract → escalate as change request, do not decide it here. | Intent Gate |
| **tasks** | Tasks are small and single-responsibility. | Tasks map 1:1 to In-scope slices. Zero out-of-scope tasks. | Intent Gate |
| **apply** | TDD red → green → **refactor**. Ugly is allowed at green; quality is bought at refactor. | Per task: stay inside the slice. New decision needed → stop the task, raise change request. | **Clean Code Gate** at refactor-exit + Intent Gate per task |
| **verify** | Score touched code against the rubric `/18`; any blocker fails. | **Intent-fit** against the contract: scope respected, decisions unchanged, acceptance met. Drift = blocker. | **Both gates** |
| **archive** | — | Confirm final state matches the frozen Objective and decisions. Record approved change requests. Compile the Fidelity & Quality Report. | Intent Gate (final) |

## Hard integration rule (inherited from the host harness)

The **Clean Code Gate fires at refactor-exit, never at green.** Green buys correctness (it may be ugly
and temporary); refactor buys quality; the gate guards the refactor. This is what lets TDD and the
overlay coexist instead of fighting.

## What every phase emits

```
Intent Gate: aligned | drift-detected   (+ the deviation, if any)
```

Phases that touch code additionally emit:

```
Clean Code Gate: passed | blocked       (+ score /18 and required fixes, if blocked)
```

`drift-detected` or `blocked` halts the chain at that phase. Drift returns to the human as a change
request (see [`INTENT-CONTRACT.md`](INTENT-CONTRACT.md)); a blocked quality gate loops back into the
smallest fix and re-checks.
