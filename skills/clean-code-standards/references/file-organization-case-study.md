# Case study — file organization: reading flow vs technical type

How the **reading-flow (step-down)** norm was distilled, by comparing three organizations of the
same code. Live artifacts: `workspaces/norms-lab/file-organization/` (a shared test proves all three
behave identically — only the organization differs).

## Subject

A `signup(payload, deps)` handler in one file that uses `db`/`mailer`/`hasher` and does several
things: validate payload, enforce password policy, check email uniqueness, assign the default plan,
persist, send a welcome email, shape the response.

## The three variants

- **A — procedural monolith.** Everything inside one `signup()`. Linear to read, but one function
  carries all eight responsibilities and no rule is testable without the whole IO path.
- **B — grouped by technical type.** Sections for `validators`, `io helpers`, `formatters`, with the
  orchestrator at the bottom. Separated, but you jump between sections to follow the flow.
- **C — by reading flow (step-down).** `signup()` first, reading as a table of contents
  (`checkPayload → persistNewUser → notifyWelcome → created`); each step defined below in call order;
  pure domain rules separated from IO.

## Scorecard

| Metric (how measured) | A | B | C | Better |
| --- | :--: | :--: | :--: | :--: |
| Concerns in the busiest function | 8 | 2 | 2 | lower |
| Upward reading jumps to follow the flow | 0 | ~8 | 0 | lower |
| Functions mixing abstraction levels | 1 | 0 | 0 | lower |
| Domain rules testable without IO | 0 | 4 | 4 | higher |
| Lines until you grasp what the file does | ~4 | ~45 | ~6 | lower |

## The discriminator

**B and C tie on separation** (concerns 2, testable 4) — so splitting into small functions is *not*
what makes C win. What separates them is reading jumps (8 vs 0) and time-to-understand (45 vs 6),
both caused by one thing:

> C is ordered so **reading order = execution order**: the highest-level function comes first and
> reads as an index; each step is defined below in call order (step-down). B grouped by technical
> type and pushed the orchestrator to the bottom, breaking reading order.

## The norm

Organize a file by **reading flow, not by technical type**: highest-level function first as a table
of contents of well-named steps, each step defined below in call order (step-down), every function at
a single level of abstraction.

**Meta-lesson:** separating responsibilities and organizing them are different. You can separate
perfectly (B) and still read badly. Quality lived in the order, not in the split.
