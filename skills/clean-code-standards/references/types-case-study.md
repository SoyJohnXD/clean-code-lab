# Case study — types & interfaces: make illegal states unrepresentable

Round 6 of the norms lab (TypeScript). Live artifacts: `workspaces/norms-lab/types/`. This round is
**compiler-verified**: `npm run typecheck` (`tsc --noEmit`) passes, and `misuse.ts` documents exactly
what each model catches.

## Subject

Model a remote-data state (`loading` / `success` / `error`) and a `describe(state)` function.
Behavior is identical across variants (`describe.test.ts`, 3/3 via `node --test`); only the type model
changes.

## The variants

- **A — boolean flags** (`loading`, `data?`, `error?`).
- **B — status string + optional fields** (`status`, `data?`, `error?`).
- **C — discriminated (tagged) union** (each state carries exactly its payload).

## Mechanical proof (misuse.ts, checked by tsc)

- A: `{ loading: true, data, error }` (all three) compiles; `{ loading: false }` (which state?) compiles.
- B: `{ status: "loading", data }` compiles; `{ status: "success" }` without data compiles.
- C: all three illegal constructions are **compile errors** (confirmed by `@ts-expect-error`).

## Scorecard

| Metric | A flags | B status+fields | C union | Better |
| --- | :--: | :--: | :--: | :--: |
| Illegal states that compile (of those shown) | 2 | 2 | 0 | lower |
| Payload access needs `!` / extra guards | yes | yes (`!`) | no | — |
| Narrowing: payload typed by the state | no | no | yes | — |
| Modeling mistakes caught by the compiler | 0 | 0 | 3 | higher |

## The norm

Model mutually-exclusive variants as a **discriminated union** so illegal states are unrepresentable;
narrowing on the tag gives you the payload typed, with no `!` or defensive guards. This is a norm, not
a preference — the compiler decides.

## The convention (type vs interface)

`type` and `interface` are interchangeable for plain object shapes — pick one, be consistent. Use
`type` for unions, intersections, tuples, mapped/conditional types. A discriminated union **requires**
`type`.

## Meta-lesson — norm vs convention, in action

The user first picked B (the comfortable, common choice), exactly as in the naming round. But naming
was a **convention** (all options tied on quality → comfort decides). Types is a **norm**: the
compiler measurably showed B lets illegal states through and forces `!`. With the evidence on the
table, the choice flipped to C. The rule: when a hard metric separates the options, evidence overrides
comfort; when options tie on quality, comfort is a valid tiebreaker.
