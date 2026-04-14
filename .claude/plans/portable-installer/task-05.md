---
task: "05"
title: "Add selective install and update commands"
status: done
complexity: Medium
depends_on: ["02"]
---

# Task 05: Add selective install and update commands

## Goal
Users can install only specific components, list available components, and update their installation with simple flags.

## Context
- `install.sh` (from Task 02) installs everything by default
- The manifest has `type` fields (skill, agent, command) that can be used for filtering
- Each entry has a `name` for individual selection
- Update means `git pull` in the repo + re-run install to pick up new components

## Acceptance Criteria
- [ ] `install.sh --only skills` installs only skill-type components
- [ ] `install.sh --only agents` and `--only commands` work similarly
- [ ] `install.sh --only <name>` installs a single named component (e.g. `--only commit-changes`)
- [ ] `install.sh --update` runs `git pull` in the repo directory and re-links any new components
- [ ] `install.sh --list` shows all available components with their type and install status (installed/not installed)
- [ ] `install.sh --help` prints usage information covering all flags
- [ ] Flags can be combined where it makes sense (e.g. `--only skills --list`)

## Notes
Argument parsing in bash can be done with a simple `while` loop over `$@`. Keep it straightforward — no need for `getopt`. The `--list` command should check whether each target symlink exists and points to the right place.

## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** 2026-04-14

**Files changed:**
- `install.sh` — modified (all flags already wired in task 04, this task verified them)
- `tests/test_selective.sh` — created
- `tests/test_helper.sh` — modified (fixed `assert_contains` to use `grep -qF --`)

**Deviations from plan:**
The flag implementation was done as part of task 04 since the arg parsing and remote detection were intertwined. Task 05 focused on writing comprehensive tests to validate all flags.

**Interface changes:**
None beyond what was documented in task 04.
