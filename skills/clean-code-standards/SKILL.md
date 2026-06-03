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

## Compact Rules

The enforceable essence, injected into every phase. Full detail in `## Hard Rules`, `## Conventions`,
and the `/18` rubric (`references/clean-code-rubric.md`).

- Organize files by reading flow (step-down): high-level function first, steps below in call order, one abstraction level per function.
- Names carry domain intent and read without opening the body; no vague generics or type/noise words.
- Flatten control flow with guard clauses; never nest decisions into a pyramid.
- Name every behavior-changing literal — single source, narrowest scope; no duplicated or magic values.
- No long positional parameter lists; use a parameter object, and turn data clumps into named (typed) value objects.
- Make illegal states unrepresentable: model variants as discriminated unions, not flags/optional fields.
- Prefer a little duplication over the wrong abstraction; extract only the proven, stable shared seam (no speculative factory/registry/params without a caller).
- Never swallow errors or raise generic ones: visible, with cause, observable — Result in the domain, typed errors + a global observable boundary at the edges.
- Keep business rules pure (data → decision, no IO); push IO to the edges; the dependency points inward.
- Self-documenting code; no what-comments; JSDoc only for the non-obvious why or complex contracts (no type echo).
- Score touched code against the `/18` rubric at the Clean Code Gate (refactor-exit); min pass 16, no blocker.

## Hard Rules

- Keep code simple, readable, semantic, and easy to scan.
- Apply SOLID and DRY without premature abstraction.
- Use clear domain names that carry intent: a reader should know what a name does without reading its body. Avoid vague names (`data`, `item`, `handler`, `utils`) and noise words that only repeat the type or context (`emailStringValue`, `userDataObject`).
- Replace behavior-changing magic strings/numbers with named constants, enums, config, or value objects at the narrowest scope that covers all their uses, with a single source of truth — never write the same behavior-changing literal twice.
- Make code self-documenting; don't narrate the WHAT in comments or use comments to patch bad names or magic numbers (fix those with names and constants). Reserve documentation for what code can't express — a non-obvious WHY, an external/legal constraint, a contract — as JSDoc on top of functions that are complex OR carry a non-obvious contract. In a typed codebase, don't restate the types in `@param`/`@returns`; add meaning (units, ranges, constraints) or omit them.
- Keep files focused by responsibility. Split mixed or hard-to-scan files before completion.
- Organize each file by reading flow, not by technical type: put the highest-level function first as a table of contents of well-named steps, then define each step below in call order (step-down). Keep every function at a single level of abstraction. Grouping by technical kind (all validators, then all IO) separates responsibilities but breaks reading order and hides what the file does — separation is not the same as organization.
- Flatten control flow with guard clauses: check each condition where it arises and return (or throw/continue) early. Do not nest decisions into a pyramid — nesting pushes each outcome away from the condition that causes it and stacks branches the reader must hold at once.
- Don't pass long positional parameter lists, especially multiple same-type or boolean params — they invite silent swaps. Use a parameter object (named fields), and group fields that always travel together (data clumps) into a named, reusable type/value object, placing related behavior with the data.
- Make illegal states unrepresentable: model mutually-exclusive variants as a discriminated (tagged) union, not boolean flags or optional fields. The compiler then rejects impossible combinations, and narrowing on the tag ties each payload to its state — no `!` or defensive guards.
- Prefer a little duplication over the wrong abstraction. Extract only the proven, stable shared responsibility (one reason to change); don't unify code that merely looks similar but changes for different reasons, and don't build a generic engine (registry/dispatch/params) for cases that don't exist yet — a speculative abstraction is worse than the duplication it removes.
- Never swallow errors and never raise generic ones. Failures must stay visible and carry their cause: raise/return specific, typed errors (or a Result) with a code/reason, never an ambiguous sentinel (`null`/`-1`) that collides with valid values, and route them through a dedicated observability helper — don't lose the failure or why it happened.
- Keep business rules pure: a domain decision takes data and returns a decision (or Result), with no IO and importing no db/HTTP/UI. Orchestrate IO at the edges (use case/adapters); the dependency points inward. A rule you can't test without mocking the db is still coupled — a function that "separates" the rule but reads the db inside is separation in name only.
- Respect existing architecture. Keep domain rules separate from IO, UI, framework, persistence, and transport code.
- Refactor intent first: understand why the existing code is shaped that way before changing it.
- Do not introduce schema, persistence, telemetry, migration, proxy, lazy-loader, factory, interface, compatibility behavior, or library wrapper unless requested or proven.
- Do not mirror a library API with your own function parameters. Call the library directly unless the wrapper adds a current domain rule.
- Do not create broad configuration objects just to pass values around. Prefer explicit values at the entrypoint unless shared behavior needs an object.
- A refactor must reduce or preserve reading complexity. Passing tests does not compensate for harder-to-read code.

## Conventions

Preferences chosen among equally-valid options — not universal laws. Apply them for consistency;
deviate with a reason.

- **Naming form follows what a function delivers** (pick the most telling name per case, not one fixed style):
  - Predicate (returns a boolean) → `isX` / `hasX` — e.g. `isEmail`, `isStrongPassword`.
  - Pure producer (returns a value, no side effect) → name by the result — e.g. `rejectionFor`, `successResponse`.
  - Command (has a side effect: writes, sends, deletes) → action verb — e.g. `persistUser`, `sendWelcome`. A side-effecting function keeps a verb even when it returns a value, so the name never hides the effect.
- **Direct branching by default; data-driven (policy/lookup table) only when the rules are many, dynamic, or configurable.** A table of rules adds indirection that earns its keep only past a handful of fixed cases — below that, guard clauses read better.
- **Keep a constant near its use; move it to a separate file only when it is a cohesive domain concept that is shared across modules or is configuration** — name that file by the domain (`pricing-policy`), never a generic `constants` grab-bag. A generic constants file groups by technical type and breaks locality (the file-level version of organizing a file by technical kind).
- **Parameter object by default; value object when the clump is reused, has invariants, or attracts behavior.** In a typed codebase (TS-first here), model data clumps as named, reusable types so a swapped argument is a compile error and the type documents the clump everywhere.
- **`type` vs `interface`:** interchangeable for plain object shapes — pick one and stay consistent. Use `type` for unions, intersections, tuples, and mapped/conditional types; a discriminated union requires `type`.
- **Rule of three:** let duplication appear and prove it shares one reason to change before extracting. Then extract the stable common seam and keep the varying parts direct — don't reach for the abstraction on the second occurrence.
- **Error handling by layer:** in pure domain/core, return a `Result` for expected failures the immediate caller must handle. At the application boundary, throw specific typed domain errors from the consumers and catch them in ONE global handler that logs through an observability helper and maps them (known domain error → 4xx, unexpected → 5xx). Never a generic catch-all.
- **Comments:** none inline. JSDoc only on functions that are complex or carry a non-obvious contract — summary + the non-obvious why + params/returns that add meaning beyond the types (no type echo).

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
- `references/file-organization-case-study.md` — variant comparison that distilled the reading-flow (step-down) norm.
- `references/naming-convention-case-study.md` — variant comparison that distilled the naming norm and the "form follows delivery" convention.
- `references/control-flow-case-study.md` — variant comparison that distilled the guard-clause norm and the data-driven-table context rule.
- `references/magic-values-case-study.md` — variant comparison that distilled the name+single-source norm and the scope/separate-file convention.
- `references/arguments-case-study.md` — variant comparison that distilled the no-positional-list norm and the value-object/typed-clump convention.
- `references/types-case-study.md` — variant comparison (compiler-verified) that distilled the discriminated-union norm and the type-vs-interface convention.
- `references/abstraction-case-study.md` — variant comparison showing a speculative abstraction loses to plain duplication; distilled the proven-seam norm and rule-of-three.
- `references/error-handling-case-study.md` — variant comparison (sentinel/throw/Result + typed-boundary) that distilled the no-swallow/no-generic/observable norm and the by-layer convention.
- `references/domain-io-case-study.md` — variant comparison (mixed/leaky/ports-adapters) that distilled the pure-domain / IO-at-the-edges norm via "test the rule without mocks".
- `references/comments-case-study.md` — variant comparison (what/none/why/jsdoc) that distilled the self-documenting norm and the JSDoc-for-why convention.
- `references/clean-code-rubric.md` — scoring rubric for review tasks.
