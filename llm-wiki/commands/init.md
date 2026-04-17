---
description: Scaffold a new LLM wiki in the current directory. Creates raw/, wiki/{entities,concepts,themes,comparisons,synthesis}, wiki/index.md, wiki/log.md, and a CLAUDE.md schema.
argument-hint: "[domain-title]"
---

Scaffold a Karpathy-style LLM wiki in the current working directory.

Steps:

1. Check that the current directory is either empty or contains only a `.git/`. If it has existing content beyond that, warn the user and ask before proceeding.

2. Create the directory structure:
   - `raw/`
   - `wiki/`
   - `wiki/entities/`
   - `wiki/concepts/`
   - `wiki/themes/`
   - `wiki/comparisons/`
   - `wiki/synthesis/`

3. Write `wiki/index.md` with empty category sections:
   ```markdown
   # Wiki Index

   ## Entities
   _No pages yet._

   ## Concepts
   _No pages yet._

   ## Themes
   _No pages yet._

   ## Comparisons
   _No pages yet._

   ## Synthesis
   _No pages yet._
   ```

4. Write `wiki/log.md`:
   ```markdown
   # Wiki Log

   Append-only. Format: `## [YYYY-MM-DD] <op> | <title>` where op ∈ {ingest, query, lint}.
   ```

5. Copy the schema template from `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md` to the current directory. If an argument was given (`$1`), substitute the `{{DOMAIN_TITLE}}` placeholder with it. Otherwise use "Research".

6. Create a `.gitignore` that excludes `raw/_originals/`.

7. Print a summary:
   - "Wiki initialized at $(pwd)"
   - "Next: drop a markdown file into raw/ then run /llm-wiki:ingest <filename>"
   - "Or: /llm-wiki:ingest --all to compile every file in raw/"

If `CLAUDE.md` already exists in the current directory, do NOT overwrite it. Report "Wiki already initialized here" and exit.
