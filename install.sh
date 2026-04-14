#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${AGENT_SKILLS_REPO:-https://github.com/dennis-tra/agent-skills.git}"
CLONE_DIR="${AGENT_SKILLS_DIR:-$HOME/.agent-skills}"

# --- Resolve repo root ---

resolve_repo_root() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -d "$script_dir/.git" ]] && [[ -f "$script_dir/manifest.json" ]]; then
      echo "$script_dir"
      return 0
    fi
  fi
  return 1
}

# --- JSON parsing via python3 (no jq dependency) ---

parse_manifest() {
  python3 -c "
import json, sys, os
with open(os.path.join(sys.argv[1], 'manifest.json')) as f:
    for entry in json.load(f):
        print('\t'.join([entry['name'], entry['type'], entry['source'], entry['target']]))
" "$1"
}

# --- Core install logic ---

installed=0
skipped=0
warned=0

install_components() {
  local repo_root="$1"
  shift
  local filter_type="${1:-}"
  local filter_name="${2:-}"

  while IFS=$'\t' read -r name type source target; do
    if [[ -n "$filter_type" ]] && [[ "$filter_type" != "all" ]]; then
      if [[ "$type" != "$filter_type" ]] && [[ "$name" != "$filter_type" ]]; then
        continue
      fi
    fi
    if [[ -n "$filter_name" ]] && [[ "$name" != "$filter_name" ]]; then
      continue
    fi

    local abs_source="$repo_root/$source"
    local abs_target="${target/\$HOME/$HOME}"

    mkdir -p "$(dirname "$abs_target")"

    if [[ -L "$abs_target" ]]; then
      local current
      current="$(readlink "$abs_target")"
      if [[ "$current" == "$abs_source" ]]; then
        printf "  skip  %s (%s already linked)\n" "$name" "$type"
        skipped=$((skipped + 1))
        continue
      else
        printf "  warn  %s — symlink exists but points to %s\n" "$name" "$current"
        warned=$((warned + 1))
        continue
      fi
    elif [[ -e "$abs_target" ]]; then
      printf "  warn  %s — target exists and is not a symlink: %s\n" "$name" "$abs_target"
      warned=$((warned + 1))
      continue
    fi

    ln -s "$abs_source" "$abs_target"
    printf "  installed  %s → %s\n" "$name" "$abs_target"
    installed=$((installed + 1))
  done < <(parse_manifest "$repo_root")
}

print_summary() {
  echo ""
  echo "Summary: $installed installed, $skipped skipped, $warned warnings"
}

# --- Remote install (curl | sh) ---

remote_install() {
  if ! command -v git > /dev/null 2>&1; then
    echo "Error: git is required but not found."
    exit 1
  fi

  if [[ -d "$CLONE_DIR/.git" ]]; then
    echo "Updating existing clone at $CLONE_DIR ..."
    git -C "$CLONE_DIR" pull --ff-only
  else
    echo "Cloning $REPO_URL to $CLONE_DIR ..."
    git clone "$REPO_URL" "$CLONE_DIR"
  fi

  echo "Installing from $CLONE_DIR ..."
  install_components "$CLONE_DIR"
  print_summary
}

# --- List components ---

list_components() {
  local repo_root="$1"
  shift
  local filter_type="${1:-}"

  printf "%-20s %-10s %s\n" "NAME" "TYPE" "STATUS"
  printf "%-20s %-10s %s\n" "----" "----" "------"

  while IFS=$'\t' read -r name type source target; do
    if [[ -n "$filter_type" ]] && [[ "$filter_type" != "all" ]]; then
      if [[ "$type" != "$filter_type" ]] && [[ "$name" != "$filter_type" ]]; then
        continue
      fi
    fi

    local abs_source="$repo_root/$source"
    local abs_target="${target/\$HOME/$HOME}"
    local status="not installed"

    if [[ -L "$abs_target" ]]; then
      local current
      current="$(readlink "$abs_target")"
      if [[ "$current" == "$abs_source" ]]; then
        status="installed"
      else
        status="conflict"
      fi
    elif [[ -e "$abs_target" ]]; then
      status="conflict"
    fi

    printf "%-20s %-10s %s\n" "$name" "$type" "$status"
  done < <(parse_manifest "$repo_root")
}

# --- Update ---

update_install() {
  local repo_root="$1"
  if ! command -v git > /dev/null 2>&1; then
    echo "Error: git is required for --update."
    exit 1
  fi
  echo "Updating repository ..."
  git -C "$repo_root" pull --ff-only
  echo "Re-linking components ..."
  install_components "$repo_root"
  print_summary
}

# --- Usage ---

print_help() {
  cat <<'HELP'
Usage: install.sh [OPTIONS]

Install agent skills, agents, and commands via symlinks.

Options:
  --only <filter>   Install only matching components. <filter> can be:
                      - a type: skills, agents, commands
                      - a component name: commit-changes, orchestrator, etc.
  --list            List available components and their install status
  --update          Pull latest changes and re-link new components
  --help            Show this help message

Examples:
  ./install.sh                       Install everything
  ./install.sh --only skills         Install only skills
  ./install.sh --only commit-changes Install a single component
  ./install.sh --list                Show available components
  ./install.sh --update              Update and re-link

Remote install (no clone required):
  curl -fsSL https://raw.githubusercontent.com/dennis-tra/agent-skills/main/install.sh | sh
HELP
}

# --- Main ---

main() {
  local action="install"
  local filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --only)
        filter="${2:-}"
        if [[ -z "$filter" ]]; then
          echo "Error: --only requires an argument"
          exit 1
        fi
        shift 2
        ;;
      --list)
        action="list"
        shift
        ;;
      --update)
        action="update"
        shift
        ;;
      --help|-h)
        print_help
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        print_help
        exit 1
        ;;
    esac
  done

  local repo_root
  if repo_root="$(resolve_repo_root)"; then
    case "$action" in
      list)
        list_components "$repo_root" "$filter"
        ;;
      update)
        update_install "$repo_root"
        ;;
      install)
        echo "Installing from $repo_root ..."
        # Normalize type filter: strip trailing 's' from plural forms
        local type_filter="$filter"
        case "$filter" in
          skills)   type_filter="skill" ;;
          agents)   type_filter="agent" ;;
          commands) type_filter="command" ;;
        esac
        install_components "$repo_root" "$type_filter"
        print_summary
        ;;
    esac
  else
    remote_install
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
