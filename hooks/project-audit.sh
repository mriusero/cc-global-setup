#!/usr/bin/env bash
# SessionStart: in a git repo (other than ~) with no instructions file (CLAUDE.md or AGENTS.md)
# or no .claude/, nudge Claude to offer the project-config skill. A SessionStart hook's stdout
# is added to Claude's context. Plugin option project_audit=false turns it off.
case "${CLAUDE_PLUGIN_OPTION_PROJECT_AUDIT:-true}" in false|0) exit 0 ;; esac
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$CWD" ] && CWD=$PWD
[ "$CWD" = "$HOME" ] && exit 0
ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)
[ -z "$ROOT" ] && exit 0

MISSING=""
[ -f "$ROOT/CLAUDE.md" ] || [ -f "$ROOT/AGENTS.md" ] || MISSING="CLAUDE.md or AGENTS.md"
[ -d "$ROOT/.claude" ] || MISSING="${MISSING:+$MISSING + }.claude/"

if [ -n "$MISSING" ]; then
  echo "[project-audit] This project has no Claude Code configuration yet (missing: $MISSING). Offer the user a bootstrap via /cc-global-setup:project-config."
fi
exit 0
