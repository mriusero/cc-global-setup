---
paths:
  - "**/.claude/docs/**"
---

# Project docs for Claude (.claude/docs/): house convention

- `.claude/docs/` holds project knowledge meant for Claude, as curated markdown: lessons, recipes, work status, decisions. It replaces auto-memory (opaque, unreviewed): never write memory, write here.
- Nothing loads automatically: read on demand, or imported via `@.claude/docs/x.md` from the project CLAUDE.md ONLY if useful in every session.
- One topic per file, descriptive kebab-case names, absolute dates (2026-08-27, never "yesterday").
- **Curate, don't accumulate**: before writing, re-read the relevant section, then rewrite it
  consolidated (merge new with existing, delete what is stale). Never append at the end,
  never duplicate. The structure must stay readable in one pass.
- Update the existing file rather than creating a new one; delete what becomes false.
