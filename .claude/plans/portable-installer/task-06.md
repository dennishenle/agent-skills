---
task: "06"
title: "Update README with installation docs"
status: done
complexity: Low
depends_on: ["01", "02", "03", "04", "05"]
---

# Task 06: Update README with installation docs

## Goal
The README documents all installation methods clearly, replacing the current manual `cp -r` instructions, and the component inventory matches the current repo contents.

## Context
- Current `README.md` has a basic "Installation" section with `cp -r` commands
- References `incremental-planning` and `incremental-planning-follow` skills that no longer exist in the repo
- Needs to document: one-liner install, local install, selective install, update, uninstall
- Should also list agents and commands, not just skills

## Acceptance Criteria
- [ ] README lists one-liner `curl | sh` install command prominently
- [ ] Documents local install (`./install.sh`), selective install (`--only`), update (`--update`), list (`--list`), and uninstall (`./uninstall.sh`)
- [ ] Skill/agent/command inventory matches current repo contents (removes stale references)
- [ ] Notes macOS/Linux support and Windows limitation
- [ ] Includes an "Uninstall" section

## Notes
Keep the README concise. The install command should be copy-pasteable. Consider adding a short "What gets installed where" table so users know what to expect before running the script.

## Implementation Notes
<!-- Added by /implement after completion -->

**Completed:** 2026-04-14

**Files changed:**
- `README.md` — modified
- `tests/test_readme.sh` — created

**Deviations from plan:**
None.

**Interface changes:**
None (documentation only).
