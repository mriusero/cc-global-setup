Code session `<branch>`, worktree `../<repo>-wt/<branch>`, branch of the same name from `main`.
Conventional commits as you go, one per deliverable, free on this branch. **Never open a PR or
run a review from this session**: the pilot session does that. Read first: `AGENTS.md`,
`.claude/plans/wip--<topic>.md` (your plan), and <the docs and files this slice needs>.

# Subject

<Why this slice exists, in a few sentences: the problem observed, with dates and evidence.
Which areas this slice owns, and which it must not touch because another slice holds them
right now (never two sessions on the same module).>

# Deliverables

1. **<Deliverable 1>**: <expected behavior, constraints, the existing style to follow>.
2. **<Deliverable 2>**: <…>.
3. **The proof**: <the exact commands to run and what must be green, and say which ones you
   actually ran>.
4. **Docs, curated not appended**: <which sections to rewrite, which backlog line to delete>.

# Frame

- No new dependency. <Tools allowed.>
- <Commands never to run here, and why (shared resources with sessions in flight).>
- `<check command>` green before each commit. <Known red tests that are not this slice's.>
- Anything you discover that is out of scope goes in your final message, not in the backlog.

# End

Stop on the exact phrase "SLICE DONE", followed by a three-line summary: what was delivered,
what you actually ran to prove it, what remains open.
