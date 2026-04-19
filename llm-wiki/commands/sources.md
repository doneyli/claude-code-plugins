---
description: Register external source directories so the wiki can ingest from your existing project folders — no copying into raw/ required. Supports add, list, and remove.
argument-hint: "add <path> [--name N] | list | remove <name>"
---

Manage registered source directories for this wiki. Sources let you point the wiki at folders that already exist in your projects — the wiki reads from them directly without copying files into `raw/`.

## Parse arguments

Split `$ARGUMENTS` into a subcommand:

- `add <path>` — register a new source directory
- `list` — show all registered sources
- `remove <name>` — unregister a source (does NOT delete wiki pages compiled from it)

## Source storage

Sources are stored in `sources.yaml` at the wiki root. Read it if it exists; create it on first `add`.

Schema:

```yaml
sources:
  - name: research          # unique key (derived from path basename if not given)
    path: /absolute/path    # resolved to absolute
    pattern: "**/*.md"      # glob pattern for files to include
  - name: signals
    path: /absolute/path/to/signals
    pattern: "**/*.md"
```

## Subcommand: add

```
/llm-wiki:sources add ~/content-system/.claude/research
/llm-wiki:sources add ~/content-system/ideas/signals --name signals
```

1. Resolve the path to absolute (expand `~`).
2. Verify the directory exists. If not, error: "Directory not found: <path>"
3. Derive a name from the last path component if `--name` wasn't given. If the name already exists in sources.yaml, error: "Source '<name>' already registered. Use a different --name."
4. Detect what file types exist in the directory. Set `pattern` accordingly:
   - Only .md files → `"**/*.md"`
   - Mixed formats (md + pdf + csv + json etc.) → `"**/*"` (Claude can read most formats natively)
5. Read existing `sources.yaml` (or start with `{sources: []}`), append the new entry, write back atomically.
6. Count matching files. Print:
   ```
   Added source 'research' → /Users/doneyli/content-system/.claude/research
   22 files matching pattern **/*.md
   Run /llm-wiki:ingest --all to compile these into the wiki.
   ```

## Subcommand: list

```
/llm-wiki:sources list
```

Read `sources.yaml`. For each entry, count matching files on disk. Print a table:

```
Name         Path                                              Files  Pattern
───────────────────────────────────────────────────────────────────────────────
research     ~/content-system/.claude/research                    22  **/*.md
signals      ~/content-system/ideas/signals                       73  **/*.md
frameworks   ~/content-system/assets/frameworks                   10  **/*.md

3 sources, 105 total files
```

If no sources registered: "No sources registered. Run /llm-wiki:sources add <path>"

## Subcommand: remove

```
/llm-wiki:sources remove signals
```

1. Find the entry by name in `sources.yaml`.
2. Remove it. Write back.
3. Print: "Removed source 'signals'. Wiki pages compiled from it are not deleted."

If name not found: "Source 'signals' not found. Run /llm-wiki:sources list to see registered sources."

## Important

- `sources.yaml` is a YAML file at the wiki root. Use the Write tool to create/update it.
- The paths in sources.yaml are what `/llm-wiki:ingest` reads from. It will iterate files matching the pattern in each registered source directory.
- Sources and `raw/` coexist. If both exist, `ingest --all` processes both. Sources are checked first (by order in the YAML), then `raw/`.
- Do NOT copy files from source directories into `raw/`. The whole point is to read in-place.
