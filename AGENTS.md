# AGENTS.md

Guidance for any coding agent (Claude Code, Codex, Cursor, Amp, or others)
working on the GhostSpend repository itself. This is separate from
GhostSpend's own skills/agents, which are the *product* this repo ships —
this file is about maintaining the repo.

## Project Overview

GhostSpend is a Claude Code plugin (with standalone-runnable scripts) that
audits a user's local AI CLI environment for token/cost leakage: misconfigured
hooks, dead MCP servers, incomplete plugin builds, project config drift, and
cross-provider spend (Claude Code, Codex CLI, Gemini CLI, etc.) via `ccusage`.

There is no compiled build step for the project itself — everything is
plain bash and Markdown (with YAML frontmatter for skills/agents/commands).

## Repository Structure

Check for an existing configuration file:

```bash
test -f ~/.ghostspend/config.json
```

If missing, run setup first.

```text
.claude-plugin/plugin.json       Plugin manifest — keep in sync with actual
                                  files present in agents/, skills/, commands/
agents/                           Orchestrating agent(s)
skills/<name>/SKILL.md            Diagnostic methodology, one skill per dir
commands/                         Slash commands, prefixed gs- to avoid
                                  collisions with other installed plugins
scripts/                          Standalone bash scripts, no plugin required
```

## Build, Test, and Lint Commands

```bash
shellcheck scripts/*.sh          # required to pass before any script change is merged
bash -n scripts/*.sh              # quick syntax check
./scripts/setup.sh                # interactive, run manually to test
./scripts/ghostspend.sh           # interactive, run manually to test
```

There is no automated test suite yet (see CONTRIBUTING.md's "Good First
Issues" — a `bats-core` test harness with mocked directory fixtures is a
welcome contribution). Until one exists, agents modifying scripts should
run them manually against a real or plausibly-mocked environment and
report the actual output in the PR description, not just claim it works.

## Code Style Rules

- Bash: `set -uo pipefail` at the top of every script. Prefer `[[ ]]` over
  `[ ]`. Must pass `shellcheck` with zero warnings.
- Skill/agent/command Markdown: YAML frontmatter `description` fields must
  be specific and trigger-oriented (they determine when Claude invokes the
  skill) — do not genericize them for brevity.
- Command names in `commands/` must keep the `gs-` prefix. Do not add a
  new command without it; this project deliberately avoids generic names
  like `/setup` or `/audit` due to documented plugin namespace collision
  issues in Claude Code.

## Security Constraints (Non-Negotiable)

- No script or skill may make a network call without an explicit,
  visible user confirmation step first (this includes any `npm install`).
- No script or skill may read, log, or display the contents of `.env`
  files, API keys, tokens, or credentials of any kind.
- Any write action (installing a package, writing `~/.ghostspend/config.json`,
  building a plugin) must prompt for confirmation before executing.
See `SECURITY.md` for the full policy and how to report a vulnerability
found while working on this repo.

## Commit and PR Conventions

- Commit messages: imperative mood, short summary line, e.g. `Fix Codex
  detection path on Linux`.
- Every PR must update `CHANGELOG.md` if it changes behavior, and
  `README.md` if it changes installation or usage.
- Use the PR template in `.github/PULL_REQUEST_TEMPLATE.md` — do not skip
  the "how was this tested" section.

## For Claude Code Specifically

See `CLAUDE.md` at the repo root, which imports this file and adds any
Claude-Code-specific notes on top.
