# Clean Code Rubric

Use this rubric to evaluate work produced with `clean-code-standards`.

## Scoring

Each category is scored from 0 to 2.

- `0` — Fails the standard.
- `1` — Acceptable but needs improvement.
- `2` — Strong and consistent.

Minimum pass: **14/16** and no blocker.

## Categories

| Category | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Simplicity | Clever or overbuilt | Mostly simple with some noise | Direct, minimal, easy to follow |
| Naming | Ambiguous or generic | Understandable but inconsistent | Semantic, precise, domain-friendly |
| SOLID | Mixed responsibilities | Some separation | Clear responsibility and dependency direction |
| DRY | Copy-paste or premature abstraction | Minor duplication or abstraction noise | Duplication removed only where responsibility is shared |
| Magic values | Unexplained literals | Some literals remain | Meaningful constants/config/enums at correct scope |
| File organization | Large/mixed files | Mostly grouped | Focused files with obvious boundaries |
| Architecture fit | Fights project structure | Mostly follows existing shape | Respects architecture and keeps domain separate from adapters |
| Self-documenting code | Needs comments to understand | Mostly clear | Reads clearly without explanatory comments |

## Blockers

Any blocker fails the gate, regardless of score:

- Secret or credential hardcoded.
- Silent error handling.
- New `any`/untyped public API without justification.
- New code with unclear domain names.
- Business rule hidden in UI/controller/framework glue when a cleaner seam exists.
- Magic string/number that changes behavior and has no explicit name.
- File created with multiple unrelated responsibilities.
- Comments used to explain confusing code instead of improving the code.

## Review Output Template

```markdown
Clean Code Gate: passed|blocked
Score: <n>/16

Slice boundary:
- ...

Findings:
- ...

Required changes:
- ...

Tradeoffs:
- ...
```
