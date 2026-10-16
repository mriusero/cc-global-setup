---
paths:
  - "**/.mcp.json"
---

# Project MCP servers (.mcp.json)

- Location imposed by Claude Code: `.mcp.json` at the project ROOT (not in `.claude/`). Committed = shared with the team; requires workspace trust.
- Personal/experimental server: `claude mcp add` (local scope, stored in ~/.claude.json) rather than `.mcp.json`.
- Secrets through env expansion: `"Authorization": "Bearer ${API_KEY}"`, with defaults `${URL:-https://...}`. Never a plaintext token. Credential-like variables (`ANTHROPIC_API_KEY`, `NPM_TOKEN`…) expand to empty in remote `url`/`headers`, by design.
- Precedence: local > project > user > plugin > claude.ai connectors (the whole config of the highest scope wins, fields are not merged).
- Keep user-level MCP servers to a minimum: every server costs context in every session. Wire a service as a project MCP server when only that project needs it.
