# Signal Labs Plugins for Claude Code

Plugins for knowledge workers who use Claude Code as their daily driver. Built by [Don Eyli](https://signalovernoise.substack.com) (Principal AI Architect, Montreal AI community lead).

## Install

```bash
# Add the marketplace (one-time)
/plugin marketplace add doneyli/signal-labs-plugins

# Install a plugin
/plugin install llm-wiki
```

Or load directly for a single session:

```bash
claude --plugin-dir /path/to/signal-labs-plugins/llm-wiki
```

## Available Plugins

### llm-wiki

Karpathy's compiled-knowledge wiki pattern, packaged for Claude Code. Drop sources into `raw/`, Claude compiles `wiki/`.

**What it gives you:**
- Slash commands: `/llm-wiki:init`, `/llm-wiki:ingest`, `/llm-wiki:query`, `/llm-wiki:lint`
- A restricted ingest subagent (no shell, no web — reads raw/, writes wiki/)
- Enforcement hooks: `raw/` is immutable (blocked at the tool layer), frontmatter validated on every write
- Native format support: PDF, images, CSV, JSON, HTML, ICS, EML — no external tools needed

**Quickstart:**

```bash
mkdir ~/wikis/my-research && cd ~/wikis/my-research
claude --plugin-dir ~/.local/share/claude/plugins/llm-wiki
```

Then inside Claude Code:

```
/llm-wiki:init My Research Wiki
# drop files into raw/
/llm-wiki:ingest --new
/llm-wiki:query "What are the main themes?" --file-back
/llm-wiki:lint
```

See [llm-wiki/README.md](llm-wiki/README.md) for full docs.

## Coming Soon

More plugins for the Signal Labs toolkit. Subscribe to [Signal over Noise](https://signalovernoise.substack.com) for announcements.

## License

MIT
