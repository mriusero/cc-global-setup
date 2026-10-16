#!/usr/bin/env bash
# Custom statusline: code-only, no network, target <50ms.
# Reads Claude Code's status JSON on stdin and renders:
#   line 1: cwd ⎇ branch ⧉ worktree · conf freshness badge (optional, see below)
#   line 2: 👀 context bar · ⚡ 5h quota bar · 👾 7d quota bar (with time left to reset) · ✦ model
# Conf badge: shown only when $CLAUDE_CONF_STAMP (default ~/.claude/.verified-version) exists.
# It holds the Claude Code version your config was last checked against; ✓ when the
# running major.minor matches, ⚠ when Claude Code moved on since.
# rate_limits is absent before the first API response and on non-subscription
# accounts; those cards render as "—".

INPUT=$(cat)

eval "$(printf '%s' "$INPUT" | jq -r '@sh "
DIR=\(.workspace.current_dir // .cwd // "?")
VERSION=\(.version // "")
MODEL=\(.model.display_name // .model.id // "")
CTX_PCT=\((.context_window.used_percentage // 0) | floor)
CTX_IN=\(.context_window.total_input_tokens // 0)
CTX_MAX=\(.context_window.context_window_size // 200000)
P5=\((.rate_limits.five_hour.used_percentage // -1) | floor)
R5=\(.rate_limits.five_hour.resets_at // 0)
P7=\((.rate_limits.seven_day.used_percentage // -1) | floor)
R7=\(.rate_limits.seven_day.resets_at // 0)
"' 2>/dev/null)"

FULL="██████████"
EMPTY="░░░░░░░░░░"
DIM="\033[2m"; RST="\033[0m"; BOLD="\033[1m"
GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; CYAN="\033[36m"; MAGENTA="\033[35m"

bar() { # $1 = percent (int) → colored 10-char bar + " NN%"
  local p=$1 w=10
  if [ "$p" -lt 0 ]; then printf "${DIM}··········${RST} ${DIM}—${RST}"; return; fi
  local f=$(( p * w / 100 )); [ "$f" -gt "$w" ] && f=$w; [ "$f" -lt 0 ] && f=0
  local c=$GREEN; [ "$p" -ge 60 ] && c=$YELLOW; [ "$p" -ge 85 ] && c=$RED
  printf "%b%s%b%s%b %b%d%%%b" "$c" "${FULL:0:f}" "$DIM" "${EMPTY:0:$((w-f))}" "$RST" "$c" "$p" "$RST"
}

left() { # $1 = reset epoch → time remaining ("2h13", "43min", "3d 4h")
  local now rem
  now=$(date +%s); rem=$(( $1 - now ))
  [ "$rem" -le 0 ] && { printf "reset"; return; }
  local d=$(( rem / 86400 )) h=$(( (rem % 86400) / 3600 )) m=$(( (rem % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then printf "%dd %dh" "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf "%dh%02d" "$h" "$m"
  else printf "%dmin" "$m"; fi
}

# --- conf freshness: doc-derived conf (rules/ + project-config skill) vs Claude Code major.minor
CONF_STATUS=""
CUR_MM=$(printf '%s' "$VERSION" | grep -oE '^[0-9]+\.[0-9]+')
if [ -n "$CUR_MM" ]; then
  VER_MM=$(grep -oE '[0-9]+\.[0-9]+' "${CLAUDE_CONF_STAMP:-$HOME/.claude/.verified-version}" 2>/dev/null | head -1)
  if [ -z "$VER_MM" ]; then
    :
  elif [ "$CUR_MM" = "$VER_MM" ]; then
    CONF_STATUS=$(printf "${GREEN}✓${RST} ${DIM}conf v%s${RST}" "$VER_MM")
  else
    CONF_STATUS=$(printf "${YELLOW}⚠ conf v${VER_MM}→v${CUR_MM}${RST}")
  fi
fi

# --- linked worktree: git-dir differs from git-common-dir; shows "⧉ <main repo>/<worktree>"
WT_STATUS=""
GIT_DIR=$(git -C "$DIR" rev-parse --path-format=absolute --git-dir 2>/dev/null)
GIT_COMMON=$(git -C "$DIR" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
if [ -n "$GIT_COMMON" ] && [ "$GIT_DIR" != "$GIT_COMMON" ]; then
  WT_STATUS=$(printf "${MAGENTA}⧉ ${DIM}%s/${RST}${MAGENTA}%s${RST}" "$(basename "$(dirname "$GIT_COMMON")")" "$(basename "$GIT_DIR")")
fi

# --- line 1 : path ⎇ branch ⧉ worktree · conf check
SHORT_DIR=${DIR/#$HOME/\~}
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
printf "${BOLD}%s${RST}" "$SHORT_DIR"
[ -n "$BRANCH" ] && printf " ${CYAN}⎇ %s${RST}" "$BRANCH"
[ -n "$WT_STATUS" ] && printf " %s" "$WT_STATUS"
[ -n "$CONF_STATUS" ] && printf "   %s" "$CONF_STATUS"
printf "\n"

# --- line 2 : session context · 5h · 7d
CTX_K=$(( CTX_IN / 1000 )); MAX_K=$(( CTX_MAX / 1000 ))
printf "👀 %s ${DIM}%sk/%sk${RST}   ⚡ 5h %s" "$(bar "$CTX_PCT")" "$CTX_K" "$MAX_K" "$(bar "$P5")"
[ "$R5" -gt 0 ] && printf " ${DIM}→ %s${RST}" "$(left "$R5")"
printf "   👾 7d %s" "$(bar "$P7")"
[ "$R7" -gt 0 ] && printf " ${DIM}→ %s${RST}" "$(left "$R7")"
[ -n "$MODEL" ] && printf "   ${GREEN}✦ %s${RST}" "$MODEL"
printf "\n"
