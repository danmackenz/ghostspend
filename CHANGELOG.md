# Changelog

All notable changes to GhostSpend are documented here.

## [Unreleased]

### Added (initial release)

- `CLAUDE.md`: full project contract for this repo (not the plugin
  product) — commands, architecture rules, task workflows, security
  constraints, and a completion checklist, following documented Claude
  Code `CLAUDE.md` best practices.
- `AGENTS.md`: portable mirror of the same contributor guidance, readable
  by Codex, Cursor, and other non-Claude-Code coding agents.
- `.gitignore`: added `CLAUDE.local.md` and `.claude/settings.local.json`
  so personal/local instruction overrides are never committed.
- `ROADMAP.md`: planned work, prioritized (`/gs-fix` guided remediation is
  next), and an explicit "out of scope" section documenting permanent
  design boundaries (no fully-autonomous remediation, no real-time
  monitoring).
- `docs/config.md`: full schema reference for `~/.ghostspend/config.json`,
  including the `knownTools` field that drives unexpected-usage flagging.
- `docs/gs-fix-dev-plan.md`: working engineering spec for the planned
  `/gs-fix` command — interview-style remediation flow, severity
  classification, worked examples per finding type, and non-negotiable
  security constraints.
- `examples/sample-audit-output.md`: a worked, end-to-end example showing
  raw `ccusage` output, a sample `~/.ghostspend/config.json`, and the
  resulting flagged `/gs-audit` report, modeled on a real diagnosed case.
- `README.md`: new `## Troubleshooting` section covering the most common
  first-run issues (missing `ccusage`, usage-limit blocking fresh data,
  flagged-but-expected tools, Codex cost estimates, permission prompts).

### Changed

- `README.md`: repository structure diagram now lists `CLAUDE.md`,
  `AGENTS.md`, `ROADMAP.md`, `docs/`, and `examples/`, with a short note
  distinguishing `CLAUDE.md`/`AGENTS.md` from the plugin's own
  `skills/`/`agents/` product directories.
- `CONTRIBUTING.md`: now points contributors to `CLAUDE.md`/`AGENTS.md` as
  the authoritative working contract instead of duplicating code-style and
  testing guidance in two places. Also now points to `ROADMAP.md` before
  opening a feature request, to avoid duplicate proposals.
- `CLAUDE.md`: repository map updated to include `docs/`, `examples/`, and
  `ROADMAP.md`. Clarified the existing "no sample config files in repo
  root" rule to explicitly permit documentation-oriented walkthroughs in
  `examples/`, since that rule was originally aimed at preventing a fake
  `~/.ghostspend/config.json` from being committed, not at banning worked
  examples.
- `SECURITY.md`: added a forward-looking note confirming the planned
  `/gs-fix` command will preserve the same confirmation-required principle
  that governs every write action today — this is a permanent boundary,
  not something relaxed as scope grows.
- `.github/workflows/ci.yml`: corrected YAML indentation (previous version
  would have failed to parse), and expanded markdown-lint scope to include
  `docs/**/*.md`, `examples/**/*.md`, `ROADMAP.md`, `CONTRIBUTING.md`, and
  `SECURITY.md`. Added JSON validation for `marketplace.json` and
  `package.json` alongside the existing `plugin.json` check.

## [0.1.0] — Initial release

### Added

- `ghostspend-audit` skill: full diagnostic methodology covering hooks, MCP
  server health, plugin build integrity, project-level config drift, and
  cross-provider spend via `ccusage`.
- `ghostspend-setup` skill: first-run baseline configuration — records which
  AI CLI tools the user actively uses, installs `ccusage` if missing (with
  confirmation), and stores project scan directories.
- `ghostspend-orchestrator` agent: coordinates setup and audit into a single
  consolidated report, with flagged unexpected-tool usage surfaced first.
- `/gs-setup` and `/gs-audit` slash commands (prefixed to avoid namespace
  collisions with other installed plugins).
- Standalone `setup.sh` and `ghostspend.sh` scripts, usable without Claude
  Code entirely.
- Cross-provider detection for Codex CLI, Gemini CLI, and OpenCode local
  data directories.
- Config file at `~/.ghostspend/config.json` storing the known-tools
  baseline and scan directories between runs.

### Known Limitations

- No real-time monitoring — Claude Code hooks do not currently expose live
  token/cost data, so this remains an on-demand audit tool.
- Codex CLI spend figures are estimates (no native OpenAI cost API used by
  `ccusage`'s Codex data source).
- Windows support requires WSL or Git Bash; no native PowerShell port yet.
