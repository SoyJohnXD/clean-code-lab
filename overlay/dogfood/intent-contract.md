# Intent Contract — add reset() to dogfood-counter
Status: FROZEN (fixture for the closed test)

## Objective
Add a pure `reset()` to the counter domain that returns the initial count.

## In-scope
- `reset()` in `workspaces/dogfood-counter/src/counter.js`, returning `INITIAL_COUNT`.
- One test for `reset()` in `workspaces/dogfood-counter/test/counter.test.js`.

## Out-of-scope
- Persistence of any kind (localStorage, files, DB).
- UI, DOM, or rendering.
- Telemetry, logging, analytics.
- New files beyond the existing src/test.

## Frozen decisions
- `reset()` is pure and stateless — rationale: the domain holds no state; callers own the value.
  Rejected: a stateful counter object (adds state the domain does not need).

## Acceptance criteria
- `reset()` returns `INITIAL_COUNT`.
- `cd workspaces/dogfood-counter && npm test` passes.
- No new dependency, no persistence, no UI.

## SDD Slice Plan
1. Add `reset()` + its test (single slice).

## Assumptions
- [ASSUMED] Existing `increment`/`INITIAL_COUNT` stay unchanged.

## Open questions
- None.
