# Case study — arguments & data shape: name them, group clumps into types

Round 5 of the norms lab. Live artifacts: `workspaces/norms-lab/arguments/` (one expected output,
three call shapes — the shared test proves behavior is identical).

## Subject

`createShipment` from an address (4 strings), dimensions (3 numbers), weight, and express — a signature
rich enough to expose the cost of positional arguments.

## The variants

- **A — positional list.** `createShipment(street, city, zip, country, weight, length, width, height, express)`.
- **B — parameter object.** One object with named fields.
- **C — value objects.** The data clumps (`address`, `dimensions`) become types with behavior.

## Scorecard

| Metric | A positional | B param object | C value objects | Better |
| --- | :--: | :--: | :--: | :--: |
| Positional parameters | 9 | 1 | 3 | lower |
| Same-type params swappable silently | 8 | 0 | 0 | lower |
| Self-describing call site | no | yes | yes | — |
| Cost to add a field | breaks signature + all call sites | one key (non-breaking) | one key in its object | lower |
| Data clumps reusable as a type | 0 | 0 | 2 | — (by reuse) |

## The norm

Don't pass long positional parameter lists — especially multiple same-type or boolean params; they
invite silent swaps (A has 8 swappable values). Name arguments with a parameter object so call sites
are self-describing. Fields that always travel together (data clumps) become a named type.

## The convention

Parameter object by default; **value object when the clump is reused, has invariants, or attracts
behavior**. In a typed codebase (this team is TS-first), model data clumps as **named, reusable
types** — then a swap like `createShipment(dimensions, address, …)` is a compile error, not a runtime
bug, and the type documents the clump everywhere it's used.

## Meta-lesson (norms compose)

"Data clump → type" is the same cohesion principle as Rounds 1 and 4: group what belongs together by
domain. A value object pulls related behavior (`formatAddress`, `volumetricWeight`) next to its data,
just like step-down organization pulls each step next to its use.
