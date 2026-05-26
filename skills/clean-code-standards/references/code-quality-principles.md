# Clean Code Standards — Expanded Principles

## Core Philosophy

The goal is not to make code look sophisticated. The goal is to make code easy to read, change, and trust.

Good code should read like a clear technical book:

- Names explain intent.
- Structure explains responsibility.
- Dependencies explain direction.
- Tests explain behavior.
- The absence of comments is earned by clarity.

## Preferred Implementation Strategy

Use **design by slice**:

1. Understand the requested behavior.
2. Define the smallest vertical slice that delivers it.
3. Identify domain logic, IO/framework code, and presentation/API boundaries.
4. Implement the slice.
5. Refactor the slice before completion.

Avoid both extremes:

- Do not build a quick mess and promise to clean it later.
- Do not abstract every possible future before behavior exists.

## Review Checklist

- Does every name explain what the thing means in the business/problem domain?
- Can a reader understand the flow without reading comments?
- Are constants named where literals would otherwise hide meaning?
- Is each file responsible for one coherent concept?
- Is framework/IO code separated from domain decisions when possible?
- Is duplication removed only when the shared responsibility is real?
- Are tests focused on behavior instead of implementation details?
