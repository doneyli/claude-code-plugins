# Signal Labs Plugins — Repository Instructions

This is a Claude Code plugin marketplace repository. It hosts multiple plugins, each in its own self-contained directory.

## Repository layout

- `.claude-plugin/marketplace.json` — the registry. Lists every plugin by name, source path, description, and version.
- `<plugin-name>/` — each plugin directory is a complete Claude Code plugin (has its own `.claude-plugin/plugin.json`).
- `CONTRIBUTING.md` — how to add a new plugin.
- `README.md` — user-facing install instructions + plugin catalog.

## When modifying this repo

- **Adding a new plugin:** create the directory, add `plugin.json`, register in `marketplace.json`, add a row to README.md's table. See CONTRIBUTING.md.
- **Updating an existing plugin:** bump the `version` in both the plugin's `plugin.json` AND the `marketplace.json` entry.
- **Commit conventions:** conventional commits (`feat:`, `fix:`, `docs:`). Reference the plugin name in scope: `feat(llm-wiki): ...`.
- **Testing:** always verify with `claude --plugin-dir ./<plugin-name>` before pushing.

## What NOT to do

- Don't put shared code at the repo root — each plugin is self-contained.
- Don't add dependencies that require `pip install` or `brew install` — zero-install is a core principle.
- Don't forget to update `marketplace.json` when adding or versioning a plugin.
