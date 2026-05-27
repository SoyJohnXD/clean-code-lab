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
| Simplicity | Clever, overbuilt, or maintenance-heavy | Mostly simple with some noise | Direct, minimal, easy to follow |
| Naming | Ambiguous or generic | Understandable but inconsistent | Semantic, precise, domain-friendly |
| SOLID | Mixed responsibilities | Some separation | Clear responsibility and dependency direction |
| DRY | Copy-paste or premature abstraction | Minor duplication or abstraction noise | Duplication removed only where responsibility is shared |
| Magic values | Unexplained literals | Some literals remain | Meaningful constants/config/enums at correct scope |
| File organization | Large/mixed files | Mostly grouped | Focused files with obvious boundaries |
| Architecture fit | Fights project structure | Mostly follows existing shape | Respects architecture and keeps domain separate from adapters |
| Self-documenting code | Needs comments to understand | Mostly clear | Reads clearly without explanatory comments |
| Intent fit | Ignores maintainer intent or adds design without need | Intent is partially preserved | Minimal change aligned with existing code and stated goal |

## Blockers

Any blocker fails the gate, regardless of score:

- Secret or credential hardcoded.
- Silent error handling.
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
