# dogfood-counter

A deliberately tiny, dependency-free counter domain used as the target for the Intent Overlay closed
test. It exists so the overlay's Intent Gate has a real change to govern.

```bash
cd workspaces/dogfood-counter && npm test
```

- `src/counter.js` — pure domain: `increment` and `INITIAL_COUNT`.
- The closed-test change adds a `reset()` (in-scope). Persistence/UI are out-of-scope on purpose, so a
  drift attempt at `design` is unmistakable. See `overlay/dogfood/`.
