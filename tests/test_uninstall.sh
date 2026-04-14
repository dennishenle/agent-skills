#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/tests/test_helper.sh"

echo "=== Uninstall Script Tests ==="

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

FAKE_HOME="$SANDBOX/home"
mkdir -p "$FAKE_HOME"

TEST_NAME="uninstall.sh exists at repo root"
assert_file_exists "$REPO_ROOT/uninstall.sh"

TEST_NAME="uninstall.sh is executable"
if [[ -x "$REPO_ROOT/uninstall.sh" ]]; then pass; else fail "not executable"; fi

# --- Install first, then uninstall ---
HOME="$FAKE_HOME" bash "$REPO_ROOT/install.sh" > /dev/null 2>&1

TEST_NAME="pre-condition: symlinks exist after install"
assert_symlink "$FAKE_HOME/.claude/skills/commit-changes"

OUTPUT=$(HOME="$FAKE_HOME" bash "$REPO_ROOT/uninstall.sh" 2>&1)

TEST_NAME="removes skill symlinks"
assert_not_exists "$FAKE_HOME/.claude/skills/commit-changes"

TEST_NAME="removes agent symlinks"
assert_not_exists "$FAKE_HOME/.claude/agents/orchestrator.md"

TEST_NAME="removes command symlinks"
assert_not_exists "$FAKE_HOME/.claude/commands/plan-tasks.md"

TEST_NAME="prints summary"
assert_contains "$OUTPUT" "removed"

# --- Does not remove non-symlink files ---
SAFE_HOME="$SANDBOX/safe_home"
mkdir -p "$SAFE_HOME/.claude/skills"
echo "real content" > "$SAFE_HOME/.claude/skills/commit-changes"

OUTPUT2=$(HOME="$SAFE_HOME" bash "$REPO_ROOT/uninstall.sh" 2>&1)

TEST_NAME="does not remove real files (non-symlinks)"
if [[ -f "$SAFE_HOME/.claude/skills/commit-changes" ]]; then pass; else fail "real file was deleted"; fi

TEST_NAME="reports skipped non-symlinks"
assert_contains "$OUTPUT2" "skip"

# --- Handles already-gone symlinks ---
GONE_HOME="$SANDBOX/gone_home"
mkdir -p "$GONE_HOME/.claude/skills"

OUTPUT3=$(HOME="$GONE_HOME" bash "$REPO_ROOT/uninstall.sh" 2>&1)

TEST_NAME="handles missing targets without error"
assert_contains "$OUTPUT3" "skip"

report
