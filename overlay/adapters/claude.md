# Adapter — Claude Code

How the overlay binds to Claude Code's real seams. The core is host-agnostic; only this file knows
Claude Code.

## Seams we depend on

| Seam | What it is | How the overlay uses it |
| --- | --- | --- |
| `~/.claude/skills` | Claude Code skill root; entries appear in the session's `<available_skills>` | **Discovery.** The canonical skill is symlinked here so `intent-overlay` is offered to the model. |
| `~/.claude/CLAUDE.md` | The user's global instructions, read every session | **Always-on.** The installer injects the `INVARIANTS.md` block as a marker-delimited section (the user's own file — gentle-ai owns only its `<!-- gentle-ai:* -->` sections, which we never touch). |
| `~/.claude/settings.json` `hooks.PreToolUse` | Hook that returns `permissionDecision` before a tool runs | **Hard gate.** Deep-merged entry runs `check-intent-frozen.sh --json` before `Edit\|Write\|MultiEdit` and blocks on deny. |

## Activation notes

- Discovery is model-driven (same progressive-disclosure model as Codex). The always-on block and
  the hard gate enforce the invariants regardless.
- `settings.json` is merged, not overwritten: existing keys and other `PreToolUse` matchers are
  preserved; only the overlay's matcher entry is added or removed.

## What the installer writes

- Symlink: `~/.claude/skills/intent-overlay` → canonical skill.
- Block in `~/.claude/CLAUDE.md` (marker-delimited, reversible).
- A `hooks.PreToolUse` entry in `~/.claude/settings.json`, with `__GATE__` resolved to the
  installed `check-intent-frozen.sh`.
