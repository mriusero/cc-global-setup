# Changelog

All notable changes to this plugin. Versions follow [semantic versioning](https://semver.org);
each release is tagged `cc-global-setup--vX.Y.Z`.

## [0.1.0] - Unreleased

First public version.

- Git guard: ask before push, merge and PR commands; commits ask unless the project opts in and the branch isn't protected.
- Safe rm: `rm` rewritten to `trash`.
- Status line with context usage, 5-hour and 7-day limits, worktree and model, installed by `/cc-global-setup:setup-statusline`.
- Project standard: `/cc-global-setup:project-config`, nine path-scoped guides, session-start audit (CLAUDE.md or AGENTS.md).
- Pilot: `/cc-global-setup:pilot`, `pilot-launch` and `pilot-watch` for parallel slices in tmux and git worktrees.
- Every behavior-changing feature can be switched off in `/config`.
