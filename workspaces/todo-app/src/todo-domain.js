export const TODO_TITLE_MAX_LENGTH = 120;

export const TodoFilter = Object.freeze({
  ALL: "all",
  ACTIVE: "active",
  COMPLETED: "completed",
});

export function createTodo({ id, title, createdAt }) {
  return {
    id: requireNonEmptyText(id, "Todo id"),
    title: normalizeTodoTitle(title),
    completed: false,
    createdAt: requireNonEmptyText(createdAt, "Todo created date"),
  };
}

export function appendTodo(todos, todo) {
  return [...todos, todo];
}

export function toggleTodoCompletion(todos, todoId) {
  return todos.map((todo) =>
    todo.id === todoId ? { ...todo, completed: !todo.completed } : todo,
  );
}

export function removeTodo(todos, todoId) {
  return todos.filter((todo) => todo.id !== todoId);
}

export function clearCompletedTodos(todos) {
  return todos.filter((todo) => !todo.completed);
}

export function filterTodos(todos, filter) {
  if (filter === TodoFilter.ACTIVE) {
    return todos.filter((todo) => !todo.completed);
  }

  if (filter === TodoFilter.COMPLETED) {
    return todos.filter((todo) => todo.completed);
  }

  return todos;
}

export function countActiveTodos(todos) {
  return todos.filter((todo) => !todo.completed).length;
}

export function normalizeTodoTitle(title) {
  const normalizedTitle = requireNonEmptyText(title, "Todo title");

  if (normalizedTitle.length > TODO_TITLE_MAX_LENGTH) {
    throw new Error(`Todo title must be ${TODO_TITLE_MAX_LENGTH} characters or fewer.`);
  }

  return normalizedTitle;
}

function requireNonEmptyText(value, fieldName) {
  if (typeof value !== "string") {
    throw new Error(`${fieldName} must be text.`);
  }

  const normalizedValue = value.trim();

  if (normalizedValue.length === 0) {
    throw new Error(`${fieldName} is required.`);
  }

  return normalizedValue;
}
