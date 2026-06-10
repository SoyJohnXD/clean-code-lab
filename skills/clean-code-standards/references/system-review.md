# System Gate — the whole-change lens

The `/18` rubric (`clean-code-rubric.md`) scores DRY and SOLID at **touched-code scope** — per file, at
refactor-exit. Their **cross-file manifestations** — duplication across slices, dependency direction
across the whole change, module/interface growth over time, layer consistency across files — are
invisible at that scope, visible only across the whole change. The System Gate is that missing lens.

It scores the **union** of files from the `sdd/{change-name}/apply-progress` artifact plus
`git diff --name-only <change-base>...HEAD` — never just the last slice. A duplication introduced two
slices ago is still a duplication.

### Resolving `<change-base>`

`<change-base>` is the ref the change started from, resolved in priority order: (1) the base recorded
by the SDD change (proposal/state artifact), when present; (2) `git merge-base HEAD <default-branch>`;
(3) if neither resolves, fall back to the apply-progress file list alone and say so in the report.

## Firing points

- **verify** — over the whole change. `System Gate: blocked` ⇒ verify FAIL.
- **apply milestones** — when a tasks Phase/group completes, run it over that layer before the next
  Phase starts. Catches drift early, while the context that created it is still warm.
- **no-SDD path** — substantial multi-file work self-checks the System Gate before declaring done, same
  as the Clean Code Gate.

## The five dimensions

A checklist, not a numeric score — each dimension is `ok` or `issue` with a location.

1. **Cross-file duplication** — the same behavior-changing helper, mapper, or literal implemented in 2+
   places. Rule of three (`abstraction-case-study.md`) still applies: the 3rd occurrence is the signal
   to extract, not the 1st.
2. **Dependency direction** — domain code never imports infra/IO/transport. The arrow points inward
   across the whole change, not just within each touched file (`domain-io-case-study.md`).
3. **Module & interface growth** — no god-module (one new arm bolted on per slice until the file does
   five unrelated things) and no fat interface (methods hung onto a shared contract by late slices that
   most callers don't need).
4. **Layer consistency** — ONE persistence style, ONE error-handling pattern, ONE serialization approach
   per layer. Two slices solving the same concern two different ways is drift, even if each slice looks
   clean alone.
5. **Primitives reuse** — shared helpers, typed errors, and value types come from the registry (see
   below). On the 3rd occurrence of a primitive, extract; never re-copy.

## Blockers

Any one of these ⇒ `System Gate: blocked`, regardless of how clean each individual file looked at its
own Clean Code Gate:

- The same behavior-changing helper, mapper, or type is implemented twice across files.
- A domain module imports infra, IO, persistence, or transport.
- Two styles solve the same concern (persistence, error handling, serialization) within one layer.
- A module or interface grew into a god-module or fat interface across slices.
- A primitive listed in the design's `## Primitives` registry was re-implemented instead of reused.

## Primitives registry contract

The design artifact's `## Primitives` section is the **human-approved source of truth**: shared helpers
live HERE, typed errors live HERE, persistence is X, public ports are THESE. It is set once, at design
time, by a human-reviewed decision — not inferred by an agent mid-apply.

The engram topic `sdd/{change-name}/primitives` is an **append-only journal**: apply slices write to it
as they introduce or reuse a primitive, so a fresh-context agent on slice 5 has memory of what slices
1-4 already built. It is a cache for continuity, never a second authority — when the journal and the
design registry disagree, the design registry wins and the disagreement is a drift signal.

## Review Output Template

```markdown
System Gate: passed|blocked
Change: <change-name>
Files reviewed: <n> (apply-progress ∪ git diff --name-only <change-base>...HEAD)

Dimensions:
- Cross-file duplication: ok|issue — <where>
- Dependency direction: ok|issue — <where>
- Module & interface growth: ok|issue — <where>
- Layer consistency: ok|issue — <where>
- Primitives reuse: ok|issue — <where>

Blockers:
- ...

Fitness functions run:
- <tool>: <result> | none available — foundation slice proposed

Required changes:
- ...
```
