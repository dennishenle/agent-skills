---
description: Create a structured implementation plan with individual task files per task. Saves approved plan to .claude/plans/<feature-slug>/. Use /implement to execute tasks.
argument-hint: <feature-description>
---

# Plan Tasks Command

Creates an implementation plan and saves each task as a separate Markdown file so they can be executed incrementally (or all at once) with `/implement`.

## Phase 1 — PLAN

Invoke the **planner** agent with the full feature description: `$ARGUMENTS`

The planner must produce:
- **Requirements restatement** — what exactly is being built
- **Risk assessment** — potential blockers, unknowns, and edge cases
- **Ordered task breakdown** — each task represents a focused, independently testable unit of work

Each task in the breakdown must include:
- **Title** — short imperative phrase (e.g. "Add user model and migration")
- **Goal** — one or two sentences describing what "done" looks like
- **Context** — relevant existing files, patterns, and interfaces to follow
- **Acceptance criteria** — verifiable checklist items
- **Dependencies** — which prior task numbers must be complete first (empty list if none)
- **Estimated complexity** — Low / Medium / High

Tasks should be sized so each one is independently implementable in a focused session. Avoid tasks that are too coarse (entire subsystems) or too fine (single-line changes).

---

## Phase 2 — PRESENT AND AWAIT CONFIRMATION

Present the complete plan to the user clearly, formatted as:

```
# Plan: <Feature Name>

## Summary
<1–3 sentences>

## Risks
- <risk 1>
- <risk 2>

## Tasks

### Task 01: <Title>  [Low | Medium | High]
**Goal:** <goal>
**Depends on:** none | tasks 01, 02
**Context:** <relevant files and patterns>
**Acceptance criteria:**
- [ ] <criterion>

### Task 02: ...
```

Then display:

```
WAITING FOR CONFIRMATION
Proceed with saving this plan? (yes / no / modify: <your changes>)
```

**Do not write any files until the user responds.**

If the user requests modifications (`modify: ...`), regenerate the affected parts of the plan and re-present. Repeat until the user confirms with "yes", "proceed", or equivalent affirmative.

---

## Phase 3 — SAVE PLAN FILES

On confirmation, derive `<feature-slug>` from the feature description:
- lowercase, kebab-case
- strip stop words and punctuation
- max 40 characters
- Example: "Add real-time notifications for market resolution" → `realtime-market-notifications`

Create the plan directory: `.claude/plans/<feature-slug>/`

### File: `_index.md`

```markdown
---
feature: <Full Feature Name>
slug: <feature-slug>
created: <YYYY-MM-DD>
status: pending
---

# <Full Feature Name>

## Summary
<1–3 sentence description>

## Risks
<bullet list>

## Tasks

| # | Title | Status | Complexity | Depends On |
|---|-------|--------|------------|------------|
| 01 | <title> | pending | Low | — |
| 02 | <title> | pending | Medium | 01 |
```

### File: `task-NN.md` (one file per task, zero-padded to two digits)

```markdown
---
task: "NN"
title: "<Task Title>"
status: pending
complexity: Low | Medium | High
depends_on: []
---

# Task NN: <Title>

## Goal
<What "done" looks like for this task.>

## Context
<Relevant files, interfaces, naming conventions, and patterns to follow.
Be specific — list file paths and function names where known.>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

## Notes
<Warnings, gotchas, design decisions, or open questions flagged by the planner.
Leave blank if none.>
```

---

## Phase 4 — REPORT

After writing all files, report:

```
Plan saved: .claude/plans/<feature-slug>/

  _index.md        overview and task table
  task-01.md       <title>
  task-02.md       <title>
  ...

Run:
  /implement <feature-slug> 1      implement a single task
  /implement <feature-slug> all    implement all tasks sequentially
```
