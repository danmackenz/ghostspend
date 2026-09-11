# Configuration Reference: ~/.ghostspend/config.json

GhostSpend stores its baseline configuration in `~/.ghostspend/config.json`. This file is created by `scripts/setup.sh` (or the `/gs-setup` slash command) on first run and is read by `scripts/ghostspend.sh` on every audit to distinguish expected tool usage from unexpected ("flagged") activity.

This file is personal to your machine and is never committed to a repository — it lives entirely under your home directory, outside of any project folder.

## Location

```json
{
  "known_tools": ["claude-code"],
  "scan_dirs": ["~/Documents/GitHub"]
}
```
~/.ghostspend/config.json
```

## Schema

```json
{
  "knownTools": [
    "claude-code",
    "codex-cli"
  ],
  "createdAt": "2026-09-11T20:00:00Z",
  "lastAuditAt": "2026-09-11T21:00:00Z",
  "ccusageInstalled": true
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `knownTools` | array of strings | Tools you confirmed you actively use during setup. Anything detected on your system with usage data that is **not** in this list gets marked `[FLAGGED]` in audit output. |
| `createdAt` | ISO 8601 string | Timestamp of initial setup. Not modified after creation. |
| `lastAuditAt` | ISO 8601 string | Timestamp of the most recent `/gs-audit` run. Updated automatically each time the audit script completes. |
| `ccusageInstalled` | boolean | Whether `ccusage` was detected as a global install at last check. If `false`, audit output will recommend `npm install -g ccusage` rather than silently falling back to `npx`. |

### Recognized values for `knownTools`

Current detectable tools (see `scripts/ghostspend.sh` for the live detection list, since this expands over time — check `ROADMAP.md` for planned provider additions):

- `claude-code`
- `codex-cli`
- `gemini-cli`
- `copilot-cli`
- `opencode`

## Editing Manually

You can edit this file by hand if you want to adjust your known-tools baseline without re-running setup — for example, after intentionally installing a new CLI tool:

```bash
open ~/.ghostspend/config.json   # macOS
```

Add the tool's identifier (from the recognized values list above) to the `knownTools` array and save. The next `/gs-audit` run will pick up the change immediately; no restart needed.

## Resetting Your Baseline

If you want to start over — for example, after a significant change to your toolchain — delete the file and re-run setup:

```bash
rm ~/.ghostspend/config.json
```

Then run `/gs-setup` again (or `scripts/setup.sh` directly) to rebuild it interactively.

## What This File Does Not Contain

For clarity and to align with `SECURITY.md`: this file never stores API keys, tokens, credentials, spend totals, or any data that leaves your machine. It only stores your own tool preferences and timestamps, used purely to make audit output more useful to you.
