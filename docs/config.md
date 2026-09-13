# Configuration Reference: ~/.ghostspend/config.json

GhostSpend stores its baseline configuration in `~/.ghostspend/config.json`. This file is created by `scripts/setup.sh` (or the `/gs-setup` slash command) on first run and is read by `scripts/ghostspend.sh` on every audit to distinguish expected tool usage from unexpected ("flagged") activity.

This file is personal to your machine and is never committed to a repository — it lives entirely under your home directory, outside of any project folder.

## Location

`~/.ghostspend/config.json`

## Schema

```json
{
  "known_tools": ["claude-code", "codex"],
  "scan_dirs": ["/Users/example/Documents/GitHub"],
  "ccusage_installed": true,
  "rtk_installed": false,
  "setup_completed_at": "2026-09-13T20:00:00Z"
}
```

### Fields

| Field | Type | Description |
| --- | --- | --- |
| `known_tools` | array of strings | Tools you confirmed you actively use during setup. Anything detected with local activity that is **not** in this list is marked `[FLAGGED]` in audit output. Matched as a substring, so `codex` matches `codex`. |
| `scan_dirs` | array of strings | Absolute parent directories searched for project-level `.claude/settings.json` and `.mcp.json` drift. Written expanded — `~` is resolved at setup time. |
| `ccusage_installed` | boolean | Whether `ccusage` was on `PATH` at setup time. **Advisory only** — the audit re-checks `command -v ccusage` on every run and does not read this field. |
| `rtk_installed` | boolean | Whether `rtk` was on `PATH` at setup time. **Advisory only**, same as above. |
| `setup_completed_at` | ISO 8601 string | When setup last wrote this file. Not updated by audits. |

### Recognized values for `known_tools`

These are the identifiers `scripts/setup.sh` actually writes:

- `claude-code`
- `codex`
- `gemini`
- `opencode`

`copilot-cli` is listed in `README.md`'s provider coverage but is **not**
currently detected by either script — see `ROADMAP.md`.

## Editing Manually

You can edit this file by hand if you want to adjust your known-tools baseline without re-running setup — for example, after intentionally installing a new CLI tool:

```bash
open ~/.ghostspend/config.json   # macOS
```

Add the tool's identifier (from the recognized values list above) to the `known_tools` array and save. The next `/gs-audit` run will pick up the change immediately; no restart needed.

## Resetting Your Baseline

If you want to start over — for example, after a significant change to your toolchain — delete the file and re-run setup:

```bash
rm ~/.ghostspend/config.json
```

Then run `/gs-setup` again (or `scripts/setup.sh` directly) to rebuild it interactively.

## What This File Does Not Contain

For clarity and to align with `SECURITY.md`: this file never stores API keys, tokens, credentials, spend totals, or any data that leaves your machine. It only stores your own tool preferences and timestamps, used purely to make audit output more useful to you.
