# Lightweight path — small changes in native plan/execute mode

Two paths, chosen by change size. This document is the **small-change path**. Substantial changes go
through **SDD + the intent-overlay** (`overlay/`), which carries the same judgment as lenses and gates
inside SDD's own phases. Never run this path *and* SDD for the same change.

| Change size | Path | Documents |
| --- | --- | --- |
| Trivial / small | This doc: native plan mode + clean-code judgment | none |
| Substantial | SDD + `overlay/` (Intent Gate + Clean Code Gate per phase) | SDD's normal artifacts only |

## Why a separate lightweight path

SDD's proposal → spec → design → tasks chain is the right rigor for substantial work and far too much
for a one-function change. Forcing every change through it is what produced document bloat. So a small
change stays in native plan/execute mode and never generates planning artifacts.

## Substrate

Native plan/execute mode. Plan mode is already a human-in-the-loop gate (`ExitPlanMode` = approval).
The judgment and the quality bar are referenced, not duplicated:

- `skills/clean-code-standards/SKILL.md` — the design judgment and hard rules.
- `skills/clean-code-standards/references/clean-code-rubric.md` — the scoring criteria for the verify gate.

## The loop

1. **Frame (plan mode).** Understand the request, read the relevant repo context, and clarify ambiguity
   — do not guess critical product behavior, stack, data model, or acceptance criteria. State safe,
   reversible defaults as assumptions. If the change turns out to be substantial, STOP and switch to
   SDD instead of continuing here.
2. **Decide (plan mode).** Surface one design decision with 2–3 options and tradeoffs; choose the
   smallest maintainable shape and state the slice boundary. Call `ExitPlanMode` — no code until the
   user approves.
3. **Apply (execute mode).** Per slice, run TDD: **RED** (failing test) → **GREEN** (minimal code, ugly
   allowed) → **REFACTOR** (apply the clean-code skill, then run the Clean Code Gate). The Clean Code
   Gate fires at **refactor-exit, never at green**. Per iteration, report files touched and tests run.
4. **Verify.** Score the touched code against `skills/clean-code-standards/references/clean-code-rubric.md` and report
   `Clean Code Gate: passed | blocked` with a score `/18`. Blocked → smallest fix → re-verify.

## Relationship to the overlay

The overlay does NOT define a second phase model. For substantial changes it rides inside SDD's phases
(see `overlay/skill/references/PHASE-LENS.md`): the intent lives in the approved `proposal`/`spec`/
`design`, and each phase emits its `Intent Gate` / `Clean Code Gate` line. This lightweight path and
SDD are alternatives chosen by size — never both for one change.
