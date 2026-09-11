---
description: Run the full GhostSpend audit — hooks, MCP servers, plugin build health, project config drift, and cross-provider AI token spend, flagged against your known-tools baseline.
---

Invoke the `ghostspend-orchestrator` agent to run the complete GhostSpend
workflow:

1. If `~/.ghostspend/config.json` does not exist yet, run first-time setup
   (`ghostspend-setup` skill, or tell the user to run `/gs-setup`) before
   auditing — an audit without a known-tools baseline can't reliably flag
   unexpected usage.

2. Run the `ghostspend-audit` skill's full procedure, using `scan_dirs`
   from the config file if present, or asking the user directly if not.

3. Cross-reference `ccusage daily` output against `known_tools` in the
   config. Elevate any tool with spend that isn't in that list to a
   flagged finding at the top of the report.

4. Present one consolidated report: flagged unexpected usage first, then
   hooks/MCP/plugin/config findings as a table, then the overall spend
   snapshot (labeling confirmed vs. estimated costs), then prioritized
   next steps.

5. Confirm with the user before applying any fix (builds, config edits,
   scheduled jobs).
