# Agent Skills

A collection of [Cursor Agent Skills](https://docs.cursor.com/context/skills) that extend the AI agent with reusable, opinionated workflows.

## Skills

### `commit-changes`

Analyzes uncommitted changes, generates a [Conventional Commits](https://www.conventionalcommits.org/) message, commits, and pushes to origin. Prevents accidental commits to `main`/`master` by prompting for a branch name first.

### `incremental-planning`

Enforces a **plan-then-execute** workflow for complex tasks. The agent creates an `AGENT/` directory with a `PLAN.md` overview and individual `TASK_<N>.md` files. Nothing is implemented until you review and approve. Paired with `incremental-planning-follow` for execution.

### `incremental-planning-follow`

Executes one task at a time from a plan created by `incremental-planning`. After each task the agent marks it done, advances the pointer in `UPCOMING_TASK.md`, and stops for your review before moving on.

## Installation

Clone the repository and copy the skills you want into your Cursor skills directory:

```bash
# copy a single skill
cp -r <skill-directory> ~/.cursor/skills/<skill-directory>

# or copy all skills at once
cp -r commit-changes incremental-planning incremental-planning-follow ~/.cursor/skills/
```

Cursor automatically detects skills from the `SKILL.md` file inside each directory.

## License

MIT
