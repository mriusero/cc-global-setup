#!/usr/bin/env bash
# SessionStart: tell Claude when the running Claude Code has moved well past the version the
# plugin's rules were checked against (VERIFIED_VERSION): a different major.minor, or 50+
# patch releases ahead: Claude Code ships features in patch releases.
STAMP="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/VERIFIED_VERSION"
CURRENT=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
VERIFIED=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$STAMP" 2>/dev/null | head -1)
[ -z "$CURRENT" ] || [ -z "$VERIFIED" ] && exit 0

if [ "${CURRENT%.*}" != "${VERIFIED%.*}" ] || [ $(( ${CURRENT##*.} - ${VERIFIED##*.} )) -ge 50 ]; then
  echo "[rules-freshness] Claude Code is v$CURRENT but the cc-global-setup rules were checked against v$VERIFIED. Before relying on version-sensitive details from them, double-check against the official docs (claude-code-guide agent)."
fi
exit 0
