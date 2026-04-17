# Contributing a Plugin

Each plugin in this marketplace is a self-contained Claude Code plugin inside its own directory. This guide covers how to add one.

## Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json               # Required — plugin manifest
├── skills/                       # Optional — auto-invoked skills
│   └── <skill-name>/
│       └── SKILL.md
├── commands/                     # Optional — slash commands
│   └── <command-name>.md
├── agents/                       # Optional — subagents
│   └── <agent-name>.md
├── hooks/                        # Optional — enforcement hooks
│   ├── hooks.json
│   └── <hook-script>.sh
├── templates/                    # Optional — files dropped during init
├── README.md                     # Required — plugin docs
└── ...
```

## Minimal plugin.json

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "One sentence — what it does.",
  "author": { "name": "Your Name" },
  "license": "MIT"
}
```

## Steps to add a plugin

1. **Create the directory** at the repo root: `my-plugin/`
2. **Add `.claude-plugin/plugin.json`** with at least `name` and `version`
3. **Add your components** — skills, commands, agents, hooks, templates
4. **Write a README.md** inside the plugin directory covering install + quickstart
5. **Register in `marketplace.json`** — add an entry to the `plugins` array:

   ```json
   {
     "name": "my-plugin",
     "source": "./my-plugin",
     "description": "One sentence.",
     "version": "0.1.0"
   }
   ```

6. **Update the root README.md** — add a row to the Available Plugins table
7. **Test locally**:

   ```bash
   claude --plugin-dir ./my-plugin
   ```

   Verify: slash commands show up, skills trigger, hooks fire.

8. **Commit and push** — users who have already added this marketplace get the new plugin on their next `/plugin install`.

## Design principles

These aren't rules, but they describe what makes a Signal Labs plugin *feel right*.

- **Zero install beyond Claude Code.** No pip, no brew, no npm. If a plugin needs Python or Bash for hooks, it ships those scripts inline. Users clone and go.
- **Enforcement, not suggestion.** If the plugin has an invariant (e.g., "don't write to X"), enforce it with a hook, not a prompt paragraph. Prompts get ignored; hooks don't.
- **One domain, done well.** Each plugin solves one workflow problem. LLM Wiki does compiled knowledge. The next plugin does something else. Don't bundle unrelated features.
- **Native first.** Prefer Claude's built-in capabilities (Read for PDF/images, multimodal for OCR) over external tool dependencies. Every dependency is a support ticket.
- **Paid value through curation.** The code is MIT. The newsletter walkthrough — what it is, why it matters, exactly how to use it — is the paid product. The plugin is the artifact; the insight is the paywall.

## Naming conventions

- Plugin directory: `kebab-case` (e.g., `llm-wiki`, `deal-tracker`)
- Commands: short verbs (e.g., `init`, `ingest`, `query`) — they'll be namespaced by the plugin name automatically (`/llm-wiki:init`)
- Skills: descriptive of the capability (e.g., `wiki-compiler`)
- Agents: descriptive of the role (e.g., `wiki-ingester`)

## Questions

Open an issue on this repo or reach out via [Signal over Noise](https://signalovernoise.substack.com).
