---
paths:
  - "**/.claude/commands/**"
---

# Commands (.claude/commands/): legacy, prefer skills

- Commands have been merged into skills: `.claude/commands/deploy.md` → `/deploy` still works, but a skill with the same name wins.
- For anything new, create `.claude/skills/<name>/SKILL.md` (see the skills reference), not a command. Keep `commands/` for existing legacy shortcuts.
- Frontmatter: same as skills except `name` and `paths` (the invocation comes from the file name).
