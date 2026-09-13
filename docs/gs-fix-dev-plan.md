# Dev Plan: `/gs-fix` Guided Remediation

Status: Phases 1-2 shipped in v0.2.0; Phases 3-5 planned. This document lives at `docs/gs-fix-dev-plan.md` and is the working spec referenced from `ROADMAP.md`. It should be updated as design decisions are made, not treated as frozen.

## 1. Goal

Turn GhostSpend from diagnose-only into diagnose-and-guide-the-fix, while preserving the project's core trust principle established since v0.1: **GhostSpend never takes destructive or spend-affecting action without explicit, per-finding user approval.**

## 2. User Flow

```text
User runs /gs-audit
   → findings produced, each tagged with severity (critical/high/medium/low)
User runs /gs-fix
   → orchestrator loads most recent audit findings
   → for each finding (grouped by severity, critical first):
       presents the finding + 4 options:

       1. Safest fix       — lowest-risk, most conservative action
       2. Balanced fix      — resolves this + remaining critical/high, defers medium/low
       3. Skip for now       — acknowledged, suppressed from re-flagging until next full audit
       4. Other (describe)  — free-text; agent proposes a custom action within its
                               documented permission boundaries, or explains why it can't

   → user selects one option per finding (or applies "balanced" once, globally)
   → for any option that involves a real system action (installing a package,
     editing a config file, running a build command), GhostSpend shows the
     EXACT command it will run and requires a final yes/no before executing
   → summary report at the end: what was fixed, what was skipped, what needs
     manual follow-up
```

## 3. New Components

| Component | Type | Purpose |
| --- | --- | --- |
| `commands/gs-fix.md` | slash command | Entry point, `/gs-fix` |
| `skills/ghostspend-fix/SKILL.md` | skill | Decision logic: finding + severity + chosen option → concrete proposed action |
| `ghostspend-orchestrator.md` | agent (updated) | Extended to a 3-stage flow: setup → audit → fix, invocable individually or as one request |

## 4. Severity Classification (Prerequisite Change to `/gs-audit`)

Before `/gs-fix` can prioritize anything, every audit finding needs a severity tag. Proposed default mapping (adjustable, should live in `ghostspend-audit/SKILL.md`, not hardcoded in the fix skill):

| Finding type | Default severity |
| --- | --- |
| Unbuilt plugin (missing `dist/`) causing connection failure | Critical |
| MCP server failed to connect (auth/config error) | High |
| Flagged unexpected tool with active spend | High |
| Duplicate/conflicting project-level `.mcp.json` or `settings.json` | Medium |
| MCP server needs auth (not yet connected, no spend impact) | Low |
| Detected-but-unused tool with $0 spend | Low |

This table should be user-overridable later (v0.3+) but ships with sensible defaults for v0.2.

## 5. Mapping Options to Actions — Worked Examples

**Finding: unbuilt plugin, missing `dist/` (Critical)**

- Option 1 (Safest): run `npm install && npm run build` in the plugin directory, verify `dist/` exists, verify `claude mcp list` shows Connected
- Option 2 (Balanced): same as Option 1 — no lesser-risk alternative exists for a broken build
- Option 3 (Skip): note it in the summary as unresolved, re-flag on next `/gs-audit`
- Option 4 (Other): user might say "just disable that plugin instead" → agent proposes removing the plugin's entry from the relevant config instead of building it, shows the exact diff, asks for confirmation

**Finding: flagged codex-cli usage, not in `knownTools` (High)**

- Option 1 (Safest): do nothing to the tool itself; just ask the user "is this expected?" and update `~/.ghostspend/config.json` accordingly — zero risk of breaking a workflow the user actually wanted
- Option 2 (Balanced): same as Option 1 for this finding type — GhostSpend should never disable another vendor's CLI tool automatically, since it may be intentionally used elsewhere (e.g. a separate script)
- Option 3 (Skip): leave flagged, re-appears next audit
- Option 4 (Other): user says "find what's calling it" → agent runs the launchd/cron scanning checks (once built, see Roadmap "Later" section) and reports findings, still without disabling anything

**Finding: duplicate `.mcp.json` causing "Pending approval" ghost entry (Medium)**

- Option 1 (Safest): explain the cause (directory-context artifact), no file changes needed, just advises running future commands from the correct working directory
- Option 2 (Balanced): same
- Option 3 (Skip): no-op, informational only
- Option 4 (Other): user asks to delete the stray `.mcp.json` — agent shows the file content first, confirms it's safe to remove, then proposes the `rm` command for approval

This table illustrates an important pattern: **for many finding types, options 1 and 2 converge on the same safe action**, because there often isn't a meaningfully riskier "more thorough" version of the fix. The 3-option framing still matters most for findings where a real tradeoff exists (e.g. "fix everything now" vs "fix only what's breaking things today").

## 6. Security Constraints (Non-Negotiable, Ties to `SECURITY.md`)

- No fix is ever executed without the exact command/diff being shown to the user first, per finding.
- `/gs-fix` never disables, deletes, or modifies another vendor's CLI tool (Codex, Gemini, Copilot) directly — it only ever touches GhostSpend's own config (`~/.ghostspend/config.json`) or, with explicit confirmation, files inside the user's own Claude Code / project configuration that GhostSpend already had permission to read during `/gs-audit`.
- The "Other" free-text option is explicitly bounded: if a user's request falls outside documented actions (e.g. "delete my node_modules," "revoke my API key"), the agent must decline and explain why, rather than attempting it. This boundary list should be maintained in `ghostspend-fix/SKILL.md` and referenced in `SECURITY.md`.
- All fix actions should be logged (once history tracking ships) so a user can review what GhostSpend has changed over time.

## 7. Build Phases

**Phase 1 — Severity tagging — SHIPPED (v0.2.0)**
Add severity classification to existing `/gs-audit` output. No new user-facing command yet. Validates the categorization logic against real findings before building the interview flow on top of it.

**Phase 2 — `/gs-fix` skeleton, safe-fix-only — SHIPPED (v0.2.0)**
Ship `/gs-fix` supporting only Option 1 (Safest) and Option 3 (Skip) for a limited set of finding types (start with the two most common: unbuilt plugin, flagged tool). Prove the confirmation-gated execution flow works reliably before adding complexity. `ghostspend-orchestrator` also gained a basic third stage here (ask to proceed to remediation, hand off to `ghostspend-fix`) — the fuller chaining polish described in Phase 4 below is still open.

**Phase 3 — Full 4-option interview flow**
Add Option 2 (Balanced) and Option 4 (Other) across all finding types from the severity table. This is where the free-text boundary-checking logic needs the most testing.

**Phase 4 — Orchestrator integration**
Update `ghostspend-orchestrator.md` so a single natural-language request ("audit and fix my Claude setup") chains all three stages, asking only once per stage transition rather than re-confirming setup/audit steps that already ran.

**Phase 5 — Fix history + re-audit diffing**
Log applied fixes; on the next `/gs-audit`, show "resolved since last audit" alongside new findings, closing the loop the user asked about back when validating whether fixes were actually working.

## 8. Testing Plan

- Unit-style tests (extend `tests/` conventions from `CONTRIBUTING.md`) mocking each finding type and asserting the correct action is proposed for each of the 4 options
- Manual test: run against a deliberately broken setup (recreate the original unbuilt-plugin scenario) and confirm `/gs-fix` proposes exactly `npm install && npm run build`
- Boundary test: explicitly try "Other" requests that should be declined (e.g. "delete this MCP server's credentials") and confirm the agent refuses with an explanation rather than attempting it

## 9. Open Questions (Resolve Before Phase 2)

- **RESOLVED (2026-09-13):** Options are **finding-type-aware**. Each finding
  type declares which of the four options are meaningful for it; `/gs-fix`
  renders only those. Presenting two identical choices as a tradeoff erodes
  trust in the prompt.
- **RESOLVED (2026-09-13):** No `scripts/ghostspend-fix.sh` standalone
  fallback for now. The interview flow is the feature and requires Claude
  Code; a bash version would cover only trivial fixes while creating a second
  copy of the severity/action mapping to keep in sync. README notes the limit.
- Where does fix history live — inside `~/.ghostspend/config.json` or a separate `~/.ghostspend/history/` directory (as already flagged in `ROADMAP.md`)? Recommend the latter to avoid the config file growing unbounded.
- Should `/gs-fix` require a fresh `/gs-audit` run if the most recent one is older than some threshold (e.g. 24 hours), to avoid fixing stale findings? Recommend yes, with a user override.
