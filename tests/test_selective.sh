#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/tests/test_helper.sh"

echo "=== Selective Install Tests ==="

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

run_install() {
  local home="$1"; shift
  HOME="$home" bash "$REPO_ROOT/install.sh" "$@" 2>&1
}

# --- --only skills ---
H1="$SANDBOX/h1"; mkdir -p "$H1"
OUTPUT=$(run_install "$H1" --only skills)

TEST_NAME="--only skills installs skill components"
assert_symlink "$H1/.cursor/skills/commit-changes"

TEST_NAME="--only skills does NOT install agents"
assert_not_exists "$H1/.cursor/agents/orchestrator.md"

TEST_NAME="--only skills does NOT install commands"
assert_not_exists "$H1/.cursor/commands/plan-tasks.md"

# --- --only agents ---
H2="$SANDBOX/h2"; mkdir -p "$H2"
run_install "$H2" --only agents > /dev/null

TEST_NAME="--only agents installs agent components"
assert_symlink "$H2/.cursor/agents/orchestrator.md"

TEST_NAME="--only agents does NOT install skills"
assert_not_exists "$H2/.cursor/skills/commit-changes"

# --- --only commands ---
H3="$SANDBOX/h3"; mkdir -p "$H3"
run_install "$H3" --only commands > /dev/null

TEST_NAME="--only commands installs command components"
assert_symlink "$H3/.cursor/commands/plan-tasks.md"

TEST_NAME="--only commands does NOT install skills"
assert_not_exists "$H3/.cursor/skills/commit-changes"

# --- --only <name> (single component) ---
H4="$SANDBOX/h4"; mkdir -p "$H4"
run_install "$H4" --only commit-changes > /dev/null

TEST_NAME="--only commit-changes installs that single skill"
assert_symlink "$H4/.cursor/skills/commit-changes"

TEST_NAME="--only commit-changes does NOT install other skills"
assert_not_exists "$H4/.cursor/skills/tdd-workflow"

# --- --list ---
H5="$SANDBOX/h5"; mkdir -p "$H5"
run_install "$H5" > /dev/null 2>&1
OUTPUT_LIST=$(run_install "$H5" --list)

TEST_NAME="--list shows component names"
assert_contains "$OUTPUT_LIST" "commit-changes"

TEST_NAME="--list shows type column"
assert_contains "$OUTPUT_LIST" "skill"

TEST_NAME="--list shows installed status"
assert_contains "$OUTPUT_LIST" "installed"

# --- --list with filter ---
OUTPUT_LIST2=$(run_install "$H5" --only skills --list)

TEST_NAME="--list --only skills shows only skills"
if echo "$OUTPUT_LIST2" | grep -v '^NAME\|^----' | grep -v 'skill' | grep -qE 'agent|command'; then
  fail "non-skill types in filtered list"
else
  pass
fi

# --- --help ---
OUTPUT_HELP=$(run_install "$H5" --help)

TEST_NAME="--help prints usage info"
assert_contains "$OUTPUT_HELP" "Usage"

TEST_NAME="--help documents --only flag"
assert_contains "$OUTPUT_HELP" "--only"

TEST_NAME="--help documents --update flag"
assert_contains "$OUTPUT_HELP" "--update"

TEST_NAME="--help documents --list flag"
assert_contains "$OUTPUT_HELP" "--list"

# --- --update (functional test with git repo) ---
BARE="$SANDBOX/bare.git"
git clone --bare "$REPO_ROOT" "$BARE" > /dev/null 2>&1
CLONE="$SANDBOX/clone"
git clone "$BARE" "$CLONE" > /dev/null 2>&1

H6="$SANDBOX/h6"; mkdir -p "$H6"
OUTPUT_UPDATE=$(HOME="$H6" bash "$CLONE/install.sh" --update 2>&1)

TEST_NAME="--update pulls latest"
assert_contains "$OUTPUT_UPDATE" "Updating"

TEST_NAME="--update installs components"
assert_symlink "$H6/.cursor/skills/commit-changes"

report
