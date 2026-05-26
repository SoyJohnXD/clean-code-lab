# Clean Code Lab

Local pilot for validating a clean-code standard before promoting it to global agent configuration.

## How to Use

Ask an agent to work inside this folder. The local `AGENTS.md` applies the clean-code skill automatically for code tasks:

```text
Create a small full-stack project in workspaces/<name> that...
```

The agent should load:

- `AGENTS.md`
- `skills/clean-code-standards/SKILL.md`
- `docs/clean-code-rubric.md`

If the request is too vague, the agent should ask questions before coding instead of guessing.

## What This Lab Is For

- Testing frontend, backend, and full-stack projects from zero.
- Comparing different agents against the same quality rubric.
- Refining the standard before making it global.

## What This Lab Is Not For

- Global configuration changes.
- Rewriting existing production projects.
- Enforcing style through tooling before the expected behavior is validated.
