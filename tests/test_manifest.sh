#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/tests/test_helper.sh"

echo "=== Manifest Tests ==="

TEST_NAME="manifest.json exists at repo root"
assert_file_exists "$REPO_ROOT/manifest.json"

TEST_NAME="manifest.json is valid JSON (parseable by jq)"
if jq empty "$REPO_ROOT/manifest.json" 2>/dev/null; then
  pass
else
  fail "jq cannot parse manifest.json"
fi

TEST_NAME="manifest is a JSON array"
TYPE=$(jq -r 'type' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "error")
assert_eq "$TYPE" "array"

TEST_NAME="every entry has required fields: name, type, source, target"
INVALID=$(jq '[.[] | select(.name == null or .type == null or .source == null or .target == null)] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "error")
assert_eq "$INVALID" "0"

TEST_NAME="type field is one of: skill, agent, command"
BAD_TYPES=$(jq '[.[] | select(.type != "skill" and .type != "agent" and .type != "command")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "error")
assert_eq "$BAD_TYPES" "0"

TEST_NAME="contains skill: commit-changes"
HAS=$(jq '[.[] | select(.name == "commit-changes" and .type == "skill")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="contains skill: create-pull-request"
HAS=$(jq '[.[] | select(.name == "create-pull-request" and .type == "skill")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="contains skill: tdd-workflow"
HAS=$(jq '[.[] | select(.name == "tdd-workflow" and .type == "skill")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="contains agent: orchestrator"
HAS=$(jq '[.[] | select(.name == "orchestrator" and .type == "agent")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="contains agent: planner"
HAS=$(jq '[.[] | select(.name == "planner" and .type == "agent")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="contains command: plan-tasks"
HAS=$(jq '[.[] | select(.name == "plan-tasks" and .type == "command")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="contains command: implement"
HAS=$(jq '[.[] | select(.name == "implement" and .type == "command")] | length' "$REPO_ROOT/manifest.json" 2>/dev/null || echo "0")
assert_eq "$HAS" "1"

TEST_NAME="source paths are relative and point to existing files/dirs"
ALL_OK=true
while IFS= read -r src; do
  if [[ ! -e "$REPO_ROOT/$src" ]]; then
    ALL_OK=false
    break
  fi
done < <(jq -r '.[].source' "$REPO_ROOT/manifest.json" 2>/dev/null)
if $ALL_OK; then pass; else fail "source path '$src' does not exist"; fi

TEST_NAME="target paths use \$HOME (not tilde)"
TILDE_COUNT=$(jq -r '.[].target' "$REPO_ROOT/manifest.json" 2>/dev/null | grep -c '^~' || true)
assert_eq "$TILDE_COUNT" "0"

report
