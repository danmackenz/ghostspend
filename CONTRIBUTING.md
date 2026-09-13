# Contributing to GhostSpend

Thanks for considering a contribution. GhostSpend exists because a real,
specific token-leakage investigation surfaced patterns worth automating —
the best contributions keep that grounding: real leak patterns, real fixes,
tested against real (or realistically mocked) environments.

## Read This First

The detailed working contract for this repo — code style, verified
commands, architecture rules, task-specific workflows, and the completion
checklist — lives in **`CLAUDE.md`** (also mirrored in **`AGENTS.md`** for
contributors using Codex, Cursor, or other agents). This document covers
the human process around that: how to propose changes, report bugs, and
get a PR merged. Read `CLAUDE.md`/`AGENTS.md` before your first PR;
this file assumes you have.

Also check **`ROADMAP.md`** before opening a feature request — it lists
what's already planned (the `/gs-fix` guided-remediation command is the
current priority, with a full spec at `docs/gs-fix-dev-plan.md`) and what's
permanently out of scope by design (fully autonomous remediation, real-time
monitoring). Proposing something already on the roadmap isn't a problem,
but checking first avoids duplicate discussion threads.

## Before You Start

1. **Check open issues first** — someone may already be working on it.
2. **Check `ROADMAP.md`** — if you want to work on `/gs-fix` specifically,
   start with `docs/gs-fix-dev-plan.md`, which defines the build phases and
   which phase is currently active. Jumping to a later phase before an
   earlier one is merged will likely be asked to wait.
3. **For new checks or leak patterns**, open an issue describing the
   pattern you hit *before* submitting a PR. Include:
   - What tool/config caused the leak
   - How you diagnosed it (commands run, output seen)
   - The fix that resolved it
   This keeps the skills' methodology grounded in real cases rather than
   speculative ones.
4. **For bugs**, use the bug report issue template and include your OS,
   shell (`bash --version`), and the exact command that failed. Note that
   macOS ships **bash 3.2** by default — many bugs only surface there, not
   on a Homebrew-upgraded bash, so mention which one you're using.

## Development Setup

```bash
git clone https://github.com/danmackenz/ghostspend.git
cd ghostspend
chmod +x scripts/*.sh
./scripts/setup.sh
./scripts/ghostspend.sh
```

No build step is required — everything is plain bash and Markdown. There's
no compiled artifact to worry about breaking.

Install `shellcheck` before making script changes (`brew install shellcheck`
on macOS; see your package manager otherwise) — CI will run it against your
PR, so catching issues locally first saves a review round-trip.

## Testing Your Changes

There's no full test suite yet (see "Particularly Welcome Contributions"
below — this is a great place to contribute). In the meantime, follow the
verification steps in `CLAUDE.md`'s "Completion checklist" and the
task-specific workflow matching your change (adding a check, fixing a bug,
modifying a skill/agent, or working on `/gs-fix`). At minimum:

- Run `shellcheck scripts/*.sh` on modified scripts and resolve all findings.
- Run the scripts manually against **stock macOS `/bin/bash` (3.2)**, not
  just an upgraded Homebrew bash — this project deliberately avoids bash4+
  features like `mapfile`, since a large share of users will be on 3.2.
- If you touched a skill or agent Markdown file, actually invoke it in a
  live Claude Code session rather than relying on the diff looking correct.

## Particularly Welcome Contributions

- **`/gs-fix` implementation work** — see `docs/gs-fix-dev-plan.md` for the
  current build phase. Phase 1 (severity classification for existing audit
  findings) is the right entry point even if you're most interested in the
  full interview flow later.
- **Windows-native PowerShell port** of `setup.sh` and `ghostspend.sh`.
- **Automated per-tool drill-down** — currently the audit just names a
  flagged tool and suggests a manual `ccusage <tool> daily`; automating
  that follow-up would be a nice UX improvement.
- **Root-cause tracing** for background tool invocations (cron, launchd,
  CI config, IDE extensions shelling out to Codex/Gemini/subagents).
- **Oversized CLAUDE.md detection** as a new *audit* check (i.e. GhostSpend
  flagging bloated `CLAUDE.md` files in a user's other projects — not a
  change to this repo's own `CLAUDE.md`).
- **Historical trend tracking** — snapshot `ccusage` output over time.
- **Shell test framework** setup (e.g. `bats-core`) with mocked directory
  fixtures, so contributors don't need a "real" leaky environment to test
  against — ideally including a bash 3.2 compatibility test in CI.

## Pull Request Process

1. Fork the repo and create a branch from `main`.
2. Make your change, following `CLAUDE.md`/`AGENTS.md`'s code style and
   architecture rules.
3. Update `README.md` and/or `CHANGELOG.md` if your change affects usage,
   installation, or adds a new check — this is also listed in `CLAUDE.md`'s
   completion checklist. Update `ROADMAP.md` too if your change completes
   or alters a planned item.
4. Open a PR using the pull request template — fill in every section, even
   briefly. PRs without a clear "what leak pattern does this address"
   explanation may be asked for more context before review.
5. Be responsive to review feedback — this is a small project maintained
   in spare time, so quick iteration helps more than a perfect first draft.

## Reporting Security Issues

Do not open a public issue for security concerns (e.g. a way this tool
could expose credentials or be tricked into running unintended commands).
See `SECURITY.md` for the private reporting process.

## Code of Conduct

This project follows the Contributor Covenant — see `CODE_OF_CONDUCT.md`.
Be respectful, be constructive, assume good faith.
