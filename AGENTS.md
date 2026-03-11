# Repository Guidelines

## Project Structure & Module Organization
This repository is currently in bootstrap state (no application code yet). Use the structure below as the default when adding new work:
- `src/`: application source code grouped by feature/module.
- `tests/`: automated tests mirroring `src/` paths.
- `assets/`: static files (images, fixtures, sample data).
- `docs/`: design notes, architecture decisions, and onboarding docs.

Keep modules small and cohesive. Prefer feature-based folders (for example, `src/habits/`, `src/reminders/`) over generic utility dumping grounds.

## Build, Test, and Development Commands
No build tooling is configured yet. When introducing tooling, expose consistent entry points and document them here:
- `make dev` or equivalent: start local development.
- `make test` (or `npm test` / `pytest`): run all tests.
- `make lint` (or `npm run lint`): run static checks.
- `make format` (or `npm run format`): apply formatting.

If you add a new command, update this section in the same PR.

## Coding Style & Naming Conventions
- Use 4 spaces for Python, 2 spaces for JS/TS/JSON/YAML.
- Prefer descriptive names: `habit_scheduler.py`, `HabitTrackerService`, `test_habit_creation`.
- File and directory names: `snake_case` unless framework conventions require otherwise.
- Keep functions focused; avoid files that mix unrelated responsibilities.

Adopt formatter/linter defaults for the selected stack (for example, `black` + `ruff`, or `prettier` + `eslint`) and run them before opening a PR.

## Testing Guidelines
- Place tests under `tests/` and mirror source layout.
- Name tests by behavior (`test_marks_habit_complete_when_due`).
- Add unit tests for new logic and regression tests for bug fixes.
- Aim for meaningful coverage on changed code, not superficial assertions.

## Commit & Pull Request Guidelines
The repository has no established commit history yet. Use Conventional Commits going forward:
- `feat: add habit streak calculator`
- `fix: handle timezone rollover in reminder job`

PRs should include:
- Short description of the change and why it is needed.
- Linked issue/task (if available).
- Test evidence (command + result summary).
- Screenshots or logs for UI/behavior changes.

## Security & Configuration Tips
Never commit secrets. Use `.env` files for local config and provide `.env.example` with safe placeholder values.
