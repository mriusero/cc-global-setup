---
name: pilot
description: Run a multi-deliverable plan as parallel "slices": this session becomes the pilot, each slice gets its own git worktree, tmux session and Claude Code session, and the pilot watches, relays questions, reviews and closes them one PR at a time. Use when the user asks to pilot, split or parallelize a plan across sessions.
disable-model-invocation: true
---

# Pilot: parallel slices in worktrees

This session is the **pilot**. It stays in the main checkout, on the base branch, and writes
only docs and plans. **Code sessions** write code, one per slice, each in its own worktree.
Requires `git`, `tmux`, `jq`. Scripts: `${CLAUDE_PLUGIN_ROOT}/bin/pilot-launch` and
`${CLAUDE_PLUGIN_ROOT}/bin/pilot-watch`.

## 1. Split
- Start from a plan in `.claude/plans/wip--<topic>.md`. Cut it into slices of 2–3 deliverables.
- **Never two slices on the same module at the same time.** Note who owns what.
- Name each slice after its branch (`feat-search`, `chore-db-per-worktree`): the same name is
  used for the worktree and the tmux session: the only name the user sees.
- Confirm the split with the user before launching anything.

## 2. Brief
Write one brief per slice from `${CLAUDE_PLUGIN_ROOT}/templates/brief.md`, **outside the repo**
(next to the worktrees, e.g. `../<repo>-wt/briefs/<branch>.md`). It must state: what to read,
numbered deliverables, owned and forbidden areas, commands never to run, the proof required,
one commit per deliverable, never a PR or review from the code session, and the exact closing
phrase "SLICE DONE".

## 3. Launch
```bash
PILOT_CLAUDE_ARGS="--model ${user_config.pilot_model}" "${CLAUDE_PLUGIN_ROOT}/bin/pilot-launch" <branch> <brief-file>
```
The brief is passed through a file: typed input beyond ~1000 characters gets truncated.

## 4. Watch
Right after launching, start a persistent Monitor running:
```bash
"${CLAUDE_PLUGIN_ROOT}/bin/pilot-watch" <branch>
```
It prints one line per state change (QUESTION, DONE, LIMIT, IDLE, SESSION ENDED), followed by
the last 30 lines of the pane.
- **QUESTION**: relay it to the user verbatim; type their answer back with
  `tmux send-keys -t <branch> '<answer>' Enter` (check it was sent: a second Enter is sometimes needed).
  The user may also answer directly in the window.
- **LIMIT**: note where the slice stands in its plan; relaunch it from the plan after the reset.
- **IDLE**: look at the pane before assuming anything.
- Mid-session instructions: write them to a file and send a short pointer, never a long paste.

## 5. Close (one slice at a time)
1. In the code session, run the project's review skills if it has any, on its branch.
2. Push the branch, open the PR, wait for CI.
3. **Ask the user to approve the merge, one question per PR.** Never merge without it.
4. Merge, `git worktree remove ../<repo>-wt/<branch>`, kill the tmux session, update the plan,
   launch the next slice from the up-to-date base branch. Slices still running `git merge main`.
