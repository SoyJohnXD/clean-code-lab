---
name: clean-code-standards
description: "Use when implementing, writing, refactoring, or reviewing code in this lab. Enforces clean-code standards and clarification before coding."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "0.4"
---

## Activation Contract

Use this skill for code creation, refactoring, or review inside the clean-code lab. Apply it to new code and touched code only.

## Design Judgment Contract

Code is cheap; durable software is not. Before coding, supply judgment: what to build, why this shape, and what not to build.

Working code is insufficient when it raises maintenance cost. Prefer the smallest structure that makes change easier.

## Hard Rules

- Keep code simple, readable, semantic, and easy to scan.
- Apply SOLID and DRY without premature abstraction.
- Use clear domain names; avoid vague names like `data`, `item`, `handler`, or `utils` unless the domain truly says that.
- Replace behavior-changing magic strings/numbers with named constants, enums, config, or value objects at the narrowest useful scope.
- Avoid explanatory comments. Use JSDoc/doc comments only for public APIs, complex contracts, or functions with many parameters.
- Keep files focused by responsibility. Split mixed or hard-to-scan files before completion.
- Respect existing architecture. Keep domain rules separate from IO, UI, framework, persistence, and transport code.
- Refactor intent first: understand why the existing code is shaped that way before changing it.
- Do not introduce schema, persistence, telemetry, migration, proxy, lazy-loader, factory, interface, compatibility behavior, or library wrapper unless requested or proven.
- Do not mirror a library API with your own function parameters. Call the library directly unless the wrapper adds a current domain rule.
- Do not create broad configuration objects just to pass values around. Prefer explicit values at the entrypoint unless shared behavior needs an object.
- A refactor must reduce or preserve reading complexity. Passing tests does not compensate for harder-to-read code.

## Clarification Gate

Before writing code, inspect the request and repo context. Ask concise questions if the objective, stack, scope, acceptance criteria, data model, design intent, or constraints are too ambiguous.

If safe defaults exist, state them as assumptions before coding. Do not fill missing design intent with extra architecture.

## Decision Gates

| Situation | Required action |
| --- | --- |
| Feature or fix | Define the smallest vertical slice before coding |
| Refactor | State existing intent, the needed change, why the structure is minimal, and behavior that must stay untouched |
| New abstraction | Use only if it removes current complexity; otherwise keep direct code |
| Library wrapper | Block by default; allow only when it adds a current domain rule |
| Configuration object | Keep narrow; split or remove if it only groups unrelated env values |
| Compatibility seam | Require a real caller or maintainer-approved contract |
| Schema, migration, telemetry, or persistence change | Stop unless explicitly requested or required for the slice |
| Domain rule | Put it in pure domain code, not framework/UI glue |
| Repeated literal | Extract a named constant, enum, or config |
| Repeated behavior | Extract only after the shared responsibility is clear |
| Messy legacy seam | Improve touched code only; do not expand scope silently |

## Execution Steps

1. State the slice boundary: behavior, inputs/outputs, design intent, touched areas, assumptions, and out-of-scope work.
2. For refactors, list what was already clear and should not be rewritten.
3. Explain why the proposed structure is the smallest maintainable one.
4. Implement the smallest useful vertical slice.
5. Refactor before finishing: naming, constants, responsibilities, file boundaries, and dependency direction.
6. Run the available tests/checks when practical.
7. Report `Clean Code Gate: passed` only when the rules are satisfied; otherwise report `Clean Code Gate: blocked` with concrete fixes.

## Output Contract

Return:
- Slice boundary.
- Assumptions or clarification questions.
- Minimal-structure rationale.
- Files created or modified.
- Tests/checks run.
- `Clean Code Gate: passed` or `Clean Code Gate: blocked`.
- Intentional tradeoffs or untouched legacy seams.
- New abstractions introduced, or `None`.

## References

- `references/code-quality-principles.md` — expanded principles and review checklist.
- `references/refactor-overengineering-case-study.md` — anti-pattern checklist from an overbuilt refactor.
- `../../docs/clean-code-rubric.md` — scoring rubric for review tasks.
