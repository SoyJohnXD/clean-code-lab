# Case study — when to abstract: prefer duplication over the wrong abstraction

Round 7 of the norms lab. Live artifacts: `workspaces/norms-lab/abstraction/` (same public API, three
abstraction strategies, identical behavior proven by `notifications.test.js`).

## Subject

Two notification senders — `sendWelcome` and `sendPasswordReset` — that look similar but aren't the
same operation (reset needs a token; welcome doesn't).

## The variants

- **A — duplicated.** Two direct functions; some duplication (mailer shape + greeting).
- **B — premature generic.** A notification "engine": registry + dispatch-by-type + a `ctx` bag for
  the one type that needs extra data. Built for "any" notification; there are two.
- **C — minimal seam.** Extract only the proven, stable shared part (`deliver`); keep the two senders
  separate and direct.

## Scorecard

| Metric | A duplicated | B generic | C minimal seam | Better |
| --- | :--: | :--: | :--: | :--: |
| Real duplication | 1 | 0 | 0 | lower |
| Speculative constructs without a caller | 0 | 3 | 0 | lower |
| Coupling (changing welcome can break reset) | no | yes | no | lower |
| Indirection (hops) | 1 | 3 | 2 | lower |
| Cost to add a third type | copy a function | edit the engine | a direct function using `deliver` | lower |

## The counterintuitive result

**B — the abstraction that "removes duplication" — loses to A on three axes.** It adds a
registry/dispatch/`ctx` nobody needs (two types exist, not "any"), couples the two notifications onto
one shared path, and adds indirection. A speculative abstraction is worse than the duplication it
tried to remove.

## The norm

Don't build speculative abstractions (factory/registry/dispatch/params) without a current caller.
Extract only the proven, stable shared responsibility — code that shares **one reason to change**.
When in doubt, prefer a little duplication over the wrong abstraction (C fixes A's duplication without
B's costs by extracting just the stable `deliver` seam).

## The convention

**Rule of three:** let duplication appear and prove it shares one reason to change before unifying;
then extract the stable common seam and keep the varying parts direct. Don't abstract on the second
occurrence.

## Meta-lesson

"Looks similar" is not "is the same". Incidental duplication (same shape, different reasons to change)
must stay separate; only essential duplication (one reason to change) should be unified — and even
then, extract the seam, not the whole.
