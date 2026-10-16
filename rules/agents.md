---
paths:
  - "**/.claude/agents/**"
---

# Writing an agent (.claude/agents/<name>.md)

- Required frontmatter: `name` (kebab-case) and `description` (when to delegate: it is the routing criterion). The body is the agent's system prompt.
- Optional: `tools` (default: every tool available to subagents), `model` (default: per-invocation model, else this field, else `CLAUDE_CODE_SUBAGENT_MODEL`, else the main model; `inherit` forces the main model), `permissionMode`, `skills` (preloaded in full), `memory` (`user`|`project`|`local`).
- Precedence: managed > `--agents` flag > project > user > plugin; same name → highest wins. Hot-reloaded, except the first agent file of a new `agents/` directory (restart).
- An agent exists to isolate context (broad search, review, parallelizable work); don't create one for something a skill already covers.
