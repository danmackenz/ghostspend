---
name: ghostspend-fix
description: Walks the user through remediating findings from a GhostSpend audit one at a time, proposing a concrete fix per finding and executing nothing without showing the exact command and receiving explicit approval. Use after ghostspend-audit has produced findings, or when the user asks to fix, remediate, or clean up issues GhostSpend reported.
---

# GhostSpend Fix Skill

## Purpose

`ghostspend-audit` diagnoses; this skill guides remediation without ever
taking a destructive or spend-affecting action on its own. Every proposed
fix is shown to the user verbatim — the exact command or file diff — before
it runs. This is a permanent boundary (see `SECURITY.md` and
`docs/gs-fix-dev-plan.md` Section 6), not a v0.2 limitation to be relaxed
later.

This phase (Phase 2 of the dev plan) supports only two options per finding:
**Safest** and **Skip**. **Balanced** and **Other** (free-text) are Phase 3
and are not implemented here — do not improvise them.

## Freshness Gate

Before acting on any finding, confirm it came from a recent `ghostspend-audit`
run. If `~/.ghostspend/config.json`'s `setup_completed_at` is absent, or you
have no evidence an audit ran this session, re-run `ghostspend-audit` rather
than acting on findings you cannot confirm are current. Offer the user an
override ("use the findings I already have") if they'd rather not re-audit.

## Option Model — Finding-Type-Aware

Each finding type declares which options are actually meaningful for it.
Render only those. **Never present two options that would execute the
identical action** — that erodes trust in the prompt (see dev plan §9,
resolved 2026-09-13). If a finding type isn't in the table below, it isn't
supported yet in this phase — say so and stop (see "Everything Else" below).

## Supported Finding Types This Phase

Findings arrive from `scripts/ghostspend.sh` encoded as `severity|message`
(see `skills/ghostspend-audit/SKILL.md`'s Severity Classification table).
Match on the message content to identify the finding type below.

| Finding | Severity | Safest | Skip |
| --- | --- | --- | --- |
| Unbuilt plugin, missing main entry (message matches "Plugin at ... declares main entry ... but the file doesn't exist") | critical | Show `cd "<plugin_dir>" && npm install && npm run build` exactly as it appears in the finding message. On confirmation, run it, then re-run `claude mcp list` to confirm the affected server now shows Connected. | Report unresolved in the fix summary; it will re-flag on the next `/gs-audit`. Take no action. |
| Flagged tool not in `known_tools` (message matches "... has local activity and is not in known_tools (...)") | high | Ask the user directly: "Is `<tool>` expected?" On yes, add the tool's identifier to the `known_tools` array in `~/.ghostspend/config.json` — show the exact before/after JSON diff first. **Never** touch the vendor's CLI itself (do not disable, uninstall, or reconfigure Codex/Gemini/OpenCode). | Leave the finding as-is; it reappears on the next `/gs-audit`. Take no action. |

## Everything Else In This Phase

For any finding type not in the table above (MCP pending-approval, project-
level `.mcp.json` drift, or anything else `ghostspend-audit` produces),
report it as **"not yet supported by `/gs-fix` — manual follow-up needed"**
and move to the next finding. Do not invent a plausible-looking fix for an
unsupported type; that is exactly the kind of unreviewed action this skill
exists to prevent.

## Hard Boundaries

These mirror `SECURITY.md` and apply without exception:

- Never disable, delete, uninstall, or reconfigure another vendor's CLI tool
  (Codex, Gemini, Copilot, OpenCode) directly. The only file this skill
  writes to is `~/.ghostspend/config.json`.
- Never execute a command or write a file without first showing the user
  the exact command or diff and receiving an explicit yes.
- If a user's request (even a "Safest" or "Skip" follow-up question) implies
  an action outside the two tables above, decline and explain why, rather
  than attempting a plausible-sounding substitute.
- No network call (e.g. `npm install`) proceeds without the same explicit
  confirmation step already required by `CLAUDE.md`'s non-negotiables.

## Procedure

1. Confirm a recent audit exists (Freshness Gate above). If not, re-run
   `ghostspend-audit` or get the user's explicit override.
2. Sort findings critical → high → medium → low (already the order
   `scripts/ghostspend.sh` prints them in).
3. For each finding, in order:
   - If its type is in the Supported Finding Types table, present only
     **Safest** and **Skip** (never more, never less).
   - If its type is not in that table, report it as unsupported per
     "Everything Else" and move on — do not ask the user to choose between
     options that don't exist yet.
4. On **Safest**, show the exact command or diff, wait for an explicit yes,
   then execute and confirm the result (e.g. re-check `claude mcp list`).
5. On **Skip**, take no action and note it as skipped in the summary.
6. Close with a summary: what was fixed, what was skipped, what needs
   manual follow-up (unsupported types), grouped the same way the audit
   summary is.
