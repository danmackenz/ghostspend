# AGENTS.md

Guidance for coding agents working on the GhostSpend repository itself. This
includes Claude Code, Codex, Cursor, Amp, and other coding agents. This file
is separate from GhostSpend's own skills and agents, which are the product
shipped by this repository.

## Project Overview

GhostSpend is a Claude Code plugin with standalone-runnable scripts. It audits
a user's local AI CLI environment for token and cost leakage, including
misconfigured hooks, unavailable MCP servers, incomplete plugin builds,
project configuration drift, and cross-provider spend.

Supported examples include Claude Code, Codex CLI, and Gemini CLI, with usage
data read through `ccusage`.

The repository has no compiled build step. It consists of Bash scripts and
Markdown files with YAML frontmatter for skills, agents, and commands.

## Repository Structure

Check for an existing configuration file:

```bash
test -f ~/.ghostspend/config.json
```

If the configuration file is missing, run setup first.

```text
.claude-plugin/plugin.json        Plugin manifest; keep it synchronized with
                                  files in agents/, skills/, and commands/
agents/                           Orchestrating agents
skills/<name>/SKILL.md            Diagnostic methodology, one skill per directory
commands/                         Slash commands with the gs- prefix
scripts/                          Standalone Bash scripts
```

## Build, Test, and Lint Commands

```bash
shellcheck scripts/*.sh           # required before script changes are merged
bash -n scripts/*.sh              # quick syntax check
./scripts/setup.sh                # interactive manual test
./scripts/ghostspend.sh           # interactive manual test
```

There is no automated test suite yet. See the “Good First Issues” section in
`CONTRIBUTING.md` for a proposed `bats-core` test harness with mocked
directory fixtures.

Until automated tests exist, agents modifying scripts must run them manually
against a real or plausibly mocked environment. Report the actual output in
the pull request rather than claiming that the scripts work without testing.

## Code Style Rules

- Bash scripts must use `set -uo pipefail` near the top. Prefer `[[ ]]` over
  `[ ]`. Scripts must pass ShellCheck with zero warnings.
- Skill, agent, and command Markdown files must use YAML frontmatter.
  `description` fields must be specific and trigger-oriented because they
  determine when Claude invokes the skill.
- Commands in `commands/` must retain the `gs-` prefix. Do not add generic
  commands such as `/setup` or `/audit`; the prefix avoids collisions with
  other installed plugins.

## Security Constraints

These constraints are non-negotiable:

- No script or skill may make a network call without explicit, visible user
  confirmation first. This includes `npm install`.
- No script or skill may read, log, or display `.env` files, API keys, tokens,
  or credentials of any kind.
- Any write action must prompt for confirmation before it executes. Examples
  include installing a package, writing
  `~/.ghostspend/config.json`, and building a plugin.
- See `SECURITY.md` for the complete policy and vulnerability-reporting
  instructions.

## Commit and Pull Request Conventions

- Use imperative commit messages with a short summary line. Example:
  `Fix Codex detection path on Linux`.
- Every pull request must update `CHANGELOG.md` when behavior changes.
- Update `README.md` when installation or usage changes.
- Use `.github/PULL_REQUEST_TEMPLATE.md` and complete its testing section.

## For Claude Code Specifically

See `CLAUDE.md` at the repository root. It imports this file and adds
Claude-Code-specific instructions.
