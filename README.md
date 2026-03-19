# Incremental Planning Skill

A pair of [Cursor Agent Skills](https://docs.cursor.com/context/skills) that enforce an **incremental planning-then-executing workflow** for complex, multi-step tasks. Work is broken into discrete task files so you can review, ask questions, and approve each step before the AI begins implementation.

## How It Works

The workflow has two phases, each handled by its own skill:

### Phase 1 — Plan (`incremental-planning`)

When you describe a goal, the agent **does not implement anything**. Instead it:

1. Creates an `AGENT/` directory with a `PLAN.md` overview.
2. Generates a `TASK_<N>.md` file for each step, containing a description, acceptance criteria, and any open questions.
3. Sets `UPCOMING_TASK.md` to point at the first task.
4. Stops and waits for your review.

### Phase 2 — Execute (`incremental-planning-follow`)

When you say "continue", "implement the next task", or similar, the agent:

1. Reads `UPCOMING_TASK.md` to find the current task.
2. Implements **only** that single task.
3. Renames the task file to `TASK_<N>_DONE.md` and advances the pointer.
4. Stops and waits for your review before moving on.

This cycle repeats until all tasks are complete.

## File Structure

After planning, your project will contain:

```text
AGENT/
├── PLAN.md            # High-level overview of all steps
├── UPCOMING_TASK.md   # Points to the next task to execute
├── TASK_1.md          # Detailed description of step 1
├── TASK_2.md          # Detailed description of step 2
├── ...
```

As tasks are completed, they are renamed (e.g. `TASK_1.md` → `TASK_1_DONE.md`).

## Installation

Clone this repository and copy the skills into your cursor directory:

```bash
cp -r ~/.cursor/skills/incremental-planning-skill/incremental-planning ~/.cursor/skills/incremental-planning
cp -r ~/.cursor/skills/incremental-planning-skill/incremental-planning-follow ~/.cursor/skills/incremental-planning-follow
```

Cursor will automatically detect the skills from the `SKILL.md` files inside each subdirectory.

## Skills Reference

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `incremental-planning` | User asks to plan, break down, or implement a complex feature | Creates the `AGENT/` directory with a plan and task files |
| `incremental-planning-follow` | User asks to continue, proceed, or work on the next step | Executes a single task and advances the plan |

## License

MIT
