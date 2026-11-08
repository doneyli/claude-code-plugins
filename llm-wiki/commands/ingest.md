---
description: Compile raw sources into the wiki. Pass a specific file (any supported format) or --new to process anything not yet in log.md or --all to re-ingest everything. Reads supported PDF, image, and text formats directly using Claude's native reading capabilities; source files stay unchanged.
argument-hint: "<path-to-file> | --new | --all"
---

Compile raw sources into the wiki following the workflow in `${CLAUDE_PLUGIN_ROOT}/skills/wiki-compiler/SKILL.md`.

## Step 0 — Read supported sources directly

For each target resolved in Step 1, read the source in place using the Read tool.
Hold its content in memory for Step 2; no intermediate markdown file is needed.

| Source format | How to read it |
|---------------|----------------|
| `.md`, `.txt` | Read the text directly. |
| `.pdf` | Read natively, in requests of up to 20 pages. |
| `.png`, `.jpg`, `.jpeg` | Read with multimodal vision; distinguish visible text from interpretation. |
| `.csv`, `.tsv`, `.json`, `.html`, `.htm`, `.ics`, `.eml` | Read as text and extract the source-supported content relevant to the wiki. |

Keep `raw/` and registered external source files immutable: never write, edit,
rename, move, or replace them. Do not stage conversions elsewhere or bypass the
source-protection hook. Wiki pages cite the original source filename, including
its extension, in `sources:`; use the external-path citation rules in Step 1.
For example, cite `raw/report.pdf`, not a generated markdown substitute.

If a format is not natively readable (for example `.docx`, `.pptx`, audio, or
`.mbox`), warn and skip it: `"Skipping <source-path> — format not supported
natively."` If reading is incomplete, state the coverage limit; do not invent
missing content or claim the whole source was processed.

## Step 1 — Resolve arguments and build file list

Parse `$ARGUMENTS`:

- **If a specific file path**: ingest that single file. Can be under `raw/` OR under any registered source directory. Can be `.md` or any natively-readable format.
- **If `--new` or empty**: collect files from TWO places, then filter to new-only:
  1. **sources.yaml** (if it exists): read each source entry, glob files matching `pattern` under `path`. These are external project files — read in-place, never copy.
  2. **raw/** (if it exists): list all files (any extension).
  3. Filter: keep only files NOT already referenced in `wiki/log.md` (grep for `Ingested <filepath>` — match on the full path or basename).
- **If `--all`**: same collection from both sources.yaml + raw/, but skip the log.md filter — process everything.

**Source priority:** process sources.yaml entries first (in order listed), then raw/. This way the user's curated source directories are ingested before ad-hoc drops.

**Citing sources from external directories:** when a file comes from a registered source (not raw/), cite it in the wiki page's `sources:` frontmatter using the full path relative to the wiki root, or the absolute path if outside the wiki tree. For example:
- File at `~/content-system/.claude/research/pain-points.md` → `sources: [~/content-system/.claude/research/pain-points.md]`
- File at `raw/notes.md` → `sources: [raw/notes.md]`

## Step 2 — For each file to ingest

1. Read `CLAUDE.md`, `wiki/index.md`, `wiki/log.md` — then read the raw file.
   - For `.md` and text files: read normally.
   - For `.pdf`: use Read tool (it handles PDFs natively, up to 20 pages at a time).
   - For `.png`/`.jpg`: use Read tool (multimodal — you'll see the image).
   - For `.csv`/`.json`/`.html`/`.ics`/`.eml`: use Read tool (text formats).
2. Extract 3-5 key takeaways from the source.
3. Identify which existing wiki pages this source touches. Update them additively, preserving existing content.
4. Create new entity/concept/theme pages only where the source supports real content (more than single-mentions).
5. Maintain `[[wikilinks]]` and `## Backlinks` sections.
6. Update `wiki/index.md` — add new pages under the correct `## <Type>` section with a one-line summary.
7. Append a dated entry to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <source title>
   - Ingested raw/<filename>
   - Pages touched: [[a]], [[b]]
   - New pages: [[c]]
   - Notes: <key facts, stats, contradictions found>
   ```

## Hard rules (enforced by plugin hooks)

- **Never write to `raw/`.** It is immutable. A PreToolUse hook will block you.
- Every wiki page you create needs valid YAML frontmatter with `title`, `type`, `created`, `last_updated`. A PostToolUse hook will validate.
- Every claim cites a raw file (by its original filename, including extension). No fabrication.
- Pages with type ∈ {entity, concept, theme} need non-empty `sources:`. Synthesis pages may cite wiki pages instead.

## When finished

Print a concise summary:

```
Pages created: [[...]]
Pages updated: [[...]]
Contradictions flagged: [...]
Formats processed: 3 .md, 2 .pdf, 1 .csv
New log entry: "## [DATE] ingest | <title>"
```
