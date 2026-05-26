---
name: clean-code-standards
description: "Trigger: clean code, implement, write code, refactor, code review, SOLID, DRY. Enforce the local clean-code delivery gate."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "0.1"
---

## Activation Contract

Use this skill only when the user explicitly asks for `clean-code-standards`, `clean code`, `normativa clean-code`, or equivalent.

Apply it to new code and touched code. Do not rewrite unrelated legacy code.

## Hard Rules

- Prefer simple, readable code over clever abstractions.
- Apply SOLID and DRY, but do not introduce abstractions before a real duplication or responsibility boundary exists.
- Make names semantic, specific, and easy to read aloud.
- Do not use magic strings or magic numbers. Promote them to named constants, enums, configuration, or value objects at the narrowest useful scope.
- Keep code self-explanatory. Do not add comments to compensate for unclear code.
- Allow JSDoc/doc comments only for public APIs, complex contracts, or functions with many parameters.
- Keep files focused. Split files that mix responsibilities or become hard to scan.
- Respect the existing architecture. If hexagonal/clean architecture exists, keep domain rules separate from IO, UI, framework, and persistence.
- For projects without architecture, still separate pure domain logic from adapters and delivery code in new work.

## Decision Gates

| Situation | Required action |
| --- | --- |
| Feature or bug fix | Define the smallest vertical slice before coding |
| New domain rule | Put it in a pure function/service, not inside UI/controller/framework glue |
| Repeated literal | Extract a named constant or enum |
| Repeated behavior | Extract only after the duplicated responsibility is clear |
| Large or mixed file | Split by responsibility before marking the task complete |
| Existing messy code | Improve only the touched seam; do not expand scope silently |

## Execution Steps

1. State the slice boundary: behavior, inputs/outputs, touched areas, and what is out of scope.
2. Implement the smallest working vertical slice.
3. Refactor before finishing: names, constants, responsibilities, file boundaries, and dependency direction.
4. Run the available tests/checks when practical.
5. Report `Clean Code Gate: passed` only when the hard rules are satisfied.
6. Report `Clean Code Gate: blocked` with concrete reasons when the result would violate the standard.

## Output Contract

Return:
- Slice boundary.
- Files created or modified.
- Tests/checks run.
- `Clean Code Gate: passed` or `Clean Code Gate: blocked`.
- Any intentional tradeoff or local legacy seam left untouched.

## References

- `references/code-quality-principles.md` — expanded principles and review checklist.
