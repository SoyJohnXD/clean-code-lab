# Case study — control flow: guard clauses vs nesting vs policy table

Round 3 of the norms lab. Live artifacts: `workspaces/norms-lab/control-flow/` (a shared test proves
every variant behaves identically — only the branching changes).

## Subject choice matters

The first attempt reused the signup handler, but its validation is a **flat list of independent
checks** — every control-flow style looked the same, so nothing was evident. Lesson: when the subject
can't exercise the axis, switch the subject. We moved to an **authorization decision**
(`publishDecision(user, post)`) with dependent conditions, where the styles diverge sharply.
(`single-exit` was dropped — the user disliked one-return discipline.)

## The variants

- **A — guard clauses.** Early return, flat: each condition sits next to its outcome.
- **B — nested conditionals.** The pyramid that grows "naturally": each outcome drifts far from the
  condition that causes it.
- **C — policy table.** Rules as data; the first matching rule wins.

## Scorecard

| Metric | A guard | B nested | C policy table | Better |
| --- | :--: | :--: | :--: | :--: |
| Max nesting depth | 1 | 5 | 1 | lower |
| Distance condition→outcome (lines) | 0 | ~14 | 0 | lower |
| Lines to add/reorder a rule | 1 | restructure the tree | 1 | lower |
| Branches to hold at the worst point | 1 | 5 | 1 | lower |
| Indirection | 0 | 0 | 2 | lower |

## The norm

**Flatten control flow with guard clauses: check each condition where it arises and return early.
Never nest decisions into a pyramid** — nesting (B) separates each outcome from its cause and stacks
branches the reader must hold at once. This is measurable (depth, condition→outcome distance), so it
is a norm, and B is the antiexample.

## The context rule (convention)

A and C are both flat; A wins by adding no indirection. C's rule table only earns its keep when the
rules are **many, dynamic, or configurable**. So: **direct guard clauses by default; data-driven
table only past a handful of fixed cases.** (This previews Round 6 — when to abstract.)

## Meta-lesson

If the subject can't make the axis visible, change the subject. Carry the prior winners (step-down
organization, fit naming) as principles applied to the new subject, not as literal code.

See also `magic-values-case-study.md`, where the same "group by domain, not technical type" norm
reappears at the file level (a generic `constants.js` is the file-level version of organizing by
technical kind).
