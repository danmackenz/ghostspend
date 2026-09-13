# <img src="docs/assets/ghostspend-icon.png" alt="GhostSpend logo" width="48" valign="middle"/> GhostSpend

Find the AI spend you didn't know you had — and the exact steps to fix it.

GhostSpend audits your entire AI CLI toolchain (Claude Code, Codex, Gemini CLI, Copilot, and more) for hidden cost leaks: misfiring hooks, dead or duplicated MCP servers, unbuilt plugins, config drift across projects, and spend from tools you didn't realize were running. It doesn't just report a number — it flags what's unexpected and tells you precisely what to run to fix it.

This is a free, open-source Claude Code plugin (and standalone script) that finds hidden token/cost leakage across your **entire AI CLI toolchain** — not just Claude Code, but Codex CLI, Gemini CLI, GitHub Copilot CLI, and others — plus misconfigured hooks, dead or duplicated MCP servers, plugins that never finished building, and project-level config drift across multiple repos.

Born from a real diagnostic session that traced an unexpectedly high weekly spend down to specific causes, including a genuine surprise: a chunk of spend was coming from **Codex CLI and OpenCode** — tools the user hadn't confirmed as part of their active workflow — invisible to Claude-only tools, and only surfaced by checking cross-provider usage logs.

## What Makes GhostSpend Different

Most usage trackers show you a number. GhostSpend asks *"did you expect this?"* — it records a one-time baseline of which AI tools you actually, knowingly use, then flags anything outside that baseline on every future audit, front and center, instead of burying it in a combined total.

## What It Checks

| # | Check | Why it matters |
| --- | --- | --- |
| 1 | Global hooks (`~/.claude/settings.json`) | Hooks firing on every tool call add overhead |
| 2 | MCP server connectivity (`claude mcp list`) | Failed/duplicated servers indicate stale config |
| 3 | Plugin build integrity | Cached plugins shipped as TypeScript source sometimes never get built, causing silent connection failures every session |
| 4 | Project-level config drift | Individual repos can carry `.claude/settings.json` or `.mcp.json` that duplicates or conflicts with global config |
| 5 | **Cross-provider spend** (via `ccusage`) | Surfaces Codex CLI, Gemini CLI, OpenCode, and other tool usage in one combined report |
| 6 | **Unexpected-tool flagging** (Codex CLI, Gemini CLI, OpenCode) | Cross-references local activity against your known-tools baseline — the core feature |
| 7 | Orphaned AI CLI processes | Catches zombie processes left running after a crashed connection |

## Important Limitations (Read Before Relying On This)

- **On-demand audit, not real-time monitoring.** Claude Code hooks don't currently receive live token/cost data as input — an [open upstream feature request](https://github.com/anthropics/claude-code/issues/11008), not something GhostSpend can work around. Run it periodically; don't expect automatic alerts.
- **Uses your existing Bash tool permissions.** No special access is requested beyond what Claude Code's Bash tool already has. Expect approval prompts for new command types on first run unless pre-approved in `settings.json`.
- **Doesn't auto-fix anything.** It diagnoses and proposes fixes; Claude will ask for confirmation before any write action or install.
- **Codex CLI has no native dollar-cost tracking.** `ccusage`'s Codex figures are *estimates* from token counts against third-party pricing data (LiteLLM), not an OpenAI-confirmed bill. GhostSpend reports this distinction rather than presenting estimates as fact.
- **Doesn't explain *why* a background tool ran.** It flags *that* a tool has unexpected spend and points toward likely causes (cron jobs, launchd agents, IDE extensions, notify hooks), but tracing the exact trigger is a manual follow-up.
- **bash 3.2 compatible by design.** macOS ships bash 3.2 by default (no `mapfile`, no bash4+ features). Both scripts are deliberately written to run on stock macOS without requiring a Homebrew bash upgrade.

## Prerequisites

These are the only things you need *before* cloning and running setup — everything else (`ccusage`, `rtk`) is detected and offered for install interactively by `setup.sh`, so it isn't duplicated here.

| Requirement | Why | Install command (if missing) |
| --- | --- | --- |
| `git` | To clone the repo | macOS: `xcode-select --install` · Debian/Ubuntu: `sudo apt install git` |
| `bash` | Runs the scripts (3.2+ is fine — no upgrade needed on macOS) | Pre-installed on macOS and Linux |
| `node` + `npm` | Required by `ccusage` (and `rtk`, optional) | macOS: `brew install node` · Debian/Ubuntu: `sudo apt install nodejs npm` · or [nodejs.org](https://nodejs.org) |
| Homebrew (macOS only, optional) | Convenience for installing `node` and, for contributors, `shellcheck` | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |

Contributors modifying the scripts also need `shellcheck` (`brew install shellcheck` on macOS) — this is a dev-only dependency, not required for end users running the tool.

## Installation

### Option A: As a Claude Code plugin (recommended)

```bash
git clone https://github.com/danmackenz/ghostspend.git
mkdir -p ~/.claude/plugins/ghostspend
rsync -a --exclude='.git' --exclude='.github' --exclude='CONTRIBUTING.md' --exclude='SECURITY.md' --exclude='CODE_OF_CONDUCT.md' \
  ghostspend/ ~/.claude/plugins/ghostspend/
chmod +x ~/.claude/plugins/ghostspend/scripts/*.sh
```

Restart Claude Code, then run `/gs-setup` once, followed by `/gs-audit` any time.

Once published to a marketplace, you can add it either from the terminal inside Claude Code:

```bash
/plugin marketplace add danmackenz/ghostspend
/plugin install ghostspend
```

...or from the Claude Desktop app GUI:

1. Open Claude Code inside Claude Desktop.
2. Go to **Settings → Plugins → Add → Add marketplace**.
3. Choose **Add from a repository** (syncs a plugin marketplace from a GitHub repository or Git URL).
4. Paste the GhostSpend Git repository URL.
5. Click **Sync**.

### Option B: Standalone scripts (no Claude Code required)

```bash
git clone https://github.com/danmackenz/ghostspend.git
cd ghostspend/scripts
chmod +x setup.sh ghostspend.sh
./setup.sh
./ghostspend.sh
```

`setup.sh` will check for `ccusage` and offer to run `npm install -g ccusage` for you if it's missing — you don't need to do this manually first.

## Usage

**Inside Claude Code:**

```bash
/gs-setup
/gs-audit
```

Or just ask: *"Run a GhostSpend audit across all my AI tools."* The `ghostspend-orchestrator` agent handles running setup first if needed, then the audit, then presents one consolidated report with flagged findings at the top.

**From any terminal:**

```bash
./scripts/setup.sh                                             # one-time, interactive
./scripts/ghostspend.sh                                        # run any time after
./scripts/ghostspend.sh ~/Documents/GitHub "~/Documents/Claude Projects"
```

Quote any path containing spaces. If you skip `setup.sh`, `ghostspend.sh` still works, just without unexpected-usage flagging.

To check a specific tool directly:

```bash
ccusage codex daily
ccusage gemini daily
```

## Troubleshooting

### "ccusage not installed" warning

GhostSpend depends on [`ccusage`](https://www.npmjs.com/package/ccusage) for cross-provider token/spend data. If you see a warning instead of numbers, install it globally so audits run faster and don't re-fetch it via `npx` every time:

```bash
npm install -g ccusage
```

Verify it worked:

```bash
which ccusage
ccusage --version
```

### No usage data shows up for today

If you've hit a weekly or usage-window limit on Claude Code (or another provider), new API calls are blocked until the limit resets — meaning **no new spend is being recorded at all**, not that everything is suddenly efficient. A flat total right after hitting a cap doesn't mean a fix worked; it means data collection paused. Re-run the audit after your limit window resets for a meaningful comparison.

### A tool shows up as detected but has $0 spend

GhostSpend's tool detection checks for the *presence* of a tool's local config/data directory (e.g. `~/.codex`, `~/.gemini`, `~/.config/opencode`), separately from whether `ccusage` reports any spend for it. A tool can be installed with no recent usage — this isn't an error, just a heads-up in case you forgot you installed it.

**A tool I use is showing as `[FLAGGED]`**

This means the tool has usage data but isn't in the `known_tools` array in `~/.ghostspend/config.json`. This is expected the first time you add a new tool to your workflow. Fix it by re-running `./scripts/setup.sh` (or `/gs-setup`) and answering `y` when asked about that tool, or by editing the config manually — see [`docs/config.md`](docs/config.md) for the exact schema.

### Codex CLI spend numbers look approximate

This is expected, not a bug. Codex CLI has no native dollar-cost tracking; `ccusage`'s Codex figures are estimates derived from token counts against third-party pricing data (LiteLLM), not an OpenAI-confirmed bill. Treat Codex figures as directional, not exact, when making budget decisions.

**`shellcheck: command not found`**

This only affects contributors modifying the scripts, not end users running them. Install it via Homebrew:

```bash
brew install shellcheck
```

### Scripts fail with "permission denied"

Make sure the scripts are executable:

```bash
chmod +x scripts/*.sh
```

### Claude Code prompts for approval on every command

This is expected behavior, not a bug in GhostSpend. The plugin runs standard shell commands (`find`, `pgrep`, `claude mcp list`, etc.) through Claude Code's normal Bash tool — the same approval flow that applies to any command Claude Code runs on your behalf. GhostSpend does not request or need any special permission tier beyond what Claude Code already provides.

### Windows

GhostSpend's scripts are bash-based and currently only tested on macOS and Linux. Windows users should run them inside WSL. Native Windows/PowerShell support is tracked in [`ROADMAP.md`](ROADMAP.md) — contributions welcome.

## Platform Notes

- **macOS/Linux**: Works as-is, including stock macOS bash 3.2 — no Homebrew bash upgrade required to *run* the tool (only to *develop* it, for `shellcheck`).
- **Windows**: Run via WSL or Git Bash; native PowerShell not yet supported (good first contribution — see below).
- **Requires**: `bash`, `find`, `grep`, `pgrep`. Strongly recommended: `ccusage` for the cross-provider spend check (needs `node`/`npm`). Optional: `rtk` for a faster Claude-Code-only savings summary.

## Repository Structure

```bash
ghostspend/
├── .claude-plugin/
│   ├── plugin.json                    # Plugin manifest
│   └── marketplace.json               # Plugin marketplace manifest
├── agents/
│   └── ghostspend-orchestrator.md     # Orchestrates setup + audit into one report
├── skills/
│   ├── ghostspend-setup/
│   │   └── SKILL.md                   # First-run baseline configuration
│   └── ghostspend-audit/
│       └── SKILL.md                   # Full diagnostic methodology
├── commands/
│   ├── gs-setup.md                    # /gs-setup slash command
│   └── gs-audit.md                    # /gs-audit slash command
├── scripts/
│   ├── setup.sh                       # Interactive, standalone-runnable, bash 3.2-compatible
│   └── ghostspend.sh                  # Interactive, standalone-runnable, bash 3.2-compatible
├── examples/
│   └── sample-audit-output.md         # Real worked example: raw ccusage → flagged report
├── docs/
│   ├── config.md                      # ~/.ghostspend/config.json schema reference
│   └── gs-fix-dev-plan.md             # /gs-fix engineering spec (planned v0.2.x)
├── .github/                           # Issue templates, PR template, CI workflow
├── CLAUDE.md                          # Project contract Claude Code reads when developing this repo
├── AGENTS.md                          # Same contributor guidance, portable to Codex/Cursor/other agents
├── ROADMAP.md                         # Planned checks and explicit out-of-scope items
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── package.json
└── README.md
```

### A note on CLAUDE.md and AGENTS.md

GhostSpend is a Claude Code plugin, but this repo's *own source code* is also maintained with AI coding agents — so it uses the same `CLAUDE.md`/`AGENTS.md` pattern documented for any Claude Code project. `CLAUDE.md` is the full project contract (commands, architecture rules, task workflows, security constraints, completion checklist) that Claude Code reads automatically when you work in this repo. `AGENTS.md` mirrors that same guidance in the portable, cross-tool format used by Codex, Cursor, and other agents — since this project's own contributors may well be using tools other than Claude Code to submit PRs.

Don't confuse these with `skills/` and `agents/` in the plugin structure above — those are GhostSpend's *product*, shipped to end users. `CLAUDE.md`/`AGENTS.md` govern how anyone (human or AI) works on *this repository*.

## Contributing

Issues and PRs welcome. See [`ROADMAP.md`](ROADMAP.md) for planned work and what's explicitly out of scope. Particularly useful contributions:

- **Windows-native PowerShell port** of both scripts.
- **More provider-specific drill-downs** — automatically running `ccusage <tool> daily` for every flagged tool instead of just naming it.
- **Root-cause tracing for background tool invocations** — scanning `launchd`/`cron`/CI config for anything that shells out to Codex, Gemini CLI, or triggers a Claude subagent with a non-default model.
- **Oversized CLAUDE.md detection** — large project instruction files get re-sent as context every turn (this would be a new *audit check*, not a change to this repo's own `CLAUDE.md`).
- **Historical trend tracking** — snapshotting `ccusage` output over time to show whether fixes actually reduced spend.
- **Test coverage** for both scripts against mocked directory structures, including a bash 3.2 compatibility test in CI.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full process, and [`CLAUDE.md`](CLAUDE.md) / [`AGENTS.md`](AGENTS.md) for the working conventions this repo expects from any contributor, human or AI.

## License

MIT — use, fork, and adapt freely. See [`LICENSE`](LICENSE).
