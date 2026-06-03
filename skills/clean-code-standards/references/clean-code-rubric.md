# Clean Code Rubric

Use this rubric to evaluate work produced with `clean-code-standards`.

## Scoring

Each category is scored from 0 to 2.

- `0` — Fails the standard.
- `1` — Acceptable but needs improvement.
- `2` — Strong and consistent.

Minimum pass: **16/18** and no blocker.

## Categories

| Category | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Simplicity | Clever, overbuilt, or deeply nested (pyramid) | Mostly simple, some nesting/noise | Direct, flat control flow (guard clauses), minimal, easy to follow |
| Naming | Ambiguous or generic | Understandable but inconsistent | Semantic, precise, domain-friendly |
| SOLID | Mixed responsibilities | Some separation | Clear responsibility and dependency direction |
| DRY | Copy-paste, or premature/speculative abstraction (registry/dispatch/params without a caller) | Minor duplication or abstraction noise | Duplication removed only where responsibility is genuinely shared (one reason to change) |
| Magic values | Unexplained or duplicated literals | Some literals remain | Meaningful constants/config/enums, single source, at the narrowest scope covering their uses |
| File organization | Large/mixed files, or grouped by technical type so the flow scatters | Mostly grouped, some reading jumps | Focused files that read top-down by flow (high-level first, step-down), one level of abstraction per function |
| Architecture fit | Fights project structure, mixes domain rules with IO, or models data so illegal states are representable | Mostly follows existing shape | Respects architecture, keeps domain rules pure (testable without IO mocks) and separate from adapters, and models variant states so illegal ones are unrepresentable |
| Self-documenting code | Comments narrate the what or patch bad names/magic; positional/mystery call sites | Mostly clear | Reads clearly without explanatory comments (only a non-obvious why is documented); call sites name their arguments |
| Intent fit | Ignores maintainer intent or adds design without need | Intent is partially preserved | Minimal change aligned with existing code and stated goal |

## Blockers

Any blocker fails the gate, regardless of score:

- Secret or credential hardcoded.
- Silent error handling, a generic/untyped error that loses the cause, or an ambiguous sentinel (`null`/`-1`) that collides with valid values.
- Generated code that works but increases maintenance burden without a current design need.
- New `Any`, tuple-return API, proxy, lazy-loader, factory, or interface without a current caller and clear justification.
- Wrapper over a library API that only mirrors existing parameters instead of adding a current domain rule.
- Broad configuration value object used only to pass unrelated environment values through the code.
- New code with unclear domain names.
- Refactor introduces schema, migration, telemetry, persistence, or product behavior not requested by the slice.
- Compatibility wrapper exists without a maintainer-approved compatibility contract.
- Parallel string lists duplicate names already available from code objects.
- Business rule hidden in UI/controller/framework glue when a cleaner seam exists.
- Magic string/number that changes behavior and has no explicit name.
- File created with multiple unrelated responsibilities.
- Comments used to explain confusing code instead of improving the code.

## Review Output Template

```markdown
Clean Code Gate: passed|blocked
Score: <n>/18
Intent fit: <pass|partial|fail>

Slice boundary:
- ...

Findings:
- ...

Required changes:
- ...

Tradeoffs:
- ...

New abstractions:
- ...
```
