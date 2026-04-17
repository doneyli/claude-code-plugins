# llm-wiki — Claude Code plugin

Karpathy's compiled-knowledge wiki pattern, packaged as a Claude Code plugin. No install beyond Claude Code itself. Drop into any folder, curate sources in `raw/`, let Claude compile `wiki/`.

## What it gives you

- `wiki-compiler` **skill** — the "compiler" knowledge. Auto-invokes when you say things like "ingest these into my wiki" or work inside a directory that has the pattern set up.
- `wiki-ingester` **subagent** — restricted agent (no Bash, no WebFetch) for unattended ingest runs.
- Four **slash commands**:
  - `/llm-wiki:init [domain-title]` — scaffold a new wiki in the cwd
  - `/llm-wiki:ingest <file> | --new | --all` — compile raw sources into wiki pages
  - `/llm-wiki:query "..." [--file-back]` — answer grounded in the wiki, optionally file the answer back
  - `/llm-wiki:lint` — health check: orphans, broken links, stale pages, missing frontmatter
- Two **hooks** (enforcement, not just prompts):
  - PreToolUse: blocks writes to `raw/` (immutability invariant)
  - PostToolUse: validates YAML frontmatter on `wiki/*.md` writes

## Install

```bash
# Via the Signal Labs marketplace (recommended)
/plugin marketplace add doneyli/signal-labs-plugins
/plugin install llm-wiki

# Or clone and load directly
git clone https://github.com/doneyli/signal-labs-plugins.git ~/.claude/plugins/signal-labs
claude --plugin-dir ~/.claude/plugins/signal-labs/llm-wiki

# Or for a single session
cd <your-wiki-root>
claude --plugin-dir /path/to/llm-wiki-plugin
```

Inside Claude Code, run `/reload-plugins` to pick up changes without restarting.

## Quickstart

```bash
mkdir ~/wikis/my-research
cd ~/wikis/my-research

claude --plugin-dir ~/.claude/plugins/llm-wiki
```

Then inside the Claude Code session:

```
/llm-wiki:init Enterprise AI Research

# Drop a markdown file into raw/ (from a shell: `cp ~/Downloads/notes.md raw/`)

/llm-wiki:ingest raw/notes.md

# Browse the resulting wiki/ pages in any markdown editor

/llm-wiki:query "What are the main themes?"
/llm-wiki:query "What is the competitive landscape?" --file-back
/llm-wiki:lint
```

## Scope

**Included:** the pattern, the conventions, the workflow, and enforcement hooks. Works for the research domain out of the box; `CLAUDE.md` is editable for other domains.

**Natively supported source formats** (no external tools):
- `.md`, `.txt`, `.pdf`, `.png`, `.jpg`, `.csv`, `.tsv`, `.json`, `.html`, `.ics`, `.eml`
- Claude reads these directly via its built-in PDF, vision, and text capabilities
- Just drop any of these into `raw/` and run `/llm-wiki:ingest`

**Not included** (use the `llm-wiki` CLI for these):
- Binary format conversion (`.docx`, `.pptx`, audio) — needs pandoc/whisper.cpp
- Overlay mode / `sources.yaml` watching external projects
- Cost controls / `--max-cost` / `sync --dry-run`
- Web UI / graph view / search
- Phased ingest / running cost tally / scheduled sync

If you need those, `git clone https://github.com/doneyli/llm-wiki` and use the CLI.

## Directory layout of a wiki

```
my-wiki/
├── CLAUDE.md                    # the schema
├── raw/                         # you curate this
│   └── your-sources.md
├── wiki/                        # the compiled result
│   ├── index.md
│   ├── log.md
│   ├── entities/
│   ├── concepts/
│   ├── themes/
│   ├── comparisons/
│   └── synthesis/
└── .gitignore
```

## License

MIT
