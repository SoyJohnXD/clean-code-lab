# Refactor Review Prompt

Use this prompt after an agent creates one of the sample projects.

```text
Use clean-code-standards.

Review the project in workspaces/<project-name> against docs/clean-code-rubric.md.

Do not rewrite everything. Identify only the smallest changes needed for touched code to pass the Clean Code Gate.

If changes are needed, apply them, run available checks, and report:
- score before
- score after
- files changed
- Clean Code Gate result
```
