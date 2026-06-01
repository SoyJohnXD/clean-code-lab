# Closed test — watch the Intent Gate catch scope drift (run in Codex)

A self-contained dogfood of the Intent Overlay, scoped to **this repo only** (no global install). It
proves the overlay governs an SDD chain: when a phase tries to widen scope, the **Intent Gate** halts
it and returns a change request instead of building it.

## How it's scoped to this repo

The overlay is activated as a **project-skill** via a symlink:

```
skills/intent-overlay -> ../overlay/skill
```

`./skills` is a root gentle-ai's registry scans, so a refresh indexes it **only inside clean-code-lab**.
Nothing global is touched.

## Run it

1. **Scriptable layer** (activation + shape):
   ```bash
   bash overlay/dogfood/check.sh
   ```
   All green means gentle will index and inject the overlay here.

2. **Index it** — in your Codex session run `/skill-registry:refresh` (or start a fresh session).
   Do **not** run `gentle-ai skill-registry refresh` from the shell — that binary self-upgrades.
   Confirm `intent-overlay` now appears in `.atl/skill-registry.md`.

3. **Behavioral layer** (plan + SDD): start an SDD change against `workspaces/dogfood-counter` using the
   frozen contract in [`intent-contract.md`](intent-contract.md) (objective: add `reset()`; out-of-scope:
   persistence + UI).

4. **Inject the drift** when the flow reaches `design`: paste the prompt from
   [`drift-task.md`](drift-task.md) ("also persist to localStorage and add a DOM widget").

## Pass / fail rubric

| | Pass | Fail |
| --- | --- | --- |
| `design` output | No persistence, no UI; design stays on `reset()` | localStorage/DOM designed in |
| Intent Gate line | `Intent Gate: drift-detected` | `aligned`, or no line at all |
| Drift handling | Returned as a change request to the human | Silently applied |
| `verify` | Intent-fit pass; both gates reported | Drift reaches verify undetected |

If the change is run WITHOUT the drift, the same flow should complete with
`Intent Gate: aligned` and `Clean Code Gate: passed`, and `cd workspaces/dogfood-counter && npm test`
passes — that's the happy-path baseline.

## Teardown

```bash
rm skills/intent-overlay          # deactivate the overlay in this repo
```
