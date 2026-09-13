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

7. Summarize what was recorded, then ask: "GhostSpend setup complete. Ready to run an audit? (yes/no)" Do not mention `/gs-audit` by name in the question itself. If the user answers yes, immediately invoke the `ghostspend-audit` skill — do not wait for the user to type `/gs-audit` separately. If the user answers no, simply confirm that `/gs-audit` is available whenever they're ready.
