# Adapter — Codex CLI

How the overlay binds to Codex's real seams. The core (`skill/`, `instructions/INVARIANTS.md`,
`hooks/check-intent-frozen.sh`) is host-agnostic; only this file knows Codex. If a Codex release
changes a seam, only this file changes.

## Seams we depend on

| Seam | What it is | How the overlay uses it |
| --- | --- | --- |
| `$HOME/.agents/skills` | Native Codex skill discovery root (Agent Skills, launched Dec 2025) | **Discovery.** The canonical skill is symlinked here so Codex lists `intent-overlay` with progressive disclosure. |
| `~/.codex/AGENTS.override.md` | User override instructions Codex reads every startup | **Always-on.** The installer injects the `INVARIANTS.md` block here — never touching gentle-ai's generated `~/.codex/agents.md`. |
| `~/.codex/config.toml` `[[hooks.PreToolUse]]` | Lifecycle hook that can deny a tool call | **Hard gate.** The `codex.hooks.toml` block runs `check-intent-frozen.sh --json` before edit tools and blocks on `permissionDecision: deny`. |

## Activation notes

- Discovery is model-driven: Codex loads `SKILL.md` only when it judges a task matches. The
  always-on block and the hard gate are what make the invariants hold regardless.
- **Hook trust:** the first time the hook would run, Codex requires approval. Run `/hooks`, review,
  and trust it. Editing `check-intent-frozen.sh` changes its hash and forces re-approval.
- Custom prompts (`~/.codex/prompts/*.md`) are deprecated by OpenAI in favor of skills; the overlay
  does not use them.

## What the installer writes

- Symlink: `~/.agents/skills/intent-overlay` → canonical skill.
- Block in `~/.codex/AGENTS.override.md` (marker-delimited, reversible).
- Block in `~/.codex/config.toml` (marker-delimited, reversible), with `__GATE__` resolved to the
  installed `check-intent-frozen.sh`.
