# llm-wiki — Claude Code plugin

An implementation of Andrej Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern, packaged as a Claude Code plugin. The architecture — immutable sources curated by a human, compiled `wiki/` pages maintained by an LLM, with ingest/query/lint as the three core operations — is based on Karpathy's original gist. This plugin makes it runnable in two commands with no install beyond Claude Code itself.

## What it gives you

- `wiki-compiler` **skill** — the "compiler" knowledge. Auto-invokes when you say things like "ingest these into my wiki" or work inside a directory that has the pattern set up.
- `wiki-ingester` **subagent** — restricted agent (no Bash, no WebFetch) for unattended ingest runs.
- Six **slash commands**:
  - `/llm-wiki:init [domain-title]` — scaffold a new wiki in the cwd
  - `/llm-wiki:sources add <path> | list | remove <name>` — register external project folders as source directories
  - `/llm-wiki:ingest <file> | --new | --all` — compile sources into wiki pages
  - `/llm-wiki:query "..." [--file-back]` — answer grounded in the wiki, optionally file the answer back
  - `/llm-wiki:lint` — health check: orphans, broken links, stale pages, missing frontmatter
  - `/llm-wiki:export` — render the wiki as a static HTML site (opens with a double-click, no server)
- Two **hooks** (enforcement, not just prompts):
  - PreToolUse: blocks writes to `raw/` (immutability invariant)
  - PostToolUse: validates YAML frontmatter on `wiki/*.md` writes

## Install

```bash
# Via the marketplace (recommended)
/plugin marketplace add doneyli/claude-code-plugins
/plugin install llm-wiki

# Or clone and load directly
git clone https://github.com/doneyli/claude-code-plugins.git ~/.claude/plugins/claude-code-plugins
claude --plugin-dir ~/.claude/plugins/claude-code-plugins/llm-wiki
```

Inside Claude Code, run `/reload-plugins` to pick up changes without restarting.

## Quickstart A — Fresh wiki with `raw/`

The classic Karpathy flow. You curate sources in `raw/`, Claude compiles `wiki/`.

```bash
mkdir ~/wikis/my-research && cd ~/wikis/my-research
claude    # plugin loads automatically if installed via marketplace
```

```
/llm-wiki:init Enterprise AI Research

# Drop files into raw/ from a shell:
#   cp ~/Downloads/notes.md raw/
#   cp ~/Downloads/report.pdf raw/   (PDF, images, CSV, JSON all work natively)

/llm-wiki:ingest --all
/llm-wiki:query "What are the main themes?" --file-back
/llm-wiki:lint
/llm-wiki:export    # → site/index.html, open in browser
```

## Quickstart B — Existing project with source directories

Point the wiki at folders that already exist in your projects. No copying files into `raw/`. The wiki reads them in-place.

```bash
mkdir ~/wikis/content-research && cd ~/wikis/content-research
claude
```

```
/llm-wiki:init Content Research

# Register your existing project folders as sources:
/llm-wiki:sources add ~/content-system/.claude/research
/llm-wiki:sources add ~/content-system/ideas/signals
/llm-wiki:sources add ~/content-system/ideas/customer-patterns
/llm-wiki:sources add ~/content-system/assets/frameworks

# See what's registered:
/llm-wiki:sources list
#   Name              Path                                            Files  Pattern
#   ─────────────────────────────────────────────────────────────────────────────
#   research          ~/content-system/.claude/research                  22  **/*.md
#   signals           ~/content-system/ideas/signals                     73  **/*.md
#   customer-patterns ~/content-system/ideas/customer-patterns           12  **/*.md
#   frameworks        ~/content-system/assets/frameworks                 10  **/*.md
#   4 sources, 117 total files

# Compile everything into the wiki:
/llm-wiki:ingest --all

# Later, when new files land in those folders:
/llm-wiki:ingest --new    # only processes files not yet in log.md
```

Wiki pages cite the original paths in `sources:` frontmatter (e.g., `sources: [~/content-system/.claude/research/pain-points.md]`). Files never move. The wiki compiles from wherever they already are.

**Sources and `raw/` coexist.** You can register project folders AND drop ad-hoc files into `raw/`. `ingest --all` processes both — sources first (in order), then `raw/`.

## Source management

```
# Add a source directory
/llm-wiki:sources add ~/my-project/docs --name project-docs

# List all registered sources with file counts
/llm-wiki:sources list

# Remove a source (wiki pages compiled from it are NOT deleted)
/llm-wiki:sources remove project-docs
```

Sources are stored in `sources.yaml` at the wiki root. You can edit it by hand if needed.

## Supported source formats

**Natively supported** (no external tools — Claude reads them directly):

| Format | How |
|--------|-----|
| `.md`, `.txt` | Text |
| `.pdf` | Built-in PDF reader (up to 20 pages per request) |
| `.png`, `.jpg` | Multimodal vision — describe + OCR |
| `.csv`, `.tsv`, `.json`, `.html`, `.ics`, `.eml` | Text formats |

**Not natively supported** (warn + skip):
- `.docx`, `.pptx` — need pandoc / python-pptx
- `.m4a`, `.mp3`, `.wav` — need whisper.cpp
- `.mbox` — need splitting

For these, convert manually or use the [full CLI](https://github.com/doneyli/llm-wiki).

## All commands

| Command | What it does |
|---------|-------------|
| `/llm-wiki:init [title]` | Scaffold a new wiki (CLAUDE.md, wiki/, raw/, index.md, log.md) |
| `/llm-wiki:sources add/list/remove` | Register external project folders as source directories |
| `/llm-wiki:ingest <file>\|--new\|--all` | Compile sources into wiki pages (reads from sources.yaml + raw/) |
| `/llm-wiki:query "..." [--file-back]` | Answer grounded in the wiki; optionally file the answer as a synthesis page |
| `/llm-wiki:lint` | Health check: orphans, broken links, stale pages, missing frontmatter |
| `/llm-wiki:export` | Render the entire wiki as a static HTML site in `site/` |

## Directory layout

```
my-wiki/
├── CLAUDE.md                    # the wiki schema
├── sources.yaml                 # registered source directories (optional)
├── raw/                         # local curated sources (optional)
│   └── your-sources.md
├── wiki/                        # the compiled result
│   ├── index.md
│   ├── log.md
│   ├── entities/
│   ├── concepts/
│   ├── themes/
│   ├── comparisons/
│   └── synthesis/
├── site/                        # static HTML export (after /llm-wiki:export)
│   └── index.html
└── .gitignore
```

## License

MIT
