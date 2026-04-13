---
description: Implement one or all tasks from a /plan-tasks plan using TDD. Single task updates downstream task files. All-tasks mode runs sequentially with one subagent per task via the orchestrator.
argument-hint: <feature-slug> <task-number | all>
---

# Implement Command

Executes tasks from a plan created by `/plan-tasks`.

**Usage:**
```
/implement <feature-slug> <N>      implement task N with TDD
/implement <feature-slug> all      implement all pending tasks (orchestrated)
```

Arguments: `$ARGUMENTS`

Parse the first token as `<feature-slug>` and the second as `<target>` (a task number or the literal `all`).

---

## Phase 0 — LOAD PLAN

Resolve the plan directory: `.claude/plans/<feature-slug>/`

Read `_index.md`. If the directory or index does not exist:
```
Error: No plan found at .claude/plans/<feature-slug>/
Run /plan-tasks <feature-description> to create one first.
```

Parse the task list and their current statuses from `_index.md`.

---

## Phase 1 — SINGLE TASK MODE

*Skip to Phase 2 if `<target>` is `all`.*

### 1a. Read and Validate

Read `.claude/plans/<feature-slug>/task-<NN>.md`.

Check `depends_on`: for each listed task number, verify its status is `done` in `_index.md`.
If a dependency is not done, stop:
```
Error: Task NN depends on task MM which is not yet complete.
Run /implement <feature-slug> MM first.
```

If the task status is already `done`, warn the user:
```
Task NN is already marked done. Re-implement? (yes / no)
```
Stop unless the user confirms.

### 1b. Mark In-Progress

Update `task-<NN>.md` frontmatter: `status: in-progress`
Update the corresponding row in `_index.md`.

### 1c. Implement with TDD

Apply the **tdd-workflow** to implement the task using the acceptance criteria as the test target:

1. **RED** — Write failing tests that cover each acceptance criterion
2. **GREEN** — Write the minimum implementation to make all tests pass
3. **REFACTOR** — Clean up the code without breaking tests
4. **VERIFY** — Run type-check and lint; resolve any issues before continuing

### 1d. Mark Done

Update `task-<NN>.md`:
- Set `status: done` in frontmatter
- Append the following section at the end of the file:

```markdown
## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** <YYYY-MM-DD>

**Files changed:**
- `path/to/file` — created | modified

**Deviations from plan:**
<Describe any deviations and why, or write "None".>

**Interface changes:**
<List any public interfaces, types, function signatures, or file paths that
differ from what the plan described. Downstream tasks may need updating.>
```

Update the corresponding row in `_index.md` to `done`.

### 1e. Update Downstream Tasks

Scan all task files with `status: pending` or `status: in-progress` that have a task number greater than NN.

For each downstream task, read its **Context** and **Acceptance Criteria** sections and compare against the **Interface changes** recorded in step 1d.

If any interface, file path, type name, or data structure introduced or changed in task NN affects a downstream task:
- Update the **Context** section of that task file to reflect the actual implementation
- Prepend a notice at the top of the affected section:
  ```
  > Updated after task NN: <brief reason for the change>
  ```
- Do NOT alter the task's **Goal** or **Acceptance Criteria** unless a criterion has become impossible or redundant due to the upstream change. If that happens, annotate the criterion with a strikethrough and a note rather than deleting it silently.

### 1f. Report

```
Task NN complete: <title>

  Tests:      N written, all passing
  Files:      <list of changed files>
  Downstream: tasks NN+1, NN+2 updated  (or "none affected")

Next: /implement <feature-slug> <NN+1>
```

---

## Phase 2 — ALL TASKS MODE

*Activated when `<target>` is `all`.*

This mode uses the **orchestrator** agent to coordinate sequential subagent execution. The orchestrator maintains the task loop and state; each individual task runs in its own isolated subagent.

### 2a. Pre-flight

Read `_index.md` and collect all tasks with `status: pending` in ascending order. Skip tasks that are already `done`.

If all tasks are already done:
```
All tasks are already complete. Nothing to implement.
```

### 2b. Orchestration Loop

The **orchestrator** agent runs the following loop sequentially — one task at a time, never in parallel (tasks may depend on each other's output).

For each pending task in order:

**Step 1 — Dependency check**
Verify all tasks listed in `depends_on` are `done`. If not, this indicates a plan error — report it and halt the loop.

**Step 2 — Spawn task subagent**
Launch a subagent for the current task. Pass the subagent:
- The full content of `task-<NN>.md`
- The full content of `_index.md`
- The current content of all downstream `task-*.md` files
- The instruction to execute **Phase 1, steps 1a–1e** (single task mode, minus the pre-flight checks already done by the orchestrator)

**Step 3 — Wait and verify**
Wait for the subagent to complete. Read back `task-<NN>.md` and confirm `status: done`. If the subagent did not mark it done or reported an error:
- Pause the loop
- Report the failure to the user with the subagent's output
- Wait for user instruction (`continue`, `skip`, or `abort`) before proceeding

**Step 4 — Propagate downstream updates**
Read the **Interface changes** section written by the subagent. Apply any downstream task file updates that the subagent may have missed or that affect tasks further ahead in the queue. (The orchestrator has the full task graph view; subagents only see their immediate downstream.)

**Step 5 — Advance**
Move to the next pending task and repeat.

### 2c. Final Report

After all tasks complete (or the loop is halted):

```
## Implementation Complete: <feature-slug>

| # | Title | Status | Files Changed |
|---|-------|--------|---------------|
| 01 | <title> | done | N |
| 02 | <title> | done | N |
| 03 | <title> | skipped / failed | — |

Total: N tasks completed, M files created or modified

Suggested next steps:
  /code-review     review all changes before committing
  /prp-commit      commit with a structured message
```
