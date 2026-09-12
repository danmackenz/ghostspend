---
name: ghostspend-audit
description: Diagnoses hidden token/cost leakage across a user's AI CLI tools (Claude Code, Codex CLI, Gemini CLI, and others) by checking hooks, MCP server health, plugin build integrity, project-level config drift, and cross-provider spend via ccusage — cross-referenced against the user's known-tools baseline from ghostspend-setup. Use this whenever a user reports unexpectedly high AI tooling spend, wants a routine health check, or asks about background processes / hooks / MCP servers / other CLIs silently consuming tokens.
---

# GhostSpend Audit Skill

## Purpose

Unexpectedly high AI tooling spend is almost never explained by a single
cause, and it is rarely confined to just Claude Code. This skill was built
after a real diagnostic session found:

1. A misidentified local tool mistaken for something suspicious.
2. Hooks running on every command, adding overhead.
3. Failing, duplicated, or misconfigured MCP servers.
4. A cached plugin whose TypeScript source never got built, crashing its
   MCP server on every session.
5. Config drift across 15+ project directories.
6. **Significant spend attributed to tools the user didn't realize they
   were actively running** — Codex CLI and a different Claude model tier
   (Haiku) invoked by background processes, invisible to Claude-only
   tooling like `rtk cc-economics`.

Point 6 is the biggest and easiest-to-miss category, which is why this
skill cross-references spend against a `known_tools` baseline recorded by
the `ghostspend-setup` skill, rather than presenting every tool's spend as
equally expected.

## Prerequisite

Check for `~/.ghostspend/config.json`. If it doesn't exist, defer to the
`ghostspend-setup` skill first (or the `ghostspend-orchestrator` agent,
which handles this automatically) — an audit without a known-tools
baseline can still run, but cannot reliably distinguish expected from
unexpected usage.

## When To Use This Skill

- User reports high or unexplained AI tooling costs (Claude, Codex, or
  otherwise).
- User asks "why is my AI usage so expensive" or "what's using my tokens."
- User wants a periodic health check on hooks, plugins, or MCP servers.
- User mentions background processes, hooks, or agents they didn't
  knowingly start.
- User is surprised by usage from a tool/model they don't think they use.
- User is auditing multiple projects/repos for consistency.

## Procedure

Run via the Bash tool. Expect approval prompts for new command types on
first use — normal Claude Code behavior, not something to bypass.

### Step 1 — Identify unfamiliar binaries before assuming malice

`file <path>` before `cat`-ing an unknown executable. A garbled binary dump
is not inherently a red flag — check `<tool> --version` / `--help` first.

### Step 2 — Audit global and per-project hooks

```bash
cat ~/.claude/settings.json | grep -A 5 hooks
find <project_parent_dirs> -maxdepth 4 -path "*/.claude/settings.json" -exec cat {} \;
```

Hooks merge across global and project scope; a project-local hook does not
replace a global one. Flag only broad-matcher `PreToolUse` hooks with no
clear purpose.

### Step 3 — Check MCP server health

```bash
claude mcp list
```

Categorize: `Needs authentication` (inert, low priority), `CONNECTION_CLOSED`
(likely local process crash, see Step 4), auth/config errors (often a
duplicate of a working entry), `Pending approval` with a project-local
`.mcp.json` path (usually a directory-context artifact).

### Step 4 — Diagnose local MCP server crashes

Run the failing command directly (e.g. `node /path/to/server.js`). A
`MODULE_NOT_FOUND` on a `dist/...` path usually means unbuilt TypeScript
source. Check `package.json` for a `build` script, then, with confirmation:

```bash
cd /path/to/plugin && npm install && npm run build
```

This fix is global if the plugin cache is shared across projects (it
typically is).

### Step 5 — Scan for project-level config drift

```bash
find <parent_dir> -maxdepth 4 -path "*/.claude/settings.json"
find <parent_dir> -maxdepth 3 -iname ".mcp.json" -not -path "*/node_modules/*"
```

Use `scan_dirs` from `~/.ghostspend/config.json` if present; otherwise ask
the user directly rather than guessing at a default layout.

### Step 6 — Validate cross-provider spend

Prefer a global `ccusage` install over `npx` for speed. Run the **combined**
report with no source restriction:

```bash
ccusage daily
```

This surfaces every locally-detected AI CLI tool (Claude Code, Codex CLI,
Gemini CLI, GitHub Copilot CLI, OpenCode, Amp, Droid, Qwen, Grok Build CLI,
and more) in one pass. Cross-reference the tools shown against
`known_tools` in the config file. Any tool with non-trivial spend NOT in
that list is a **flagged finding** — surface it prominently, not as a
routine line item.

Drill into any flagged tool specifically:

```bash
ccusage codex daily
ccusage gemini daily
```

If `rtk` is installed, its `cc-economics` command gives a faster
Claude-Code-only view but never substitutes for the combined `ccusage`
check — always run both.

### Step 7 — Investigate the source of flagged usage

Don't just report the number — help find *why* it ran:

- Cron jobs, launchd agents, or CI pipelines invoking Codex CLI or
  triggering subagent calls on a different model.
- `~/.codex/config.toml` and any `notify` hooks firing automatically.
- IDE extensions that silently shell out to Codex or a Claude subagent.

### Step 8 — Note ecosystem limitations honestly

Claude Code hooks don't currently receive live token/cost data as input
(open upstream feature request). Codex CLI has no native dollar-cost
tracking — `ccusage`'s Codex figures are estimates from token counts
against third-party pricing (LiteLLM), not a confirmed bill. State this
plainly rather than presenting estimates as fact.

## Output Format

A table: Issue | Tool/Provider | Root Cause | Fix | Scope (global/
per-project) | Confirmed vs. Estimated Cost | Status. Flagged unexpected-tool
findings go above the table, not inside it.
