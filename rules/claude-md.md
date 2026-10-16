---
paths:
  - "**/CLAUDE.md"
  - "**/AGENTS.md"
---

# Writing a project CLAUDE.md / AGENTS.md

- Which file: `AGENTS.md` alone when other coding agents (Codex, Cursor…) also work in the repo;
  Claude Code reads it natively (v2.1.277+). `CLAUDE.md` alone for a Claude-only project.
  **Both present → Claude reads only CLAUDE.md** (default `/config` › Project instructions);
  if you need both, start CLAUDE.md with `@AGENTS.md` and keep only Claude-specific lines in it.
- Target < 200 lines; adherence drops beyond that. Split into `.claude/rules/` (path-scoped) or nested files in subdirectories (loaded when Claude works there).
- Content: team conventions, architecture, project commands. Never what can be derived from the code, never secrets.
- Files are concatenated (user → project → nested), nothing overrides: don't repeat or contradict the user-level file.
- Imports: `@path/file` (max 4 hops, paths relative to the importing file). Wrap in backticks (`` `@x` ``) to neutralize. Imports organize a file but don't reduce its cost: imported files load at launch too. Only import what is useful in EVERY session; otherwise put it in `.claude/docs/` and read on demand.
