#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/tests/test_helper.sh"

echo "=== Install Script Tests ==="

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

FAKE_HOME="$SANDBOX/home"
mkdir -p "$FAKE_HOME"

TEST_NAME="install.sh exists at repo root"
assert_file_exists "$REPO_ROOT/install.sh"

TEST_NAME="install.sh is executable"
if [[ -x "$REPO_ROOT/install.sh" ]]; then pass; else fail "not executable"; fi

# --- Run the installer with HOME overridden into sandbox ---
run_install() {
  HOME="$FAKE_HOME" bash "$REPO_ROOT/install.sh" "$@" 2>&1
}

OUTPUT=$(run_install)

TEST_NAME="creates target directories"
if [[ -d "$FAKE_HOME/.claude/skills" ]] && [[ -d "$FAKE_HOME/.claude/commands" ]]; then
  pass
else
  fail "target directories not created"
fi

TEST_NAME="creates symlink for skill: commit-changes"
assert_symlink "$FAKE_HOME/.claude/skills/commit-changes"

TEST_NAME="skill symlink points to correct source"
assert_symlink_target "$FAKE_HOME/.claude/skills/commit-changes" "$REPO_ROOT/skills/commit-changes"

TEST_NAME="creates symlink for command: plan-tasks.md"
assert_symlink "$FAKE_HOME/.claude/commands/plan-tasks.md"

TEST_NAME="prints summary output"
assert_contains "$OUTPUT" "install"

# --- Idempotency test: run again, should skip ---
OUTPUT2=$(run_install)

TEST_NAME="second run is idempotent (skips already-linked)"
assert_contains "$OUTPUT2" "skip"

# --- Conflict test: real file at target ---
CONFLICT_HOME="$SANDBOX/conflict_home"
mkdir -p "$CONFLICT_HOME/.claude/skills"
echo "real file" > "$CONFLICT_HOME/.claude/skills/commit-changes"

OUTPUT3=$(HOME="$CONFLICT_HOME" bash "$REPO_ROOT/install.sh" 2>&1 || true)

TEST_NAME="warns on conflict (target exists but is not our symlink)"
assert_contains "$OUTPUT3" "warn"

report
