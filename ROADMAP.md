# GhostSpend Roadmap

This document tracks where GhostSpend is headed. It's intentionally short and practical — items get added here when they come from a real, diagnosed problem (a leak someone actually hit), not speculative features. See `CONTRIBUTING.md` for how to propose additions.

## Now (v0.1.x)

- [x] Core audit script (`scripts/ghostspend.sh`) — hooks, MCP connection status, plugin build health, project config drift, cross-provider spend via `ccusage`
- [x] Interactive setup (`scripts/setup.sh`) — dependency check, tool detection, known-tools baseline
- [x] Claude Code plugin packaging — `/gs-setup` and `/gs-audit` slash commands, orchestrator agent
- [x] First public release (`v0.1.0`) — shipped 2026-09-12
- [x] v0.1.1 release polish — verified defects and documentation drift fixed

## Next (v0.2.x) — Guided Remediation: `/gs-fix`

The single highest-value addition planned: turning GhostSpend from a *diagnose-only* tool into a *diagnose-and-guide-the-fix* tool, without ever taking destructive action without explicit, per-fix user approval. Shipped in phases — see `docs/gs-fix-dev-plan.md` for the full plan.

- [x] **Severity classification** added to `/gs-audit` output (Phase 1) — every finding is tagged `critical` / `high` / `medium` / `low` (encoded as `severity|message`) and the summary groups critical-first, so `/gs-fix` can prioritize.
- [x] **`/gs-fix` command, safe-fix-only** (Phase 2) — walks findings critical-first, offering only **Safest** and **Skip** for two finding types (unbuilt plugin, flagged tool). Options are finding-type-aware; unsupported finding types are reported as needing manual follow-up rather than guessed at.
- [x] **`ghostspend-fix` skill** — encodes decision logic for translating a finding + chosen option into an actual proposed command, shown to the user before it runs.
- [x] **Orchestrator update** — `ghostspend-orchestrator` gains a third stage after setup → audit → **fix**, so a user can ask once ("audit and fix my setup") and get the guided flow for supported finding types.
- [ ] **Full 4-option interview flow** (Phase 3) — add **Balanced** and **Other** (free-text, bounded to documented actions) across every finding type in the severity table, not just the two Phase 2 supports.
- [ ] **Orchestrator chaining polish** (Phase 4) — a single request chains setup → audit → fix without re-confirming stages that already ran this session.
- [ ] **Fix history + re-audit diffing** (Phase 5) — log applied fixes; show "resolved since last audit" on the next `/gs-audit` run.

## Next (v0.2.x) — Other Planned Checks

- [ ] **Historical MCP failure detection** — the audit currently probes MCP
  connectivity only at run time (`claude mcp list`). A server that fails and
  retries for an extended period between audits, then happens to be connected
  when the audit runs, is invisible. Scanning Claude Desktop/Code MCP logs for
  repeated connection failures against the same server would catch these retry
  storms. Also not covered today: long-lived VM keepalive loops, and orphaned
  session-storage directories that never appear in the normal session list.
- [ ] **Historical trend tracking** — store audit results over time (e.g. `~/.ghostspend/history/`) so users can see spend/config drift trends across weeks, not just a single point-in-time snapshot
- [ ] **Oversized CLAUDE.md / AGENTS.md detection** — flag project instruction files above a line-count threshold, since these get re-sent as context on every turn and are an under-recognized cost driver
- [ ] **Cron / launchd / scheduled task scanning** — detect background jobs that might be triggering AI CLI tools without the user's direct action (this came up directly from Dan's Codex/Haiku investigation)
- [ ] **IDE extension detection** — flag installed extensions (VS Code, JetBrains) known to call Claude, Codex, Copilot, or Gemini in the background

## Later (Unscheduled)

- [ ] **Windows support** — current scripts are bash/macOS-Linux only; a PowerShell port or WSL-based path is needed for Windows users
- [ ] **More provider coverage** — expand beyond Claude Code, Codex CLI, Gemini CLI, and OpenCode as `ccusage` (or equivalent tooling) adds support for more agentic CLIs. GitHub Copilot CLI is advertised in `README.md`'s intro but has no detection branch in either script yet.
- [ ] **Config file schema versioning** — as `~/.ghostspend/config.json` grows, add a `schemaVersion` field and migration handling so upgrades don't break existing configs
- [ ] **`/gs-fix` execution history** — log which fixes were applied, when, and via which option chosen, feeding into historical trend tracking above
- [ ] **Opt-in anonymized benchmarking** — let users optionally compare their spend/config patterns against anonymized aggregate data from other GhostSpend users (strictly opt-in, no default data collection — see `SECURITY.md`)

## Explicitly Out of Scope

- **Real-time background monitoring** — not currently possible. Claude Code hooks don't receive live token/cost data as input; this is an open upstream feature request, not something GhostSpend can build around today. GhostSpend remains an on-demand audit (and, once `/gs-fix` ships, guided-remediation) tool until that changes.
- **Fully autonomous remediation with no user approval** — even with `/gs-fix` shipped, GhostSpend will never execute a fix without the user selecting an option first for that specific finding. This is a permanent design boundary, not a v0.2 limitation to be removed later. See Security Constraints in `docs/gs-fix-dev-plan.md`.
- **Destructive actions outside documented boundaries** — `/gs-fix`'s "Other" free-text option is bounded by what the underlying skill/agent is explicitly permitted to do (see dev plan). It will not, for example, delete arbitrary files or revoke credentials just because a user's natural-language request implies it — it will explain what it can't do and why.

## How to Propose Something

Open an issue using the feature request template and answer its "how did you diagnose this manually" question — that grounding is what keeps this roadmap tied to real problems rather than guesses.
