# Case study — domain/IO boundary: keep the rule pure, push IO to the edges

Round 9 of the norms lab. Live artifacts: `workspaces/norms-lab/domain-io/` (`renewal.test.js`,
12/12). The test itself is the proof: only the pure variant's rule runs with zero mocks.

## Subject

Renew a subscription: a pure rule (can it renew? new end, amount) surrounded by IO (load, charge,
save).

## The variants

- **A — mixed.** Rule and IO tangled in one function; no rule exists to test in isolation.
- **B — leaky split.** A `decideRenewal` that *looks* like domain but takes `deps` and reads the db
  inside — separation in name only; the rule still needs a db mock and still knows IO.
- **C — ports & adapters.** Pure `decideRenewal(subscription, today)` (data → decision, imports
  nothing); the use case orchestrates IO at the edges.

## Scorecard

| Metric | A mixed | B leaky | C ports/adapters | Better |
| --- | :--: | :--: | :--: | :--: |
| Test the rule without mocks | impossible (no rule) | no | yes | — |
| Domain knows infrastructure | yes | yes | no | lower |
| Mocks to test the decision | db + payment | db | 0 | lower |
| Changing the DB / adding a channel touches domain | yes | yes | no | lower |
| Rule is pure / deterministic | no | no | yes | — |

## The norm

Keep business rules pure: a domain decision takes data and returns a decision (or Result), with no IO
and importing nothing from db/HTTP/UI. Orchestrate IO at the edges; the dependency points inward. This
is measurable — if you can't test the rule without mocking the db, the domain is still coupled.

## The trap (B)

"Extracting a function" is not the same as inverting the dependency. B's `decideRenewal` reads the db
inside, so the rule is still chained to infrastructure. Separation of names, not of dependencies.

## Composes with earlier rounds

The pure decision returns a discriminated-union / Result (Rounds 6 and 8). The use case reads like
step-down orchestration (Round 1): load → decide → act. The boundary is where typed errors +
observability (Round 8) live.
