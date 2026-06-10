# Clean Code Lab — Local Agent Instructions

This lab is a pilot. Do not apply these standards globally yet.

## Activation

For any task that creates, modifies, refactors, or reviews code inside this lab, load and follow:

- `skills/clean-code-standards/SKILL.md` — the design judgment both paths gate against.
- For a **small change**: `harness/HARNESS.md` — native plan/execute mode + the Clean Code Gate.
- For a **substantial change**: `overlay/skill/SKILL.md` + `overlay/skill/references/PHASE-LENS.md` —
  SDD with the intent-overlay's gates folded into each phase.

Pick the path by change size; do not run both for the same change. The user should not need to repeat
the standard in every prompt — the lab context is the activation boundary.

## Workspace Rules

- Create all experimental projects under `workspaces/<project-name>/`.
- Keep generated projects self-contained.
- Do not modify global Codex, OpenCode, Claude, or Gentle AI configuration from this lab.
- Do not rewrite unrelated code to satisfy the standard; improve the code being created or touched.

## Clarification Rule

Before writing code, ask concise clarification questions when the request lacks enough information to implement safely. Do not guess critical product behavior, stack constraints, data models, acceptance criteria, or integration boundaries.

If the missing detail has a safe, reversible default, state the default as an assumption before coding.

## Local Quality Contract

Every code task in this lab must report:

- Slice boundary.
- Assumptions or clarification questions.
- Files created or modified.
- Tests/checks run.
- `Clean Code Gate: passed` or `Clean Code Gate: blocked`.
- Tradeoffs or legacy seams intentionally left untouched.

<!-- intent-overlay:start -->
## Intent Overlay (active)

Govern every substantial SDD change with one approved intent and one quality bar — no extra documents.
The intent lives in SDD's own `proposal`/`spec`/`design`; the human approving the proposal is the
freeze. Trivial or small changes skip SDD: apply clean-code judgment inline and stop.

Pass these overlay paths to EVERY SDD phase, applied through `overlay/skill/references/PHASE-LENS.md`:
- `overlay/skill/references/VISION.md`
- `overlay/skill/references/PHASE-LENS.md`

Every phase emits `Intent Gate: aligned | drift-detected`. Code phases also emit the Clean Code Gate
at refactor-exit. `drift-detected` halts the chain and returns to the human as a change request
(a proposal amendment); it is never applied silently.
<!-- intent-overlay:end -->
