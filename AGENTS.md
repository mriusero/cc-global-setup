# cc-global-setup

One Claude Code plugin at the repo root, listed by `.claude-plugin/marketplace.json` (`source: "./"`).
Everything is bash + jq. Its author uses it daily, installed from this working copy.

- The installed plugin is a copy in Claude Code's plugin cache, not this working copy. Try a change
  live with `claude --plugin-dir .`; once committed, `claude plugin marketplace update
  cc-global-setup`, `claude plugin update cc-global-setup@cc-global-setup`, then restart.
- Run `./tests/run.sh` after touching hooks, `bin/` or the status line; add a case for new behavior.
- Portable to macOS: bash 3.2, BSD sed (`[[:space:]]`, not `\s`), no `timeout`.
- Each feature that can be unwanted is a `userConfig` switch in `plugin.json`; hooks read it as
  `CLAUDE_PLUGIN_OPTION_<KEY>` and exit 0 when it is `false`.
- Validate with `claude plugin validate .` and `claude plugin validate .claude-plugin/plugin.json`.
- Release: bump `version` in `plugin.json` (semver: major = option/command renamed or removed or a
  default changes behavior, from 1.0 on; minor = new feature or option, and before 1.0 any
  behavior change; patch = fixes, guides refreshed),
  update the README version badge, move the `CHANGELOG.md` section from Unreleased to the date,
  commit, then `claude plugin tag --push`: the release workflow publishes the GitHub release.
- Raise the minimum Claude Code version in the README (badge + Requirements) when using a newer feature.
- After re-checking `rules/` against the official docs, write the Claude Code version to `VERIFIED_VERSION`.
- Nothing personal or project-specific here: personal config stays in the author's `~/.claude`.
- Personal repo: no contributions accepted (README, "About this repository").
