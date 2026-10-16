---
paths:
  - "**/.claude/skills/**"
---

# Writing a skill (.claude/skills/<name>/SKILL.md)

- The `description` (+ `when_to_use`, combined cap 1,536 chars) is loaded EVERY session: keep it dense and trigger-oriented. The body only loads on invocation (`/name` or automatic) and then stays in context for the session.
- Useful frontmatter: `allowed-tools` (pre-approves tools for the current turn, restricts nothing; the grant expires with your next message), `disallowed-tools`, `model`, `effort`, `context: fork` (+ `agent`) to run in an isolated subagent, `paths` to limit auto-invocation, `disable-model-invocation: true` (user-only), `user-invocable: false` (Claude-only).
- Dynamic injection: `` !`cmd` `` runs before the skill is read.
- Same name: enterprise > personal (`~/.claude/skills/`) > project (`.claude/skills/`). Plugin skills are namespaced (`/plugin:skill`), so they never collide. Hot-reloaded; if `.claude/skills/` didn't exist at startup, run `/reload-skills` after creating it.
- Supporting files (long references, scripts) live in the skill folder and are read on demand from SKILL.md.
