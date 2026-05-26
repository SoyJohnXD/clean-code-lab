const TODO_STORAGE_KEY = "clean-code-lab.todo-app.todos";

export function loadStoredTodos() {
  const storedTodos = window.localStorage.getItem(TODO_STORAGE_KEY);

  if (!storedTodos) {
    return [];
  }

  try {
    const parsedTodos = JSON.parse(storedTodos);
    return Array.isArray(parsedTodos) ? parsedTodos : [];
  } catch {
    return [];
  }
}

export function saveStoredTodos(todos) {
  window.localStorage.setItem(TODO_STORAGE_KEY, JSON.stringify(todos));
}
