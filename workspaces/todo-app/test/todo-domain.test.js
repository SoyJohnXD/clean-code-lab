import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  TodoFilter,
  appendTodo,
  clearCompletedTodos,
  countActiveTodos,
  createTodo,
  filterTodos,
  normalizeTodoTitle,
  removeTodo,
  toggleTodoCompletion,
} from "../src/todo-domain.js";

const CREATED_AT = "2026-05-26T00:00:00.000Z";

describe("todo domain", () => {
  it("creates a normalized active todo", () => {
    const todo = createTodo({ id: "todo-1", title: "  Write tests  ", createdAt: CREATED_AT });

    assert.deepEqual(todo, {
      id: "todo-1",
      title: "Write tests",
      completed: false,
      createdAt: CREATED_AT,
    });
  });

  it("rejects empty titles", () => {
    assert.throws(
      () => normalizeTodoTitle("   "),
      /Todo title is required/,
    );
  });

  it("appends todos without mutating the current list", () => {
    const currentTodos = [todoFixture({ id: "todo-1" })];
    const addedTodo = todoFixture({ id: "todo-2" });

    const nextTodos = appendTodo(currentTodos, addedTodo);

    assert.deepEqual(currentTodos.map((todo) => todo.id), ["todo-1"]);
    assert.deepEqual(nextTodos.map((todo) => todo.id), ["todo-1", "todo-2"]);
  });

  it("toggles one todo completion state", () => {
    const nextTodos = toggleTodoCompletion(
      [todoFixture({ id: "todo-1" }), todoFixture({ id: "todo-2" })],
      "todo-2",
    );

    assert.equal(nextTodos[0].completed, false);
    assert.equal(nextTodos[1].completed, true);
  });

  it("filters active and completed todos", () => {
    const activeTodo = todoFixture({ id: "todo-1" });
    const completedTodo = todoFixture({ id: "todo-2", completed: true });

    assert.deepEqual(filterTodos([activeTodo, completedTodo], TodoFilter.ACTIVE), [activeTodo]);
    assert.deepEqual(filterTodos([activeTodo, completedTodo], TodoFilter.COMPLETED), [
      completedTodo,
    ]);
  });

  it("removes todos and clears completed todos", () => {
    const activeTodo = todoFixture({ id: "todo-1" });
    const completedTodo = todoFixture({ id: "todo-2", completed: true });

    assert.deepEqual(removeTodo([activeTodo, completedTodo], "todo-1"), [completedTodo]);
    assert.deepEqual(clearCompletedTodos([activeTodo, completedTodo]), [activeTodo]);
  });

  it("counts active todos", () => {
    const todos = [
      todoFixture({ id: "todo-1" }),
      todoFixture({ id: "todo-2", completed: true }),
      todoFixture({ id: "todo-3" }),
    ];

    assert.equal(countActiveTodos(todos), 2);
  });
});

function todoFixture({ id, completed = false }) {
  return {
    id,
    title: `Todo ${id}`,
    completed,
    createdAt: CREATED_AT,
  };
}
