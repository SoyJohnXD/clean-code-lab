# Intent Contract — protocol and template

The Intent Contract is the frozen truth that the host harness (SDD) must obey. It is produced by a
guided design interrogation **before any code is written**, frozen by a human, and then read by every
phase. Phases may elaborate within it; they may never edit it. Only the human amends it, via an
explicit change request.

## Phase 0 — guided freeze (how the contract is captured)

This is not filling a template. It is a design interrogation.

1. **Review the change.** Identify every decision that must be made to execute it.
2. **Undecided is grave.** The contract does not freeze while a critical decision is still open.
3. **Inform, do not guess.** For each open decision that matters, propose 2–3 options and explain what
   each one is and its tradeoffs, then wait for the choice. **No limit on clarification rounds.**
4. **Produce the contract** below, including the SDD Slice Plan.
5. **Freeze explicitly.** A human signs off. Only then does SDD start. Anything the agent had to
   assume is tagged `[ASSUMED]` and visible at freeze.

### Decision altitude (what to freeze vs. what to leave to design)

Freeze a decision in Phase 0 **only if leaving it open would be grave** — that is, if it:

- defines or moves the **scope / boundary** of the change,
- is **expensive to reverse** later,
- affects **observable behavior** or the acceptance criteria,
- fixes the overall **architectural shape**.

Everything **local and reversible inside a slice** is NOT decided here — `design` elaborates it
**within the contract**. This is what keeps Phase 0 from stepping on the purpose/design phases:
Phase 0 locks the *what* and the decisions that matter; purpose/design do the detailed *how* without
re-deciding or expanding.

## Template

```markdown
# Intent Contract — <change name>
Status: DRAFT | FROZEN (<date>, signed: <human>)

## Objective
<one sentence — the frozen goal>

## In-scope
- <explicit item>

## Out-of-scope
- <explicit item>        # this list is what stops scope creep

## Frozen decisions
- <decision> — rationale: <why> — rejected: <option(s) and why not>

## Acceptance criteria
- <measurable, observable condition>

## SDD Slice Plan
1. <small, achievable slice the host consumes one at a time>
2. ...

## Assumptions
- [ASSUMED] <safe, reversible default the human did not explicitly confirm>

## Open questions
- <none — freeze requires this list empty of critical items>
```

**Freeze criterion:** zero critical decisions open and no critical open questions. If either remains,
the contract stays DRAFT and SDD does not start.

## Intent Gate (runs at every phase boundary)

Before a phase returns, it self-checks against the FROZEN contract and emits one telemetry line:

```
Intent Gate: aligned | drift-detected
```

Checks:

- Did this phase stay within In-scope and respect Out-of-scope?
- Did it introduce a decision not in the contract?
- Did it reinterpret or widen the Objective?
- Do its outputs still satisfy the Acceptance criteria?

**`drift-detected` → STOP.** Do not apply the deviation. Surface it to the human as a change request
(below). Resume only after the human amends the contract or rejects the change.

## Change request (the only way the contract changes)

```markdown
## Change request — <change name>
Detected in phase: <phase>
Deviation: <what the phase wanted to do that the contract does not cover>
Why it came up: <reason>
Proposed contract amendment: <add to in-scope / new decision / revised acceptance>
Impact on slices: <which slices change>
```

The human accepts (the contract is amended and re-frozen) or rejects (the phase proceeds within the
original contract). Either way the decision is recorded; nothing is changed silently.
