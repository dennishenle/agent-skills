# Agent Skills

A collection of [Cursor Agent Skills](https://docs.cursor.com/context/skills), agents, and commands that extend the AI agent with reusable, opinionated workflows.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/dennis-tra/agent-skills/main/install.sh | bash
```

This clones the repo to `~/.agent-skills` and symlinks all components into your Cursor directories. Customize the clone location with `AGENT_SKILLS_DIR`:

```bash
AGENT_SKILLS_DIR=~/my-skills curl -fsSL https://raw.githubusercontent.com/dennis-tra/agent-skills/main/install.sh | bash
```

## Local Install

If you already have the repo cloned:

```bash
git clone https://github.com/dennis-tra/agent-skills.git
cd agent-skills
./install.sh
```

### Selective Install

```bash
./install.sh --only skills         # install only skills
./install.sh --only agents         # install only agents
./install.sh --only commands       # install only commands
./install.sh --only commit-changes # install a single component by name
```

### List Components

```bash
./install.sh --list                # show all components and their install status
./install.sh --only skills --list  # show only skills
```

### Update

```bash
./install.sh --update              # git pull + re-link any new components
```

## What Gets Installed

| Component | Type | Installed To |
|-----------|------|-------------|
| commit-changes | skill | `~/.cursor/skills/commit-changes` |
| create-pull-request | skill | `~/.cursor/skills/create-pull-request` |
| tdd-workflow | skill | `~/.cursor/skills/tdd-workflow` |
| orchestrator | agent | `~/.cursor/agents/orchestrator.md` |
| planner | agent | `~/.cursor/agents/planner.md` |
| plan-tasks | command | `~/.cursor/commands/plan-tasks.md` |
| implement | command | `~/.cursor/commands/implement.md` |

All installs use symlinks so updates propagate automatically via `git pull`.

## Components

### Skills

**`commit-changes`** — Analyzes uncommitted changes, generates a [Conventional Commits](https://www.conventionalcommits.org/) message, commits, and pushes to origin. Prevents accidental commits to `main`/`master` by prompting for a branch name first.

**`create-pull-request`** — Opens a GitHub pull request from the current branch into `main` using the `gh` CLI. Ensures the working tree is clean, gathers commit context, and crafts a Conventional Commits-style title with a structured description.

**`tdd-workflow`** — Enforces test-driven development with 80%+ coverage. Guides the agent through RED/GREEN/REFACTOR cycles with git checkpoint commits at each stage.

### Agents

**`orchestrator`** — Runs a sequence of tasks with pre-flight validation, sequential execution via subagents, downstream propagation, and a final report.

**`planner`** — Breaks down a feature description into a structured plan with ordered, dependency-tracked tasks.

### Commands

**`plan-tasks`** — Creates a structured plan for a feature, producing an `_index.md` and individual `task-NN.md` files under `.claude/plans/`.

**`implement`** — Executes tasks from a plan using TDD. Supports single task (`/implement slug N`) and all-tasks mode (`/implement slug all`).

## Uninstall

```bash
./uninstall.sh
```

Removes only the symlinks created by the installer. Real files and directories are left untouched.

## Platform Support

Tested on **macOS** and **Linux**. The install scripts use POSIX-compatible shell constructs and avoid GNU-only flags. Windows is not currently supported (symlink semantics differ).

Requires `bash`, `python3`, and `git`.

## License

MIT
