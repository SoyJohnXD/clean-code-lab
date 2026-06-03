# Intent Overlay — always-on invariants

The block between the markers below is injected verbatim into each host's global instructions
(`~/.codex/AGENTS.override.md`, `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`) by
`intent-overlay install`. It is idempotent and reversible: `uninstall` removes exactly this block
and leaves the rest of the file byte-identical.

Why always-on and not only a skill: skills are loaded by progressive disclosure — only when the
model decides a task matches. These invariants must hold on *every* turn, so they belong in the
instruction layer the host always reads, not in a skill it may skip.

<!-- intent-overlay:start -->
## Intent Overlay (active)

Governance that rides inside the host harness (gentle-ai/SDD). It adds no artifacts: the intent lives
in SDD's own documents and quality is the existing clean-code bar. Two gates, emitted as self-check
lines — never as new files.

- **Proportional ceremony.** Trivial or small changes do not run SDD: apply clean-code judgment inline
  and stop. SDD (and these gates) is for substantial changes only. Do not generate planning documents
  for work that does not need them. **No SDD ⇒ no verify phase, so verification is on YOU:** still run
  the Clean Code Gate at refactor-exit and self-check against the rubric, and use the host's own
  plan/approval step as the human gate. Skipping SDD never means skipping the quality bar.
- **Intent lives in SDD.** Objective, in-scope/out-of-scope, and decisions live in the approved
  `proposal` (elaborated in `design`); acceptance criteria live in the `spec`. The human approving the
  proposal IS the freeze — there is no separate Intent Contract and no sentinel file. Code work
  (`apply`) starts only once the proposal is approved; SDD's own phase dependencies enforce this.
- **Intent Gate** at every phase boundary — emit `Intent Gate: aligned | drift-detected`, checking the
  phase output against the approved proposal/spec. On `drift-detected`, STOP: return a change request
  (an amendment to the proposal) to the human. Never widen scope or add a decision silently.
- **Decisions are surfaced, never silent.** Architecture-shaping decisions — those that move scope, are
  costly to reverse, change observable behavior, or fix architectural shape (a pattern, a dependency
  direction, an interface, a data model, a library choice) — are always made explicit with 2–3 options
  and tradeoffs, never guessed. Who chooses depends on the mode (below). Only local, reversible details
  inside a slice are decided without surfacing.
- **Decision Ledger (mode-aware).** Every phase emits what it **Decided** (with rationale + rejected
  alternatives) and what it **Defers**. In **interactive** SDD, `propose`/`design` STOP and defer
  architecture-shaping decisions to the human. In **automatic** SDD, the agent decides them itself —
  choosing the smallest maintainable option — but still records each in the ledger; never silently.
  Either way `design` elaborates only within the agreed decisions and returns a genuinely new
  architecture-shaping decision as a change request. Rules, gates, and verification stay in force in
  both modes.
- **Clean Code Gate** at refactor-exit (never at green) — emit `Clean Code Gate: passed | blocked`.
  Prefer the smallest maintainable shape; reject speculative abstractions, passthrough wrappers,
  broad config objects, and vague names. Passing tests do not justify harder-to-read code.

Per-phase detail lives in the `intent-overlay` skill (`references/PHASE-LENS.md`).
<!-- intent-overlay:end -->
