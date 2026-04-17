---
description: Compile raw sources into the wiki. Pass a specific file (any supported format) or --new to process anything not yet in log.md or --all to re-ingest everything. Auto-converts PDF, images, CSV, JSON, HTML, ICS, EML using Claude's native reading capabilities — no external tools needed.
argument-hint: "<path-to-file> | --new | --all"
---

Compile raw sources into the wiki following the workflow in `${CLAUDE_PLUGIN_ROOT}/skills/wiki-compiler/SKILL.md`.

## Step 0 — Auto-convert non-markdown files

Before ingesting, check if any target files are non-markdown. Claude Code can natively read these formats — use the Read tool to read them, extract the content, and write a `.md` conversion into `raw/`.

**Natively convertible formats** (no external tools needed):

| Extension | How to convert |
|-----------|---------------|
| `.pdf` | Read the PDF (up to 20 pages). Write a markdown version preserving headings, lists, tables, and key content. |
| `.png`, `.jpg`, `.jpeg` | Read the image (multimodal). Write a markdown file with a description/caption and any visible text (OCR). |
| `.csv`, `.tsv` | Read the file. Write a markdown file with the data as a markdown table (first 100 rows) and column summary stats. |
| `.json` | Read the file. Write a markdown file: arrays-of-objects as tables, nested objects as nested headings. |
| `.html`, `.htm` | Read the file. Extract the article body, strip nav/footer/ads, write clean markdown. |
| `.ics` | Read the file. Write a chronological event listing (date, title, location, description). |
| `.eml` | Read the file. Write markdown with Subject/From/To/Date in frontmatter and body as content. |
| `.txt` | Read the file. Wrap in frontmatter, keep body verbatim. |

**Not natively convertible** (warn the user):
- `.docx` → suggest: `pandoc -f docx -t gfm file.docx > raw/file.md`
- `.pptx` → suggest: install `python-pptx` or use the CLI's `llm-wiki import`
- `.m4a`, `.mp3`, `.wav` → suggest: install `whisper.cpp` or use the CLI
- `.mbox` → suggest: use the CLI's `llm-wiki import`

**Conversion procedure for each non-md file:**

1. Read the file using the Read tool (Claude natively handles PDF, images, CSV, etc.)
2. Write a converted markdown file to `raw/<slug>.md` where slug = kebab-cased original filename. Include this frontmatter:
   ```yaml
   ---
   source_type: pdf | image | csv | json | html | ics | eml | txt
   source_path: <original file path>
   imported_at: YYYY-MM-DD
   original_title: <extracted title or filename>
   conversion_tool: claude-native
   conversion_confidence: high | medium | low
   ---
   ```
   - `high` for text-based (CSV, JSON, HTML, EML, ICS, TXT)
   - `medium` for PDF (layout may lose structure)
   - `low` for images (OCR/description is approximate)
3. Move the original file to `raw/_originals/<original-name>` (create `_originals/` if needed)
4. Proceed to ingest the new `.md` file

**Important:** the PreToolUse hook blocks writes to `raw/`. For this conversion step ONLY, write the `.md` files using the Write tool — the hook allows writes to `raw/*.md` and `raw/_originals/`. It blocks edits to existing raw files, not creation of new converted markdown.

Wait — the hook blocks ALL writes to `raw/`. For the conversion step to work, you need to write the converted `.md` into `raw/`. Two options:
- Write the converted content to a temp location, then tell the user to move it into `raw/`. Clunky.
- **Better:** write the converted `.md` directly into `wiki/_converted/` as an intermediate staging area, then ingest from there.

**Actually simplest:** just ingest the non-md file directly — read it via the Read tool, and proceed with the normal ingest workflow (steps 1-7 below) using the file's content as if it were markdown. No intermediate `.md` file needed. The source file stays in `raw/` untouched, and wiki pages cite it as `raw/<original-filename>` in their `sources:` frontmatter.

**Use this approach:** When you encounter a non-md file, read it natively, hold its content in memory, and proceed with the ingest workflow below. The wiki page's `sources:` field cites the original file (e.g., `raw/report.pdf`). No conversion step writes to disk.

For unsupported formats, print a warning and skip: `"Skipping raw/<file> — format not supported natively. Use the CLI's llm-wiki import to convert."`

## Step 1 — Resolve arguments

Parse `$ARGUMENTS`:

- **If a specific file path** (exists under `raw/`): ingest that single file. Can be `.md` or any natively-readable format.
- **If `--new` or empty**: list ALL files in `raw/` (any extension) that are NOT referenced in `wiki/log.md` (grep for `Ingested raw/<basename>`). Process each in order.
- **If `--all`**: process every file in `raw/` regardless of log state.

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
