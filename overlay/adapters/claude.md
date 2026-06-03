# Adapter — Claude Code

How the overlay binds to Claude Code's real seams. The core is host-agnostic; only this file knows
Claude Code.

## Seams we depend on

| Seam | What it is | How the overlay uses it |
| --- | --- | --- |
| `~/.claude/skills` | Claude Code skill root; entries appear in the session's `<available_skills>` | **Discovery.** Both skills (`intent-overlay` + `clean-code-standards`) are symlinked here so they appear in `<available_skills>`. |
| `~/.claude/CLAUDE.md` | The user's global instructions, read every session | **Always-on.** The installer injects the `INVARIANTS.md` block as a marker-delimited section (the user's own file — gentle-ai owns only its `<!-- gentle-ai:* -->` sections, which we never touch). |

## Activation notes

- Discovery is model-driven (same progressive-disclosure model as Codex). The always-on block keeps
  the invariants present every session regardless.
- There is no hard PreToolUse gate. Code work is gated by SDD itself: `apply` depends on an approved
  proposal, so `settings.json` is never modified.
- **Non-SDD / inline work** uses Claude's **plan mode (`ExitPlanMode`)** as the human gate. There is no
  verify phase, so the Clean Code Gate + self-check against the rubric still run. Decisions and
  verification apply with or without SDD.
- **Automatic SDD:** the agent makes the decisions itself (recording them in the Decision Ledger); all
  rules, gates, and verification stay in force.

## What the installer writes

- Symlinks: `~/.claude/skills/intent-overlay` and `~/.claude/skills/clean-code-standards` → canonicals.
- Block in `~/.claude/CLAUDE.md` (marker-delimited, reversible).
