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

Governance over the host harness. Two pillars, two gates — they apply to every change, in every
SDD/OpenSpec phase.

- **Freeze before code.** No code is written until a human freezes an Intent Contract (objective,
  in-scope, out-of-scope, frozen decisions, acceptance criteria, slice plan). The freeze writes the
  sentinel `.atl/intent/<change>.frozen`; a hard PreToolUse gate denies code edits until it exists.
- **Intent Gate** at every phase boundary — emit `Intent Gate: aligned | drift-detected`. On
  `drift-detected`, STOP: return a change request to the human. Never apply a scope change or a new
  decision silently.
- **Decisions escalate.** A decision not already in the contract goes to the human, not decided
  inside a phase. When a decision is open, propose 2–3 options with tradeoffs; do not guess.
- **Clean Code Gate** at refactor-exit (never at green) — emit `Clean Code Gate: passed | blocked`.
  Prefer the smallest maintainable shape; reject speculative abstractions, passthrough wrappers,
  broad config objects, and vague names. Passing tests do not justify harder-to-read code.

Full contract and per-phase lens live in the `intent-overlay` skill (`references/`).
<!-- intent-overlay:end -->
