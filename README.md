# Clean Code Lab

Local home of the **clean-code harness** — a 3-phase control workflow that makes an agent build
software the way we want it built: informed decisions, human-in-the-loop, and simple, decoupled,
semantic code (SOLID + DRY).

The lab is also where we validate the harness before promoting any of it to global agent configuration.

## The Harness

The lab is governed by `harness/HARNESS.md`, not by a passive skill. The harness runs on native
plan/execute mode and moves through three phases with two human gates:

1. **Plan** (plan mode) — frame the request, surface one design decision with tradeoffs, define the
   smallest slice. **Human gate:** you approve before any code is written (`ExitPlanMode`).
2. **Apply loop** (execute mode) — implement the slice with TDD: red → green → refactor. The Clean Code
   Gate fires at refactor-exit, never at green.
3. **Verify** — score the touched code against `docs/clean-code-rubric.md`. **Human gate:** blocked stops
   and returns to you; passed is done.

The clean-code judgment lives in `skills/clean-code-standards/SKILL.md` + `docs/clean-code-rubric.md` —
the harness's constitution. The harness decides *how* the agent works; the constitution decides *what*
good code is.

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
