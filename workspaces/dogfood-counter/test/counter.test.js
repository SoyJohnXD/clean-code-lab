import { test } from "node:test";
import assert from "node:assert/strict";
import { increment, INITIAL_COUNT } from "../src/counter.js";

test("increment adds one", () => {
  assert.equal(increment(INITIAL_COUNT), 1);
});
