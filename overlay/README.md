# Governance Overlay

A governance layer that sits **on top of** gentle-ai and makes every SDD subagent obey one frozen
intent and one quality bar — installed **once, globally**, with zero per-project setup. It solves two
pains:

- **Scope drift** — the goal agreed in plan mode gets re-decided or widened as SDD runs.
- **Quality drift** — generated code adds unnecessary over-engineering, vague names, or speculative
  abstractions.

## How it works — a global user-skill

gentle-ai's skill registry **scans user skill roots, never owns them, and never prunes them** (verified
in `gentle-pi/extensions/skill-registry.ts`). On every session start it refreshes the registry and
injects each skill's `## Compact Rules` into every subagent under `## Project Standards (auto-resolved)`.

So the overlay ships as **one user-skill** ([`skill/`](skill)):

- `skill/SKILL.md` — frontmatter + `## Compact Rules` (the enforceable essence of both pillars).
- `skill/references/` — `INTENT-CONTRACT.md`, `PHASE-LENS.md`, `VISION.md` (the full contract).

Install it once and gentle injects it everywhere. **No `CLAUDE.md` edits, no registry edits, no
per-project files.** A `gentle-ai upgrade` only touches gentle's own npm packages, so it cannot break
the overlay.

### Two pillars, two gates

| Pillar | Gate | Fires |
| --- | --- | --- |
| Intent (fidelity) | **Intent Gate** | every phase boundary — `aligned \| drift-detected` |
| Judgment (quality) | **Clean Code Gate** | refactor-exit — `passed \| blocked` |

The intent is frozen by a human **before any code is written**. Scope changes or changes to a frozen
decision halt the chain and return to the human as a change request — never applied silently.

## CLI

```bash
overlay/intent-overlay install         # discovery + always-on block + hard gate, into every present host
overlay/intent-overlay doctor          # verify canonical skill, symlinks, and each host's hook + block
overlay/intent-overlay uninstall       # reverse everything (reversible)
overlay/intent-overlay freeze <change> # write .atl/intent/<change>.frozen so the hard gate allows edits
overlay/intent-overlay unfreeze <change>
```

After `install`, run `gentle-ai skill-registry refresh --force` in a project (it is a shell command,
**not** a Codex slash command) or start a new session so gentle indexes it. In Codex, approve the hook
once via `/hooks`.

The canonical lives in your skill hub (`~/.codex/skills/intent-overlay/`) and is symlinked into the
other scanned roots that already exist (`~/.claude/skills`, `~/.agents/skills`, …) — mirroring how your
existing skills are laid out.

## Verify it works

1. `overlay/intent-overlay install` then `overlay/intent-overlay doctor` → all checks green.
2. `gentle-ai skill-registry refresh --force` in any project, then confirm `intent-overlay` appears
   in `.atl/skill-registry.md` with its compact rules — proof gentle will inject it.
3. **Dogfood (acceptance):** start a small SDD change, freeze an Intent Contract whose **Out-of-scope**
   excludes persistence, then during `design` deliberately steer toward adding persistence. Expected:
   the Intent Gate reports `drift-detected`, the chain halts, and it comes back as a change request —
   not silently designed in.

Run the test suites:

```bash
bash overlay/intent-overlay.test.sh    # the global CLI (uses a throwaway HOME)
bash overlay/install.test.sh           # the AGENTS.md fallback installer
```

## Coexistence invariant

The overlay only ever creates a **user-skill that the registry reads**. It never writes gentle-owned
files: not the `<!-- gentle-ai:* -->` sections of `CLAUDE.md`, not `.atl/skill-registry.md`, not the
package skills. That is what lets gentle-ai and the overlay live together across upgrades.

## Fallback: per-project (non-gentle hosts)

For a host without the registry mechanism, `install.sh` wires the overlay into a project's `AGENTS.md`
via an idempotent, reversible marker block. See [`adapters/gentle-ai.md`](adapters/gentle-ai.md). This
is a fallback; the global CLI above is the primary path.
