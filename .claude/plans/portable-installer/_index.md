---
feature: Portable Installer for Agent Skills
slug: portable-installer
created: 2026-04-14
status: done
---

# Portable Installer for Agent Skills

## Summary
Create an install/uninstall system that lets users set up all skills, agents, and commands from this repo on any macOS or Linux system with a single command. A manifest file maps each component to its Cursor target directory, and a shell script handles cloning, symlinking, updating, and removal.

## Risks
- Cursor directory layout may vary across versions — target paths should be configurable in the manifest
- Windows support is unclear — symlinks work differently; scoped to macOS/Linux initially
- Agents and commands may not have a global install path — support both global and per-project targets
- Existing manual installs could conflict — detect and warn about non-symlink targets

## Tasks

| # | Title | Status | Complexity | Depends On |
|---|-------|--------|------------|------------|
| 01 | Create installation manifest | done | Low | — |
| 02 | Create core install script | done | Medium | 01 |
| 03 | Add uninstall support | done | Low | 02 |
| 04 | Add remote one-liner install | done | Medium | 02 |
| 05 | Add selective install and update commands | done | Medium | 02 |
| 06 | Update README with installation docs | done | Low | 01, 02, 03, 04, 05 |
