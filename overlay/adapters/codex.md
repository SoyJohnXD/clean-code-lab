# Adapter — Codex CLI

How the overlay binds to Codex's real seams. The core (`skill/`, `instructions/INVARIANTS.md`) is
host-agnostic; only this file knows Codex. If a Codex release changes a seam, only this file changes.

## Seams we depend on

| Seam | What it is | How the overlay uses it |
| --- | --- | --- |
| `$HOME/.agents/skills` | Native Codex skill discovery root (Agent Skills, launched Dec 2025) | **Discovery.** Both skills (`intent-overlay` + `clean-code-standards`) are symlinked here so Codex lists them with progressive disclosure. |
| `~/.codex/AGENTS.override.md` | User override instructions Codex reads every startup | **Always-on.** The installer injects the `INVARIANTS.md` block here — never touching gentle-ai's generated `~/.codex/agents.md`. |

## Activation notes

- Discovery is model-driven: Codex loads `SKILL.md` only when it judges a task matches. The
  always-on block keeps the invariants present every session regardless.
- There is no hard gate. Code work is gated by SDD itself: `apply` depends on an approved proposal, so
  `config.toml` is never modified and no hook trust is required.
- Custom prompts (`~/.codex/prompts/*.md`) are deprecated by OpenAI in favor of skills; the overlay
  does not use them.
- **Non-SDD / inline work** uses Codex's plan/approval step as the human gate. There is no verify
  phase, so the Clean Code Gate + self-check against the rubric still run. Decisions and verification
  apply with or without SDD.
- **Automatic SDD:** the agent makes the decisions itself (recording them in the Decision Ledger); all
  rules, gates, and verification stay in force.

## What the installer writes

- Symlinks: `~/.agents/skills/intent-overlay` and `~/.agents/skills/clean-code-standards` → canonicals.
- Block in `~/.codex/AGENTS.override.md` (marker-delimited, reversible).
