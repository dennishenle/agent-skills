---
name: incremental-planning-follow
description: >-
  Executes the next task in an incremental plan created by the
  incremental-planning skill. Use when the user asks to continue, implement,
  proceed, or follow up on a planned task, or references UPCOMING_TASK.md,
  AGENT/PLAN.md, or asks to work on the next step.
---

# Incremental Planning — Follow Up

This skill implements a single task from an existing incremental plan inside
the `AGENT/` directory. It enforces strict one-task-at-a-time execution.

## Workflow

1. **Read** `AGENT/UPCOMING_TASK.md` to identify which `TASK_<N>.md` to work on.
2. **Read** `AGENT/PLAN.md` for overall context.
3. **Read** the referenced `AGENT/TASK_<N>.md` for full details.
4. **Implement** that task — and only that task.
5. **Mark done:**
   a. Rename `TASK_<N>.md` to `TASK_<N>_DONE.md`.
   b. Add a `## Status: Done` section at the top of the file summarizing what
      was implemented.
6. **Advance the pointer:** Update `AGENT/UPCOMING_TASK.md` to reference the
   next `TASK_<N>.md`. If no tasks remain, write "All tasks complete."
7. **Review next task:** Open the newly referenced `TASK_<N>.md` and add any
   questions or considerations that arose during the current implementation.
8. **Stop.** Do not start the next task. Inform the user what was completed and
   that the next task is ready for review.

## Rules

- **One task per invocation.** Never implement more than the single task
  referenced by `UPCOMING_TASK.md`.
- **No guessing.** If the current task has unanswered questions or blockers,
  stop and ask the user rather than making assumptions.
- **Plan adjustments.** If implementation reveals that the plan needs changes
  (new steps, reordering, scope changes), update `PLAN.md` and
  create/modify task files accordingly, then inform the user before continuing.

## File Reference

| File | Purpose |
|------|---------|
| `AGENT/PLAN.md` | High-level overview of all steps |
| `AGENT/TASK_<N>.md` | Detailed description of step N |
| `AGENT/TASK_<N>_DONE.md` | Completed step N (renamed after done) |
| `AGENT/UPCOMING_TASK.md` | Points to the next task to execute |
