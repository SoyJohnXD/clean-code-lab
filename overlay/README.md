# Governance Overlay

A governance layer that sits **on top of** gentle-ai and makes every SDD subagent obey one frozen
intent and one quality bar — installed **once, globally**, with zero per-project setup. It solves two
pains:

- **Scope drift** — the goal agreed in plan mode gets re-decided or widened as SDD runs.
- **Quality drift** — generated code adds unnecessary over-engineering, vague names, or speculative
  abstractions.

## How it works — two global user-skills

gentle-ai's skill registry **scans user skill roots, never owns them, and never prunes them** (verified
in `gentle-pi/extensions/skill-registry.ts`). On every session start it refreshes the registry and
injects each skill's `## Compact Rules` into every subagent under `## Project Standards (auto-resolved)`.

So install ships **two user-skills**, single source each:

- `intent-overlay` ([`skill/`](skill)) — governance only. `SKILL.md` (`## Compact Rules` for intent +
  the gates) + `references/` (`PHASE-LENS.md`, `VISION.md`). It does NOT define quality; it points to:
- `clean-code-standards` ([`../skills/clean-code-standards`](../skills/clean-code-standards)) — the
  single quality source: `## Compact Rules` (the distilled norms) + `references/clean-code-rubric.md`
  (the `/18`). The overlay's Clean Code Gate scores against this skill.

Install copies both into the hub and symlinks them into every present skill root, so gentle injects
both. Beyond the skills, install adds one reversible, marker-delimited **always-on block** to each
host's own instruction file (e.g. `~/.claude/CLAUDE.md`) — it never edits gentle-ai-owned sections, the
registry, or per-project files. A `gentle-ai upgrade` only touches gentle's own npm packages, so it
cannot break the overlay.

### Two pillars, two gates

| Pillar | Gate | Fires |
| --- | --- | --- |
| Intent (fidelity) | **Intent Gate** | every phase boundary — `aligned \| drift-detected` |
| Judgment (quality) | **Clean Code Gate** | refactor-exit — `passed \| blocked` |

The intent lives in SDD's own `proposal`/`spec`/`design` — no separate document. The human approving
the proposal is the freeze; code work (`apply`) starts only after that. Scope changes or changes to an
approved decision halt the chain and return to the human as a change request — never applied silently.
Trivial or small changes skip SDD entirely and use clean-code judgment inline.

## CLI

```bash
overlay/intent-overlay install    # discovery skill + always-on block, into every present host
overlay/intent-overlay doctor     # verify the canonical skill, symlinks, and each host's block
overlay/intent-overlay uninstall  # reverse everything (reversible)
```

After `install`, run `gentle-ai skill-registry refresh --force` in a project (it is a shell command,
**not** a Codex slash command) or start a new session so gentle indexes it.

The canonical lives in your skill hub (`~/.codex/skills/intent-overlay/`) and is symlinked into the
other scanned roots that already exist (`~/.claude/skills`, `~/.agents/skills`, …) — mirroring how your
existing skills are laid out.

## Verify it works

1. `overlay/intent-overlay install` then `overlay/intent-overlay doctor` → all checks green.
2. `gentle-ai skill-registry refresh --force` in any project, then confirm `intent-overlay` appears
   in `.atl/skill-registry.md` with its compact rules — proof gentle will inject it.
3. **Dogfood (acceptance):** start a small SDD change, approve a proposal whose **Out-of-scope**
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
