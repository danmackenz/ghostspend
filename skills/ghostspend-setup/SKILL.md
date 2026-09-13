---
name: ghostspend-setup
description: First-run configuration for GhostSpend — installs/verifies ccusage, records which AI CLI tools the user actually uses on purpose, and stores project scan directories. Use this before the first ghostspend-audit run, or when the user wants to reconfigure known tools or scan paths.
---

# GhostSpend Setup Skill

## Purpose

The audit skill's most valuable output — flagging spend from a tool the
user didn't know was running — only works if GhostSpend knows which tools
the user *does* expect to use. This skill builds that baseline once, so
every future audit can compare against it automatically instead of asking
the user to re-explain their setup each time.

## When To Use This Skill

- First time GhostSpend runs on a machine (no `~/.ghostspend/config.json`).
- User explicitly asks to reconfigure, add a newly-adopted tool, or update
  their project scan paths.

## Procedure

### Step 1 — Check dependencies

```bash
command -v ccusage >/dev/null 2>&1 && echo "ccusage: installed" || echo "ccusage: MISSING"
command -v claude >/dev/null 2>&1 && echo "claude: installed" || echo "claude: MISSING"
command -v rtk >/dev/null 2>&1 && echo "rtk: installed (optional)" || echo "rtk: not installed (optional)"
```

If `ccusage` is missing, ask the user for confirmation before installing —
this is a global npm install and should not happen silently:

```bash
npm install -g ccusage
```

If the user declines, note that the audit skill will fall back to
`npx ccusage`, which works but is slower on every run.

### Step 2 — Detect which AI CLI tools have local activity at all

```bash
ls -d ~/.codex ~/.gemini ~/.config/opencode ~/.claude 2>/dev/null
```

Present whatever is found to the user as a checklist-style question: "I
found local data for: Claude Code, Codex CLI. Which of these do you
actively and knowingly use? (Anything you don't select will be flagged
in future audits if it shows spend.)"

Do not assume — always ask. A tool with local data but no recent use is
exactly the ambiguous case GhostSpend exists to catch, so don't pre-filter
it out based on your own guess.

### Step 3 — Record project scan directories

Ask the user where their coding projects live (they may have multiple
parent folders, as in the original diagnostic case: a GitHub folder plus
one or two tool-specific folders). Do not assume `~/Documents` or
`~/Projects` — ask directly, since layouts vary widely.

### Step 4 — Write the config file

Create `~/.ghostspend/config.json` (confirm with the user before writing,
since this is a new file on their system):

```json
{
  "known_tools": ["claude-code", "codex"],
  "scan_dirs": ["/Users/example/Documents/GitHub"],
  "ccusage_installed": true,
  "rtk_installed": true,
  "setup_completed_at": "<ISO 8601 timestamp>"
}
```

### Step 5 — Suggest (don't apply) permission pre-approval

Explain that GhostSpend's audit will trigger Bash tool approval prompts for
commands like `find`, `claude mcp list`, and `ccusage` on first use. If the
user wants to reduce prompt friction for future runs, show them the
relevant addition to their `~/.claude/settings.json` permissions allowlist,
but let them decide whether to add it — do not edit their settings file
without explicit confirmation.

### Step 6 — Hand off

Once config is written (or confirmed as unchanged), ask the user directly: "GhostSpend setup complete. Ready to run an audit? (yes/no)" Keep the command name out of the visible question — this is a plain yes/no prompt, not a suggestion to type a command.

- If the user answers **yes**, invoke the `ghostspend-audit` skill immediately. Do not wait for the user to separately run `/gs-audit`.
- If the user answers **no**, confirm that `/gs-audit` remains available any time they're ready, and end the setup skill there.

## Output Format

A short confirmation summary: what was installed, what tools were marked
as known vs. unknown, what directories will be scanned, and where the
config file now lives — followed by the yes/no audit prompt described in
Step 6.
