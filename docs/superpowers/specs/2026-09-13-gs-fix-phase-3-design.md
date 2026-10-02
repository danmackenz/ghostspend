# Design: `/gs-fix` Phase 3 — Full 4-Option Interview Flow

Status: Approved by user in brainstorming session, 2026-09-13. Feeds into an
implementation plan via `superpowers:writing-plans`.

## Context

`v0.2.0` (merged via PR #12, commit `27bda0e`) shipped severity classification
plus `/gs-fix` Phases 1-2: `Safest` and `Skip` only, for 2 of the 5 finding
types in `skills/ghostspend-audit/SKILL.md`'s severity table (unbuilt plugin,
flagged tool). This design covers Phase 3 per `docs/gs-fix-dev-plan.md` §7:
adding `Balanced` and `Other` (free-text, boundary-checked), across all 5
finding types.

This is the first genuinely unplanned work in the GhostSpend line. The prior
release-polish plan explicitly scoped Phase 3 out. `docs/gs-fix-dev-plan.md`
§9's two already-resolved open questions (finding-type-aware options; no
standalone bash fallback) stand and are not relitigated here. Its other two
open questions (fix-history location, staleness threshold) belong to Phase 5
and are out of scope here.

## Live-test finding (informs the plan's verification section)

The Milestone B live-test of `/gs-fix` was deferred as "not drivable from a
non-interactive Bash tool." That is no longer true: driving an interactive
`claude --plugin-dir` session via `tmux send-keys` / `capture-pane` works and
was used to verify Phase 2 behavior during this design's research (confirmed:
plugin loads from the working tree, `/gs-audit` and `/gs-fix` both dispatch,
Phase 2's Safest/Skip-only behavior for the one supported critical finding is
exactly as `SKILL.md` documents, unsupported types correctly fall to manual
follow-up).

**Incident during that test:** a blind `Down Down` + `Enter` keystroke
sequence (intended to reach a "Type something" menu option) instead landed on
and confirmed the already-highlighted "Safest — run it" option, which
executed a real `npm install && npm run build` against
`project-health-auditor`'s actual plugin cache directory before it could be
interrupted. The build succeeded and fixed a genuinely broken plugin, but it
ran without genuine per-action user consent — simulated keystrokes are not a
substitute for a real yes. The implementation plan's verification section
must bake in the fix: **always `capture-pane` and read the exact highlighted
option before sending `Enter`**, and during live tests of any confirmation
prompt, **default to declining/Skip** unless a fix is actually intended.

## Decisions

### 1. Balanced is a global batch mode, not a 4th per-finding option

Walking through `docs/gs-fix-dev-plan.md` §5's worked examples plus the new
MCP-failing case (decision 3 below) shows `Balanced` and `Safest` resolve to
the *identical action* for every finding type GhostSpend currently handles —
there is no finding where a "more thorough but riskier" alternative
meaningfully exists. Phase 2's `SKILL.md` already has a hard rule: *"Never
present two options that would execute the identical action."* Presenting
`Balanced` as a 4th per-finding button would violate that rule outright.

Re-reading `docs/gs-fix-dev-plan.md` §2, `Balanced` was already described as
a global mode — *"user selects one option per finding (or applies 'balanced'
once, globally)"*. Phase 3 implements it that way:

- When 2+ critical/high findings exist, `/gs-fix` offers a mode choice before
  the per-finding walkthrough: **"Fix all critical/high now (each still
  shown and confirmed individually), defer medium/low"** vs. **"walk through
  one at a time."**
- With 0 or 1 critical/high findings, skip this choice entirely — it's
  ceremony with nothing to batch. Go straight to the walkthrough.
- Choosing the batch mode does **not** skip per-action confirmation.
  `CLAUDE.md`'s non-negotiable ("no fix ... may execute ... without explicit,
  per-finding user confirmation") and `docs/gs-fix-dev-plan.md` §6 apply
  unconditionally. Batch mode only skips *re-asking which option to use* for
  each critical/high finding (it always applies that finding's Safest
  action) and defers medium/low findings automatically instead of asking
  about each one.
- Per-finding, only **Safest / Skip / Other** are ever rendered. `Balanced`
  never appears as a per-finding option label.

### 2. Per-finding-type option table (all 5 types)

| Finding | Severity | Safest (= Balanced's per-finding action) | Skip | Other (bounded) |
| --- | --- | --- | --- | --- |
| Unbuilt plugin, missing main entry | critical | *(unchanged from Phase 2)* Show `cd "<plugin_dir>" && npm install && npm run build` exactly as in the finding message; on yes, run it, then re-run `claude mcp list` to confirm Connected. | *(unchanged)* Take no action; re-flags next audit. | "Disable it instead" → show the diff removing that one plugin's key from `~/.claude/settings.json`'s `enabledPlugins`; on yes, apply. |
| Flagged tool not in `known_tools` | high | *(unchanged from Phase 2)* Ask "is `<tool>` expected?"; on yes, show the exact before/after JSON diff adding it to `~/.ghostspend/config.json`; on yes, write it. Never touch the vendor CLI itself. | *(unchanged)* Take no action; re-flags next audit. | "Find what's calling it" → read-only investigation (`launchctl list`, `crontab -l`, the tool's own config file) — report findings, change nothing. |
| MCP server(s) failing to connect | high | **New.** For each server `claude mcp list` shows failing, run the audit's Step-4 diagnostic (invoke the server's command directly to categorize the failure). If it resolves to a missing-build cause, fold into the identical build-fix action as the unbuilt-plugin row (same command, same confirmation, same verification). If it resolves to auth/config, report the per-server cause and stop — no command is proposed; it goes to manual follow-up like today. | Take no action; re-flags next audit. | "Just remove that server" → show the diff removing the one named failing server's entry from its config file (project `.mcp.json` or global MCP config, whichever the finding named); on yes, apply. |
| MCP server(s) pending approval | low | No file changes; explain the duplicate-`.mcp.json` cause (directory-context artifact) and advise running future commands from the correct working directory. | Take no action (already effectively a no-op). | "Delete the stray file" → show the full file content of the one named `.mcp.json`; on yes, `rm` it. |
| Project-level `.mcp.json` drift | medium | No file changes; same explanation as above. | Take no action. | Same as the row above — show content, confirm, `rm` the one named file. |

### 3. The MCP-failing finding's diagnostic step reuses, never duplicates, the build-fix logic

`scripts/ghostspend.sh`'s "MCP server(s) failing to connect" finding is a
bare count with no pre-diagnosed cause (`"... see list above for reasons
(auth, config mismatch, missing build)"`), unlike the other four finding
types which are already root-caused at audit time. Phase 3 does not add a
new fix action for this — it adds a **diagnostic step** (per
`skills/ghostspend-audit/SKILL.md` Step 4: run the failing server's command
directly, check for `MODULE_NOT_FOUND` on a `dist/...` path) that, when it
resolves to "missing build," produces exactly the same proposed command and
confirmation flow already defined for the unbuilt-plugin row. This keeps one
fix implementation instead of two near-duplicate ones. Auth/config causes are
not fixable by GhostSpend and always fall to manual follow-up, matching
`docs/gs-fix-dev-plan.md`'s existing stance that GhostSpend never touches
authentication.

### 4. "Other" free-text boundary

Since `ghostspend-fix` is a markdown-driven skill with no code-level
enforcement, the boundary is a documented allow-list Claude checks a request
against — the same governance style as the existing Hard Boundaries section,
made concrete enough to be mechanically checkable rather than a vague "stay
safe" instruction.

**In bounds** — and only ever targeting a file/entry/command a finding
already named, never a fresh target the user picks on the spot:

- Read-only investigation (any command; no dependency on a pre-built
  scanning feature existing first)
- Edit `~/.ghostspend/config.json` (`known_tools`, `scan_dirs` only)
- Edit `~/.claude/settings.json`'s `enabledPlugins` key, for one
  already-named plugin only
- Delete one already-named stray `.mcp.json` file
- Remove one already-named MCP server entry from its config file
- Run the already-shown plugin build command for an already-named plugin
  directory

**Out of bounds — decline and explain, never attempt a plausible
substitute:**

- Anything touching a vendor CLI's own binary, config, or credentials
  (Codex, Gemini, Copilot, OpenCode)
- Deleting or rotating credentials, tokens, API keys, or `.env` files
- Any `~/.claude/settings.json` key other than the one named plugin's
  `enabledPlugins` entry (global hooks stay off-limits)
- Any file or target not already named by a specific finding
- Any network call beyond the one already-shown, already-confirmed build
  command
- Broad or destructive operations (`rm -rf`, deleting directories, bulk file
  operations)

Every in-bounds `Other` action still requires the identical show-command/
diff-then-explicit-yes gate as `Safest` — `Other` changes *what* is proposed,
never *whether* it's confirmed first. Every decline names the specific
boundary line it hit rather than a generic refusal, and always ends with
"manual follow-up" framing rather than a dead end.

## Non-Goals (explicitly out of scope for Phase 3)

- Fix-history logging and re-audit diffing (Phase 5, `docs/gs-fix-dev-plan.md`
  §7)
- A staleness threshold on how old an audit can be before `/gs-fix` requires
  a re-run (open question in dev plan §9, unresolved, not part of this phase)
- Any change to `scripts/ghostspend.sh` or `skills/ghostspend-audit/SKILL.md`
  — Phase 3 is skill-logic-only; the severity table already covers all 5
  finding types
- Orchestrator integration (Phase 4)
- A `scripts/ghostspend-fix.sh` standalone fallback (already resolved "no" in
  dev plan §9)

## Files Touched

- `skills/ghostspend-fix/SKILL.md` — main rewrite: Option Model, all 5
  finding-type tables, the `Other` boundary list, the batch-mode procedure
- `commands/gs-fix.md` — minor update noting Balanced/Other now exist
- `docs/gs-fix-dev-plan.md` — mark Phase 3 complete; record the
  Balanced-as-batch and MCP-failing decisions from this design
- `ROADMAP.md`, `CHANGELOG.md`, `README.md` — usual per-release updates;
  README's "Phase-2 limitation" note needs updating to reflect Phase 3 scope

## Verification Plan

- `shellcheck`/`bash -n` are unaffected (no script changes) but still run as
  part of the standard completion checklist.
- **Live plugin session (Gate 4), now actually drivable:** use the tmux
  method proven during this design's research —
  `tmux new-session -d ...` → `claude --plugin-dir "$PWD" --settings
  '{"enabledPlugins":{"ghostspend@ghostspend":false}}'` inside it →
  `send-keys`/`capture-pane` to drive `/gs-setup` → `/gs-audit` → `/gs-fix`.
  **Before every `Enter` that confirms a menu choice, `capture-pane` and read
  the actual highlighted option — never blind arrow-count.** During tests of
  any real confirmation prompt, choose Skip/decline unless a fix is
  genuinely intended, to avoid repeating this design session's incident
  (an accidental real `npm install && npm run build` against a live plugin
  triggered by a misnavigated keystroke sequence).
- **Batch-mode test:** contrive or find 2+ real critical/high findings,
  confirm the global-mode choice appears, and confirm each fix inside batch
  mode still gets its own individual show-command-and-confirm step.
- **Boundary test (Gate 5, extended):** in the live session, give `Other` an
  out-of-bounds request (e.g. "revoke my API key," "disable codex entirely")
  for at least two different finding types, and confirm each declines with
  the specific boundary line it hit, not a plausible substitute.
- **Per-finding-type spot check:** for each of the 5 finding types, confirm
  Safest, Skip, and Other are all offered and distinct, and that the MCP-
  failing row's diagnostic step correctly reuses the build-fix path when the
  underlying cause is a missing build.
