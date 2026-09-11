# GhostSpend

A Claude Code plugin (with standalone-runnable bash scripts) that audits a
user's local AI CLI environment for hidden token/cost leakage: misconfigured
hooks, dead or duplicated MCP servers, plugins with incomplete builds,
project-level config drift, and cross-provider spend (Claude Code, Codex
CLI, Gemini CLI, and others) via `ccusage`.

## Non-negotiables

- This repo ships two kinds of Markdown with YAML frontmatter —
  `skills/*/SKILL.md`, `agents/*.md`, and `commands/*.md` — that Claude
  Code parses structurally. Do not remove or reformat the `---` frontmatter
  blocks; broken frontmatter silently disables the component.
- Slash commands in `commands/` must keep the `gs-` prefix
  (`gs-setup`, `gs-audit`, and the planned `gs-fix`). Do not add a new
  command without it — this is a deliberate choice to avoid the documented
  Claude Code plugin namespace collision issue with generic command names.
- No script or skill may make a network call without an explicit, visible
  user confirmation step first. This includes `npm install -g ccusage` and
  any plugin `npm install`/`npm run build` step.
- No script or skill may read, log, or display `.env` file contents, API
  keys, tokens, or credentials of any kind.
- There is no build step for this repo itself — it is plain bash and
  Markdown. Do not introduce a compiler, bundler, or transpilation step
  without discussing it first.
- No fix, check, or future `/gs-fix` action may execute a destructive or
  spend-affecting change without explicit, per-finding user confirmation.
  This is a permanent project boundary — see `ROADMAP.md`'s "Explicitly Out
  of Scope" section and `docs/gs-fix-dev-plan.md`'s Security Constraints.

## Stack and repository map

- **Language:** Bash (POSIX-ish, targeting bash 3.2+ for macOS default
  compatibility) and Markdown with YAML frontmatter.
- **Runtime dependency for full functionality:** Node.js/npm (only for
  installing/running `ccusage`, an external tool this repo wraps, not
  something this repo builds).
- **No package manager for the repo itself** — nothing here needs
  `npm install` to run; `package.json` exists only for npm discoverability
  and to expose `bin` entries.

```text
.claude-plugin/plugin.json         Plugin manifest — keep in sync with the
                                    actual files present in agents/, skills/,
                                    commands/. If you add or rename a
                                    component file, update this manifest in
                                    the same change.
agents/
  ghostspend-orchestrator.md       Orchestrates setup + audit into one report
                                    (will gain a third stage when /gs-fix ships)
skills/
  ghostspend-setup/SKILL.md        First-run baseline configuration procedure
  ghostspend-audit/SKILL.md        Full diagnostic methodology
commands/
  gs-setup.md                      /gs-setup slash command
  gs-audit.md                      /gs-audit slash command
scripts/
  setup.sh                         Interactive, standalone-runnable
  ghostspend.sh                    Interactive, standalone-runnable
docs/
  config.md                        Schema reference for
                                    ~/.ghostspend/config.json
  gs-fix-dev-plan.md                Working engineering spec for the planned
                                    /gs-fix command — update this as design
                                    decisions are made, don't treat as frozen
examples/
  sample-audit-output.md            Worked, end-to-end example: raw ccusage
                                    output -> config state -> flagged report
.github/                           Issue/PR templates, CI workflow
README.md, CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md, CHANGELOG.md
ROADMAP.md                         Planned work and permanent scope boundaries
AGENTS.md                          Portable, cross-tool contributor guidance
                                    (also read by Codex, Cursor, etc.)
```

## Commands

Verified against the actual scripts in this repo — do not add commands
here that aren't real:

```bash
shellcheck scripts/*.sh      # required, must pass with zero warnings before merge
bash -n scripts/*.sh          # quick syntax-only check
./scripts/setup.sh            # interactive first-run config, run manually to test
./scripts/ghostspend.sh        # interactive audit, run manually to test
```

There is no automated test suite yet. Until one exists (see
`CONTRIBUTING.md` for the open `bats-core` contribution), verification means
actually running the script and reporting real output — do not claim a
check passed without running it.

## Architecture and file-location rules

- **Skills** (`skills/*/SKILL.md`) contain diagnostic *methodology* —
  step-by-step procedures Claude follows. They should not contain the raw
  shell commands verbatim if those commands live in `scripts/`; instead
  reference the script. Keep the two in sync: if you change a check in
  `ghostspend.sh`, update the corresponding step in `ghostspend-audit/SKILL.md`.
- **Agents** (`agents/*.md`) orchestrate *when* skills run and how their
  output is combined — they contain decision logic, not diagnostic detail.
- **Commands** (`commands/*.md`) are thin dispatchers that invoke a skill
  or agent. Do not duplicate a skill's full procedure inside a command file.
- **Scripts** (`scripts/*.sh`) must remain runnable standalone, without
  Claude Code installed at all — this is a stated project value (see
  README.md "Option B"). Do not add a script that depends on a Claude-Code-
  only environment variable without a non-Claude fallback.
- **Docs** (`docs/*.md`) hold reference material and active engineering
  specs that are too detailed for `README.md` but still need to live
  somewhere discoverable — e.g. the `~/.ghostspend/config.json` schema and
  the `/gs-fix` dev plan. Unlike `skills/`, files here are read by humans,
  not parsed structurally by Claude Code.
- **Examples** (`examples/*.md`) hold worked, illustrative walkthroughs of
  real tool output for documentation purposes. This is distinct from the
  rule below about config files: a narrative example showing what audit
  output looks like is encouraged; a literal, loadable
  `~/.ghostspend/config.json` template is not.
- User-facing config lives at `~/.ghostspend/config.json`, never inside
  the repo itself. Do not commit a real, loadable sample config file
  anywhere in the repo (root or otherwise) — illustrative config snippets
  belong inside documentation code blocks (as in `docs/config.md` and
  `examples/sample-audit-output.md`), not as standalone `.json` files a
  script could accidentally read.

## Coding standards

- Bash: `set -uo pipefail` at the top of every script; prefer `[[ ]]` over
  `[ ]`; quote variable expansions that could contain spaces or globs.
- Prefer functions like `ok()`, `warn()`, `fail()`, `flag()` (already
  defined in `ghostspend.sh`) for consistent, colorized output rather than
  raw `echo` for status lines.
- Skill/agent/command YAML frontmatter `description` fields must be
  specific and trigger-oriented — they determine when Claude invokes the
  component. Do not genericize a description for brevity; specificity is
  the point.
- Do not invent a new check's exact command syntax without first verifying
  it — e.g. confirm a `ccusage` subcommand or flag actually exists before
  documenting or scripting it.

## Task-specific workflows

### Adding a new diagnostic check

1. Confirm the check's underlying command actually works by running it
   yourself first — do not add speculative checks.
2. Add the shell logic to `scripts/ghostspend.sh`, following the existing
   `section()`/`ok()`/`warn()`/`fail()` pattern.
3. Update `skills/ghostspend-audit/SKILL.md` with the corresponding
   methodology step, in the same order as the script.
4. Update `README.md`'s "What It Checks" table.
5. Add a `CHANGELOG.md` entry.
6. If the check introduces a new severity-worthy finding type, add it to
   the severity table in `docs/gs-fix-dev-plan.md` so `/gs-fix` (once
   built) handles it correctly — even before `/gs-fix` itself exists.

### Fixing a bug in a script

1. Reproduce the failure by running the script yourself.
2. Identify the root cause before editing — state it in the PR.
3. Make the smallest fix; do not refactor unrelated sections.
4. Re-run `shellcheck` and the script manually to confirm the fix.

### Modifying a skill or agent's Markdown

1. Edit the file.
2. Install this repo locally as a plugin (README.md "Option A") and
   actually invoke `/gs-setup` or `/gs-audit` in a live Claude Code
   session — editing frontmatter/prose alone does not confirm the
   component triggers or behaves as intended.
3. Report what you actually observed in the live session, not just the
   diff.

### Working on `/gs-fix` (planned, v0.2.x)

1. Read `docs/gs-fix-dev-plan.md` in full before writing any code — it
   defines the phase order (severity tagging first, then a safe-fix-only
   skeleton, then the full 4-option flow) and the non-negotiable security
   constraints.
2. Do not skip ahead to Phase 3 (full interview flow) before Phase 1
   (severity classification) is merged — later phases depend on it.
3. Any new finding type added anywhere in the audit must have a severity
   and a mapped action for at least the "Safest" and "Skip" options before
   `/gs-fix` can support it.

## Security and secrets

- No secrets, API keys, or credentials of any kind belong in this repo,
  in generated config templates, or in example output shown in
  documentation.
- Every write action (installing `ccusage`, writing
  `~/.ghostspend/config.json`, building a plugin) must prompt for user
  confirmation before executing — this is enforced in `setup.sh` via
  `read -rp` prompts and must be preserved in any modification.
- This principle extends to the planned `/gs-fix` command without
  exception: no option (including "Other" free-text) may execute a
  proposed action without the user seeing the exact command/diff first
  and explicitly approving it. See `docs/gs-fix-dev-plan.md` Section 6.
- See `SECURITY.md` for the full policy and vulnerability reporting
  process. Report a security concern found while working on this repo
  through that process, not as a regular GitHub issue.

## Completion checklist

Before reporting a change as done:

- [ ] `shellcheck scripts/*.sh` passes with zero warnings (if scripts changed)
- [ ] The modified script or skill was actually run/invoked, not just edited
- [ ] `.claude-plugin/plugin.json` still lists every actual component file
- [ ] `README.md` and `CHANGELOG.md` updated if behavior, usage, or
      installation changed
- [ ] `ROADMAP.md` updated (checked off or amended) if the change
      completes or alters a planned item
- [ ] No secrets, credentials, or unconfirmed network calls introduced
- [ ] Report: files changed, commands actually run, and any remaining
      limitations or untested paths

## Deeper documentation

- Contributor workflow and PR process: @CONTRIBUTING.md
- Security policy and vulnerability reporting: @SECURITY.md
- Cross-tool (non-Claude-Code) contributor guidance: @AGENTS.md
- Full feature list and installation options: @README.md
- Planned work and permanent scope boundaries: @ROADMAP.md
- `~/.ghostspend/config.json` schema reference: @docs/config.md
- `/gs-fix` engineering spec: @docs/gs-fix-dev-plan.md
