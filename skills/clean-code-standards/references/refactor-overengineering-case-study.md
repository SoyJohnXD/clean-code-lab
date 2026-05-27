# Refactor Overengineering Case Study

Use this checklist when a refactor passes tests but feels harder to read.

## Anti-pattern

A refactor tried to remove import-time side effects and improve testability, but added lazy proxy classes, broad settings objects, library API wrappers, parallel string lists, tuple-return builders, schema changes, and telemetry fields that were not requested by the maintainer.

## Review checks

- Did the refactor preserve the existing intent, or did it replace clear code with a framework?
- Are new classes, factories, lazy loaders, interfaces, or proxies required by a current caller?
- Does a wrapper only mirror a library API that could be called directly?
- Is a configuration object grouping unrelated environment values only for convenience?
- Did the change introduce schema, migration, telemetry, or persistence behavior outside the requested slice?
- Are tests protecting user-visible behavior, or are they locking in new abstractions?
- Would the maintainer find the changed code easier to modify than the original?

## Required response

If any answer is negative, block the clean-code gate and ask for the smallest direct implementation that satisfies the slice.
