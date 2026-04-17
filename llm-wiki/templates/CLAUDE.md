# {{DOMAIN_TITLE}} — LLM Wiki Schema

This wiki follows the Karpathy LLM Wiki pattern, installed via the `llm-wiki` Claude Code plugin. The `wiki-compiler` skill (bundled) reads this file on every operation.

## 1. Architecture (three layers)

1. `raw/` — immutable source files you curate. LLM reads, never writes. The plugin's PreToolUse hook blocks writes here.
2. `wiki/` — LLM-owned compiled markdown.
3. `CLAUDE.md` (this file) — conventions, workflows.

## 2. Page types

| Type | Folder | Description | TTL |
|------|--------|-------------|-----|
| entity | entities/ | Company, product, person, or tool mentioned in sources | 180d |
| concept | concepts/ | Pattern, framework, or idea | 365d |
| theme | themes/ | Narrative arc, editorial angle, or research cluster | 90d |
| comparison | comparisons/ | A vs B analysis or filed query output | 90d |
| synthesis | synthesis/ | Cross-cutting analysis spanning multiple sources | 90d |

## 3. Frontmatter (required on every wiki page)

```yaml
---
title: <Exact page title>
type: entity | concept | theme | comparison | synthesis
tags: [domain-tags]
sources: [raw/<filename>.md, ...]
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
ttl: 90d | 180d | 365d | null
confidence: high | medium | low
---
```

- `confidence`: high = multiple sources agree; medium = single source; low = inference or weak signal.

## 4. Page body conventions

- `[[wikilinks]]` for every reference to another wiki page. Bare slug only.
- Cite sources with inline `^[raw/filename.md]` or `## Sources` section.
- `> [!contradiction]` where sources disagree.
- `> [!confidential]` for sensitive material.
- `> [!gap]` for known missing coverage.
- Every page ends with `## Backlinks`. The LLM maintains it.

## 5. index.md structure

Organized by type. One line per page with a terse summary:

```
## Entities
- [[entity-name]] — one-line description
```

## 6. log.md structure

Append-only, parseable:

```
## [YYYY-MM-DD] ingest | <source title>
- Ingested raw/<file>.md
- Pages touched: [[a]], [[b]]
- New pages: [[c]]
- Notes: ...
```

## 7. Workflows

Use the plugin's slash commands:

- `/llm-wiki:ingest <file>` or `/llm-wiki:ingest --new` — compile raw sources into wiki pages
- `/llm-wiki:query "..." [--file-back]` — answer a question grounded in the wiki
- `/llm-wiki:lint` — health check (orphans, broken links, stale pages, missing frontmatter)

The `wiki-compiler` skill also auto-invokes when you say things like "ingest this into my wiki" or "compile these sources".

## 8. What NOT to do

- Do not write to `raw/`. The plugin hook will block you.
- Do not delete wiki pages silently — log the deletion in `log.md`.
- Do not create pages without source citations (synthesis pages excepted).
- Do not duplicate content — always `[[link]]`.
- Do not overstate `confidence`.
- Do not fabricate data.
