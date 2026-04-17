---
description: Health-check the wiki. Surface orphans, broken wikilinks, stale pages, missing frontmatter, and pages missing source attribution.
---

Lint the wiki in the current directory. Output a report grouped by check type.

For each `.md` file under `wiki/` (skip `wiki/log.md`):

1. **Frontmatter validation**
   - YAML frontmatter exists between `---` markers
   - Required fields: `title`, `type`, `created`, `last_updated`
   - `confidence` ∈ {high, medium, low} if present
   - `ttl` matches `^\d+d$` or is null
   - `created` / `last_updated` match YYYY-MM-DD

2. **Link integrity**
   - Every `[[wikilink]]` resolves to an existing wiki page
   - Report broken links with file:line

3. **Orphans**
   - Count inbound `[[references]]` to each page
   - Pages with 0 inbound (except `wiki/index.md`) are orphans
   - Exception: synthesis pages linked from `wiki/index.md`

4. **Backlinks section audit**
   - Every page has a `## Backlinks` heading (warn if missing)

5. **Staleness**
   - `last_updated + ttl < today` → stale
   - Skip pages with `ttl: null`

6. **Source attribution**
   - Pages with type ∈ {entity, concept, theme, capability, narrative, client, pattern} have non-empty `sources:`
   - Synthesis and comparison pages may have empty `sources:`

Output format:

```
=== Frontmatter ===
✗ wiki/entities/foo.md: missing required field 'type'

=== Links ===
✗ wiki/concepts/bar.md:15: broken link [[nonexistent]]

=== Orphans ===
⚠ wiki/themes/lonely.md: 0 inbound links

=== Staleness ===
⚠ wiki/entities/old.md: stale (last_updated 2025-01-01, ttl 90d)

=== Attribution ===
✗ wiki/entities/foo.md: type 'entity' requires non-empty sources:

=== Summary ===
N errors, M warnings (K pages checked)
```

If there are errors, suggest specific fixes — but do NOT auto-fix unless the user asks. Just report.

Do not invent issues. If the wiki is clean, print `Healthy — 0 errors, 0 warnings.`
