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

> **MANDATORY:** You MUST delegate to the **orchestrator** agent for all-tasks mode. Do NOT implement tasks yourself in a loop — launch the orchestrator and let it coordinate the subagents. This is non-negotiable.

Invoke the **orchestrator** agent with:

- `<plan-dir>`: `.claude/plans/<feature-slug>/`
- `<task-instructions>`: the template below

The orchestrator handles pre-flight validation, the sequential execution loop, downstream propagation, and the final report. See the orchestrator definition for those mechanics.

### Task instruction template

Pass the following as `<task-instructions>` to the orchestrator. The orchestrator substitutes `<NN>` and `<plan-dir>` before handing it to each subagent.

````
You are implementing task <NN> from the plan at <plan-dir>.

Execute the following steps in order. Do not skip any step.

## 1. Mark In-Progress
Update `task-<NN>.md` frontmatter: set `status: in-progress`.
Update the corresponding row in `_index.md` to `in-progress`.

## 2. Implement with TDD
Apply the tdd-workflow to implement this task using its acceptance criteria as the test target:
1. RED   — Write failing tests that cover each acceptance criterion
2. GREEN — Write the minimum implementation to make all tests pass
3. REFACTOR — Clean up without breaking tests
4. VERIFY — Run type-check and lint; resolve any issues

## 3. Mark Done
Update `task-<NN>.md`:
- Set `status: done` in frontmatter
- Append this section at the end of the file:

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

## 4. Update Downstream Tasks
Scan all task files with `status: pending` or `status: in-progress` that have a task number greater than <NN>.

For each downstream task, compare its Context and Acceptance Criteria sections against the Interface changes you recorded in step 3.

If any interface, file path, type name, or data structure you introduced or changed affects a downstream task:
- Update the Context section of that downstream task file to reflect the actual implementation
- Prepend a notice at the top of the affected section:
  > Updated after task <NN>: <brief reason>
- Do NOT alter the task's Goal or Acceptance Criteria unless a criterion has become impossible or redundant. If so, annotate with a strikethrough and a note — never delete silently.

When done, output a short summary:
- Task status (done / failed)
- Tests written and passing
- Files changed
- Downstream tasks updated (or "none")
- Any deviations from the plan
````

After the orchestrator's final report, append:

```
Suggested next steps:
  /code-review     review all changes before committing
  /prp-commit      commit with a structured message
```
