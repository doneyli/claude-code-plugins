#!/usr/bin/env bash
# PreToolUse hook: block any Write/Edit/MultiEdit targeting a file under raw/
# inside an llm-wiki directory. Raw sources are immutable.
#
# Receives JSON on stdin with tool_input.file_path. Exit 0 to allow;
# exit 2 with a stderr message to block with a user-visible reason.

set -euo pipefail

# Only care when we're inside a wiki (CLAUDE.md + wiki/ sibling)
# Find wiki root by walking up from cwd
find_wiki_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/CLAUDE.md" ]] && [[ -d "$dir/wiki" ]]; then
      echo "$dir"; return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

WIKI_ROOT="$(find_wiki_root || true)"
[[ -z "$WIKI_ROOT" ]] && exit 0   # not inside a wiki — nothing to guard

# Parse the tool input JSON
input="$(cat)"
file_path="$(printf '%s' "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except (json.JSONDecodeError, KeyError):
    pass
" 2>/dev/null || echo "")"

[[ -z "$file_path" ]] && exit 0

# Resolve to absolute path for comparison
abs_path="$file_path"
[[ "$abs_path" != /* ]] && abs_path="$PWD/$abs_path"

# Normalize (no shell realpath dependency; good enough for this check)
raw_root="$WIKI_ROOT/raw"

# Allow writes to raw/_originals/ (conversion staging area)
case "$abs_path" in
  "$raw_root/_originals"|"$raw_root/_originals"/*) exit 0 ;;
esac

# Block writes under raw/ (any depth) — raw sources are immutable
case "$abs_path" in
  "$raw_root"|"$raw_root"/*)
    printf '{"decision":"block","reason":"llm-wiki: writes to raw/ are blocked. Raw sources are immutable. Write to wiki/ instead."}' >&2
    exit 2
    ;;
esac

exit 0
