---
name: project-config
description: Bootstrap or audit a project's Claude Code configuration (CLAUDE.md/AGENTS.md and the .claude/ directory). Use when initializing Claude config in a new project, auditing an existing one, or deciding where a setting, rule, skill, hook, doc, plan or MCP server belongs.
---

# Project config: bootstrap & audit

One guide per component lives in `${CLAUDE_PLUGIN_ROOT}/rules/`. Read the relevant one before
writing that component: `claude-md.md` (also AGENTS.md), `rules.md`, `skills.md`, `agents.md`,
`commands.md`, `settings.md` (also hooks & plugins), `mcp.md`, `docs.md`, `plans.md`.
They were checked against the Claude Code version in `${CLAUDE_PLUGIN_ROOT}/VERIFIED_VERSION`;
if Claude Code is much newer, double-check version-sensitive facts with the official docs.

## Target layout (create only what the project actually needs, YAGNI)

```
project/
├── CLAUDE.md or AGENTS.md # conventions & architecture, <200 lines (see claude-md.md for which)
├── .mcp.json              # only if the team shares MCP servers (location imposed)
└── .claude/               # ENTIRELY committed & pushed (project doc, like a README)
    ├── settings.json      # permissions, hooks, env, enabledPlugins
    ├── rules/             # path-scoped guidance
    ├── skills/            # project procedures
    ├── agents/            # project subagents
    ├── hooks/             # hook scripts (referenced from settings.json)
    ├── docs/              # curated knowledge for Claude (replaces memory)
    └── plans/             # <status>--<slug>.md: todo/wip/stby/done, synthesized on close
```

## Bootstrap (new project)

1. Write a minimal instructions file: what the project is, key commands, conventions the code
   can't show. Nothing derivable from the code.
2. Create `.claude/settings.json` only when there is something to put in it. If agent commits
   should not prompt on feature branches, add `"env": {"CLAUDE_GIT_GUARD_ALLOW": "commit"}`.
3. Migrate any relevant knowledge into `.claude/docs/` as markdown, never auto-memory.

## Audit (existing project)

- Instructions file <200 lines, no code-derivable content, no secrets anywhere committed;
  not both CLAUDE.md and AGENTS.md unless CLAUDE.md imports `@AGENTS.md`.
- Anything user-level that only this project uses → move into the project.
- Unconditional rules that could be `paths:`-scoped; skill descriptions bloated.
- Verify: `/status` (settings sources), `/context` (loaded files), `/skills`.
