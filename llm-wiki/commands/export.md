---
description: Export the wiki as a static HTML site. Converts all wiki/*.md pages to browseable HTML files in site/ that open with a double-click — no server needed.
argument-hint: "[--output-dir site/]"
---

Export the wiki as a static HTML site. Read every `.md` file under `wiki/`, convert to HTML, write to a `site/` directory.

## Parse arguments

- `--output-dir <path>` — output directory (default: `site/` in the wiki root)

## Step 1 — Read the template

Read `${CLAUDE_PLUGIN_ROOT}/templates/export-page.html`. This is the HTML shell with `{{TITLE}}`, `{{NAV}}`, `{{CONTENT}}`, `{{META}}`, `{{TOC}}` placeholders.

If the template doesn't exist, use this inline template:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{TITLE}} — Wiki</title>
<style>
/* Inline Wikipedia-modern hybrid */
*,*::before,*::after{box-sizing:border-box}
:root{--bg:#fafafa;--card:#fff;--text:#1a1a1a;--text2:#555;--link:#0645ad;--border:#d4d4d4;--sidebar:260px;--max-w:780px;--font:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;--serif:Georgia,"Times New Roman",serif}
body{margin:0;font-family:var(--font);font-size:17px;line-height:1.65;color:var(--text);background:var(--bg)}
a{color:var(--link);text-decoration:none}a:hover{text-decoration:underline}
.layout{display:flex;min-height:100vh}
.sidebar{width:var(--sidebar);background:var(--card);border-right:1px solid var(--border);padding:1.5rem 1rem;position:sticky;top:0;height:100vh;overflow-y:auto;font-size:14px}
.sidebar h2{font-size:13px;text-transform:uppercase;letter-spacing:.06em;color:var(--text2);margin:1.2em 0 .4em;font-family:var(--font)}
.sidebar ul{list-style:none;margin:0;padding:0}.sidebar li{margin:.2em 0}.sidebar a.active{font-weight:700;color:var(--text)}
.main{flex:1;max-width:var(--max-w);padding:2rem 2.5rem 4rem;margin:0 auto}
h1{font-family:var(--serif);font-size:2rem;font-weight:400;border-bottom:1px solid var(--border);padding-bottom:.3em;margin:0 0 .4em}
h2{font-family:var(--serif);font-size:1.4rem;font-weight:400;margin:1.8em 0 .5em;border-bottom:1px solid #eee;padding-bottom:.2em}
h3{font-size:1.1rem;margin:1.4em 0 .4em}
.meta{font-size:13px;color:var(--text2);margin-bottom:1.5em;display:flex;gap:.5em;flex-wrap:wrap;align-items:center}
.tag{display:inline-block;background:#eef;color:#336;font-size:11px;padding:2px 8px;border-radius:3px;font-weight:500}
.tag.concept{background:#dcfce7;color:#166534}.tag.entity{background:#dbeafe;color:#1e40af}.tag.theme{background:#f3e8ff;color:#6b21a8}.tag.synthesis{background:#fef3c7;color:#92400e}
table{border-collapse:collapse;width:100%;margin:1em 0}th,td{border:1px solid var(--border);padding:.5em .75em;text-align:left}th{background:#f5f5f5;font-weight:600}tr:nth-child(even){background:#fafafa}
.callout{border-left:4px solid;padding:.75em 1em;margin:1em 0;border-radius:0 4px 4px 0}
.callout-contradiction{border-color:#f59e0b;background:#fffbeb}.callout-gap{border-color:#3b82f6;background:#eff6ff}.callout-confidential{border-color:#374151;background:#f9fafb}
blockquote{border-left:3px solid var(--border);margin:1em 0;padding:.5em 1em;color:var(--text2)}
code{background:#f4f4f4;padding:.15em .4em;border-radius:3px;font-size:.9em}
pre{background:#f4f4f4;padding:1em;border-radius:4px;overflow-x:auto}pre code{background:none;padding:0}
.backlinks{margin-top:3em;padding-top:1em;border-top:1px solid var(--border);font-size:14px;color:var(--text2)}
.footer{text-align:center;font-size:12px;color:var(--text2);padding:2em 0;border-top:1px solid var(--border)}
@media(max-width:768px){.sidebar{display:none}.main{padding:1rem}}
</style>
</head>
<body>
<div class="layout">
<nav class="sidebar">
<h2>Wiki</h2>
<ul><li><a href="{{ROOT}}index.html">Home</a></li></ul>
{{NAV}}
</nav>
<div class="main">
<h1>{{TITLE}}</h1>
<div class="meta">{{META}}</div>
{{CONTENT}}
<div class="footer">Exported from LLM Wiki</div>
</div>
</div>
</body>
</html>
```

## Step 2 — Build the page list

Read `wiki/index.md`. Parse the category sections (## Entities, ## Concepts, etc.) to build the sidebar navigation. Also glob `wiki/**/*.md` (excluding `wiki/log.md`) to find all pages.

## Step 3 — Convert each page

For each `.md` file under `wiki/`:

1. Read the file.
2. Parse YAML frontmatter → extract `title`, `type`, `tags`, `confidence`, `last_updated`, `sources`.
3. Convert the markdown body to HTML:
   - `[[wikilinks]]` → `<a href="<resolved-path>.html">display text</a>` (resolve by finding the .md file whose stem matches, convert to relative .html path)
   - `> [!contradiction]` → `<div class="callout callout-contradiction"><strong>Contradiction:</strong> ...`
   - `> [!gap]` → `<div class="callout callout-gap"><strong>Gap:</strong> ...`
   - `> [!confidential]` → `<div class="callout callout-confidential"><strong>Confidential:</strong> ...`
   - `^[raw/file.md]` → `<sup>[source]</sup>`
   - `## Backlinks` section → render as `<div class="backlinks"><h3>Backlinks</h3>...`
   - Standard markdown (headings, bold, italic, lists, code, tables, links) → HTML
4. Build metadata badges: `<span class="tag type">entity</span>` + tags + `Last updated: YYYY-MM-DD` + `Confidence: high`
5. Fill the template: replace `{{TITLE}}`, `{{META}}`, `{{CONTENT}}`, `{{NAV}}`, `{{ROOT}}` (relative path to site root: `""` for root, `"../"` for subdirs)
6. Write to `site/<relative-path>.html` (mirror the wiki/ directory structure, replacing .md → .html)

## Step 4 — Generate index page

Convert `wiki/index.md` to `site/index.html`. The sidebar lists all categories with links to their pages.

## Step 5 — Summary

```
Exported N pages to site/
Open site/index.html in your browser.
```

## Quality rules

- Every `[[wikilink]]` must resolve to a real .html file in site/. If unresolved, render as plain text with a "missing" class.
- Preserve the wiki's structure: `site/entities/`, `site/concepts/`, etc.
- The output must work via `file://` protocol (no absolute paths, no CDN, no fetch calls).
- Inline all CSS in each page (no external stylesheet) so each page is self-contained.
