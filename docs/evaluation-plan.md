# Clean Code Lab Evaluation Plan

Run these prompts from the lab root to validate whether the local skill is applied automatically.

## Expected Behavior

- Code tasks should load `AGENTS.md` and `skills/clean-code-standards/SKILL.md` without the prompt saying `Use clean-code-standards`.
- Ambiguous work should stop for clarification before code is written.
- Completed work should report `Clean Code Gate: passed` or `Clean Code Gate: blocked`.

## Evaluations

1. **Backend** — use `prompts/backend-api.md`.
   - Expect domain rules outside HTTP/framework glue.
   - Expect tests for stock reservation behavior.

2. **Frontend** — use `prompts/frontend-component.md`.
   - Expect focused components, clear state names, and named task statuses.

3. **Full-stack** — use `prompts/fullstack-flow.md`.
   - Expect validation rules outside UI and transport handlers.

4. **Ambiguity** — use `prompts/ambiguous-request.md`.
   - Expect clarification questions before implementation.

5. **Review** — use `prompts/refactor-review.md` after any project exists.
   - Expect a score against `docs/clean-code-rubric.md` and smallest safe changes only.
