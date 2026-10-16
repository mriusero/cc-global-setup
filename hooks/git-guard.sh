#!/usr/bin/env bash
# Ask the user before push/merge/PR, and before commit unless the project opts in.
# Opt-in: "env": {"CLAUDE_GIT_GUARD_ALLOW": "commit"} in the project's .claude/settings(.local).json
# allows commits on any branch except the protected ones (plugin option protected_branches).
# Plugin options arrive as CLAUDE_PLUGIN_OPTION_<KEY>; git_guard=false turns the hook off.
case "${CLAUDE_PLUGIN_OPTION_GIT_GUARD:-true}" in false|0) exit 0 ;; esac
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$CMD" ] && exit 0

ask() {
  jq -n --arg why "$1" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "ask",
      "permissionDecisionReason": $why
    }
  }'
  exit 0
}

git_re='(^|[;&|]\s*)(rtk\s+)?git\s+(-C\s+\S+\s+)?'
if echo "$CMD" | grep -qE "${git_re}(push|merge)(\s|$)|(^|[;&|]\s*)(rtk\s+)?gh\s+pr\s+(create|merge)(\s|$)"; then
  ask "User approval required before push/PR/merge"
fi
echo "$CMD" | grep -qE "${git_re}commit(\s|$)" || exit 0

cwd=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
top=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null)
branch=$(git -C "${cwd:-.}" branch --show-current 2>/dev/null)
allow=""
for f in "$top/.claude/settings.json" "$top/.claude/settings.local.json"; do
  if [ -f "$f" ]; then
    v=$(jq -r '.env.CLAUDE_GIT_GUARD_ALLOW // empty' "$f" 2>/dev/null)
    [ -n "$v" ] && allow="$allow $v"
  fi
done
protected=" ${CLAUDE_PLUGIN_OPTION_PROTECTED_BRANCHES:-main master} "
if echo "$allow" | grep -qw commit && [ -n "$branch" ] && [[ "$protected" != *" $branch "* ]]; then
  exit 0
fi
ask "User approval required before commit (protected branch, or project without CLAUDE_GIT_GUARD_ALLOW=commit)"
