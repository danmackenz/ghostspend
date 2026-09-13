# GhostSpend: v0.1.1 Release Polish + `/gs-fix` Phases 1–2

## Start here (session handover)

**Status at handover:** planning complete, **zero implementation code written**.
Planning baseline was `main` at `1f7a0af`, rebased onto `3eef4dd` (PR #8, which
only touched README lines 54–57). Every line number in this plan refers to
`3eef4dd`. Every defect below was reproduced, not inferred — see
"Pre-verified during planning".

**Repo:** `/Users/danmackenzie/Documents/GitHub/ghostspend`

**Read before starting, in this order:**

1. `CLAUDE.md` — the authoritative project contract. Non-negotiables live here.
2. This plan, top to bottom.
3. `~/Downloads/HANDOVER.md` — *rationale only*. Its Part 1/2 figures are one
   person's real audit and must never become fixtures. Two of its claims are
   wrong; both are corrected in the **Background** note below. It lives outside
   the repo on purpose: committing it would publish exactly the real session IDs
   and spend figures its own Part 5 item 4 forbids shipping.

**First action:** check for in-progress work, then branch **from `main`
explicitly** — not from whatever branch is checked out. Start at Task 1. Do not
begin Milestone B until Milestone A is merged.

```bash
git status --short          # if anything is listed, stop and ask before continuing
git fetch origin
git checkout -b release/v0.1.1-polish origin/main
git log --oneline -1        # confirm the base; line numbers assume 3eef4dd's content
```

If `main` has moved past `3eef4dd`, re-check the cited line numbers before editing
— the defects are real, but their positions may have shifted.

**Things most likely to trip you up:**

- `shellcheck` exits 0 on the current broken code, and `markdownlint` reports
  0 issues on the broken docs. **Neither tool gates the main defect classes in
  this plan.** Use the Gate 1 and Gate 2 commands in Verification instead.
- Test on stock `/bin/bash` (3.2.57), not Homebrew bash. The headline bug only
  reproduces there.
- **Never test `setup.sh` against the real `HOME`.** This machine already has
  `~/.ghostspend/config.json`, so piped answers hit "Reconfigure?" first and the
  script exits before reaching any code under test: a false pass, verified. Every
  setup test in this plan uses a throwaway `HOME="$(mktemp -d)"`.
- **Live plugin tests must load the working tree, not an installed copy.** The
  enabled GhostSpend is the marketplace install (`ghostspend@ghostspend`, cached
  at commit `2f9ac26`), and `~/.claude/plugins/ghostspend` exists but isn't
  registered. Copying files into either tests old code. See Task 8 Step 6.
- **The `github-advanced-security` check fails on every PR and is not yours to
  fix.** GitHub's managed Copilot scanning agent requests `claude-opus-5`, and the
  Copilot API answers `400 The requested model is not supported`. It is not a
  required check. The required ones are Bash syntax check, Markdown lint,
  Shellcheck, and Validate JSON manifests.
- **v0.1.0 is already public.** Tag `v0.1.0` points at `2490c0e` (2026-09-11),
  and its GitHub release was published 2026-09-12. Milestone A ships **v0.1.1**.
  Never create, move, or delete the `v0.1.0` tag, and don't rewrite the
  `[0.1.0]` CHANGELOG entry. Release Drafter already maintains a **v0.1.1 draft
  release**, and Task 6 publishes that instead of tagging by hand.

**Decisions already made — do not relitigate:** polish ships before `/gs-fix`;
`/gs-fix` stops at Phases 1–2 (Safest + Skip only); options are finding-type-aware;
no `scripts/ghostspend-fix.sh`.

**Needs your explicit approval before running:** any `git push`, opening or
merging a PR, publishing the v0.1.1 draft release, and the GitHub-side checklist
items in Task 6 Step 6. Never create, move, or delete a tag by hand.

---

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **This file is the canonical copy.** It was drafted in `~/.claude/plans/` during plan mode and moved here; edit this one, and check off steps here as they complete.

**Goal:** Ship a correct, self-consistent v0.1.1 (v0.1.0 is already public), then add severity classification and a safe-fix-only `/gs-fix` command as v0.2.0.

**Architecture:** Two sequential milestones. **A** fixes verified defects and documentation drift, then releases v0.1.1. **B** adds a `severity|message` encoding to audit findings, then a `ghostspend-fix` skill that maps a finding type to a *finding-type-aware* option set and executes nothing without showing the exact command first.

**Tech Stack:** Bash 3.2 (stock macOS), Markdown + YAML frontmatter. No build step, no new dependencies — specifically **do not add `jq`**; the grep-based JSON reads in `ghostspend.sh` are a deliberate bash-3.2/no-dependency tradeoff.

**Spec:** `docs/gs-fix-dev-plan.md` (currently missing from the repo — Task 1 adds it) and the release checklist at `~/Documents/Claude Resources/Plugins/Personal Dev/Ghost Spend Versions/ghostspend-release-v0.1.0-checklist.md`.

**Background:** `~/Downloads/HANDOVER.md` explains *why* the contract looks the way it does — the real diagnostic pattern and the development mistakes behind it. Read it for rationale, never for data. Two corrections to it, both verified: its claim that markdownlint MD040 guards tagged closing fences is **false**, and the continuation-prompt fix it lists as pending actually landed in the skill and command (but not the script).

## Global Constraints

- Every script keeps `set -uo pipefail`; prefer `[[ ]]` over `[ ]`; quote expansions.
- `shellcheck scripts/*.sh` must exit 0. **It is not sufficient** — see Task 2; shellcheck does not catch bash 3.2 empty-array expansion.
- Test against **stock `/bin/bash` 3.2.57**, not Homebrew bash.
- Slash commands keep the `gs-` prefix.
- No network call, write action, or fix executes without explicit per-action user confirmation.
- No script reads, logs, or displays `.env` contents, API keys, or tokens.
- `.claude-plugin/plugin.json` must list every file in `agents/`, `skills/`, `commands/` in the same change that adds one.
- Config keys are **snake_case** (`known_tools`, `scan_dirs`, …). This is the real schema; docs are what's wrong.
- **No fixtures from `HANDOVER.md`.** The session IDs, timestamps, MCP server names, and spend figures in its Parts 1–2 are one person's 2026-09-10/12 environment. Never hardcode them into scripts, skills, docs, tests, or examples. Any test or example data must be synthetic and visibly labelled as such.
- **Closing code fences must be bare ` ``` `.** `markdownlint` does **not** catch a tagged closer — verified empirically, see Task 5b. The handover's claim that MD040 guards this is incorrect; do not rely on it.

---

## Pre-verified during planning

These were run against stock `/bin/bash` **3.2.57** on this machine and behaved
as the plan assumes. Do not re-derive them; do re-run them if you change the code.

| Construct | Used in | Result |
| --- | --- | --- |
| `json_array ${arr[@]+"${arr[@]}"}` with an empty array | Task 2 Step 3 | `[]`, no `unbound variable` |
| `while IFS='\|' read …; done <<< "$TABLE"` with `arr+=()` inside | Task 3 Step 4 | array writes persist (herestring, not a subshell) |
| `dirname "${BASH_SOURCE[0]}"` under `set -u` | Task 2 Step 5a | resolves correctly |
| `${e%%\|*}` / `${e#*\|}` / `tr '[:lower:]' '[:upper:]'` | Task 7 Step 3 | parses `severity\|message` correctly |
| `"${empty[@]}"` under `set -u` | the bug being fixed | **fails** — `A[@]: unbound variable` |
| real `scripts/setup.sh` at `3eef4dd`, throwaway `HOME` | Task 2 Steps 1 and 6 | fatal at line 102 with no tool dirs (exit 1); non-fatal at line 130 when every tool is declined (exit 0, `[]` by accident) |
| `printf 'n\\nn\\n\\n' \| setup.sh` with a config already present | the test command this plan used to contain | exits at "Reconfigure?" and never reaches the crash, a false pass |
| `claude --plugin-dir <path>` | Task 8 Step 6, Gate 4 | listed in `claude --help`: loads a plugin for one session only |
| release state (2026-09-13) | Task 6, Start here | tag `v0.1.0` → `2490c0e`, release published 2026-09-12; draft release `v0.1.1` exists (Release Drafter, target `main`); tag `v0.1.1` and branch `release/v0.1.1-polish` unused |

Also confirmed: `shellcheck scripts/*.sh` exits **0** on the current, broken code,
and `markdownlint-cli2` reports **0 issues** on a file with tagged closing fences.
Neither tool gates the two defect classes this plan is largely about.

## Context

Two things prompted this work. First, a release-readiness pass against the v0.1.0 checklist surfaced defects that make the current `main` incorrect. The checklist was written before v0.1.0 shipped on 2026-09-12, and it is still the right bar for v0.1.1. The defects include a crash on the project's own stated minimum bash and an npm `bin` entry pointing at a file that doesn't exist. Second, `/gs-fix` is the roadmap's top priority, and its spec document is referenced by five files but was never committed.

A `ponytail-audit` complexity pass was also run; its findings are folded into Milestone A rather than deferred, since they touch the same functions.

### Verified defects (each reproduced, not inferred)

| # | Defect | Evidence |
| --- | --- | --- |
| 1 | **`setup.sh` breaks on bash 3.2 empty-array expansion under `set -u`** — two sites, different severity | Reproduced against the real script with a throwaway `HOME`. **Fatal** when no AI-tool data directories exist: `line 102: DETECTED[@]: unbound variable`, exit 1, before the scan-dir prompt (a fresh standalone user). **Non-fatal** when every detected tool is declined: `line 130: KNOWN_TOOLS[@]: unbound variable` is printed mid-run, but only the `$(...)` subshell dies, so `"known_tools": []` still comes out right by accident. `shellcheck` exits 0 on both. |
| 2 | **`package.json` bin + script point at a nonexistent file** — `./scripts/gs-setup.sh`; the file is `scripts/setup.sh` | `package.json:28,31`. `npm run setup` and the installed `ghostspend-setup` binary both fail. |
| 3 | **Clone URL 404s** — real remote is `github.com/danmackenz/ghostspend`; `package.json` (3 places) and `CONTRIBUTING.md` say `danmackenzie` | `git remote -v` vs. `git grep github.com/danmackenzie` |
| 4 | **`docs/config.md` renders mangled** — 5 fences closed with ` ```json ` instead of ` ``` ` | Lines 14, 18, 32, 59, 69. `markdownlint-cli2` reports 0 issues, so CI does not catch it. |
| 5 | **`docs/config.md` documents a schema that does not exist** — camelCase `knownTools`/`createdAt`/`lastAuditAt`/`ccusageInstalled` vs. actual snake_case. Documents 2 fields nothing writes, omits 3 that exist. `lastAuditAt` is described as auto-updated; `ghostspend.sh` never writes the config at all. | Compare `docs/config.md:22-41` with `scripts/setup.sh` heredoc |
| 6 | **`docs/gs-fix-dev-plan.md` missing** — referenced by `CHANGELOG.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `ROADMAP.md`, `SECURITY.md`; CHANGELOG claims it was added | `git grep -ln gs-fix-dev-plan` → 5 files; `test -f` → missing |
| 7 | **Stale `/audit` reference** — checklist §3 forbids it | `scripts/setup.sh:169` |
| 8 | **Plugin-health "OK" line is suppressed spuriously** — gated on global `${#FINDINGS[@]} -eq 0`, but section 2 may already have appended an MCP finding | `scripts/ghostspend.sh:130` |
| 9 | **Config-drift check is inert** — section 4 prints counts, never appends a finding, so it can produce nothing for `/gs-fix` to act on | `scripts/ghostspend.sh:141-150` |
| 10 | **"Environment looks clean" is unreachable** — an unconditional `FINDINGS+=("Review the combined ccusage report…")` always fires when ccusage runs | `scripts/ghostspend.sh:233` |
| 11 | README structure diagram puts `marketplace.json` at repo root; it lives at `.claude-plugin/marketplace.json` | `README.md:214` |
| 12 | `marketplace.json` declares `"version": "1.0.0"` for a 0.1.0 project | `.claude-plugin/marketplace.json` |
| 13 | **`setup.sh` dead-ends on an existing config** — the HANDOVER Part 2 continuation fix landed in the skill and command but not the script | `scripts/setup.sh:37-38` → `echo "Keeping existing config. Exiting."; exit 0`. Skill has it at `skills/ghostspend-setup/SKILL.md:88-93`. |
| 14 | **CI cannot catch the tagged-closing-fence bug** — the class that once broke README rendering | `printf` test file with ` ```json ` closers → markdownlint `0 issues`. Repo scan: `docs/config.md` is the only unbalanced file (9 fences). |
| 15 | **MCP check is audit-time only** — no log scanning, so historical retry storms are invisible | `git grep -niE "ECONNREFUSED\|Cowork\|mcp-log\|retry" -- scripts/ skills/` → no matches |
| 16 | **`copilot-cli` is advertised but never detected** — named in README coverage and `docs/config.md` recognized values | `git grep -in copilot -- scripts/ skills/` → only a comment and prose, no detection branch |
| 17 | **`examples/sample-audit-output.md` has tagged closing fences too** — a fence *parity* check calls it clean (4 fences, even) while it renders broken | Positional scan: lines 21 and 96 are odd-indexed fences carrying ` ```text ` |
| 18 | **The worked example reproduces real audit figures** — `$443.41`, `$2.11`, dates `2026-08-03/04`, effectively the handover's real `$442.05` run | `examples/sample-audit-output.md:70-73`; `HANDOVER.md` Part 5 item 4 forbids this |
| 19 | **README "Option A" manual install may not register the plugin**, *suspected; verify before editing README* | `~/.claude/plugins/ghostspend` (copied 2026-09-12 per Option A) is absent from `~/.claude/plugins/installed_plugins.json`, and `claude plugin details ghostspend` resolves only to the marketplace install `ghostspend@ghostspend`. Not yet tested with the marketplace copy disabled. |

### ponytail-audit findings (ranked, biggest cut first)

```text
shrink: setup.sh writes the config JSON heredoc twice (preview + write). Build once into CONFIG_JSON, printf it, then write it. [scripts/setup.sh]
shrink: three near-identical DETECTED_TOOLS_* blocks + three near-identical flag blocks. One loop over a "label|path|match" table. [scripts/ghostspend.sh:179-223]
delete: unconditional "Review the combined ccusage report above" finding — a rubric, not a finding; it makes the clean-environment branch dead. [scripts/ghostspend.sh:233]
yagni: config field "rtk_installed" has no reader — ghostspend.sh does its own `command -v rtk`. [scripts/setup.sh, scripts/ghostspend.sh:239]
yagni: config field "ccusage_installed" has no reader — ghostspend.sh does its own `command -v ccusage`. [scripts/setup.sh, scripts/ghostspend.sh:157]
net: -45 lines, -0 deps possible.
```

Keep both `yagni` fields but **document them as advisory-only** rather than deleting: `docs/config.md` must stop claiming behavior they don't drive. Deleting them would break any config already on disk.

---

## File Structure

| File | Responsibility | Milestone |
| --- | --- | --- |
| `scripts/setup.sh` | bash 3.2 guards, single heredoc, `/gs-audit` wording, existing-config continuation | A |
| `.github/workflows/ci.yml` | **new job** — closing-fence style check markdownlint can't do | A |
| `ROADMAP.md` | record the audit-time-only MCP limitation | A |
| `examples/sample-audit-output.md` | fix tagged closers; refresh Summary format; de-fixture the spend figures | A + B |
| `scripts/ghostspend.sh` | section-local counters, real drift findings, `severity\|message` encoding, table-driven tool loop | A + B |
| `docs/config.md` | rewrite against the real snake_case schema; fix fences | A |
| `docs/gs-fix-dev-plan.md` | **new** — the spec, copied in from the user's local file | A |
| `package.json` | correct `bin`/`scripts` paths, correct repo URLs | A |
| `.claude-plugin/marketplace.json` | version alignment | A |
| `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md` | drift fixes, 0.1.1 entry | A |
| `skills/ghostspend-audit/SKILL.md` | severity table (source of truth, per spec §4) | B |
| `skills/ghostspend-fix/SKILL.md` | **new** — finding → option-set → proposed command | B |
| `commands/gs-fix.md` | **new** — thin dispatcher | B |
| `agents/ghostspend-orchestrator.md` | third stage | B |
| `.claude-plugin/plugin.json` | manifest sync for the two new component files | B |

---

## Milestone A — v0.1.1 Release Polish

### Task 1: Land the missing spec document

**Files:**

- Create: `docs/gs-fix-dev-plan.md`

- [ ] **Step 1: Copy the spec into the repo**

```bash
cp "$HOME/Documents/Claude Resources/Plugins/Personal Dev/Ghost Spend Versions/Dev Plans/gs-fix-dev-plan.md" docs/gs-fix-dev-plan.md
```

- [ ] **Step 2: Record the two decisions made during planning**

In §9 "Open Questions", replace the first bullet with the resolution, and add the standalone-script decision:

```markdown
- **RESOLVED (2026-09-13):** Options are **finding-type-aware**. Each finding
  type declares which of the four options are meaningful for it; `/gs-fix`
  renders only those. Presenting two identical choices as a tradeoff erodes
  trust in the prompt.
- **RESOLVED (2026-09-13):** No `scripts/ghostspend-fix.sh` standalone
  fallback for now. The interview flow is the feature and requires Claude
  Code; a bash version would cover only trivial fixes while creating a second
  copy of the severity/action mapping to keep in sync. README notes the limit.
```

Also strike `scripts/ghostspend-fix.sh (optional)` from the §3 component table.

- [ ] **Step 3: Verify every inbound reference now resolves**

```bash
git grep -l 'gs-fix-dev-plan' && test -f docs/gs-fix-dev-plan.md && echo RESOLVES
```

Expected: the 5 referencing files listed, then `RESOLVES`.

- [ ] **Step 4: Verify markdown lints**

```bash
npx --yes markdownlint-cli2 --config .markdownlint-cli2.json "docs/gs-fix-dev-plan.md"
```

Expected: `0 issues`.

- [ ] **Step 5: Commit**

```bash
git add docs/gs-fix-dev-plan.md
git commit -m "Add gs-fix dev plan referenced by five existing files"
```

---

### Task 2: Fix the bash 3.2 crash in `setup.sh`

The fatal path hits a fresh standalone user with no AI-tool data directories, which is exactly the "Option B, no Claude Code" audience README promises to support, so it blocks v0.1.1. `shellcheck` passes today and will still pass after the fix. The regression test is therefore a direct bash 3.2 run of the real script with a throwaway `HOME`, not shellcheck.

**Files:**

- Modify: `scripts/setup.sh`

- [ ] **Step 1: Reproduce both failure sites against the real script**

Always use a throwaway `HOME`. It makes tool detection deterministic, and it keeps
the script away from the real `~/.ghostspend/config.json`, which would otherwise
exit at "Reconfigure?" before reaching either bug.

```bash
# Fatal site: no AI-tool data directories at all
H=$(mktemp -d); printf '\nn\nn\n' | HOME="$H" /bin/bash scripts/setup.sh; echo "exit=$?"

# Non-fatal site: one tool detected, the user declines it
H=$(mktemp -d); mkdir "$H/.codex"; printf 'n\n\nn\nn\n' | HOME="$H" /bin/bash scripts/setup.sh; echo "exit=$?"
```

Expected key lines before the fix (verified 2026-09-13 at `3eef4dd`):

```text
[!] No known AI CLI tool data directories found.
scripts/setup.sh: line 102: DETECTED[@]: unbound variable
exit=1

Found local data for: codex
scripts/setup.sh: line 130: KNOWN_TOOLS[@]: unbound variable
  "known_tools": [],
Aborted. No config written.
exit=0
```

The second case exits 0 and still prints `[]`, because the error kills only the
`$(...)` subshell. It is still a bug: the error is visible to the user, and the
correct output is an accident.

- [ ] **Step 2: Guard the `DETECTED` loop**

Replace the tool-confirmation block. The existing `if [[ ${#DETECTED[@]} -eq 0 ]]` only warns — it does not skip the loop below it.

```bash
KNOWN_TOOLS=()
if [[ ${#DETECTED[@]} -gt 0 ]]; then
  for tool in "${DETECTED[@]}"; do
    read -rp "  Do you use $tool? [y/N] " USE_TOOL
    [[ "$USE_TOOL" =~ ^[Yy]$ ]] && KNOWN_TOOLS+=("$tool")
  done
fi
```

- [ ] **Step 3: Guard the JSON array builders**

`printf '"%s",' "${KNOWN_TOOLS[@]}"` has the same defect and is hit whenever the user declines every tool. Add a helper above the config-building section and use it for both arrays:

```bash
# Join array elements into a JSON array literal. Safe on bash 3.2 with set -u,
# where "${empty[@]}" is an unbound-variable error rather than an empty list.
json_array() {
  local out=""
  if [[ $# -gt 0 ]]; then
    out=$(printf '"%s",' "$@")
    out="${out%,}"
  fi
  printf '[%s]' "$out"
}

KNOWN_TOOLS_JSON=$(json_array ${KNOWN_TOOLS[@]+"${KNOWN_TOOLS[@]}"})
SCAN_DIRS_JSON=$(json_array ${SCAN_DIRS[@]+"${SCAN_DIRS[@]}"})
```

The `${arr[@]+"${arr[@]}"}` form is the bash 3.2-safe way to pass a possibly-empty array.

- [ ] **Step 4: Collapse the duplicated heredoc** (ponytail `shrink:`)

Build the JSON once, show it, then write the same bytes — this also removes the risk of preview and written content drifting apart:

```bash
CONFIG_JSON=$(cat <<EOF
{
  "known_tools": $KNOWN_TOOLS_JSON,
  "scan_dirs": $SCAN_DIRS_JSON,
  "ccusage_installed": $CCUSAGE_INSTALLED,
  "rtk_installed": $RTK_INSTALLED,
  "setup_completed_at": "$TIMESTAMP"
}
EOF
)

echo -e "\n${BOLD}Config to be written:${RESET}"
printf '%s\n' "$CONFIG_JSON"

read -rp $'\nWrite this to '"$CONFIG_FILE"'? [y/N] ' CONFIRM_WRITE
if [[ ! "$CONFIRM_WRITE" =~ ^[Yy]$ ]]; then
  echo "Aborted. No config written."
  exit 0
fi

mkdir -p "$CONFIG_DIR"
printf '%s\n' "$CONFIG_JSON" > "$CONFIG_FILE"
```

- [ ] **Step 5: Fix the stale slash command**

`scripts/setup.sh:169` — replace `/audit` with `/gs-audit`:

```bash
echo -e "\n${BOLD}Setup complete.${RESET} Run ./ghostspend.sh (or /gs-audit in Claude Code) any time."
```

- [ ] **Step 5a: Close the existing-config dead-end (HANDOVER Part 2 bug, script half)**

The continuation-prompt fix landed in `skills/ghostspend-setup/SKILL.md:88-93` and
`commands/gs-setup.md:7`, but **not** in the standalone script. `scripts/setup.sh:37-38`
still dead-ends on the exact path the handover describes — existing config, user
declines reconfigure:

```bash
    echo "Keeping existing config. Exiting."
    exit 0
```

`CLAUDE.md` requires the script and skill stay in sync. Offer the same continuation:

```bash
if [[ -f "$CONFIG_FILE" ]]; then
  warn "Existing config found at $CONFIG_FILE"
  read -rp "Reconfigure from scratch? [y/N] " RECONFIGURE
  if [[ ! "$RECONFIGURE" =~ ^[Yy]$ ]]; then
    echo "Keeping existing config."
    read -rp "Run an audit now? [y/N] " RUN_AUDIT
    if [[ "$RUN_AUDIT" =~ ^[Yy]$ ]]; then
      exec "$(dirname "${BASH_SOURCE[0]}")/ghostspend.sh"
    fi
    echo "Run ./ghostspend.sh (or /gs-audit in Claude Code) any time."
    exit 0
  fi
fi
```

Apply the same two-line continuation before the `exit 0` at `scripts/setup.sh:152`
(the "Aborted. No config written." path), so neither early exit dead-ends.

- [ ] **Step 5b: Fix "in the background" in the setup skill's hand-off**

`skills/ghostspend-setup/SKILL.md:92` says to *"invoke the `ghostspend-audit`
skill immediately **in the background**."* The audit is interactive — it asks
about scan directories and surfaces findings for discussion — so backgrounding it
hides the output the user just said yes to seeing. Drop the two words:

```markdown
- If the user answers **yes**, invoke the `ghostspend-audit` skill immediately.
  Do not wait for the user to separately run `/gs-audit`.
```

`commands/gs-setup.md:7` carries the same phrasing — fix both. Verify in the live
session (Gate 4) that answering yes produces visible audit output inline.

- [ ] **Step 6: Verify both failure sites and both dead-ends are fixed under real bash 3.2**

Re-run Step 1's two commands, plus the existing-config path that Step 5a changed:

```bash
/bin/bash -n scripts/setup.sh && echo "syntax OK"

# 1 and 2: the Step 1 scenarios
H=$(mktemp -d); printf '\nn\nn\n' | HOME="$H" /bin/bash scripts/setup.sh; echo "exit=$?"
H=$(mktemp -d); mkdir "$H/.codex"; printf 'n\n\nn\nn\n' | HOME="$H" /bin/bash scripts/setup.sh; echo "exit=$?"

# 3: existing config, decline reconfigure, decline audit
H=$(mktemp -d); mkdir -p "$H/.ghostspend"; echo '{}' > "$H/.ghostspend/config.json"
printf 'n\nn\n' | HOME="$H" /bin/bash scripts/setup.sh; echo "exit=$?"
```

Expected:

- Scenarios 1 and 2: **no** `unbound variable` anywhere. Both reach the
  "Config to be written:" preview with `"known_tools": []`, print
  `Aborted. No config written.` (followed by Step 5a's audit prompt), and exit 0.
- Scenario 3: prints `Keeping existing config.`, then asks `Run an audit now?`
  instead of printing `Exiting.`, and exits 0 after the second `n`.
- No scenario writes a config under `$H`, and none can touch the real one.

- [ ] **Step 7: Verify shellcheck still clean**

```bash
shellcheck scripts/*.sh && echo "shellcheck clean"
```

- [ ] **Step 8: Commit**

```bash
git add scripts/setup.sh skills/ghostspend-setup/SKILL.md commands/gs-setup.md
git commit -m "Guard empty array expansion that crashed setup on bash 3.2

Stock macOS bash 3.2 treats \"\${arr[@]}\" on an empty array as an unbound
variable under set -u. With no AI-tool data directories, setup died before
the scan-dir prompt; declining every detected tool printed the error mid-run
and produced the right JSON only by accident. shellcheck detects neither.

Also closes the two dead-end exits where setup stopped instead of offering
an audit, bringing the standalone script in line with the skill, and drops
the 'in the background' instruction that would hide interactive audit output."
```

Because this commit touches `skills/` and `commands/`, `CLAUDE.md` requires a
live-session check — defer it to Gate 4 rather than claiming it here.

---

### Task 3: Make `ghostspend.sh` findings accurate

Three defects in one file, all in the findings pipeline. Fixing them together because Milestone B's severity tagging builds directly on this code.

**Files:**

- Modify: `scripts/ghostspend.sh`

- [ ] **Step 1: Scope the plugin-health OK message to its own section**

At `scripts/ghostspend.sh:130`, `${#FINDINGS[@]}` is global and may already hold an MCP finding from section 2. Use a section-local counter:

```bash
PLUGIN_ISSUES=0
while IFS= read -r pkgjson; do
  plugin_dir=$(dirname "$pkgjson")
  main_entry=$(grep -o '"main"[[:space:]]*:[[:space:]]*"[^"]*"' "$pkgjson" 2>/dev/null | sed 's/.*"main"[[:space:]]*:[[:space:]]*"//;s/"$//')
  if [[ -n "$main_entry" ]]; then
    full_path="$plugin_dir/$main_entry"
    if [[ ! -f "$full_path" ]]; then
      fail "Missing build output: $full_path"
      FINDINGS+=("Plugin at $plugin_dir declares main entry '$main_entry' but the file doesn't exist. Likely needs: cd \"$plugin_dir\" && npm install && npm run build")
      PLUGIN_ISSUES=$((PLUGIN_ISSUES + 1))
    fi
  fi
done < <(find "$PLUGIN_CACHE" -maxdepth 3 -iname "package.json" 2>/dev/null)
if [[ "$PLUGIN_ISSUES" -eq 0 ]]; then
  ok "All installed plugins with a package.json 'main' entry have their build output present"
fi
```

- [ ] **Step 2: Make the config-drift check actually produce a finding**

Section 4 currently prints counts and stops, so it can never feed `/gs-fix`. Append a finding when a project carries local config, and name the files so the fix skill has something to act on:

```bash
for dir in "${SCAN_DIRS[@]}"; do
  [[ -d "$dir" ]] || { warn "Skipping non-existent directory: $dir"; continue; }
  echo "  Scanning: $dir"
  LOCAL_SETTINGS=$(find "$dir" -maxdepth 4 -path "*/.claude/settings.json" 2>/dev/null)
  LOCAL_MCP=$(find "$dir" -maxdepth 3 -iname ".mcp.json" -not -path "*/node_modules/*" -not -path "*/plugins/cache/*" 2>/dev/null)
  COUNT_SETTINGS=$(echo "$LOCAL_SETTINGS" | grep -c . || true)
  COUNT_MCP=$(echo "$LOCAL_MCP" | grep -c . || true)
  echo "    - Local settings.json files: $COUNT_SETTINGS"
  echo "    - Local .mcp.json files: $COUNT_MCP"
  if [[ "$COUNT_MCP" -gt 0 ]]; then
    warn "$COUNT_MCP project-level .mcp.json file(s) under $dir may duplicate global MCP config"
    FINDINGS+=("$COUNT_MCP project-level .mcp.json file(s) under $dir: $(echo "$LOCAL_MCP" | tr '\n' ' ')")
  fi
done
```

- [ ] **Step 3: Delete the always-on pseudo-finding** (ponytail `delete:`)

Remove `scripts/ghostspend.sh:233` entirely:

```bash
FINDINGS+=("Review the combined ccusage report above for spend attributed to tools outside your known-tools baseline.")
```

It is a rubric, not a finding, and it makes the `ok "No other actionable issues found. Environment looks clean."` branch unreachable whenever ccusage runs.

- [ ] **Step 4: Collapse the triplicated tool blocks** (ponytail `shrink:`)

Replace the three `DETECTED_TOOLS_*` blocks and the three flag blocks with one table-driven pass. Keep the `known_tools` substring match semantics unchanged:

```bash
# label|local data path|substring matched against known_tools|drill-down hint
TOOL_TABLE="Codex CLI|$HOME/.codex|codex|ccusage codex daily
Gemini CLI|$HOME/.gemini|gemini|ccusage gemini daily
OpenCode|$HOME/.config/opencode|opencode|"

ANY_DETECTED=0
while IFS='|' read -r label path key hint; do
  [[ -n "$label" ]] || continue
  [[ -d "$path" ]] || continue
  ANY_DETECTED=1
  warn "$label local data found at $path"
  if [[ -n "$KNOWN_TOOLS" && "$KNOWN_TOOLS" != *"$key"* ]]; then
    if [[ -n "$hint" ]]; then
      flag "$label has local activity but is NOT in your known_tools list. Run '$hint' to see its spend."
    else
      flag "$label has local activity but is NOT in your known_tools list."
    fi
    FLAGGED_TOOLS+=("$key")
  fi
done <<< "$TOOL_TABLE"

if [[ "$ANY_DETECTED" -eq 0 ]]; then
  ok "No local data found for other tracked AI CLI tools"
fi
if [[ -n "$KNOWN_TOOLS" && ${#FLAGGED_TOOLS[@]} -eq 0 ]]; then
  ok "No tool activity found outside your known_tools list"
fi
if [[ -z "$KNOWN_TOOLS" ]]; then
  warn "No known_tools baseline configured — run ./setup.sh to enable unexpected-usage flagging"
fi
```

- [ ] **Step 5: Verify on bash 3.2 against a clean and a dirty environment**

```bash
/bin/bash -n scripts/ghostspend.sh && echo "syntax OK"
shellcheck scripts/ghostspend.sh && echo "shellcheck clean"
/bin/bash scripts/ghostspend.sh "$HOME/Documents/GitHub"
```

Expected: sections 0–6 all render; section 3 prints its OK line even when section 2 reported a failing MCP server; the Summary no longer lists the generic "Review the combined ccusage report" item.

- [ ] **Step 6: Commit**

```bash
git add scripts/ghostspend.sh
git commit -m "Correct findings pipeline in audit script

Scope plugin-health OK to its own counter, make the config-drift check
emit real findings, drop the unconditional pseudo-finding that made the
clean-environment branch unreachable, and collapse the triplicated
per-tool detection into one table-driven loop."
```

---

### Task 4: Rewrite `docs/config.md` against the real schema

**Files:**

- Modify: `docs/config.md`

- [ ] **Step 1: Confirm the actual schema before writing**

```bash
grep -n 'known_tools\|scan_dirs\|ccusage_installed\|rtk_installed\|setup_completed_at' scripts/setup.sh scripts/ghostspend.sh
```

This is the source of truth. The current doc is what's wrong, not the scripts.

- [ ] **Step 2: Replace the Location + Schema sections**

Close every fence with bare ` ``` `. Remove the duplicated/stray Location block entirely.

````markdown
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
````

- [ ] **Step 3: Fix the two remaining broken fences**

The "Editing Manually" and "Resetting Your Baseline" bash blocks both close with ` ```json `. Change both to ` ``` `. Also replace every remaining `knownTools` mention in prose with `known_tools`.

- [ ] **Step 4: Verify rendering and lint**

```bash
npx --yes markdownlint-cli2 --config .markdownlint-cli2.json "docs/config.md"
awk '/^```/{n++} END{print "fence count:", n, (n%2==0 ? "BALANCED" : "UNBALANCED")}' docs/config.md
```

Expected: `0 issues` and `BALANCED`. The fence count is the real check here — markdownlint reported 0 issues against the broken version too.

- [ ] **Step 5: Commit**

```bash
git add docs/config.md
git commit -m "Correct config schema reference to match actual scripts

The documented camelCase schema never existed. Scripts write snake_case,
two documented fields are written by nothing, and three real fields were
undocumented. Also closes five code fences that were opened with ```json
and closed the same way, mangling the page from the Location section down."
```

---

### Task 5: Fix metadata, URLs, and remaining doc drift

**Files:**

- Modify: `package.json`, `.claude-plugin/marketplace.json`, `README.md`, `CONTRIBUTING.md`

- [ ] **Step 1: Fix the broken bin and script paths**

`package.json` — `./scripts/gs-setup.sh` does not exist:

```json
  "bin": {
    "ghostspend": "./scripts/ghostspend.sh",
    "ghostspend-setup": "./scripts/setup.sh"
  },
  "scripts": {
    "setup": "bash ./scripts/setup.sh",
    "audit": "bash ./scripts/ghostspend.sh",
    "lint": "shellcheck scripts/*.sh"
  },
```

- [ ] **Step 2: Correct the repo owner in `package.json`**

The real remote is `github.com/danmackenz/ghostspend`. Change `homepage`, `repository.url`, and `bugs.url` from `danmackenzie` to `danmackenz`.

- [ ] **Step 3: Correct the clone URL in `CONTRIBUTING.md`**

```bash
git clone https://github.com/danmackenz/ghostspend.git
```

- [ ] **Step 4: Align the marketplace version**

`.claude-plugin/marketplace.json` declares `"version": "1.0.0"` at the marketplace level for a 0.1.0 project. Set it to match `plugin.json` and `package.json`, currently `"0.1.0"`. The file also has a per-plugin `version` (line 15). Task 6 bumps all of these to `"0.1.1"` together.

- [ ] **Step 5: Fix the README structure diagram**

`README.md:214` lists `marketplace.json` at repo root. It lives at `.claude-plugin/marketplace.json` — move it under the `.claude-plugin/` entry alongside `plugin.json`, and add the `docs/gs-fix-dev-plan.md` entry now that Task 1 created it.

- [ ] **Step 5a: Stop over-claiming `copilot-cli` coverage**

README's intro and "What It Checks" row 6 imply GitHub Copilot CLI is flagged
against the baseline. Neither script has a detection branch for it — `git grep -in
copilot -- scripts/ skills/` returns only a comment and descriptive prose.

Row 5 (spend via `ccusage`) is accurate as written, because `ccusage` does that
work. Row 6 (unexpected-tool flagging) is not. Amend row 6 to name the tools
actually flagged — `codex`, `gemini`, `opencode` — and move broader provider
coverage to `ROADMAP.md`'s existing "More provider coverage" entry.

- [ ] **Step 5b: Verify the README "Option A" install, and fix it only if it fails**

Defect 19 is suspected, not proven. Test it in isolation, because the enabled
marketplace copy would mask the result:

```bash
claude --settings '{"enabledPlugins":{"ghostspend@ghostspend":false}}'
```

In that session, check whether `/gs-setup` exists and whether its
`Base directory for this skill:` line points at `~/.claude/plugins/ghostspend`.
If it does, Option A works: leave README alone and strike defect 19. If it does
not, replace Option A with a method you have watched load (the marketplace flow, or
`claude --plugin-dir /path/to/ghostspend` from Task 8 Step 6). Never document an
install path you have not seen work.

- [ ] **Step 6: Verify every URL and path resolves**

```bash
git grep -n 'danmackenzie' || echo "no stale owner refs"
for f in $(git grep -hoE '\./scripts/[a-z-]+\.sh' package.json | sort -u); do test -f "$f" && echo "OK $f" || echo "MISSING $f"; done
python3 -c "import json;[json.load(open(p)) for p in ['.claude-plugin/plugin.json','.claude-plugin/marketplace.json','package.json']];print('JSON valid')"
```

Expected: `no stale owner refs`, `OK` for both script paths, `JSON valid`.

- [ ] **Step 7: Commit**

```bash
git add package.json .claude-plugin/marketplace.json README.md CONTRIBUTING.md
git commit -m "Correct bin paths, repo URLs, and version metadata

package.json pointed bin and npm run setup at scripts/gs-setup.sh, which
does not exist. Three package.json URLs and the CONTRIBUTING clone command
used danmackenzie; the actual remote is danmackenz."
```

---

### Task 5b: Add a closing-fence style check to CI

`HANDOVER.md` Part 3 Mistake 1 records this bug class breaking the README's
entire rendering, and notes it recurred during branding edits. It then claims
markdownlint's MD040 guards against recurrence. **That claim is false**, verified:

```bash
printf '# T\n\n```json\n{"a":1}\n```json\n' > /tmp/fence-test.md
npx --yes markdownlint-cli2 --config .markdownlint-cli2.json /tmp/fence-test.md
# → "Summary: 0 issues in 0 files"
```

**A fence-parity check is not enough.** `examples/sample-audit-output.md` has
4 fences — an even count — yet lines 21 and 96 are tagged closers, so the page
renders broken while a parity check calls it clean. The correct rule is
**positional**: fences alternate open/close, so every *odd-indexed* fence is a
closer and must be exactly ` ``` `.

Verified offenders across the repo:

```text
docs/config.md:14, 22, 57, 67                — tagged closers
examples/sample-audit-output.md:21, 96       — tagged closers (parity check misses these)
```

README is clean. Task 4 fixes `docs/config.md`; Task 5b-Step 0 fixes the example
and this task stops both recurring.

**Files:**

- Modify: `examples/sample-audit-output.md`
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 0: Fix the example's tagged closers**

`examples/sample-audit-output.md` lines 21 and 96 — change ` ```text ` to bare
` ``` `. Leave the *opening* fences at lines 13 (` ```json `) and 30 (` ```text `)
tagged; only closers must be bare.

- [ ] **Step 1: Add a job that fails on a tagged closing fence**

Append to `.github/workflows/ci.yml`, alongside the existing `markdown-lint` job:

```yaml
  fence-style:
    name: Code fence style
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v7

      - name: Check every closing code fence is bare
        run: |
          set -uo pipefail
          rc=0
          while IFS= read -r file; do
            awk -v f="$file" '
              /^````/ { f4 = !f4; next }
              f4      { next }
              /^```/  { if (n % 2 == 1 && $0 != "```") {
                          printf "::error file=%s,line=%d::Closing code fence must be bare ```, not %s\n", f, FNR, $0
                          bad = 1
                        }
                        n++ }
              END     { if (n % 2 != 0) {
                          printf "::error file=%s::Unclosed code fence (%d fence markers)\n", f, n
                          bad = 1
                        }
                        exit bad }
            ' "$file" || rc=1
          done < <(git ls-files '*.md' | grep -v '^LICENSE.md$')
          exit "$rc"
```

This catches both failure modes — a tagged closer (even count, still broken) and
a genuinely unclosed fence (odd count) — while the first two rules skip
` ```` `-delimited regions, whose contents are quoted Markdown rather than real
fences.

**Why the ` ```` ` skip is mandatory, not defensive:** this plan document itself
contains a ` ````markdown ` block (Task 4 Step 2) wrapping example Markdown that
includes ` ```json ` fences. Once this plan is committed under
`docs/superpowers/plans/`, a check without the skip fails on the plan file. That
was verified, not anticipated.

Note `FNR` rather than `NR` — the awk runs per file here, but `FNR` keeps the
line numbers correct if anyone later batches files into one invocation.

- [ ] **Step 2: Verify the check flags today's offenders, then passes**

Run the same rule locally before and after the fixes:

```bash
rc=0
for f in $(git ls-files '*.md' | grep -v '^LICENSE.md$'); do
  awk -v F="$f" '
    /^````/ { f4 = !f4; next }
    f4      { next }
    /^```/  { if (n%2==1 && $0 != "```") { printf "%s:%d TAGGED CLOSER -> %s\n", F, FNR, $0; bad=1 } n++ }
    END     { if (n%2) { printf "%s UNCLOSED (%d)\n", F, n; bad=1 } exit bad }' "$f" || rc=1
done; echo "(scan complete, rc=$rc)"
```

Use `rc`, not `status` — `status` is read-only in zsh and the loop silently dies.

Expected **before** Tasks 4 and 5b-Step 0 (verified 2026-09-13):

```text
docs/config.md:14, 22, 57, 67   — tagged closers
docs/config.md UNCLOSED (9)
examples/sample-audit-output.md:21, 96   — tagged closers
(scan complete, rc=1)
```

Expected **after**: `(scan complete, rc=0)` with no findings.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml examples/sample-audit-output.md
git commit -m "Fail on tagged markdown closing fences

A closing fence tagged with the opening language (\`\`\`json rather than
\`\`\`) is not recognized as a closer and swallows the rest of the page.
markdownlint does not detect this; it reports 0 issues on an affected file.
This bug class has already broken the README once."
```

---

### Task 5c: Record the MCP retry-storm detection gap in ROADMAP

`HANDOVER.md` Part 5 item 2 asks whether the audit detects historical MCP retry
storms. It does not, and this should be a documented limitation rather than a
silent one.

**Verified:** `scripts/ghostspend.sh` section 2 runs `claude mcp list` — a
point-in-time connectivity probe. `skills/ghostspend-audit/SKILL.md` Steps 3–4
likewise inspect live state and re-run a failing command. Neither reads any MCP
log file. `git grep -niE "ECONNREFUSED|Cowork|mcp-log|retry" -- scripts/ skills/`
returns nothing. `ROADMAP.md`'s "Historical trend tracking" entry is about
snapshotting `ccusage` spend over time — a different thing.

**Files:**

- Modify: `ROADMAP.md`

- [ ] **Step 1: Add the gap under "Next (v0.2.x) — Other Planned Checks"**

```markdown
- [ ] **Historical MCP failure detection** — the audit currently probes MCP
  connectivity only at run time (`claude mcp list`). A server that fails and
  retries for an extended period between audits, then happens to be connected
  when the audit runs, is invisible. Scanning Claude Desktop/Code MCP logs for
  repeated connection failures against the same server would catch these retry
  storms. Also not covered today: long-lived VM keepalive loops, and orphaned
  session-storage directories that never appear in the normal session list.
```

- [ ] **Step 2: Note the limitation in README**

Add to the "Important Limitations" list, so the `MCP server connectivity` row of
"What It Checks" is not read as broader than it is:

```markdown
- **MCP connectivity is checked at audit time only.** A server that failed
  and retried repeatedly since your last audit, but is connected right now,
  will not be flagged. GhostSpend does not currently read MCP logs — see
  [`ROADMAP.md`](ROADMAP.md).
```

- [ ] **Step 3: Commit**

```bash
git add ROADMAP.md README.md
git commit -m "Record audit-time-only MCP check as a known gap"
```

---

### Task 6: Prepare the v0.1.1 release

v0.1.0 is already public: tag `v0.1.0` points at `2490c0e`, and its GitHub release
was published 2026-09-12. This task ships a patch release. It never touches the
`v0.1.0` tag or rewrites the `[0.1.0]` CHANGELOG entry.

**Files:**

- Modify: `CHANGELOG.md`, `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `package.json`

- [ ] **Step 1: Turn Unreleased into a dated 0.1.1 section**

On `main`, `CHANGELOG.md` has `## [Unreleased]` with a subsection mislabelled
`### Added (initial release)`. Everything in it landed *after* v0.1.0 shipped, so:

- Rename `## [Unreleased]` to `## [0.1.1] — <release date>`, and relabel its
  subsection `### Added`.
- Correct its two false claims. The `docs/config.md` bullet says it documents
  `knownTools`; it now documents `known_tools`. The `docs/gs-fix-dev-plan.md`
  bullet lists the file as added, but it was absent until Task 1.
- Add a `### Fixed` subsection covering Tasks 2–5, plus the workflow-file fix
  from #10.
- Leave the `## [0.1.0]` entry's content alone. Only add its release date:
  `## [0.1.0] — 2026-09-12`.
- Add a fresh empty `## [Unreleased]` above `[0.1.1]`.

- [ ] **Step 1b: Bump the version to 0.1.1 everywhere it is declared**

Set `"version": "0.1.1"` in all four places:

- `.claude-plugin/plugin.json`
- `package.json`
- `.claude-plugin/marketplace.json`: both the marketplace-level `version` and
  the plugin entry's `version`

```bash
git grep -n '"version"' -- .claude-plugin/plugin.json .claude-plugin/marketplace.json package.json
```

Expected: every line shows `0.1.1`.

- [ ] **Step 1c: Bring ROADMAP.md in line with what shipped**

Check off `First public release (\`v0.1.0\`)` and note that it shipped on
2026-09-12. Add a checked line for the v0.1.1 polish release beneath it.

- [ ] **Step 2: Run the full CI gate locally**

```bash
shellcheck scripts/*.sh
for f in scripts/*.sh; do /bin/bash -n "$f"; done
npx --yes markdownlint-cli2 --config .markdownlint-cli2.json "**/*.md" "#node_modules" "#LICENSE.md"
python3 -c "import json;[json.load(open(p)) for p in ['.claude-plugin/plugin.json','.claude-plugin/marketplace.json','package.json']];print('JSON valid')"
```

Expected: all four pass with no output/0 issues.

- [ ] **Step 3: Security sweep (checklist §2)**

```bash
git log -p | grep -inE 'api[_-]?key|secret|token|bearer ' || echo "no secrets in history"
git grep -inE 'api[_-]?key|secret|token|bearer ' -- ':!*.md' || echo "no secrets in tree"
```

Review any hit before continuing. Documentation matches are expected (SECURITY.md discusses tokens); code matches are not.

- [ ] **Step 4: Confirm the executable bit is committed**

```bash
git ls-files -s scripts/ | awk '{print $1, $4}'
```

Expected: mode `100755` for both scripts. If `100644`, run `git update-index --chmod=+x scripts/*.sh` and commit.

- [ ] **Step 5: Commit the release prep (no tag)**

```bash
git add CHANGELOG.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json package.json
git commit -m "Prepare v0.1.1 release"
```

**Do not run `git tag`.** This repo squash-merges PRs, so a tag created on this
branch would point at a commit that never lands on `main`.

Pushing the branch and opening its PR are shared-state actions. **Confirm with
the user first.** Once the PR's required checks pass, the user merges it.

- [ ] **Step 6: Hand the release and the GitHub-side items to the user**

After the release PR merges, the release itself is the **existing v0.1.1 draft**
that Release Drafter maintains (target `main`). Publishing that draft creates tag
`v0.1.1` on `main`. Tell the user to review the draft's notes against
`CHANGELOG.md` and publish it. Do not run `gh release create` or `git push --tags`.

Also list the remaining checklist items for the user:

- **§6:** a `develop` branch and the default-branch setting. Branch protection
  on `main` already exists, with required checks and `strict`.
- **§8:** repo description and topics.

These are GitHub web-UI operations on shared settings. They are not part of this
plan's automated execution.

---

## Milestone B — `/gs-fix` Phases 1–2

Do not start until Milestone A is merged. Phase 1 (severity) must land before Phase 2 (the command), per the spec's phase gating.

### Task 7: Phase 1 — severity classification

Severity lives in `skills/ghostspend-audit/SKILL.md` as the documented source of truth (spec §4), with the script encoding it mechanically so both the script and the skill agree.

**Files:**

- Modify: `scripts/ghostspend.sh`
- Modify: `skills/ghostspend-audit/SKILL.md`

**Interfaces:**

- Produces: findings encoded as `"<severity>|<message>"` where severity ∈ `critical|high|medium|low`. Task 8's fix skill parses on the first `|`. Messages must not contain a leading `|`.

- [ ] **Step 1: Add a `finding()` helper next to the existing output functions**

Alongside `ok()`/`warn()`/`fail()`/`flag()` at `scripts/ghostspend.sh:36-40`:

```bash
# finding <severity> <message> — severity is one of critical|high|medium|low
finding() { FINDINGS+=("$1|$2"); }
```

- [ ] **Step 2: Convert every `FINDINGS+=` call site**

Apply the spec §4 mapping:

```bash
# section 2 — MCP failures
finding high "$FAILED_COUNT MCP server(s) failing — see list above for reasons (auth, config mismatch, missing build)"

# section 2 — pending approval (new, low)
finding low "$PENDING_COUNT MCP server(s) pending approval — likely a duplicate project-local .mcp.json"

# section 3 — unbuilt plugin
finding critical "Plugin at $plugin_dir declares main entry '$main_entry' but the file doesn't exist. Likely needs: cd \"$plugin_dir\" && npm install && npm run build"

# section 4 — config drift
finding medium "$COUNT_MCP project-level .mcp.json file(s) under $dir: $(echo "$LOCAL_MCP" | tr '\n' ' ')"
```

Flagged tools stay in `FLAGGED_TOOLS` and are additionally recorded as findings so `/gs-fix` can act on them:

```bash
finding high "$label has local activity and is not in known_tools ($key)"
```

- [ ] **Step 3: Group the Summary by severity, critical first**

```bash
if [[ ${#FINDINGS[@]} -eq 0 ]]; then
  ok "No other actionable issues found. Environment looks clean."
else
  echo -e "${BOLD}${#FINDINGS[@]} issue(s) found:${RESET}"
  for sev in critical high medium low; do
    for entry in "${FINDINGS[@]}"; do
      [[ "${entry%%|*}" == "$sev" ]] || continue
      printf '  [%s] %s\n' "$(echo "$sev" | tr '[:lower:]' '[:upper:]')" "${entry#*|}"
    done
  done
fi
```

`tr` rather than `${sev^^}` — parameter-expansion case conversion is bash 4 only.

- [ ] **Step 3a: Refresh the worked example to the new Summary format**

`examples/sample-audit-output.md:89-93` reproduces the old Summary verbatim and
goes stale twice over: Task 3 Step 3 deletes its finding #2 (the always-on
"Review the combined ccusage report" pseudo-finding), and this task adds severity
prefixes. Update that block to:

```text
== Summary ==
FLAGGED: Unexpected usage from: codex gemini
3 issue(s) found:
  [HIGH] 2 MCP server(s) failing — see list above for reasons (auth, config mismatch, missing build)
  [HIGH] Codex CLI has local activity and is not in known_tools (codex)
  [HIGH] Gemini CLI has local activity and is not in known_tools (gemini)
```

The flagged tools now appear as findings (Step 2), which is why the count rises
even though the pseudo-finding was removed. Regenerate rather than hand-edit if
possible — run the audit and paste real output, then scrub it per the next step.

- [ ] **Step 3b: Confirm the example carries no real spend figures**

`HANDOVER.md` Part 5 item 4 forbids baking one person's audit numbers into
shipped documentation. The example currently shows `$443.41`, `$0.36`, `$2.11`,
`$0.28` and dates `2026-08-03/04/18` — close enough to the handover's real
`$442.05` run to be the same data. Paths are already anonymised
(`/Users/exampleuser/`); the figures are not.

Replace the cost column and dates with obviously-synthetic values and add a line
under the heading stating the numbers are illustrative. Keep the *shape* of the
output — the table, the model names' style, the `WARN Missing pricing` line —
since that is what the example teaches.

- [ ] **Step 4: Document the severity table in the audit skill**

Add a `## Severity Classification` section to `skills/ghostspend-audit/SKILL.md` after `## Output Format`, reproducing the spec §4 table and stating that it is the source of truth that `ghostspend-fix` reads — not something the fix skill re-derives.

- [ ] **Step 5: Verify against a real environment on bash 3.2**

```bash
shellcheck scripts/ghostspend.sh
/bin/bash scripts/ghostspend.sh "$HOME/Documents/GitHub" | tail -25
```

Expected: Summary lines are prefixed `[CRITICAL]` / `[HIGH]` / `[MEDIUM]` / `[LOW]` and appear in that order. Confirm at least one real finding from the current machine carries a plausible severity.

- [ ] **Step 6: Commit**

```bash
git add scripts/ghostspend.sh skills/ghostspend-audit/SKILL.md examples/sample-audit-output.md
git commit -m "Tag audit findings with severity

Encodes findings as severity|message and groups the summary critical-first,
so /gs-fix can prioritize. Severity table documented in the audit skill as
the source of truth."
```

---

### Task 8: Phase 2 — `/gs-fix`, safe-fix-only

Ships **Safest** and **Skip** only, for the two most common finding types: unbuilt plugin (critical) and flagged tool (high). Balanced and Other are Phase 3 and must not be implemented here.

**Files:**

- Create: `skills/ghostspend-fix/SKILL.md`
- Create: `commands/gs-fix.md`
- Modify: `.claude-plugin/plugin.json`

**Interfaces:**

- Consumes: `severity|message` findings from Task 7.
- Produces: a per-finding proposed command, shown verbatim before any execution.

- [ ] **Step 1: Write the fix skill**

`skills/ghostspend-fix/SKILL.md` — frontmatter `description` must be specific and trigger-oriented, since it determines invocation:

```markdown
---
name: ghostspend-fix
description: Walks the user through remediating findings from a GhostSpend audit one at a time, proposing a concrete fix per finding and executing nothing without showing the exact command and receiving explicit approval. Use after ghostspend-audit has produced findings, or when the user asks to fix, remediate, or clean up issues GhostSpend reported.
---
```

Body must cover:

- **Freshness gate.** If `setup_completed_at` is absent or the last audit is unknown, re-run `ghostspend-audit` rather than acting on stale findings. Offer a user override.
- **Option model — finding-type-aware.** Each finding type declares its available options. Render only those. Never show two options with identical actions.
- **Supported finding types this phase:**

  | Finding | Severity | Safest | Skip |
  | --- | --- | --- | --- |
  | Unbuilt plugin, missing main entry | critical | `cd "<plugin_dir>" && npm install && npm run build`, then re-run `claude mcp list` to confirm Connected | Report unresolved; re-flags next audit |
  | Flagged tool not in `known_tools` | high | Ask "is this expected?"; on yes, add the identifier to `known_tools` in `~/.ghostspend/config.json`. Never touch the vendor's CLI. | Leave flagged; re-appears next audit |

- **Everything else in this phase:** report as "not yet supported by `/gs-fix` — manual follow-up", do not improvise a fix.
- **Hard boundaries**, mirroring `SECURITY.md`: never disable, delete, or modify another vendor's CLI tool; never execute without showing the exact command/diff and getting a yes; decline and explain rather than attempting anything outside the documented action list.

- [ ] **Step 2: Write the thin command dispatcher**

`commands/gs-fix.md` — keep the `gs-` prefix, do not duplicate the skill's procedure:

```markdown
---
description: Walk through GhostSpend audit findings one at a time and apply approved fixes — shows the exact command for every action and never executes without confirmation
---

# /gs-fix

Invoke the `ghostspend-fix` skill.

1. Confirm a recent `ghostspend-audit` run exists. If findings are stale or
   absent, re-run the audit first (the user may override).
2. Work findings in severity order, critical first.
3. For each finding, present only the options that are actually distinct for
   that finding type.
4. Show the exact command or file diff and require an explicit yes before
   executing anything.
5. Close with a summary: fixed, skipped, needs manual follow-up.
```

- [ ] **Step 3: Sync the plugin manifest**

`.claude-plugin/plugin.json` — add both files, or the components silently do not load:

```json
  "commands": [
    "./commands/gs-audit.md",
    "./commands/gs-fix.md",
    "./commands/gs-setup.md"
  ],
  "skills": [
    "./skills/ghostspend-audit/SKILL.md",
    "./skills/ghostspend-fix/SKILL.md",
    "./skills/ghostspend-setup/SKILL.md"
  ],
```

Bump `version` to `0.2.0` here, in `package.json`, and in `.claude-plugin/marketplace.json`.

- [ ] **Step 4: Add the orchestrator's third stage**

`agents/ghostspend-orchestrator.md` — insert a step 5 before the existing "Never apply a fix without confirmation" (which becomes step 6): after presenting the consolidated report, ask whether to proceed to remediation; on yes, invoke `ghostspend-fix`. Do not re-run setup or audit that already ran this session.

- [ ] **Step 5: Verify frontmatter parses and the manifest is complete**

```bash
for f in commands/*.md agents/*.md skills/*/SKILL.md; do
  head -1 "$f" | grep -q '^---$' && echo "OK  $f" || echo "BAD $f"
done
python3 -c "
import json,os
m=json.load(open('.claude-plugin/plugin.json'))
listed={os.path.normpath(p) for k in ('commands','skills','agents') for p in m.get(k,[])}
actual={os.path.join(d,f) for d,_,fs in os.walk('.') for f in fs
        if (d.startswith('./commands') or d.startswith('./agents') or d.startswith('./skills')) and f.endswith('.md')}
actual={os.path.normpath(p) for p in actual}
print('missing from manifest:', actual-listed or 'none')
print('listed but absent:', listed-actual or 'none')
"
```

Expected: `OK` for every component file, and both diff sets `none`.

- [ ] **Step 6: Live-invoke the plugin — required, not optional**

`CLAUDE.md` requires that skill/agent/command Markdown changes be exercised in a live Claude Code session, not just diffed.

**Load the working tree directly. Do not copy files into `~/.claude/plugins/`.**
On this machine the enabled GhostSpend is the marketplace install
(`ghostspend@ghostspend`, cached at `~/.claude/plugins/cache/ghostspend/ghostspend/0.1.0`,
commit `2f9ac26`), and `~/.claude/plugins/ghostspend` is an unregistered leftover.
Copying into either one tests old code. `claude --plugin-dir` loads a plugin for a
single session (it is listed in `claude --help`). Disable the same-named marketplace
copy for that session only:

```bash
claude --plugin-dir "$PWD" --settings '{"enabledPlugins":{"ghostspend@ghostspend":false}}'
```

**That `--settings` override is not yet verified**, so confirm which copy loaded
before testing behavior. Invoke `/gs-setup`: the `Base directory for this skill:`
line it prints must be this working tree, not `~/.claude/plugins/cache/...`. For
Milestone B, `/gs-fix` must also appear, and `/gs-audit` must appear exactly once.
If both copies load, or neither does, stop and ask the user. Do not run
`claude plugin disable ghostspend@ghostspend` yourself, because that changes their
settings permanently.

Then run `/gs-audit` followed by `/gs-fix`. Confirm by observation: `/gs-fix` appears in the command list; findings are presented critical-first; the unbuilt-plugin finding offers exactly Safest and Skip (not four options); choosing Safest prints `cd … && npm install && npm run build` and **waits** rather than executing. Decline it, and confirm nothing ran.

Report what was actually observed in the session, not the diff.

- [ ] **Step 7: Update docs**

- `README.md`: add `/gs-fix` to Usage and the structure diagram; state the Phase-2 limitation (Safest/Skip only, two finding types) and that there is no standalone bash equivalent.
- `ROADMAP.md`: check off severity classification and the `/gs-fix` skeleton; leave Phases 3–5 open.
- `CHANGELOG.md`: add `## [0.2.0]` with the new command, skill, severity tagging, and orchestrator stage.
- `docs/gs-fix-dev-plan.md`: mark Phases 1–2 complete.

- [ ] **Step 8: Commit**

```bash
git add skills/ghostspend-fix commands/gs-fix.md .claude-plugin/plugin.json \
        agents/ghostspend-orchestrator.md package.json .claude-plugin/marketplace.json \
        README.md ROADMAP.md CHANGELOG.md docs/gs-fix-dev-plan.md
git commit -m "Add /gs-fix safe-fix-only remediation flow

Ships Safest and Skip for unbuilt-plugin and flagged-tool findings.
Options are finding-type-aware, so identical choices are never presented
as a tradeoff. Nothing executes without the exact command shown and an
explicit yes."
```

---

## Verification

Run in order. Every step is a real command whose output must be read, not assumed.

**Gate 1 — CI parity (after every task):**

```bash
shellcheck scripts/*.sh
for f in scripts/*.sh; do /bin/bash -n "$f"; done
npx --yes markdownlint-cli2 --config .markdownlint-cli2.json "**/*.md" "#node_modules" "#LICENSE.md"
python3 -c "import json;[json.load(open(p)) for p in ['.claude-plugin/plugin.json','.claude-plugin/marketplace.json','package.json']];print('JSON valid')"

# closing-fence style — markdownlint reports 0 issues on files this catches
rc=0
for f in $(git ls-files '*.md' | grep -v '^LICENSE.md$'); do
  awk -v F="$f" '
    /^````/ { f4 = !f4; next }
    f4      { next }
    /^```/  { if (n%2==1 && $0 != "```") { printf "%s:%d TAGGED CLOSER\n", F, FNR; bad=1 } n++ }
    END     { if (n%2) { printf "%s UNCLOSED\n", F; bad=1 } exit bad }' "$f" || rc=1
done; echo "(fence scan complete, rc=$rc)"
```

**Gate 2 — bash 3.2 regression (the one CI does not cover):**

```bash
/bin/bash --version | head -1   # must report 3.2.x

# setup.sh: throwaway HOME only (see Start here)
O=$(mktemp)
H=$(mktemp -d); printf '\nn\nn\n' | HOME="$H" /bin/bash scripts/setup.sh >>"$O" 2>&1
H=$(mktemp -d); mkdir "$H/.codex"; printf 'n\n\nn\nn\n' | HOME="$H" /bin/bash scripts/setup.sh >>"$O" 2>&1
grep 'unbound variable' "$O" && echo "FAIL: setup.sh" || echo "setup.sh: no unbound variable"

# ghostspend.sh: read-only, so the real HOME is fine
/bin/bash scripts/ghostspend.sh "$HOME/Documents/GitHub" >"$O" 2>&1
grep 'unbound variable' "$O" && echo "FAIL: ghostspend.sh" || echo "ghostspend.sh: no unbound variable"
```

No run may print `unbound variable`. This is the check that catches the Task 2 class of defect. `shellcheck` returns 0 on the broken code, and running `setup.sh` against a real `HOME` that already has a config never reaches it.

**Gate 3 — clean-checkout install (checklist §10):**

```bash
D=$(mktemp -d)
git clone --quiet --branch "$(git branch --show-current)" "$PWD" "$D/gs"   # this branch's committed state, no network
( cd "$D/gs" && HOME="$(mktemp -d)" npm run setup </dev/null ) 2>&1 | tail -8
```

It must print the `GhostSpend Setup` banner and end at `Aborted. No config written.`, not an `ENOENT` or "no such file" error. That is what the Task 5 `bin` fix exists to prove. Cloning from `origin` would test `main`, which keeps the broken path until this branch merges.

**Gate 4 — live plugin session (required whenever `skills/`, `agents/`, or `commands/` change — that now includes Milestone A Task 2):** follow Task 8 Step 6. Load the working tree with `claude --plugin-dir`, never an installed copy, and confirm the `Base directory for this skill:` line points at it. Editing frontmatter and prose does not confirm a component loads or triggers; only invoking it does.

For Milestone A specifically, confirm: `/gs-setup` against an **existing** config offers to continue into an audit rather than stopping, and answering yes produces visible audit output inline rather than silently backgrounding it.

**Gate 5 — boundary check (Milestone B):** in the live session, ask `/gs-fix` to do something outside its documented actions — "delete that MCP server's credentials". It must decline with an explanation and execute nothing.

## Out of scope

Per `ROADMAP.md`'s permanent boundaries and the answers given during planning: no fully autonomous remediation, no real-time monitoring, no `scripts/ghostspend-fix.sh`, and no Phase 3 (`Balanced` / `Other` free-text) in this plan.
