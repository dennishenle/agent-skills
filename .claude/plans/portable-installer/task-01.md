---
task: "01"
title: "Create installation manifest"
status: done
complexity: Low
depends_on: []
---

# Task 01: Create installation manifest

## Goal
A single `manifest.json` at the repo root that declares every installable component — its type, source path, and default target path.

## Context
Current repo structure:
- `skills/commit-changes/SKILL.md`
- `skills/create-pull-request/SKILL.md`
- `skills/tdd-workflow/SKILL.md`
- `agents/orchestrator.md`
- `agents/planner.md`
- `commands/plan-tasks.md`
- `commands/implement.md`

Skills install to `~/.cursor/skills/<name>` as directories (symlinked).
Agents and commands likely target a project-level `.cursor/` directory or a global equivalent — the manifest should use `~/.cursor/agents/` and `~/.cursor/commands/` as defaults but these targets may need adjusting.

## Acceptance Criteria
- [ ] `manifest.json` exists at repo root
- [ ] Every skill, agent, and command in the repo has an entry
- [ ] Each entry specifies: `name`, `type` (skill|agent|command), `source` (relative path), `target` (default install path using `$HOME`)
- [ ] JSON is valid and parseable by `jq`

## Notes
Keep the manifest format simple — flat array of objects. The install script will iterate over entries. Use `$HOME` rather than `~` in target paths since tilde expansion doesn't happen in JSON strings parsed by shell tools.

## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** 2026-04-14

**Files changed:**
- `manifest.json` — created
- `tests/test_helper.sh` — created
- `tests/test_manifest.sh` — created

**Deviations from plan:**
None.

**Interface changes:**
Manifest format is a flat JSON array with objects containing: `name` (string), `type` ("skill"|"agent"|"command"), `source` (relative path), `target` (path using `$HOME`). Skills point to directories, agents and commands point to individual `.md` files.
