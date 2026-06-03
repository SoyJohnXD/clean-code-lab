# Case study — error handling: never swallow, never generic, observe

Round 8 of the norms lab. Live artifacts: `workspaces/norms-lab/error-handling/`
(`withdraw.test.js` + `typed-boundary.test.js`, 13/13).

## Subject

`withdraw(account, amount)` with EXPECTED domain failures (invalid amount, insufficient funds). Same
underlying decision; the variants differ in how failure is reported.

## The variants

- **A — silent sentinel.** Returns `null` on any failure: both failures collapse into one `null`, the
  reason is lost, and `null` collides with valid values.
- **B — throw.** Loud and carries a reason, but failure isn't in the signature; the caller can forget
  to catch and control jumps non-locally.
- **C — Result type.** Failure is in the return value (`{ ok:false, error } | { ok:true, balance }`);
  forces the caller to handle it, reads linearly, keeps the reason. (A discriminated union — Round 6.)
- **D — typed errors + global boundary.** The core throws SPECIFIC typed errors (`InsufficientFundsError`,
  never a generic `Error`); ONE boundary catches, logs through an observability helper (Grafana), and
  maps known domain errors → 4xx, unexpected → 5xx.

## Scorecard

| Metric | A sentinel | B throw | C Result | Better |
| --- | :--: | :--: | :--: | :--: |
| Distinguishes failure from success | fragile (null) | yes | yes | — |
| Preserves the reason | no | yes | yes | — |
| Failure visible in the contract | no | no | yes | — |
| Forces the caller to handle it | no | no | yes | — |
| Non-local jump | no | yes | no | — |

## The norm

Never swallow errors and never raise generic ones. A failure must stay visible and carry its cause —
typed errors or a Result with a code/reason, never an ambiguous sentinel that collides with valid
values — and it must be observable (routed through a logging helper, not lost). A loses this norm: it
collapses two failures into one `null`.

## The convention — error handling by layer

Both B and C make failure explicit; the choice is architectural and layered:

- **Pure domain / core:** return a `Result` for expected failures the immediate caller must handle.
- **Application boundary:** consumers throw specific typed domain errors; ONE global handler catches,
  logs for observability (→ Grafana), and maps them (known domain error → 4xx, unexpected → 5xx).
  Never a generic catch-all. (Variant D shows this.)

These compose: Result inside the domain, typed exceptions + a central observable boundary at the edges.

## Meta-lesson

"Handle errors correctly" decomposes into three measurable things: (1) don't lose the failure,
(2) don't lose the cause (no generics/sentinels), (3) make it observable. The exception-vs-Result
debate is a convention on top of that norm, resolved by layer.
