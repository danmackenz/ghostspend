# Security Policy

## Scope

GhostSpend is a diagnostic tool that runs shell commands (via Claude Code's
Bash tool or directly) to inspect your local Claude Code configuration,
MCP server status, plugin installations, and AI CLI usage logs. It does
not transmit any data off your machine — every check reads local files or
runs local commands only. `ccusage` itself is also local-first and does not
upload usage data.

Security concerns relevant to this project generally fall into one of two
categories:

1. **A GhostSpend script or skill could be tricked into running an
   unintended or destructive command.**
2. **A GhostSpend script could expose sensitive local data** (API keys,
   tokens, file contents) that it shouldn't need to read.

## Supported Versions

| Version | Supported |
| :------ | :-------: |
| 0.1.x   | Yes       |

As a young project, only the latest released version receives security
fixes. Please update before reporting an issue to confirm it still applies.

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Instead:

1. Open a private security advisory via GitHub's "Report a vulnerability"
   feature on this repository (Security tab → Advisories → New draft
   security advisory), or
2. If that's unavailable, open an issue with minimal detail (e.g. "Security
   concern — please contact me privately") and a maintainer will follow up
   for details via a private channel.

Please include:

- The specific script, skill, or command involved
- Steps to reproduce
- The potential impact (what could go wrong, and for whom)

## What To Expect

- Acknowledgement of your report within a reasonable time given this is a
  community-maintained project, not a funded security team.
- An assessment of severity and, if confirmed, a fix released as a patch
  version with a corresponding `CHANGELOG.md` entry (credited to you unless
  you prefer otherwise).
- Public disclosure only after a fix is available, coordinated with you.

## Design Principles That Limit Risk

- All destructive or write actions (installing `ccusage`, building a
  plugin, writing config files) require explicit user confirmation before
  execution — this is enforced by Claude Code's own tool-use safety model
  when run as a plugin, and by explicit `read -rp` confirmation prompts
  when run as standalone scripts.
- No network calls are made by GhostSpend's own code. `npm install -g
  ccusage` and `npm install` (for plugin builds) are the only exceptions,
  and both require your prior confirmation.
- No credentials, API keys, or `.env` file contents are read or displayed
  by any check.

## Forward-Looking: `/gs-fix` (Planned)

GhostSpend's roadmap (see `ROADMAP.md` and `docs/gs-fix-dev-plan.md`)
includes a planned `/gs-fix` command that will propose concrete remediation
actions for findings surfaced by `/gs-audit`. This section exists to state,
in advance of that feature shipping, that it will not weaken any principle
above:

- `/gs-fix` will never execute an action without showing the exact command
  or file diff and receiving explicit per-finding approval — including for
  its planned free-text "Other" option, which is bounded to a documented
  set of permitted actions and will decline (with an explanation) anything
  outside that boundary rather than attempting it.
- `/gs-fix` will not disable, modify, or remove another vendor's CLI tool
  (Codex, Gemini, Copilot, etc.) directly. It only ever touches
  GhostSpend's own config or, with explicit confirmation, files the user
  already granted `/gs-audit` permission to read.
- If this changes during implementation, this section and
  `docs/gs-fix-dev-plan.md`'s Security Constraints will be updated together,
  and the change will be called out explicitly in `CHANGELOG.md` — it will
  not be a silent scope expansion.
