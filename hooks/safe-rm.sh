#!/usr/bin/env bash
# Rewrite `rm [flags] x` into `trash x` so deletions stay recoverable.
# No-op when no `trash` command is available (macOS 15+ ships one; Linux: trash-cli).
case "${CLAUDE_PLUGIN_OPTION_SAFE_RM:-true}" in false|0) exit 0 ;; esac
command -v trash >/dev/null 2>&1 || exit 0
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$CMD" ]; then
  exit 0
fi

if ! echo "$CMD" | grep -qE '(^|\s|;|&&|\|\|)rm\s'; then
  exit 0
fi

REWRITTEN=$(echo "$CMD" | sed -E 's/(^|[;&|]+[[:space:]]*)rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*/\1trash /g')

if [ "$CMD" = "$REWRITTEN" ]; then
  exit 0
fi

ORIGINAL_INPUT=$(echo "$INPUT" | jq -c '.tool_input')
UPDATED_INPUT=$(echo "$ORIGINAL_INPUT" | jq --arg cmd "$REWRITTEN" '.command = $cmd')

jq -n \
  --argjson updated "$UPDATED_INPUT" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "rm → trash (files moved to the Trash, recoverable)",
      "updatedInput": $updated
    }
  }'
