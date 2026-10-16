---
paths:
  - "**/.claude/rules/**"
---

# Writing a rule (.claude/rules/*.md)

- Frontmatter `paths: ["glob/**"]` → the rule only loads when Claude reads/edits a matching file. Without `paths`, it loads unconditionally every session: avoid unless necessary.
- A rule is guidance, NOT enforcement. To actually block or guarantee an action, use a hook in `.claude/settings.json`.
- One topic per file, short (< 30 lines). User rules load before project rules but neither overrides the other: on conflict Claude may follow either, so keep them consistent.
- Symlinks are supported. In `~/.claude/rules/` they load normally. In a project's `.claude/rules/`, a link pointing outside the repo needs a one-time approval, and then only rules without `paths` load.
