#!/usr/bin/env bash
set -euo pipefail

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

parse_manifest() {
  python3 -c "
import json, sys, os
with open(os.path.join(sys.argv[1], 'manifest.json')) as f:
    for entry in json.load(f):
        print('\t'.join([entry['name'], entry['type'], entry['source'], entry['target']]))
" "$1"
}

# --- Core uninstall logic ---

removed=0
skipped=0

uninstall_components() {
  local repo_root="$1"

  while IFS=$'\t' read -r name type source target; do
    local abs_source="$repo_root/$source"
    local abs_target="${target/\$HOME/$HOME}"

    if [[ -L "$abs_target" ]]; then
      local current
      current="$(readlink "$abs_target")"
      if [[ "$current" == "$abs_source" ]]; then
        rm "$abs_target"
        printf "  removed  %s (%s)\n" "$name" "$type"
        removed=$((removed + 1))
      else
        printf "  skip  %s — symlink points elsewhere: %s\n" "$name" "$current"
        skipped=$((skipped + 1))
      fi
    elif [[ -e "$abs_target" ]]; then
      printf "  skip  %s — not a symlink, leaving untouched: %s\n" "$name" "$abs_target"
      skipped=$((skipped + 1))
    else
      printf "  skip  %s — not installed\n" "$name"
      skipped=$((skipped + 1))
    fi
  done < <(parse_manifest "$repo_root")
}

# --- Main ---

main() {
  local repo_root
  if repo_root="$(resolve_repo_root)"; then
    echo "Uninstalling agent-skills from $repo_root ..."
    uninstall_components "$repo_root"
    echo ""
    echo "Summary: $removed removed, $skipped skipped"
  else
    echo "Error: not running from a local clone."
    exit 1
  fi
}

main "$@"
