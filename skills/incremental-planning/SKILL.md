---
name: incremental-planning
description: >-
  Enforces an incremental planning-then-executing workflow for complex tasks.
  Use when the user asks to plan, break down, or incrementally implement a
  feature, refactor, or multi-step task. Also use when the user references
  AGENT/, PLAN.md, TASK files, or UPCOMING_TASK.md.
---

# Incremental Planning

A two-phase workflow that separates **planning** from **execution**. Work is
broken into discrete task files so the user can review, ask questions, and
approve each step before implementation begins.

## Phase 1: Planning

When the user describes a goal or feature, **do not implement anything**. Instead:

1. Create an `AGENT/` directory in the project root (if it doesn't exist).
2. Create `AGENT/PLAN.md` — a high-level overview listing all steps as a
   numbered list. Keep it concise; details go in the task files.
3. For each step, create `AGENT/TASK_<N>.md` (e.g. `TASK_1.md`, `TASK_2.md`).
   Each file should contain:
   - A clear description of what will be done in that step.
   - Acceptance criteria — how to know the step is complete.
   - Any open questions for the user (clearly marked).
4. Create `AGENT/UPCOMING_TASK.md` whose sole content is a reference to
   `TASK_1.md` (the first task to execute).
5. **Stop.** Do not begin any implementation. Inform the user that the plan is
   ready for review and that they can answer questions or request changes in the
   task files.

### Planning Guidelines

- Each task should be small enough to complete in a single session.
- Tasks should be ordered by dependency — later tasks may depend on earlier
  ones, but never the reverse.
- If the scope is unclear, add questions in the relevant `TASK_<N>.md` files
  rather than guessing.
- Prefer more, smaller tasks over fewer, larger ones.

## Phase 2: Execution

When the user asks to proceed (e.g. "implement the next task", "continue",
or references `UPCOMING_TASK.md`):

1. Read `AGENT/UPCOMING_TASK.md` to determine which task to work on.
2. Read the referenced `TASK_<N>.md` for full details.
3. Implement **only** that single task. Do not start any subsequent tasks.
4. After completing the task:
   a. Rename the file from `TASK_<N>.md` to `TASK_<N>_DONE.md`.
   b. Add a `## Status: Done` section at the top of the file with a brief
      summary of what was implemented.
   c. Update `AGENT/UPCOMING_TASK.md` to reference the next `TASK_<N>.md`.
      If all tasks are complete, write "All tasks complete." instead.
5. Review the **next** task file (the one now referenced by `UPCOMING_TASK.md`)
   and add any new questions that arose during the current implementation.
6. **Stop.** Inform the user what was completed and that the next task is ready
   for review.

### Execution Rules

- Never skip ahead. One task per cycle.
- If a blocker or unanswered question exists in the current task, stop and ask
  the user instead of guessing.
- If implementation reveals that the plan needs adjustment (new steps, reorder,
  scope change), update `PLAN.md` and create/modify task files accordingly,
  then inform the user before continuing.

## File Reference

| File | Purpose |
|------|---------|
| `AGENT/PLAN.md` | High-level overview of all steps |
| `AGENT/TASK_<N>.md` | Detailed description of step N |
| `AGENT/TASK_<N>_DONE.md` | Completed step N (renamed after done) |
| `AGENT/UPCOMING_TASK.md` | Points to the next task to execute |
