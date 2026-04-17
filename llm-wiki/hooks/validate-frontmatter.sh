#!/usr/bin/env bash
# PostToolUse hook: after a wiki/*.md write, verify YAML frontmatter is valid
# and entity/concept/theme pages cite at least one source. Advisory only —
# we print a warning but do not roll back the write (that would require
# restoring backups, which the plugin isn't set up to do).
#
# Receives JSON on stdin with tool_input.file_path.

set -euo pipefail

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
[[ -z "$WIKI_ROOT" ]] && exit 0

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

abs_path="$file_path"
[[ "$abs_path" != /* ]] && abs_path="$PWD/$abs_path"
wiki_root_dir="$WIKI_ROOT/wiki"

# Only validate files under wiki/*.md
case "$abs_path" in
  "$wiki_root_dir"/*.md|"$wiki_root_dir"/**/*.md) ;;
  *) exit 0 ;;
esac

# Skip log.md — it's append-only prose
[[ "$(basename "$abs_path")" == "log.md" ]] && exit 0
[[ "$(basename "$abs_path")" == "index.md" ]] && exit 0

# Validate via Python (PyYAML optional — fall back to regex)
python3 - "$abs_path" << 'PYEOF'
import sys, re
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as f:
        text = f.read()
except OSError:
    sys.exit(0)

if not text.startswith("---"):
    print(f"llm-wiki WARN: {path} has no YAML frontmatter.", file=sys.stderr)
    sys.exit(0)

end = text.find("\n---", 3)
if end == -1:
    print(f"llm-wiki WARN: {path} frontmatter is unclosed.", file=sys.stderr)
    sys.exit(0)

fm_text = text[3:end]

# Try PyYAML; fall back to simple regex parse
try:
    import yaml
    fm = yaml.safe_load(fm_text) or {}
    if not isinstance(fm, dict):
        fm = {}
except ImportError:
    fm = {}
    for line in fm_text.splitlines():
        if ":" in line:
            k, _, v = line.partition(":")
            fm[k.strip()] = v.strip().strip('"').strip("'")
except Exception:
    print(f"llm-wiki WARN: {path} frontmatter is malformed YAML.", file=sys.stderr)
    sys.exit(0)

required = ("title", "type", "created", "last_updated")
missing = [f for f in required if not fm.get(f)]
if missing:
    print(f"llm-wiki WARN: {path} frontmatter missing: {', '.join(missing)}",
          file=sys.stderr)

page_type = str(fm.get("type", "")).strip()
source_required = {"entity", "concept", "theme", "capability",
                   "narrative", "client", "pattern"}
if page_type in source_required:
    sources = fm.get("sources") or []
    if not sources:
        print(f"llm-wiki WARN: {path} type '{page_type}' requires non-empty sources:",
              file=sys.stderr)

if page_type and page_type not in (source_required | {"synthesis", "comparison",
                                                        "use-case", "benchmark",
                                                        "content-angle", "vertical",
                                                        "engagement", "framework",
                                                        "offering", "anti-pattern"}):
    print(f"llm-wiki WARN: {path} unknown type '{page_type}'.", file=sys.stderr)
PYEOF

exit 0
