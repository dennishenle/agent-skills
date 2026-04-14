---
task: "02"
title: "Create core install script"
status: done
complexity: Medium
depends_on: ["01"]
---

# Task 02: Create core install script

## Goal
A single `install.sh` that reads the manifest and symlinks all components from source to their target directories. Idempotent and cross-platform (macOS + Linux).

## Context
- `manifest.json` (from Task 01) provides the source-to-target mapping
- Current user has symlinks in `~/.cursor/skills/` pointing into this repo clone
- Script should use symlinks (not copies) so updates propagate via `git pull`
- Must work with both bash and zsh on macOS (which ships bash 3.x) and Linux
- Avoid GNU-only flags (e.g. `readlink -f` is not available on stock macOS — use a portable alternative)

## Acceptance Criteria
- [ ] `install.sh` exists at repo root and is executable (`chmod +x`)
- [ ] Reads `manifest.json` to determine what to install and where
- [ ] Creates target directories if they don't exist
- [ ] Creates symlinks from target to source for each component
- [ ] Skips components that are already correctly linked (idempotent)
- [ ] Warns (does not overwrite) if a target path exists and is not a symlink to this repo
- [ ] Works on both macOS and Linux (POSIX-compatible, no GNU-only flags)
- [ ] Prints a summary of what was installed/skipped/warned

## Notes
Use `#!/usr/bin/env bash` shebang. Parse JSON with a lightweight approach — either bundle a tiny parser or use `python3 -c` (available on both macOS and Linux) to avoid requiring `jq` as a dependency. Resolve the repo root relative to the script's own location.

## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** 2026-04-14

**Files changed:**
- `install.sh` — created
- `tests/test_install.sh` — created

**Deviations from plan:**
None.

**Interface changes:**
- `install.sh` is the main entry point. It exposes: `resolve_repo_root()`, `parse_manifest()`, `install_components(repo_root [filter_type] [filter_name])`, and `print_summary()` as sourceable functions.
- JSON parsing uses `python3 -c` — no `jq` dependency.
- The script guards its `main()` behind `[[ "${BASH_SOURCE[0]}" == "$0" ]]` so it can be sourced by other scripts.
- Environment variables: `AGENT_SKILLS_REPO` (repo URL), `AGENT_SKILLS_DIR` (clone dir, default `$HOME/.agent-skills`).
