# Phase Lens — the vision, translated per SDD phase

The intent lives in SDD's own artifacts: the `proposal` (objective, in-scope/out-of-scope, decisions)
captures it, and the human approving the proposal freezes it. Every later phase reads the **approved**
`proposal`/`spec`/`design` and applies [`VISION.md`](VISION.md) through the lens below. Every phase
emits its `Intent Gate` line; phases that produce or touch code also run the Clean Code Gate at
refactor-exit.

The quality lens is sourced from the `clean-code-standards` skill — its `## Compact Rules` and the
`/18` rubric; this table is not a second standard, it is where each of those rules bites per phase.

| Phase | Quality lens (clean-code) | Fidelity lens (intent) | Gate |
| --- | --- | --- | --- |
| **explore** | Bias toward the simplest viable shape. Flag over-engineering risk early. Do not invent abstractions while exploring. | Explore within the user's request; surface open scope/decision questions for the proposal. Do not widen the question. | Intent Gate |
| **propose** | Smallest vertical slice. No speculative architecture. | Capture the objective, in-scope/out-of-scope, and decisions — each as **Decided** (local/reversible, with rationale) or **Deferred** (architecture-shaping → 2–3 options for the human). The human picks the deferred ones; that pick is part of approval. Becomes the frozen intent once approved. | Intent Gate |
| **spec** | Requirements stay concrete and minimal. | Every requirement maps to the approved in-scope. No new scope smuggled in as a "requirement". | Intent Gate |
| **design** | Justify the minimal structure. No handlers/wrappers/factories/interfaces without a current caller (hard rules). Keep domain separate from IO/UI/transport. | Elaborate the *how* ONLY within the human-picked decisions. A new architecture-shaping decision → STOP, log it as Deferred and return a change request; never pick it here. | Intent Gate |
| **tasks** | Tasks are small and single-responsibility. Plan foundation slices for shared primitives (row-mapping, error hierarchy, persistence style) BEFORE feature slices; the design emits a `## Primitives` registry. If no duplication/dependency/complexity fitness check exists and the change is substantial, propose one as a foundation slice. | Tasks map 1:1 to in-scope slices. Zero out-of-scope tasks. | Intent Gate |
| **apply** | TDD red → green → **refactor**. Ugly is allowed at green; quality is bought at refactor. Read the design `## Primitives` registry and the `sdd/{change}/primitives` journal BEFORE coding; grep before creating any helper/mapper/error/type — reuse or extend. On the 3rd duplication, extract; record new primitives in the journal. At a milestone (a tasks Phase completes), run the System lens over that layer before the next. | Per task: stay inside the slice. New decision needed → stop the task, raise change request. | **Clean Code Gate** at refactor-exit + Intent Gate per task |
| **verify** | Score touched code against the rubric `/18`; any blocker fails. Run the System Gate over the WHOLE change (apply-progress ∪ git diff) per clean-code-standards `references/system-review.md`, run available fitness functions, emit `System Gate: passed \| blocked`; blocked ⇒ verify FAIL. | **Intent-fit** against the approved proposal/spec: scope respected, decisions unchanged, acceptance met. Drift = blocker. | **All three gates** |
| **archive** | — | Confirm final state matches the approved objective and decisions. Record approved change requests (proposal amendments). Compile the Fidelity & Quality Report. | Intent Gate (final) |

## Proportional ceremony

SDD is for substantial changes. A trivial or small change skips SDD entirely: apply clean-code
judgment inline, run the Clean Code Gate at refactor-exit, and stop. Do not produce
proposal/spec/design documents for work that does not need them — that document bloat is exactly what
this overlay exists to prevent.

## Decision Ledger (which decisions need you)

Every phase externalizes its decisions instead of burying them. A decision needs the human — frozen in
the `proposal`, or escalated later as a change request — when it:

- defines or moves the **scope/boundary** of the change,
- is **expensive to reverse**,
- affects **observable behavior** or the acceptance criteria,
- fixes **architectural shape**: a pattern, a dependency direction, an interface, a data model, a
  library/framework choice.

Everything **local and reversible inside a slice** the phase may decide on its own — but it records it.
Each phase emits:

```
Decisions — <phase>
- Decided: <decision> — rationale; rejected: <alternative>
- Deferred (needs human): <question> — [A] <option> (+/−) · [B] <option> (+/−)
```

Mode-aware: in **interactive** SDD, `propose` and `design` STOP and defer architecture-shaping
decisions to the human. In **automatic** SDD, the agent decides them itself (smallest maintainable
option) and records each as Decided with its rationale + rejected alternatives — never silently. Either
way `design` elaborates only within the agreed decisions; a genuinely new architecture-shaping decision
is returned as a change request, never picked inside the phase. The quality lens, the gates, and
`verify` stay in force in both modes.

## Hard integration rule (inherited from the host harness)

The **Clean Code Gate fires at refactor-exit, never at green.** Green buys correctness (it may be ugly
and temporary); refactor buys quality; the gate guards the refactor. This is what lets TDD and the
overlay coexist instead of fighting.

## What every phase emits

Each phase emits its **Decision Ledger** (Decided / Deferred — see above) plus:

```
Intent Gate: aligned | drift-detected   (+ the deviation, if any)
```

Phases that touch code additionally emit:

```
Clean Code Gate: passed | blocked       (+ score /18 and required fixes, if blocked)
```

Phases that score the whole change (verify; apply at milestones) additionally emit:

```
System Gate: passed | blocked           (+ blockers and required fixes, if blocked)
```

`drift-detected` or `blocked` halts the chain at that phase. A blocked quality gate or a blocked System
Gate loops back into the smallest fix and re-checks. `drift-detected` returns to the human as a change
request (below).

## Change request (the only way the intent changes)

The approved proposal is the frozen truth. Phases may elaborate within it; they may never widen it
silently. When a phase needs something the proposal does not cover, it STOPS and returns:

```markdown
## Change request — <change name>
Detected in phase: <phase>
Deviation: <what the phase wanted to do that the proposal does not cover>
Why it came up: <reason>
Proposed amendment: <add to in-scope / new decision / revised acceptance>
Impact on slices: <which tasks/slices change>
```

The human accepts (the proposal is amended and re-approved) or rejects (the phase proceeds within the
original proposal). Either way the decision is recorded; nothing changes silently.
