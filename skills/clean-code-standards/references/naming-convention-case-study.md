# Case study — naming: the norm vs the convention

Round 2 of the norms lab. Live artifacts: `workspaces/norms-lab/naming/` (a shared test proves every
variant behaves identically — only the names change).

## Method correction that shaped this round

The first attempt compared one good naming style against two straw men (vague, noisy). That is not a
choice — it pushes the answer. Corrected rule: **show only legitimate variants; the person picks by
comfort.** When every option is good, the quality metrics tie, so the result is a **convention**
(preference), not a **norm** (law).

## The norm (the quality bar every good style shares)

A name carries domain intent and is understandable **without reading the body** — no vague generics
(`data`, `item`, `check`, `ok`), no noise words that only repeat the type/context
(`emailStringValue`, `userDataObject`). This is a Hard Rule.

The straw men proved it by contrast: vague names (`check`, `ok1`, `data`) drop "understandable without
body" to 3/8; noisy names (`validateUserInputPayloadObject`) score ~18 noise words and ~8 redundant
names. The good styles all score 8/8 understandable, 0 noise, 0 generics.

## The convention (chosen among equally-valid styles)

Three legitimate styles tied on quality: action (`persistUser`, `isEmail`), business narrative
(`registerUser`, `meetsPasswordPolicy`), result-oriented (`savedUserFrom`, `emailIsValid`). The user's
insight: the best choice is **context-dependent** — sometimes one is more telling than another.

That unifies the styles into one rule: **the naming form follows what the function delivers.**

| The function… | Most telling form | Example |
| --- | --- | --- |
| returns a boolean (predicate) | `isX` / `hasX` | `isEmail`, `isStrongPassword` |
| is a pure producer (value, no effect) | name by the result | `rejectionFor`, `successResponse` |
| is a command (has a side effect) | action verb | `persistUser`, `sendWelcome` |

Refinement: a side-effecting function keeps a verb **even when it returns a value**, so a noun-like
name never hides that it writes/sends. See `style-fit.js` for the rule applied.

## Meta-lessons

- Compare good vs good, never good vs straw man.
- Distinguish a **norm** (objective, universal) from a **convention** (preference among valid options).
- Conventions are often **context rules**, not fixed picks: choose the most telling form per case.
