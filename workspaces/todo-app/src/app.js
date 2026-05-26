import {
  TodoFilter,
  appendTodo,
  clearCompletedTodos,
  countActiveTodos,
  createTodo,
  filterTodos,
  removeTodo,
  toggleTodoCompletion,
} from "./todo-domain.js";
import { loadStoredTodos, saveStoredTodos } from "./storage.js";

const EMPTY_STATE_TEXT = "No todos match this view.";
const PLURAL_TASK_LABEL = "tasks";
const SINGULAR_TASK_LABEL = "task";

const todoForm = document.querySelector("[data-todo-form]");
const todoInput = document.querySelector("[data-todo-input]");
const formError = document.querySelector("[data-form-error]");
const todoList = document.querySelector("[data-todo-list]");
const todoSummary = document.querySelector("[data-todo-summary]");
const clearCompletedButton = document.querySelector("[data-clear-completed]");
const filterButtons = [...document.querySelectorAll("[data-filter]")];

let todos = loadStoredTodos();
let activeFilter = TodoFilter.ALL;

todoForm.addEventListener("submit", (event) => {
  event.preventDefault();
  formError.textContent = "";

  try {
    const todo = createTodo({
      id: crypto.randomUUID(),
      title: todoInput.value,
      createdAt: new Date().toISOString(),
    });

    todos = appendTodo(todos, todo);
    todoInput.value = "";
    commitTodoChanges();
  } catch (error) {
    formError.textContent = error.message;
  }
});

todoList.addEventListener("click", (event) => {
  const clickedControl = event.target.closest("[data-todo-action]");

  if (!clickedControl) {
    return;
  }

  const todoId = clickedControl.dataset.todoId;

  if (clickedControl.dataset.todoAction === "toggle") {
    todos = toggleTodoCompletion(todos, todoId);
  }

  if (clickedControl.dataset.todoAction === "remove") {
    todos = removeTodo(todos, todoId);
  }

  commitTodoChanges();
});

clearCompletedButton.addEventListener("click", () => {
  todos = clearCompletedTodos(todos);
  commitTodoChanges();
});

filterButtons.forEach((filterButton) => {
  filterButton.addEventListener("click", () => {
    activeFilter = filterButton.dataset.filter;
    renderTodos();
  });
});

renderTodos();

function commitTodoChanges() {
  saveStoredTodos(todos);
  renderTodos();
}

function renderTodos() {
  const visibleTodos = filterTodos(todos, activeFilter);
  todoList.replaceChildren(...createTodoListNodes(visibleTodos));
  todoSummary.textContent = formatTodoSummary(countActiveTodos(todos));
  clearCompletedButton.disabled = todos.every((todo) => !todo.completed);
  updateSelectedFilter();
}

function createTodoListNodes(visibleTodos) {
  if (visibleTodos.length === 0) {
    const emptyState = document.createElement("li");
    emptyState.className = "empty-state";
    emptyState.textContent = EMPTY_STATE_TEXT;
    return [emptyState];
  }

  return visibleTodos.map(createTodoNode);
}

function createTodoNode(todo) {
  const todoNode = document.createElement("li");
  todoNode.className = "todo-list-item";
  todoNode.dataset.completed = String(todo.completed);

  const toggleButton = document.createElement("button");
  toggleButton.className = "todo-toggle";
  toggleButton.type = "button";
  toggleButton.dataset.todoAction = "toggle";
  toggleButton.dataset.todoId = todo.id;
  toggleButton.setAttribute("aria-pressed", String(todo.completed));
  toggleButton.textContent = todo.completed ? "Undo" : "Done";

  const title = document.createElement("span");
  title.className = "todo-title";
  title.textContent = todo.title;

  const removeButton = document.createElement("button");
  removeButton.className = "remove-button";
  removeButton.type = "button";
  removeButton.dataset.todoAction = "remove";
  removeButton.dataset.todoId = todo.id;
  removeButton.setAttribute("aria-label", `Remove ${todo.title}`);
  removeButton.textContent = "×";

  todoNode.append(toggleButton, title, removeButton);
  return todoNode;
}

function updateSelectedFilter() {
  filterButtons.forEach((filterButton) => {
    const isSelected = filterButton.dataset.filter === activeFilter;
    filterButton.classList.toggle("is-selected", isSelected);
    filterButton.setAttribute("aria-pressed", String(isSelected));
  });
}

function formatTodoSummary(activeTodoCount) {
  const taskLabel = activeTodoCount === 1 ? SINGULAR_TASK_LABEL : PLURAL_TASK_LABEL;
  return `${activeTodoCount} ${taskLabel} left`;
}
