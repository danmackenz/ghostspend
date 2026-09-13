# Example: Real GhostSpend Audit Output

This file lives at `examples/sample-audit-output.md` and shows an actual
`./scripts/ghostspend.sh` run end-to-end — not a mocked example. It's taken
from the diagnostic session that GhostSpend was built from, lightly
redacted to remove personal service URLs and domain names (replaced with
`<redacted>` where they don't affect the pattern being demonstrated).

## 1. Config At Time Of Audit

`~/.ghostspend/config.json`, written by `./scripts/setup.sh`:

```json
{
  "known_tools": ["claude-code","opencode"],
  "scan_dirs": ["/Users/exampleuser/Documents/GitHub"],
  "ccusage_installed": true,
  "rtk_installed": true,
  "setup_completed_at": "2026-09-11T21:26:20Z"
}
```

Note: `codex` and `gemini` were detected on disk during setup but the user
answered "no" when asked if they actively use them — so they are **not**
in `known_tools`. That's the baseline GhostSpend checks future spend
against.

## 2. Full Audit Run

```text
$ ./scripts/ghostspend.sh

== 0. GhostSpend configuration ==
[OK] Config found at /Users/exampleuser/.ghostspend/config.json
  Known tools: "known_tools": ["claude-code","opencode"]

== 1. Global hook configuration ==
[OK] Global hooks found in /Users/exampleuser/.claude/settings.json
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [

== 2. MCP server connectivity ==
Checking MCP server health…
[... 28 servers connected, output truncated for brevity ...]
plugin:github:github: <redacted> (HTTP) - ✘ Failed to connect — HTTP 400: Error POSTing to endpoint: bad request: Authorization header is badly formatted
ai-clarity-scanner: <redacted> (HTTP) - ✘ Failed to connect — Protected resource <redacted> does not match expected <redacted> (or origin)
[FAIL] 2 MCP server(s) failed to connect

== 3. Installed plugin build health (missing dist/ detection) ==

== 4. Project-level config drift across scanned directories ==
  Scanning: /Users/exampleuser/Documents/GitHub
    - Local settings.json files: 14
    - Local .mcp.json files: 2

== 5. Cross-provider AI token spend (ccusage) ==
[OK] ccusage found globally — using installed binary
--- Combined daily report (all detected AI CLI tools) ---

╭────────────────────────────────────────────╮
│  Coding (Agent) CLI Usage Report - Daily   │
│     Detected: Claude, Codex, OpenCode      │
╰────────────────────────────────────────────╯

┌────────────┬───────────────┬────────────┬─────────────┐
│ Date       │ Agent         │ ...        │  Cost (USD) │
├────────────┼───────────────┼────────────┼─────────────┤
│ 2026-08-03 │ - Codex       │ gpt-5.6-terra │      $0.36 │
│ 2026-08-04 │ - Codex       │ gpt-5.5, gpt-5.6-terra │ $2.11 │
│ 2026-08-18 │ - OpenCode    │ big-pickle, etc. │    $0.28 │
│ ...        │ - Claude      │ various       │  (full total: $443.41 across all tools) │
└────────────┴───────────────┴────────────┴─────────────┘
WARN  Missing pricing for big-pickle; cost excludes this model.

--- Per-tool presence check ---
[WARN] Codex CLI local data found at ~/.codex
[WARN] Gemini CLI local data found at ~/.gemini
[WARN] OpenCode local data found at ~/.config/opencode

--- Unexpected usage check (against your known_tools list) ---
[FLAGGED] Codex CLI has local activity but is NOT in your known_tools list. Run 'ccusage codex daily' to see its spend.
[FLAGGED] Gemini CLI has local activity but is NOT in your known_tools list. Run 'ccusage gemini daily' to see its spend.

== 6. Zombie / orphaned AI CLI processes ==
[... 2 legitimate long-running MCP node processes, not zombies ...]

== Summary ==
FLAGGED: Unexpected usage from: codex gemini
2 issue(s) found:
  1. 2 MCP server(s) failing — see list above for reasons (auth, config mismatch, missing build)
  2. Review the combined ccusage report above for spend attributed to tools outside your known-tools baseline.

Done. Re-run after applying fixes to confirm they took effect.
```

## 3. What This Demonstrates

Two real findings came out of a single run that a Claude-only usage report
would never have surfaced:

- **Codex CLI spend on 2026-08-03 and 08-04** ($0.36 + $2.11) — small in
  isolation, but invisible in every Claude-specific tool the user had
  checked before running GhostSpend.
- **Gemini CLI flagged purely on presence** — `~/.gemini` exists on disk
  even though `ccusage` showed no billed activity for it in this window.
  GhostSpend still surfaces this, since a tool with no *recent* spend can
  still represent forgotten setup worth reviewing.

Note that `opencode` was **not** flagged, even though it has real spend in
the ccusage table — because the user confirmed during `./scripts/setup.sh`
that they do knowingly use it. This is the core mechanic: GhostSpend
doesn't flag total spend, it flags spend from tools **outside your
declared baseline**.

## 4. What The User Did Next

In the real case this is drawn from, the flagged Codex activity was traced
to prior manual CLI usage the user had genuinely forgotten about, rather
than a rogue background process. GhostSpend's job stopped at flagging it
clearly — it does not auto-disable or reconfigure anything on its own (see
`SECURITY.md` and `ROADMAP.md` for why this is a deliberate design choice,
not a missing feature).
