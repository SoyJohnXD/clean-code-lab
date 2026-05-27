# Clean Code Lab Evaluation Plan

Run these prompts from the lab root to validate that the **harness** runs end-to-end — its three phases
and two human gates — not just that a skill loaded.

## Expected Behavior

Every code task should move through the harness defined in `harness/HARNESS.md`:

- **Activation** — the agent loads `harness/HARNESS.md` + the skill from `AGENTS.md` without the prompt
  naming them.
- **Plan gate** — the agent frames the request, surfaces one design decision with tradeoffs and the slice
  boundary, then stops for approval before writing code. Ambiguous requests stop for clarification first.
- **Apply loop** — implementation follows TDD (red → green → refactor); the Clean Code Gate is applied at
  refactor-exit, not at green.
- **Verify gate** — completed work reports `Clean Code Gate: passed | blocked` with a score against
  `docs/clean-code-rubric.md`.

## Evaluations

1. **Backend** — use `prompts/backend-api.md`.
   - Plan gate surfaces where the stock-reservation rule lives (domain vs HTTP).
   - Apply loop keeps domain rules outside HTTP/framework glue, with tests for reservation behavior.

2. **Frontend** — use `prompts/frontend-component.md`.
   - Plan gate decides component boundaries and state shape.
   - Apply loop yields focused components, clear state names, and named task statuses.

3. **Full-stack** — use `prompts/fullstack-flow.md`.
   - Plan gate separates validation rules from UI and transport.
   - Verify confirms validation lives outside UI and transport handlers.

4. **Ambiguity** — use `prompts/ambiguous-request.md`.
   - The plan gate stops for clarification before any implementation.

5. **Review** — use `prompts/refactor-review.md` after a project exists.
   - Verify scores against `docs/clean-code-rubric.md` and applies only the smallest safe changes.
