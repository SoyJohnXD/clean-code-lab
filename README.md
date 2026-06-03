# Clean Code Lab

Local home of the **clean-code governance** — make an agent build software the way we want it built:
informed decisions, human-in-the-loop, and simple, decoupled, semantic code (SOLID + DRY). Ceremony
matches the work via two paths, chosen by change size.

The lab is also where we validate both before promoting any of it to global agent configuration.

## The two paths

Pick by change size — never run both for the same change.

**Small changes** follow `harness/HARNESS.md` on native plan/execute mode, with two human gates:

1. **Plan** (plan mode) — frame the request, surface one design decision with tradeoffs, define the
   smallest slice. You approve before any code is written (`ExitPlanMode`).
2. **Apply** (execute mode) — implement with TDD: red → green → refactor. The Clean Code Gate fires at
   refactor-exit, never at green.
3. **Verify** — score against `skills/clean-code-standards/references/clean-code-rubric.md`. Blocked stops and returns to you; passed is
   done.

**Substantial changes** run SDD with the `overlay/` intent-overlay: the intent lives in SDD's approved
`proposal`/`spec`/`design` (no separate contract, no extra documents), and every phase emits its
`Intent Gate` line — code phases also emit `Clean Code Gate`. See `overlay/skill/references/PHASE-LENS.md`.

The clean-code judgment lives in `skills/clean-code-standards/SKILL.md` + `skills/clean-code-standards/references/clean-code-rubric.md` —
the single source of *what* good code is, shared by both paths.

## How to Use

Work inside this folder. `AGENTS.md` auto-loads `harness/HARNESS.md` + the skill for any code task — you
do not repeat the standard in every prompt.

1. Enter plan mode and ask for a feature, e.g. *"Create a small inventory API in
   `workspaces/inventory-api` that..."* (see `prompts/`).
2. The agent frames the work, surfaces a design decision with tradeoffs, and stops at the plan gate.
   Approve or redirect.
3. In execute mode it builds the slice with TDD and reports `Clean Code Gate: passed | blocked` with a
   rubric score.

If the request is too vague, the agent asks before coding instead of guessing.

## What This Lab Is For

- Running the harness on frontend, backend, and full-stack projects from zero.
- Comparing agents against the same harness and quality rubric.
- Refining the harness and the standard before making either global.

## What This Lab Is Not For

- Global configuration changes.
- Rewriting existing production projects.
- Enforcing style through tooling before the expected behavior is validated.
