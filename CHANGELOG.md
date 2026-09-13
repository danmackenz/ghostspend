# Changelog

All notable changes to GhostSpend are documented here.

## [Unreleased]

## [0.1.1] — 2026-09-13

### Added

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
  including the `known_tools` field that drives unexpected-usage flagging.
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
  `package.json` alongside the existing `plugin.json` check. Fixed YAML
  indentation that made three workflow files invalid (#10).

### Fixed

- `scripts/setup.sh`: fixed a bash 3.2 crash on stock macOS — `"${arr[@]}"`
  on an empty array is an unbound-variable error under `set -u`. With no
  detected AI-tool data directories, setup died before the scan-dir prompt;
  declining every detected tool printed the error mid-run and produced the
  right JSON only by accident. Also closes two dead-end exits (existing
  config, aborted write) that stopped instead of offering to run an audit,
  and drops an "in the background" instruction that would have hidden
  interactive audit output.
- `scripts/ghostspend.sh`: the plugin-health "OK" line was suppressed
  whenever any earlier section had already recorded a finding — now scoped
  to a section-local counter. The project-config-drift check printed counts
  but never produced a finding; it now flags project-level `.mcp.json`
  files. Removed an unconditional pseudo-finding that made the
  clean-environment "Environment looks clean" branch unreachable whenever
  `ccusage` ran. Collapsed three near-identical per-tool detection blocks
  into one table-driven loop.
- `package.json`: `bin` and `npm run setup` pointed at
  `./scripts/gs-setup.sh`, which doesn't exist; corrected to
  `./scripts/setup.sh`. Also corrected `homepage`, `repository.url`, and
  `bugs.url` from the stale `danmackenzie` owner to the real `danmackenz`.
- `CONTRIBUTING.md`: corrected the clone URL to the real repo owner.
- `docs/config.md`: rewritten against the actual snake_case schema
  (`known_tools`, `scan_dirs`, `ccusage_installed`, `rtk_installed`,
  `setup_completed_at`) — the previous camelCase schema never existed.
  Also fixed five code fences closed with `` ```json `` instead of a bare
  closer, which mangled rendering from the Location section down.
- `examples/sample-audit-output.md`: fixed two tagged closing fences that
  rendered the rest of the file as one code block.
- `README.md`: fixed the repository structure diagram (`marketplace.json`
  lives under `.claude-plugin/`, not the repo root; added the new
  `docs/gs-fix-dev-plan.md` entry), corrected the stale `/audit` reference,
  and stopped over-claiming `copilot-cli` coverage in the "What It Checks"
  table (neither script has a detection branch for it yet).
- `.claude-plugin/marketplace.json`: the marketplace-level `version` was
  `1.0.0` for a 0.1.x project; aligned to the plugin's actual version.
- `.github/workflows/ci.yml`: added a fence-style check — a closing fence
  tagged with its opening language (e.g. `` ```json ``) is not recognized
  as a closer, and `markdownlint` does not catch this class of bug.

## [0.1.0] — 2026-09-12

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
