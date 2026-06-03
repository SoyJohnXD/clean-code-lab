# Case study — comments: self-document the what, document only the why

Round 10 (final) of the norms lab. Live artifacts: `workspaces/norms-lab/comments/`
(`price.test.js`, 12/12).

## Subject

`finalPrice(cart)` with an obvious part (sum, tax) and a NON-obvious part: rounding to the nearest
0.05, required by Swiss law (Rappen rounding) — something code alone can't explain.

## The variants

- **A — what-comments.** Comments narrate the obvious and patch bad names (`calc`, `c`, `s`) and a
  magic `1.08`; the one non-obvious line gets a WHAT comment, not the WHY.
- **B — no comments.** Self-documenting names, zero comments. The WHAT is clear, but the non-obvious
  WHY is lost — a maintainer might "simplify" the rounding and break the legal rule.
- **C — why-comments.** Same clean code + one comment for the non-obvious WHY.
- **D — jsdoc-style (team convention).** No inline comments; the non-obvious why lives in a JSDoc on
  the function that needs it; in TS it does not restate types.

## Scorecard

| Metric | A what | B none | C why | Better |
| --- | :--: | :--: | :--: | :--: |
| Comments narrating the obvious | 4 | 0 | 0 | lower |
| Comments patching bad names/magic | 3 | 0 | 0 | lower |
| WHAT clear without comments | no | yes | yes | — |
| Non-obvious WHY captured | no | no | yes | — |
| Drift risk (comment lies when code changes) | high | 0 | low | lower |

## The norm

Make code self-documenting; never narrate the WHAT or use comments to patch bad names or magic numbers
(fix those with names and constants — Rounds 2 and 4). Don't lose a non-obvious WHY: B's measured
failure is exactly that — zero comments dropped the legal reason.

## The convention (team, reconciled)

No inline comments. JSDoc only on functions that are **complex OR carry a non-obvious contract** —
summary + the non-obvious why + params/returns only where they add meaning beyond the types
(TS-first: no type echo). Two refinements over "JSDoc on complex functions, with what/params/return":
(1) don't restate TS types; (2) the trigger is "complex OR non-obvious why", because a non-obvious
reason can live in a simple function (the rounding rule), and "complexity only" would drop it.

## Meta-lesson (closes the series)

The urge to comment the WHAT is almost always a naming or constant problem (Rounds 2 & 4). Code
expresses the what; comments/JSDoc carry only what code can't — the why. Good decomposition (Rounds 1
& 7) leaves few functions complex enough to need JSDoc at all.
