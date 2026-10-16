#!/usr/bin/env bash
# Smoke tests for the hooks, the pilot watcher and the status line. Usage: ./tests/run.sh
cd "$(dirname "$0")/.." || exit 1
pass=0; fail=0
check() { # $1 = name, $2 = expected substring ("" = expect empty output), $3 = actual output
  if { [ -z "$2" ] && [ -z "$3" ]; } || { [ -n "$2" ] && [[ "$3" == *"$2"* ]]; }; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1)); printf 'FAIL %s\n  expected: %q\n  got: %q\n' "$1" "$2" "$3"
  fi
}
bash_input() { jq -n --arg c "$1" --arg d "${2:-$PWD}" '{tool_input: {command: $c}, cwd: $d}'; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"; tmux kill-session -t cgs-test 2>/dev/null' EXIT
git -C "$TMP" init -q -b feat && mkdir -p "$TMP/.claude"

# git-guard
GG=hooks/git-guard.sh
check "push asks"          '"ask"' "$(bash_input 'git push origin main' | bash $GG)"
check "gh pr create asks"  '"ask"' "$(bash_input 'gh pr create --fill' | bash $GG)"
check "chained push asks"  '"ask"' "$(bash_input 'git add . && git push' | bash $GG)"
check "status passes"      ''      "$(bash_input 'git status' | bash $GG)"
check "commit asks without opt-in" '"ask"' "$(bash_input 'git commit -m x' "$TMP" | bash $GG)"
echo '{"env":{"CLAUDE_GIT_GUARD_ALLOW":"commit"}}' > "$TMP/.claude/settings.json"
check "commit passes with opt-in" '' "$(bash_input 'git commit -m x' "$TMP" | bash $GG)"
check "commit asks on custom protected branch" '"ask"' \
  "$(bash_input 'git commit -m x' "$TMP" | CLAUDE_PLUGIN_OPTION_PROTECTED_BRANCHES="feat" bash $GG)"
git -C "$TMP" checkout -q -b main
check "commit asks on main" '"ask"' "$(bash_input 'git commit -m x' "$TMP" | bash $GG)"
check "git_guard=false disables" '' "$(bash_input 'git push' | CLAUDE_PLUGIN_OPTION_GIT_GUARD=false bash $GG)"

# safe-rm
if command -v trash >/dev/null 2>&1; then
  check "rm rewritten"         '"trash foo"'     "$(bash_input 'rm -rf foo' | bash hooks/safe-rm.sh)"
  check "chained rm rewritten" 'cd x && trash y' "$(bash_input 'cd x && rm -f y' | bash hooks/safe-rm.sh)"
  check "rmdir untouched"      ''                "$(bash_input 'rmdir foo' | bash hooks/safe-rm.sh)"
  check "safe_rm=false disables" '' "$(bash_input 'rm foo' | CLAUDE_PLUGIN_OPTION_SAFE_RM=false bash hooks/safe-rm.sh)"
fi

# project-audit
PA=hooks/project-audit.sh
check "audit nudges bare repo"   'missing: CLAUDE.md or AGENTS.md' "$(jq -n --arg d "$TMP" '{cwd: $d}' | bash $PA)"
touch "$TMP/AGENTS.md"
check "audit accepts AGENTS.md"  '' "$(jq -n --arg d "$TMP" '{cwd: $d}' | bash $PA)"
check "audit quiet outside git"  '' "$(jq -n '{cwd: "/"}' | bash $PA)"
rm "$TMP/AGENTS.md"
check "project_audit=false disables" '' "$(jq -n --arg d "$TMP" '{cwd: $d}' | CLAUDE_PLUGIN_OPTION_PROJECT_AUDIT=false bash $PA)"

# pilot-watch: question, then the closing phrase (the brief line quoting it must not count)
if command -v tmux >/dev/null 2>&1; then
  tmux new-session -d -s cgs-test "echo 'stop on the exact phrase SLICE DONE'; sleep 3; echo 'Do you want to proceed? (y/n)'; sleep 8; clear; echo 'SLICE DONE'; sleep 10"
  out=$(bin/pilot-watch cgs-test | grep '^\[' | tr '\n' ' ')
  check "pilot-watch states" '[cgs-test] QUESTION [cgs-test] DONE [cgs-test] SESSION ENDED' "$out"
fi

# statusline
S=statusline/statusline.sh
out=$(jq -n --arg d "$TMP" '{model: {display_name: "Opus 5.5"}, workspace: {current_dir: $d}, version: "2.1.0",
  context_window: {used_percentage: 42, total_input_tokens: 84000, context_window_size: 200000}}' | bash $S)
check "statusline model"         '✦ Opus 5.5' "$out"
check "statusline context"       '84k/200k'   "$out"
check "statusline no limits yet" '—'          "$out"
check "statusline badge"         'conf v2.1'  "$(echo '{"version":"2.1.5"}' | CLAUDE_CONF_STAMP=VERIFIED_VERSION bash $S)"

for f in .claude-plugin/*.json hooks/hooks.json; do
  check "valid json $f" '' "$(jq empty "$f" 2>&1)"
done

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
