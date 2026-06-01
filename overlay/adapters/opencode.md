# Adapter — OpenCode

How the overlay binds to OpenCode's real seams. The core is host-agnostic; only this file knows
OpenCode.

## Seams we depend on

| Seam | What it is | How the overlay uses it |
| --- | --- | --- |
| `~/.config/opencode/skills` | OpenCode skill root (loads `SKILL.md`) | **Discovery.** The canonical skill is symlinked here. |
| `~/.config/opencode/AGENTS.md` | Global instructions OpenCode reads | **Always-on.** The installer injects the `INVARIANTS.md` block as a marker-delimited section. |
| `~/.config/opencode/plugins/*.ts` `tool.execute.before` | Plugin hook that can throw to block a tool call | **Hard gate.** `opencode-intent-gate.ts` runs `check-intent-frozen.sh` before `edit`/`write`/`apply_patch` and throws on deny. |

## Activation notes

- **Known limitation (opencode#5894):** `tool.execute.before` does NOT intercept tool calls made by
  subagents spawned via the `task` tool. The hard gate is therefore **best-effort** in OpenCode: it
  catches the primary agent reliably, not delegated subagents. The always-on block plus the
  `permission` field in `opencode.json` are the backstop for subagents.
- Use `input.tool === "apply_patch"` (not `"patch"`) — OpenCode's edit tool surfaces under that name.

## What the installer writes

- Symlink: `~/.config/opencode/skills/intent-overlay` → canonical skill.
- Block in `~/.config/opencode/AGENTS.md` (marker-delimited, reversible).
- Plugin `~/.config/opencode/plugins/intent-overlay-gate.ts`, with `__GATE__` resolved to the
  installed `check-intent-frozen.sh`.
