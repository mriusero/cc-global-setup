---
paths:
  - "**/.claude/plans/**"
---

# Project plans (.claude/plans/): house convention

- Every multi-session work plan lives in `.claude/plans/<status>--<slug>.md`.
  Statuses: `todo` (defined, not started) · `wip` (in progress) · `stby` (paused: note why
  and the condition to resume) · `done` (closed). A transition = renaming the file.
- A plan approved in plan mode is materialized here (`wip--…`) before execution; at session
  start, `ls .claude/plans/` shows the project's state at a glance.
- Content of an active plan: goal, steps with status, decisions taken along the way (with
  the why), blockers. Update IN PLACE during the session. Curation, not a log: rewrite
  sections, don't append.
- On close (`done--`): shrink the file drastically into a summary (~20-40 lines): goal, what
  was done, decisions and their why, possible follow-ups. Execution detail lives in git.
