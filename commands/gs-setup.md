---
description: Run first-time GhostSpend setup — detect installed AI CLI tools and record your known-tools baseline
---

# /gs-setup

Run the `ghostspend-setup` skill's full procedure now:

1. Check whether `~/.ghostspend/config.json` already exists. If it does,
   tell the user and ask if they want to reconfigure or just review current
   settings, rather than overwriting silently.

2. Check for `ccusage`, `claude`, and `rtk` on PATH via the Bash tool.

3. If `ccusage` is missing, ask for confirmation before running
   `npm install -g ccusage` — do not install without an explicit yes.

4. Detect local data directories for known AI CLI tools (`~/.codex`,
   `~/.gemini`, `~/.config/opencode`, `~/.claude`) and ask the user which
   ones they actively and knowingly use.

5. Ask the user for their project parent directory path(s) to scan in
   future audits.

6. Confirm with the user, then write `~/.ghostspend/config.json` with the
   collected answers.

7. Summarize what was recorded and let the user know `/gs-audit` is ready
   to use.
