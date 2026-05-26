---
name: clean-code-standards
description: "Use when implementing, writing, refactoring, or reviewing code in this lab. Enforces clean-code standards and clarification before coding."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "0.2"
---

## Activation Contract

Use this skill for code creation, modification, refactoring, or review inside the clean-code lab. Apply it to new code and touched code only.

## Hard Rules

- Keep code simple, readable, semantic, and easy to scan.
- Apply SOLID and DRY without premature abstraction.
- Use clear domain names; avoid vague names like `data`, `item`, `handler`, or `utils` unless the domain truly says that.
- Replace behavior-changing magic strings/numbers with named constants, enums, config, or value objects at the narrowest useful scope.
- Avoid explanatory comments. Use JSDoc/doc comments only for public APIs, complex contracts, or functions with many parameters.
- Keep files focused by responsibility. Split mixed or hard-to-scan files before completion.
- Respect existing architecture. Keep domain rules separate from IO, UI, framework, persistence, and transport code.

## Clarification Gate

Before writing code, inspect the request and repo context. Stop and ask concise questions if the objective, stack, scope, acceptance criteria, data model, or constraints are too ambiguous to implement safely.

If safe defaults exist, state them as assumptions before coding.

## Decision Gates

| Situation | Required action |
| --- | --- |
| Feature or fix | Define the smallest vertical slice before coding |
| Domain rule | Put it in pure domain code, not framework/UI glue |
| Repeated literal | Extract a named constant, enum, or config |
| Repeated behavior | Extract only after the shared responsibility is clear |
| Messy legacy seam | Improve touched code only; do not expand scope silently |

## Execution Steps

1. State the slice boundary: behavior, inputs/outputs, touched areas, assumptions, and out-of-scope work.
2. Implement the smallest useful vertical slice.
3. Refactor before finishing: naming, constants, responsibilities, file boundaries, and dependency direction.
4. Run the available tests/checks when practical.
5. Report `Clean Code Gate: passed` only when the rules are satisfied; otherwise report `Clean Code Gate: blocked` with concrete fixes.

## Output Contract

Return:
- Slice boundary.
- Assumptions or clarification questions.
- Files created or modified.
- Tests/checks run.
- `Clean Code Gate: passed` or `Clean Code Gate: blocked`.
- Intentional tradeoffs or untouched legacy seams.

## References

- `references/code-quality-principles.md` — expanded principles and review checklist.
- `../../docs/clean-code-rubric.md` — scoring rubric for review tasks.
