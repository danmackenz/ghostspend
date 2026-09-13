#!/usr/bin/env bash
# ghostspend.sh
# Core diagnostic engine for GhostSpend.
# Checks Claude Code hooks, MCP server health, plugin build integrity,
# project-level config drift, AND cross-provider AI token spend
# (Claude Code, Codex CLI, Gemini CLI, Copilot CLI, and others via ccusage).
#
# Usage:
#   ./ghostspend.sh [parent_dir_1] [parent_dir_2] ...
#
# If no parent dirs are given, uses scan_dirs from ~/.ghostspend/config.json
# if present, otherwise falls back to $HOME/Documents and $HOME/Projects.
# Run ./setup.sh first for the best experience (records known_tools so
# unexpected-usage flagging works).
#
# NOTE: Written to be compatible with bash 3.2 (macOS system default),
# not just bash 4+. Avoid mapfile, associative arrays, and other bash4-only
# features — many users will not have upgraded their default bash.


set -uo pipefail


CONFIG_FILE="$HOME/.ghostspend/config.json"
DEFAULT_SCAN_DIRS=("$HOME/Documents" "$HOME/Projects")


BOLD=$(tput bold 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")


section() { echo -e "\n${BOLD}== $1 ==${RESET}"; }
ok()      { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
fail()    { echo -e "${RED}[FAIL]${RESET} $1"; }
flag()    { echo -e "${CYAN}[FLAGGED]${RESET} $1"; }
finding() { FINDINGS+=("$1|$2"); }


FINDINGS=()
FLAGGED_TOOLS=()


# ---------------------------------------------------------------------------
section "0. GhostSpend configuration"
# ---------------------------------------------------------------------------
KNOWN_TOOLS=""
CONFIG_SCAN_DIRS=""
if [[ -f "$CONFIG_FILE" ]]; then
  ok "Config found at $CONFIG_FILE"
  KNOWN_TOOLS=$(grep -o '"known_tools"[[:space:]]*:[[:space:]]*\[[^]]*\]' "$CONFIG_FILE" 2>/dev/null)
  CONFIG_SCAN_DIRS=$(grep -o '"scan_dirs"[[:space:]]*:[[:space:]]*\[[^]]*\]' "$CONFIG_FILE" 2>/dev/null | grep -o '"/[^"]*"' | tr -d '"')
  echo "  Known tools: $KNOWN_TOOLS"
else
  warn "No config found. Run ./setup.sh first for unexpected-usage flagging to work."
  warn "Falling back to default scan directories."
fi


SCAN_DIRS=()
if [[ $# -gt 0 ]]; then
  SCAN_DIRS=("$@")
elif [[ -n "$CONFIG_SCAN_DIRS" ]]; then
  while IFS= read -r dir_line; do
    [[ -n "$dir_line" ]] && SCAN_DIRS+=("$dir_line")
  done <<< "$CONFIG_SCAN_DIRS"
fi
if [[ ${#SCAN_DIRS[@]} -eq 0 ]]; then
  SCAN_DIRS=("${DEFAULT_SCAN_DIRS[@]}")
fi


# ---------------------------------------------------------------------------
section "1. Global hook configuration"
# ---------------------------------------------------------------------------
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$GLOBAL_SETTINGS" ]]; then
  if grep -q '"hooks"' "$GLOBAL_SETTINGS" 2>/dev/null; then
    ok "Global hooks found in $GLOBAL_SETTINGS"
    grep -A 3 '"PreToolUse"\|"SessionStart"\|"PostToolUse"\|"SessionEnd"' "$GLOBAL_SETTINGS" 2>/dev/null | sed 's/^/    /'
  else
    warn "No hooks configured globally (this may be intentional)"
  fi
else
  warn "No global settings.json found at $GLOBAL_SETTINGS"
fi


# ---------------------------------------------------------------------------
section "2. MCP server connectivity"
# ---------------------------------------------------------------------------
if command -v claude >/dev/null 2>&1; then
  MCP_OUTPUT=$(claude mcp list 2>&1)
  echo "$MCP_OUTPUT"
  FAILED_COUNT=$(echo "$MCP_OUTPUT" | grep -c "Failed to connect" || true)
  PENDING_COUNT=$(echo "$MCP_OUTPUT" | grep -c "Pending approval" || true)
  if [[ "$FAILED_COUNT" -gt 0 ]]; then
    fail "$FAILED_COUNT MCP server(s) failed to connect"
    finding high "$FAILED_COUNT MCP server(s) failing — see list above for reasons (auth, config mismatch, missing build)"
  else
    ok "No failed MCP connections"
  fi
  if [[ "$PENDING_COUNT" -gt 0 ]]; then
    warn "$PENDING_COUNT MCP server(s) pending approval — check for duplicate/local .mcp.json overrides"
    finding low "$PENDING_COUNT MCP server(s) pending approval — likely a duplicate project-local .mcp.json"
  fi
else
  warn "claude CLI not found on PATH — skipping MCP check"
fi


# ---------------------------------------------------------------------------
section "3. Installed plugin build health (missing dist/ detection)"
# ---------------------------------------------------------------------------
PLUGIN_CACHE="$HOME/.claude/plugins/cache"
if [[ -d "$PLUGIN_CACHE" ]]; then
  PLUGIN_ISSUES=0
  while IFS= read -r pkgjson; do
    plugin_dir=$(dirname "$pkgjson")
    main_entry=$(grep -o '"main"[[:space:]]*:[[:space:]]*"[^"]*"' "$pkgjson" 2>/dev/null | sed 's/.*"main"[[:space:]]*:[[:space:]]*"//;s/"$//')
    if [[ -n "$main_entry" ]]; then
      full_path="$plugin_dir/$main_entry"
      if [[ ! -f "$full_path" ]]; then
        fail "Missing build output: $full_path"
        finding critical "Plugin at $plugin_dir declares main entry '$main_entry' but the file doesn't exist. Likely needs: cd \"$plugin_dir\" && npm install && npm run build"
        PLUGIN_ISSUES=$((PLUGIN_ISSUES + 1))
      fi
    fi
  done < <(find "$PLUGIN_CACHE" -maxdepth 3 -iname "package.json" 2>/dev/null)
  if [[ "$PLUGIN_ISSUES" -eq 0 ]]; then
    ok "All installed plugins with a package.json 'main' entry have their build output present"
  fi
else
  warn "No plugin cache directory found at $PLUGIN_CACHE"
fi


# ---------------------------------------------------------------------------
section "4. Project-level config drift across scanned directories"
# ---------------------------------------------------------------------------
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
    finding medium "$COUNT_MCP project-level .mcp.json file(s) under $dir: $(echo "$LOCAL_MCP" | tr '\n' ' ')"
  fi
done


# ---------------------------------------------------------------------------
section "5. Cross-provider AI token spend (ccusage)"
# ---------------------------------------------------------------------------
CCUSAGE_BIN=""
if command -v ccusage >/dev/null 2>&1; then
  CCUSAGE_BIN="ccusage"
  ok "ccusage found globally — using installed binary"
else
  warn "ccusage is not installed globally."
  warn "Falling back to 'npx ccusage' (slower: re-resolves the package each run)."
  warn "Recommended: run 'npm install -g ccusage' once, then re-run."
  if command -v npx >/dev/null 2>&1; then
    CCUSAGE_BIN="npx ccusage"
  fi
fi


if [[ -n "$CCUSAGE_BIN" ]]; then
  echo "--- Combined daily report (all detected AI CLI tools) ---"
  DAILY_OUTPUT=$($CCUSAGE_BIN daily 2>&1)
  echo "$DAILY_OUTPUT"


  echo ""
  echo "--- Per-tool presence check ---"

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
      finding high "$label has local activity and is not in known_tools ($key)"
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
else
  warn "Neither ccusage nor npx is available — skipping spend check entirely."
fi


if command -v rtk >/dev/null 2>&1; then
  echo ""
  echo "--- rtk savings summary (Claude Code only, not a substitute for the ccusage check above) ---"
  rtk cc-economics 2>&1 || warn "rtk cc-economics failed to run"
fi


# ---------------------------------------------------------------------------
section "6. Zombie / orphaned AI CLI processes"
# ---------------------------------------------------------------------------
if pgrep -ilf "mcp|codex|gemini-cli" >/dev/null 2>&1; then
  pgrep -ilf "mcp|codex|gemini-cli"
else
  ok "No AI CLI-related background processes found running"
fi


# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------
if [[ ${#FLAGGED_TOOLS[@]} -gt 0 ]]; then
  echo -e "${CYAN}${BOLD}FLAGGED: Unexpected usage from: ${FLAGGED_TOOLS[*]}${RESET}"
fi
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


echo -e "\nDone. Re-run after applying fixes to confirm they took effect."
