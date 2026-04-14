#!/usr/bin/env bash
set -euo pipefail

PASS_COUNT=0
FAIL_COUNT=0
TEST_NAME=""

pass() { ((PASS_COUNT++)); printf "  ✓ %s\n" "$TEST_NAME"; }
fail() { ((FAIL_COUNT++)); printf "  ✗ %s — %s\n" "$TEST_NAME" "$1"; }

assert_eq() {
  if [[ "$1" == "$2" ]]; then pass; else fail "expected '$2', got '$1'"; fi
}

assert_contains() {
  if echo "$1" | grep -q "$2"; then pass; else fail "'$2' not found in output"; fi
}

assert_file_exists() {
  if [[ -f "$1" ]]; then pass; else fail "file '$1' does not exist"; fi
}

assert_symlink() {
  if [[ -L "$1" ]]; then pass; else fail "'$1' is not a symlink"; fi
}

assert_symlink_target() {
  if [[ -L "$1" ]] && [[ "$(readlink "$1")" == "$2" ]]; then
    pass
  else
    fail "'$1' does not symlink to '$2' (actual: $(readlink "$1" 2>/dev/null || echo 'not a link'))"
  fi
}

assert_not_exists() {
  if [[ ! -e "$1" ]]; then pass; else fail "'$1' should not exist"; fi
}

assert_exit_code() {
  if [[ "$1" -eq "$2" ]]; then pass; else fail "exit code $1, expected $2"; fi
}

report() {
  echo ""
  local total=$((PASS_COUNT + FAIL_COUNT))
  echo "Results: $PASS_COUNT/$total passed"
  if [[ $FAIL_COUNT -gt 0 ]]; then
    echo "FAILED"
    return 1
  else
    echo "OK"
    return 0
  fi
}
