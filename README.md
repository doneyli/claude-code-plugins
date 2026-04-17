# Signal Labs Plugins for Claude Code

Plugins for knowledge workers who use Claude Code as their daily driver. Built by [Don Eyli](https://signalovernoise.substack.com) — Principal AI Architect, Montreal AI community lead, author of *Signal over Noise*.

## Install

```bash
# Add the marketplace (one-time)
/plugin marketplace add doneyli/signal-labs-plugins

# Install a plugin
/plugin install llm-wiki
```

Or load a plugin directly for a single session:

```bash
git clone https://github.com/doneyli/signal-labs-plugins.git ~/.claude/plugins/signal-labs
claude --plugin-dir ~/.claude/plugins/signal-labs/llm-wiki
```

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [llm-wiki](llm-wiki/) | Karpathy-style compiled-knowledge wikis. Drop sources (PDF, images, CSV, JSON, markdown) into `raw/`, Claude compiles `wiki/`. Includes slash commands, enforcement hooks, and a restricted ingest subagent. | 0.1.0 |

### llm-wiki

**Quickstart** (inside a Claude Code session with the plugin loaded):

```
/llm-wiki:init My Research Wiki
# drop files into raw/ — supports .md, .pdf, .png, .jpg, .csv, .json, .html, .ics, .eml
/llm-wiki:ingest --new
/llm-wiki:query "What are the main themes?" --file-back
/llm-wiki:lint
```

**What it ships:**
- 4 slash commands: `/llm-wiki:init`, `/llm-wiki:ingest`, `/llm-wiki:query`, `/llm-wiki:lint`
- 1 skill: `wiki-compiler` — auto-invoked when you mention ingest/compile/wiki tasks
- 1 subagent: `wiki-ingester` — restricted (no Bash, no web) for unattended runs
- 2 hooks: `raw/` immutability enforced at the tool layer + frontmatter validation on every wiki write
- Native format support: PDF, images, CSV, JSON, HTML, ICS, EML — no external tools

Full docs: [llm-wiki/README.md](llm-wiki/README.md)

## Repository Structure

```
signal-labs-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Plugin registry — lists all available plugins
├── llm-wiki/                     # Plugin: LLM Wiki
│   ├── .claude-plugin/
│   │   └── plugin.json           # Plugin manifest
│   ├── skills/                   # Auto-invoked skills
│   ├── commands/                 # Slash commands (/llm-wiki:*)
│   ├── agents/                   # Restricted subagents
│   ├── hooks/                    # Tool-layer enforcement
│   ├── templates/                # Files dropped during /init
│   └── README.md                 # Plugin-specific docs
├── <future-plugin>/              # Next plugin goes here
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── ...
├── CONTRIBUTING.md               # How to add a plugin
├── LICENSE                       # MIT
└── README.md                     # This file
```

Each plugin is a self-contained directory. Adding a new plugin means creating a directory and registering it in `marketplace.json`. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Coming Soon

More plugins for the Signal Labs toolkit. Each one follows the same pattern: a focused tool for a specific knowledge-work problem, distributed as a Claude Code plugin with zero install friction.

Subscribe to [Signal over Noise](https://signalovernoise.substack.com) for announcements.

## License

MIT
