---
name: setup-statusline
description: Install or update the cc-global-setup status line (path, branch, worktree, context usage, 5h/7d rate limits with reset countdowns, current model) in the user's Claude Code settings. Use when the user asks to install, update or remove this status line.
disable-model-invocation: true
---

# Install the status line

Plugins cannot register the main status line, and `${CLAUDE_PLUGIN_ROOT}` changes on every
plugin update, so the script is copied to a stable location and referenced from settings.

1. Check that `jq` is installed (`command -v jq`); if not, stop and say how to install it.
2. Copy `${CLAUDE_PLUGIN_ROOT}/statusline/statusline.sh` to `~/.claude/statusline.sh` and
   `chmod +x` it. If a different file is already there, show the diff and ask before overwriting.
3. In `~/.claude/settings.json`, merge (never replace the file):
   `"statusLine": {"type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 60000}`.
   If another `statusLine` is configured, show it and ask before replacing.
4. Smoke-test and show the output:
   `echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":12,"total_input_tokens":24000,"context_window_size":200000}}' | ~/.claude/statusline.sh`
5. Mention the optional conf badge: a Claude Code version written to `~/.claude/.verified-version`
   (path overridable with `CLAUDE_CONF_STAMP`) shows ✓ while Claude Code's major.minor matches,
   ⚠ once it moves on.

Re-run after a plugin update to get the latest script. To remove: delete the `statusLine` key
and `~/.claude/statusline.sh`.
