---
task: "04"
title: "Add remote one-liner install"
status: done
complexity: Medium
depends_on: ["02"]
---

# Task 04: Add remote one-liner install

## Goal
Users can install with a single `curl | sh` command without manually cloning the repo first.

## Context
- Common pattern: `curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh`
- `install.sh` (from Task 02) currently assumes it's running from a local clone
- Needs to detect whether it's in a local clone vs piped from curl
- If piped, clone the repo to a standard location (e.g. `$HOME/.agent-skills`) then run normal install
- If the clone destination already exists, `git pull` instead of re-cloning

## Acceptance Criteria
- [ ] `install.sh` detects when it's not running from a local clone (no `.git` directory nearby)
- [ ] In remote mode, clones the repo to `$HOME/.agent-skills` (configurable via `AGENT_SKILLS_DIR` env var)
- [ ] If clone destination already exists and is a git repo, pulls latest instead of re-cloning
- [ ] After clone/pull, runs the normal manifest-based install from the cloned location
- [ ] Works when piped: `curl -fsSL <url> | sh`
- [ ] Works when downloaded and run: `curl -fsSL <url> -o install.sh && sh install.sh`

## Notes
When piped via `curl | sh`, `$0` is typically `sh` or `bash` and the script can't resolve its own directory. Use this as the detection heuristic. Also consider that `git` must be available — check and error early if not found. The GitHub repo URL will need to be hardcoded or derived — use a variable at the top of the script for easy forking.

## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** 2026-04-14

**Files changed:**
- `install.sh` — modified (added remote_install, list_components, update_install, print_help, arg parsing)
- `tests/test_remote.sh` — created

**Deviations from plan:**
Tasks 04 and 05 features were implemented together in install.sh since the arg parsing, --list, --update, and --only flags are tightly coupled with the remote detection logic. The remote fallback triggers automatically when resolve_repo_root fails.

**Interface changes:**
- `remote_install()` function added to install.sh (sourceable)
- `list_components(repo_root [filter])` function added
- `update_install(repo_root)` function added
- `print_help()` function added
- `main()` now parses --only, --list, --update, --help flags
- Plural type names (skills, agents, commands) are normalized to singular for filtering
