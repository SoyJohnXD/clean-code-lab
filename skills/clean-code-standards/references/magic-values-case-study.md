# Case study — magic values: name them, single source, scope to use

Round 4 of the norms lab. Live artifacts: `workspaces/norms-lab/magic-values/` (a shared test proves
every variant behaves identically — only how literals are named/scoped changes).

## Subject

A pricing module (rates, thresholds, fee, tax) with one threshold (`freeShippingMin`) **shared** by
`priceQuote` and `isFreeShipping`, so scope choices become visible.

## The variants (all name every literal — none leave raw magic numbers)

- **A — local consts.** Each constant in its tightest scope. But the shared threshold ends up written
  in two functions → two edit points (a bug waiting to happen).
- **B — module consts.** All constants at the top: one source, very discoverable; cost is exposing
  several single-use constants at module scope.
- **C — scoped.** Shared value at module scope (one source); single-use values local. No duplication,
  no over-exposure.
- **D — separate domain file.** A cohesive `pricing-policy.js` imported by the module.

## Scorecard

| Metric | A local | B module | C scoped | D policy file | Better |
| --- | :--: | :--: | :--: | :--: | :--: |
| Unnamed behavior-changing literals | 0 | 0 | 0 | 0 | — (all valid) |
| Edit points for the shared threshold | 2 | 1 | 1 | 1 | lower |
| Duplicated literals | 1 | 0 | 0 | 0 | lower |
| Single-use constants exposed module-wide | 0 | 6 | 0 | n/a | lower |
| File hops to learn a function's inputs | 0 | 0 | 0 | 1 | lower |

## The norm

Name every behavior-changing literal, with a **single source of truth** — never write the same one
twice (A's flaw is measurable: 2 edit points). Scope it to the narrowest place that covers all its uses.

## The convention (recommendation)

For a self-contained module: **scope to use (C)**. Move constants to a **separate file only when they
are a cohesive domain concept that is shared across modules or is configuration** — and name that file
by the domain (`pricing-policy`), never a generic `constants.js`.

## Meta-lesson (norms compose)

A generic `constants.js` ("all constants together") is the **file-level version of Round 1's variant
B**: grouping by technical type instead of by domain/use, which breaks locality. "Organize by domain,
not technical type" holds for functions inside a file *and* for files inside a project. A
`pricing-policy.js` is fine because it groups by domain cohesion, not by "they are all constants".
