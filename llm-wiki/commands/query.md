---
description: Answer a question grounded in the wiki. Optionally file the answer back as a synthesis page.
argument-hint: "\"<your question>\" [--file-back]"
---

Answer a question grounded in the wiki at the current working directory.

Parse `$ARGUMENTS`:
- The quoted string is the question.
- If `--file-back` appears, write the answer back as a synthesis page.

Steps:

1. Read `wiki/index.md` to orient.
2. Identify the 5-20 most relevant pages based on the question. Prefer:
   - Higher `confidence` in frontmatter
   - Fresher `last_updated`
   - Breadth over depth (10 medium-relevance pages beats 3 highly-relevant ones)
3. Read each identified page in full.
4. Synthesize an answer. Every factual claim cites a wiki page via `[[wikilink]]`.
5. Flag gaps with `> [!gap]` if the wiki lacks coverage the question needs. Flag contradictions with `> [!contradiction]` if relevant pages disagree.

If `--file-back` was passed:

6. Create `wiki/synthesis/<slug>.md` where slug is a kebab-cased version of the question (max 60 chars). Use frontmatter:
   ```yaml
   ---
   title: <Question>
   type: synthesis
   tags: [query-output]
   sources: [<list of wiki pages drawn on>]
   created: YYYY-MM-DD
   last_updated: YYYY-MM-DD
   ttl: 90d
   confidence: <lowest confidence among sources>
   ---
   ```
7. Write the answer body below the frontmatter. End with a `## Backlinks` section (empty if this is the first reference).
8. Link the new synthesis page from `wiki/index.md` under `## Synthesis`.

Always:

9. Append a query log entry to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] query | <question>
   - Pages consulted: [[a]], [[b]]
   - Answer filed at: wiki/synthesis/<slug>.md   (or "not filed")
   - Gaps identified: [...]
   ```

Quality bar:

- Do not invent facts not present in the pages you read.
- If the wiki has insufficient coverage, say so. Do not extrapolate.
- Confidence in your answer is bounded by the lowest-confidence source page.
- If pages have expired TTLs, note: "This answer draws on pages that may be stale."

Print the answer directly. Follow with:

```
Sources: [[page-a]], [[page-b]], ...
Confidence: high | medium | low
Gaps: [...] or "none identified"
Filed back: wiki/synthesis/<slug>.md or "not filed"
```
