---
name: pilot
description: Run a multi-deliverable plan as parallel "slices": this session becomes the pilot, each slice gets its own git worktree, tmux session and Claude Code session, and the pilot watches, relays questions, reviews and closes them one PR at a time. Use when the user asks to pilot, split or parallelize a plan across sessions.
disable-model-invocation: true
---

# Pilot: parallel slices in worktrees

This session is the **pilot**. It stays in the main checkout, on the base branch, and writes
only docs and plans. **Code sessions** write code, one per slice, each in its own worktree.
Requires `git`, `tmux`, `jq`. Scripts in `${CLAUDE_PLUGIN_ROOT}/bin/`: `pilot-launch`,
`pilot-watch`, `pilot-send`.

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
one commit per deliverable, **the review skills to run at the end** (the project's, chosen by
what the slice touches), never a PR from the code session, and the exact closing phrase
"SLICE DONE". Putting the reviews in the brief saves one round trip per review: the session
runs them, treats the important findings, and closes once.

## 3. Launch
```bash
PILOT_CLAUDE_ARGS="--model ${user_config.pilot_model}" "${CLAUDE_PLUGIN_ROOT}/bin/pilot-launch" <branch> <brief-file>
```
The brief is passed through a file: typed input beyond a few hundred characters sits in the
input box and never submits.

## 4. Watch, and talk to the session
Right after launching, start a persistent Monitor running:
```bash
"${CLAUDE_PLUGIN_ROOT}/bin/pilot-watch" <branch>
```
It prints one line per state worth acting on (QUESTION, DONE, LIMIT, IDLE, SESSION ENDED),
followed by the last 30 lines of the pane. DONE fires again on every new occurrence of the
closing phrase, so a session that closes a second time in the same window is seen.
- **Everything typed into the session goes through `pilot-send`**:
  ```bash
  "${CLAUDE_PLUGIN_ROOT}/bin/pilot-send" <branch> '<short text>'      # an answer, a command
  "${CLAUDE_PLUGIN_ROOT}/bin/pilot-send" <branch> <instruction-file>   # anything longer
  ```
  It clears leftovers from the input box when the session is idle, routes long text through a
  file and a pointer, retries the Enter a paste sometimes swallows, and prints SENT or STUCK.
  Never `tmux send-keys` by hand for text: the input box of Claude Code eats long pastes and
  shows suggested prompts that look like typed text (`❯ continue`) but were typed by nobody.
- **QUESTION**: relay it to the user verbatim; send their answer back with `pilot-send`. A
  permission prompt for a routine `git merge main` into the slice's branch is answered `1` by
  the pilot. The user may also answer directly in the window.
- **LIMIT**: note where the slice stands in its plan; relaunch it from the plan after the reset.
- **IDLE**: look at the pane before assuming anything.
- **After any instruction sent to an idle session, look at the pane two minutes later**: never
  wait on a signal alone. When asking a session for another round (a fix, a review), give it a
  numbered closing phrase ("SLICE DONE 2") so the end of the round is unambiguous.

## 5. Close (one slice at a time)
1. Read the session's closing report: the reviews listed in the brief already ran there. Run a
   review it skipped with `pilot-send`, and a review again on commits made after it.
2. Push the branch, open the PR, wait for CI.
3. **Ask the user to approve the merge, one question per PR.** Never merge without it.
4. Merge, `git worktree remove ../<repo>-wt/<branch>`, kill the tmux session, update the plan,
   launch the next slice from the up-to-date base branch. Slices still running `git merge main`.
