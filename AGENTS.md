# Clean Code Lab — Local Agent Instructions

This lab is a pilot. Do not apply these standards globally yet.

## Activation

For any task that creates, modifies, refactors, or reviews code inside this lab, load and follow:

- `harness/HARNESS.md` — the 3-phase control workflow (Plan, Apply loop, Verify).
- `skills/clean-code-standards/SKILL.md` — the design judgment the harness gates against.

The user should not need to repeat the standard in every prompt. The lab context is the activation boundary.

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
