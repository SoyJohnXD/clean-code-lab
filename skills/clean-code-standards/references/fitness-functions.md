# Fitness functions — mechanical checks for the System Gate

The five dimensions in `system-review.md` are reviewed by reading; fitness functions make some of them
mechanical. A failing command is reproducible evidence — a reviewer's "looks fine" is not.

## Rule

- **If the project already wires a check** (a `package.json` script, a `Makefile` target, a `pyproject`
  tool config, or a CI step) for duplication, dependency direction, or complexity — **run it** at the
  System Gate and report the result (tool + pass/fail/score) in the "Fitness functions run" line.
- **If no check exists and the change is substantial** — propose adding the proportional one(s) as a
  **foundation slice**. Never silently install tooling mid-apply; a new dependency, config file, or CI
  step is an architecture-shaping decision and goes through the human via the Decision Ledger.
- If neither applies (trivial change, or substantial change with tooling out of scope), report
  `none available` and continue with the read-based review.

## Catalog

| Concern | Python | TS/JS | Go |
| --- | --- | --- | --- |
| Duplication | `jscpd`; `pylint` `duplicate-code` (R0801) | `jscpd` | `dupl` |
| Dependency direction | `import-linter` | `dependency-cruiser` | `depguard` (via `golangci-lint`) |
| Complexity / size | `radon` / `xenon`; `ruff` `C901` / `PLR0915` | `eslint` `complexity`, `max-lines`, `max-lines-per-function` | `gocyclo`, `gocognit` |

## Closing the choice

Pick the **lightest tool that fits** the project's existing toolchain — one per concern, not a tooling
zoo. If the project already runs `eslint`, adding `complexity`/`max-lines` rules to its config is
smaller than introducing a new linter. The point of a fitness function is a failing command the next
agent or CI run can act on, not a new dependency to maintain for its own sake.
