# Adapter — OpenCode

How the overlay binds to OpenCode's real seams. The core is host-agnostic; only this file knows
OpenCode.

## Seams we depend on

| Seam | What it is | How the overlay uses it |
| --- | --- | --- |
| `~/.config/opencode/skills` | OpenCode skill root (loads `SKILL.md`) | **Discovery.** Both skills (`intent-overlay` + `clean-code-standards`) are symlinked here. |
| `~/.config/opencode/AGENTS.md` | Global instructions OpenCode reads | **Always-on.** The installer injects the `INVARIANTS.md` block as a marker-delimited section. |

## Activation notes

- Discovery is model-driven. The always-on block keeps the invariants present every session
  regardless.
- There is no hard gate plugin. Code work is gated by SDD itself: `apply` depends on an approved
  proposal, so no `tool.execute.before` plugin is installed.
- **Non-SDD / inline work** uses OpenCode's plan/approval step as the human gate. There is no verify
  phase, so the Clean Code Gate + self-check against the rubric still run. Decisions and verification
  apply with or without SDD.
- **Automatic SDD:** the agent makes the decisions itself (recording them in the Decision Ledger); all
  rules, gates, and verification stay in force. (Note: subagents spawned via the `task` tool receive
  the rules through the injected skill + always-on block, not a hook.)

## What the installer writes

- Symlinks: `~/.config/opencode/skills/intent-overlay` and `~/.config/opencode/skills/clean-code-standards` → canonicals.
- Block in `~/.config/opencode/AGENTS.md` (marker-delimited, reversible).
