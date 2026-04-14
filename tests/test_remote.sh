#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/tests/test_helper.sh"

echo "=== Remote Install Tests ==="

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

FAKE_HOME="$SANDBOX/home"
mkdir -p "$FAKE_HOME"

TEST_NAME="install.sh defines remote_install function"
if bash -c "source '$REPO_ROOT/install.sh' && type remote_install" > /dev/null 2>&1; then
  pass
else
  fail "remote_install function not found"
fi

TEST_NAME="remote mode checks for git availability"
if grep -q 'command -v git' "$REPO_ROOT/install.sh"; then
  pass
else
  fail "no git availability check found"
fi

TEST_NAME="remote mode contains git clone logic"
if grep -q 'git clone' "$REPO_ROOT/install.sh"; then
  pass
else
  fail "no git clone logic found"
fi

TEST_NAME="remote mode contains git pull logic"
if grep -q 'git .*pull' "$REPO_ROOT/install.sh"; then
  pass
else
  fail "no git pull logic found"
fi

TEST_NAME="AGENT_SKILLS_DIR env var is referenced"
if grep -q 'AGENT_SKILLS_DIR' "$REPO_ROOT/install.sh"; then
  pass
else
  fail "AGENT_SKILLS_DIR not referenced"
fi

# --- Functional test: simulate remote install with a local bare repo ---
BARE_REPO="$SANDBOX/bare.git"
git clone --bare "$REPO_ROOT" "$BARE_REPO" > /dev/null 2>&1

CLONE_TARGET="$SANDBOX/cloned"

OUTPUT=$(AGENT_SKILLS_REPO="$BARE_REPO" AGENT_SKILLS_DIR="$CLONE_TARGET" HOME="$FAKE_HOME" \
  bash -c 'source "'"$REPO_ROOT"'/install.sh"; remote_install' 2>&1)

TEST_NAME="remote mode clones repo to AGENT_SKILLS_DIR"
if [[ -d "$CLONE_TARGET/.git" ]]; then pass; else fail "clone dir not created at $CLONE_TARGET"; fi

TEST_NAME="remote mode installs components after cloning"
assert_symlink "$FAKE_HOME/.cursor/skills/commit-changes"

# --- Re-run: should pull instead of re-clone ---
rm -f "$FAKE_HOME/.cursor/skills/commit-changes"
OUTPUT2=$(AGENT_SKILLS_REPO="$BARE_REPO" AGENT_SKILLS_DIR="$CLONE_TARGET" HOME="$FAKE_HOME" \
  bash -c 'source "'"$REPO_ROOT"'/install.sh"; remote_install' 2>&1)

TEST_NAME="second remote run pulls instead of cloning"
assert_contains "$OUTPUT2" "Updating"

TEST_NAME="second remote run still installs components"
assert_symlink "$FAKE_HOME/.cursor/skills/commit-changes"

report
