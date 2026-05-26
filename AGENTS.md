# Clean Code Lab — Local Agent Instructions

This lab is a pilot. Do not apply these standards globally yet.

## Activation

Use `skills/clean-code-standards/SKILL.md` only when the user explicitly asks for:

- `clean-code-standards`
- `clean code`
- `normativa clean-code`
- `aplica la normativa`

If the user does not activate the standard, work normally and do not claim that the Clean Code Gate passed.

## Workspace Rules

- Create all experimental projects under `workspaces/<project-name>/`.
- Keep generated projects self-contained.
- Do not modify global Codex, OpenCode, Claude, or Gentle AI configuration from this lab.
- Do not rewrite unrelated code to satisfy the standard; improve the code being created or touched.

## Local Quality Contract

When the standard is active, every implementation must report:

- Slice boundary.
- Files created or modified.
- Tests/checks run.
- `Clean Code Gate: passed` or `Clean Code Gate: blocked`.
- Tradeoffs or legacy seams intentionally left untouched.
