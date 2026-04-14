---
task: "03"
title: "Add uninstall support"
status: done
complexity: Low
depends_on: ["02"]
---

# Task 03: Add uninstall support

## Goal
An `uninstall.sh` script that cleanly removes only the symlinks created by the installer, leaving everything else untouched.

## Context
- The install script (Task 02) creates symlinks from target directories back to this repo
- Uninstall should read the same `manifest.json` to know what to remove
- Should only remove symlinks that point into this repo's directory — never delete real files or directories
- Follow the same portable shell patterns established in `install.sh`

## Acceptance Criteria
- [ ] `uninstall.sh` exists at repo root and is executable
- [ ] Reads `manifest.json` to determine what to remove
- [ ] Removes symlinks that point to this repo's source paths
- [ ] Does not remove files/directories that are not symlinks pointing to this repo
- [ ] Prints a summary of what was removed and what was skipped
- [ ] Handles the case where some or all symlinks are already gone (no errors)

## Notes
Consider whether this should be a separate script or a `--uninstall` flag on `install.sh`. A separate script is simpler to discover and less error-prone. Keep it as a standalone `uninstall.sh`.

## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** 2026-04-14

**Files changed:**
- `uninstall.sh` — created
- `tests/test_uninstall.sh` — created

**Deviations from plan:**
None.

**Interface changes:**
`uninstall.sh` is a standalone script. Same `resolve_repo_root()` and `parse_manifest()` patterns as `install.sh`.
