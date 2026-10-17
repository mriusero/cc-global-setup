# Changelog

All notable changes to this plugin. Versions follow [semantic versioning](https://semver.org);
each release is tagged `cc-global-setup--vX.Y.Z`.

## [Unreleased]

## [0.2.0] - 2026-10-17

The pilot, after its first real days: what generalizing the scripts for release had changed is
restored, and instructions now reach a code session reliably.

### Added

- `pilot-send`: delivers an instruction to a code session and checks it was taken. It clears
  leftovers from an idle input box, routes long text through a file and a pointer, retries the
  Enter a paste sometimes swallows, and prints SENT or STUCK.

### Changed

- `pilot-launch` places the Terminal window it opens on the first free third of the screen in
  focus, from the right, so parallel slices sit side by side on any screen.
- `pilot-watch` fires DONE on every new occurrence of the closing phrase, not only on a change of
  state: a session that closes a second time in the same window (after a review, a fix) was
  silent before, and the pilot waited for nothing.
- Pilot skill and brief template: the project's review skills run at the end of the slice, before
  the closing phrase; numbered closing phrases for later rounds; `pilot-send` for everything
  typed into a session.

### Fixed

- `pilot-watch` ignored the brief line quoting the closing phrase by an English wording only, so
  a brief in another language fired a false DONE; any line saying "exact" and the instruction
  typed at the prompt no longer count. Only a real menu or yes/no prompt counts as QUESTION,
  never prose that says "Yes, ".
- `pilot-launch` resolves a relative `PILOT_WT_ROOT` from the repo root, so a project sets it once
  in the env of its `settings.json`.

## [0.1.0] - 2026-10-16

First public version: the user-scope setup I run in every project, packaged as one plugin.

### Highlights

- **Git guard.** Claude asks before `git push`, `git merge`, `gh pr create` and `gh pr merge`, even in auto mode. Commits ask too, unless the project sets `CLAUDE_GIT_GUARD_ALLOW=commit` and the branch isn't protected.
- **Safe rm.** `rm` is rewritten to `trash`, so deletions stay recoverable. A safety net, not a sandbox.
- **Status line.** Context usage, 5-hour and 7-day limits with time to reset, branch, worktree and model. Installed with `/cc-global-setup:setup-statusline`.
- **Project standard.** `/cc-global-setup:project-config` bootstraps or audits a repository's Claude setup (CLAUDE.md or AGENTS.md, `.claude/`). Nine path-scoped guides, checked against Claude Code 2.1.292. A session-start hook flags repositories with no configuration.
- **Pilot.** `/cc-global-setup:pilot` runs a large plan as parallel slices, each in its own git worktree and tmux session, watched by `pilot-watch` and merged one pull request at a time after your approval.

### Configuration

Five switches, asked when the plugin is enabled and editable in `/config`: `git_guard`, `protected_branches`, `safe_rm`, `project_audit`, `pilot_model`.

### Footprint

About 330 tokens of always-on context (three skill descriptions). Hooks run outside the model and cost nothing.

### Install

```text
/plugin marketplace add mriusero/cc-global-setup
/plugin install cc-global-setup@cc-global-setup
/cc-global-setup:setup-statusline
```

Requires Claude Code 2.1.269 or later and `jq`; the pilot also needs `tmux`. Tested on macOS and Linux.
