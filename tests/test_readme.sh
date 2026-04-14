#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/tests/test_helper.sh"

echo "=== README Tests ==="

README="$REPO_ROOT/README.md"
CONTENT=$(cat "$README")

TEST_NAME="README exists"
assert_file_exists "$README"

TEST_NAME="documents curl | sh one-liner install"
assert_contains "$CONTENT" "curl"

TEST_NAME="documents local install (./install.sh)"
assert_contains "$CONTENT" "./install.sh"

TEST_NAME="documents --only flag"
assert_contains "$CONTENT" "--only"

TEST_NAME="documents --update flag"
assert_contains "$CONTENT" "--update"

TEST_NAME="documents --list flag"
assert_contains "$CONTENT" "--list"

TEST_NAME="documents uninstall (./uninstall.sh)"
assert_contains "$CONTENT" "uninstall.sh"

TEST_NAME="lists skill: commit-changes"
assert_contains "$CONTENT" "commit-changes"

TEST_NAME="lists skill: create-pull-request"
assert_contains "$CONTENT" "create-pull-request"

TEST_NAME="lists skill: tdd-workflow"
assert_contains "$CONTENT" "tdd-workflow"

TEST_NAME="lists agents section"
assert_contains "$CONTENT" "orchestrator"

TEST_NAME="lists commands section"
assert_contains "$CONTENT" "plan-tasks"

TEST_NAME="does NOT reference stale incremental-planning skill"
if echo "$CONTENT" | grep -qF "incremental-planning"; then
  fail "stale reference to incremental-planning found"
else
  pass
fi

TEST_NAME="notes macOS/Linux support"
assert_contains "$CONTENT" "macOS"

TEST_NAME="has an Uninstall section"
assert_contains "$CONTENT" "Uninstall"

report
