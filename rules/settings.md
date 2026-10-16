---
paths:
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
  - "**/.claude/hooks/**"
---

# Project settings.json, hooks & plugins

- `.claude/settings.json` is committed (permissions, hooks, `env`, `enabledPlugins`, `extraKnownMarketplaces`). `settings.local.json` is for personal, uncommitted overrides; on a solo project, prefer folding its content back into settings.json.
- **The whole project `.claude/` is versioned and pushed** (docs, plans, rules, skills, hooks…): it is project documentation, just like a README.
- Lists (`permissions.allow`/`deny`…) merge across levels, they don't overwrite. `allow` entries (and most `env` values) from a committed settings.json wait for workspace trust; `deny`/`ask` apply directly.
- Per-project plugins: `enabledPlugins` in the project's settings.json (+ `extraKnownMarketplaces` for a non-official marketplace). Never at user level if only one project uses it.
- Hooks: scripts in `.claude/hooks/`, referenced as `${CLAUDE_PROJECT_DIR}/.claude/hooks/x.sh`. Key events: `PreToolUse`, `PostToolUse`, `SessionStart`, `Stop`, `UserPromptSubmit`. Exit 2 = block; exit 0 = no decision, the call continues through the normal permission flow (to allow or ask explicitly, print JSON with `permissionDecision`). Hooks merge across levels. They are the ONLY hard enforcement mechanism.
- Secrets: never in a committed file. Use `settings.local.json`, env vars, or `${VAR}` in `.mcp.json`.
