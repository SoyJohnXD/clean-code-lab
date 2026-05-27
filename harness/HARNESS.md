# Clean-Code Harness — 3-Phase Control Contract

## What This Is

A **harness**, not a skill. A skill is passive knowledge the agent *consults* ("this is what good code
looks like"). A harness is the **control structure that governs the agent's loop** — it dictates *how the
agent is allowed to work*: frame the problem, surface an informed decision, keep a human in the loop, and
gate quality before declaring done.

The judgment lives in the skill. This document is the workflow that puts that judgment on rails.

## Substrate

Runs on **native Claude Code plan/execute mode**. No external dependencies, no global config, no extra
tooling. Plan mode is already a human-in-the-loop gate (`ExitPlanMode` = approval).

The **constitution** is not duplicated here — it is referenced:

- `skills/clean-code-standards/SKILL.md` — the design judgment and hard rules.
- `docs/clean-code-rubric.md` — the scoring criteria for the verify gate.

## Mental Model — 4 Layers

```
LAYER 1 — Native control:   PLAN <--> EXECUTE        (ExitPlanMode = macro human gate)
LAYER 2 — Spine:            Plan > Apply loop > Verify   (the 3 phases)
LAYER 3 — Discipline:       TDD red > green > REFACTOR   (inside Apply)
LAYER 4 — Judgment:         skill + rubric as EXIT CRITERIA at decide and verify
```

**Hard integration rule:** the Clean Code Gate fires at **REFACTOR-exit, never at green**. Green buys
correctness (it may be ugly and temporary); refactor buys quality; the gate guards the refactor. This is
what lets TDD and the harness coexist instead of fighting.

## Phase 1 — PLAN (plan mode)

**Frame.** Understand the request, read the relevant repo context, and clarify ambiguity using the
Clarification Gate from the skill. Do not guess critical product behavior, stack, data model, or
acceptance criteria. State safe, reversible defaults as assumptions.

**Decide.** Surface ONE design decision with 2–3 options and their tradeoffs. Choose the smallest
maintainable shape and state why it is smaller/clearer than the alternatives. Define the slice boundary.

**Human gate.** Call `ExitPlanMode`. No code is written until the user approves.

**Output of this phase:**

- Slice boundary (behavior, inputs/outputs, touched areas).
- Design decision + rationale (why this shape, what was rejected and why).
- Assumptions or open clarification questions.
- Out-of-scope work.

## Phase 2 — APPLY LOOP (execute mode)

For each slice/task, run the TDD loop:

1. **RED** — write a failing test for the target behavior.
2. **GREEN** — write the minimal code to pass. Ugly is allowed here; it is temporary.
3. **REFACTOR** — apply `skills/clean-code-standards/SKILL.md`, then run the **Clean Code Gate**.

**HARD RULE:** the Clean Code Gate fires at refactor-exit, never at green. Green is never "done".

Per iteration, report: files touched and tests run. Loop until the slice is complete.

## Phase 3 — VERIFY

Score the touched code against `docs/clean-code-rubric.md` and report:

- `Clean Code Gate: passed | blocked`
- Score `<n>/18`
- Intent fit: `pass | partial | fail`
- Findings and required changes.

**Blocked** → loop back into APPLY for the smallest fix, then re-verify. **Passed** → done.

## Integration Rules

- **TDD:** refactor-exit is the gate; green is never "done".
- **Human-in-the-loop:** two gates — the plan gate (`ExitPlanMode`) and the verify gate (blocked stops
  and returns to the user).
- **Informed decisions:** captured in the Phase 1 output. No separate decision-record file yet — add one
  later only if the in-plan capture proves insufficient.

## Out of Scope (add later, step by step)

- Repo-local slash commands (`/speckit.*` or `/sdd-*` style).
- Decision records as standalone files (ADR-lite).
- Hooks in `.claude/settings.json` that mechanically block Edit/Write until a gate passes.
- Engram persistence or a full Spec-Kit port.
