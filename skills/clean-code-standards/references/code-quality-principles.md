# Clean Code Standards — Expanded Principles

## Core Philosophy

The goal is not to make code look sophisticated. The goal is to make code easy to read, change, and trust.

Good code should read like a clear technical book:

- Names explain intent.
- Structure explains responsibility.
- Dependencies explain direction.
- Tests explain behavior.
- The absence of comments is earned by clarity.

## AI Code Generation Requires Design Constraints

AI removes much of the friction from writing functions, classes, endpoints, and tests. That does not make good software cheaper. The scarce part is still deciding what to build, how to structure it, and why that shape is better than a simpler alternative.

An unconstrained agent can create instant legacy: code that works today but raises the cost of every future change. Clean-code guidance must therefore act as a design boundary before implementation, not as decoration after code exists.

Use this stance when guiding agents:

- Code is cheap; durable software is not.
- The agent accelerates implementation, but the prompt and skill supply design judgment.
- Prefer structure that reduces future change cost over structure that merely looks architectural.
- Every abstraction must pay rent now through clearer intent, lower coupling, or simpler change.
- Passing tests does not compensate for avoidable maintenance burden.

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
