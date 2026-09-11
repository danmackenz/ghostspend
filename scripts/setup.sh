#!/usr/bin/env bash
# setup.sh
# First-run configuration for GhostSpend. Interactive: checks dependencies,
# records which AI CLI tools you actually use, and stores project scan
# directories in ~/.ghostspend/config.json.
#
# Usage: ./setup.sh


set -uo pipefail


CONFIG_DIR="$HOME/.ghostspend"
CONFIG_FILE="$CONFIG_DIR/config.json"


BOLD=$(tput bold 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")


ok()   { echo -e "${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }


echo -e "${BOLD}GhostSpend Setup${RESET}"
echo "This will check your dependencies and record a baseline of which AI"
echo "CLI tools you actively use, so future audits can flag anything else."
echo ""


if [[ -f "$CONFIG_FILE" ]]; then
  warn "Existing config found at $CONFIG_FILE"
  read -rp "Reconfigure from scratch? [y/N] " RECONFIGURE
  if [[ ! "$RECONFIGURE" =~ ^[Yy]$ ]]; then
    echo "Keeping existing config. Exiting."
    exit 0
  fi
fi


# --- Dependency checks ------------------------------------------------------
echo -e "\n${BOLD}Checking dependencies...${RESET}"


CCUSAGE_INSTALLED=false
if command -v ccusage >/dev/null 2>&1; then
  ok "ccusage is installed"
  CCUSAGE_INSTALLED=true
else
  warn "ccusage is not installed globally (required for spend checks)"
  read -rp "Install it now with 'npm install -g ccusage'? [y/N] " INSTALL_CCUSAGE
  if [[ "$INSTALL_CCUSAGE" =~ ^[Yy]$ ]]; then
    npm install -g ccusage && CCUSAGE_INSTALLED=true
  else
    warn "Skipping. GhostSpend will fall back to 'npx ccusage' (slower)."
  fi
fi


RTK_INSTALLED=false
if command -v rtk >/dev/null 2>&1; then
  ok "rtk is installed (optional, Claude-only savings summary)"
  RTK_INSTALLED=true
else
  warn "rtk not installed (optional, skip if you don't use it)"
fi


if command -v claude >/dev/null 2>&1; then
  ok "claude CLI is installed"
else
  warn "claude CLI not found — MCP checks will be skipped in audits"
fi


# --- Detect local AI CLI tool data ------------------------------------------
echo -e "\n${BOLD}Detecting local AI CLI tool data...${RESET}"
DETECTED=()
[[ -d "$HOME/.claude" ]] && DETECTED+=("claude-code")
[[ -d "$HOME/.codex" ]] && DETECTED+=("codex")
[[ -d "$HOME/.gemini" ]] && DETECTED+=("gemini")
[[ -d "$HOME/.config/opencode" ]] && DETECTED+=("opencode")


if [[ ${#DETECTED[@]} -eq 0 ]]; then
  warn "No known AI CLI tool data directories found."
else
  echo "Found local data for: ${DETECTED[*]}"
fi


# --- Ask which tools are knowingly used -------------------------------------
echo -e "\n${BOLD}Which of these do you actively and knowingly use?${RESET}"
echo "(Anything you don't confirm here will be flagged in future audits if"
echo "it shows spend — that's the whole point.)"
KNOWN_TOOLS=()
for tool in "${DETECTED[@]}"; do
  read -rp "  Do you use $tool? [y/N] " USE_TOOL
  [[ "$USE_TOOL" =~ ^[Yy]$ ]] && KNOWN_TOOLS+=("$tool")
done


# --- Ask for scan directories -----------------------------------------------
echo -e "\n${BOLD}Where do your coding projects live?${RESET}"
echo "Enter one or more parent directory paths, one per line. Leave blank"
echo "and press Enter on an empty line when done."
SCAN_DIRS=()
while true; do
  read -rp "  Path (or Enter to finish): " DIR_INPUT
  [[ -z "$DIR_INPUT" ]] && break
  EXPANDED_DIR="${DIR_INPUT/#\~/$HOME}"
  if [[ -d "$EXPANDED_DIR" ]]; then
    SCAN_DIRS+=("$EXPANDED_DIR")
    ok "Added: $EXPANDED_DIR"
  else
    warn "Directory not found, skipping: $EXPANDED_DIR"
  fi
done


if [[ ${#SCAN_DIRS[@]} -eq 0 ]]; then
  warn "No scan directories added. Defaulting to \$HOME/Documents and \$HOME/Projects."
  SCAN_DIRS=("$HOME/Documents" "$HOME/Projects")
fi


# --- Build and write config -------------------------------------------------
KNOWN_TOOLS_JSON=$(printf '"%s",' "${KNOWN_TOOLS[@]}")
KNOWN_TOOLS_JSON="[${KNOWN_TOOLS_JSON%,}]"
SCAN_DIRS_JSON=$(printf '"%s",' "${SCAN_DIRS[@]}")
SCAN_DIRS_JSON="[${SCAN_DIRS_JSON%,}]"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")


echo -e "\n${BOLD}Config to be written:${RESET}"
cat <<EOF
{
  "known_tools": $KNOWN_TOOLS_JSON,
  "scan_dirs": $SCAN_DIRS_JSON,
  "ccusage_installed": $CCUSAGE_INSTALLED,
  "rtk_installed": $RTK_INSTALLED,
  "setup_completed_at": "$TIMESTAMP"
}
EOF


read -rp $'\nWrite this to '"$CONFIG_FILE"'? [y/N] ' CONFIRM_WRITE
if [[ ! "$CONFIRM_WRITE" =~ ^[Yy]$ ]]; then
  echo "Aborted. No config written."
  exit 0
fi


mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" <<EOF
{
  "known_tools": $KNOWN_TOOLS_JSON,
  "scan_dirs": $SCAN_DIRS_JSON,
  "ccusage_installed": $CCUSAGE_INSTALLED,
  "rtk_installed": $RTK_INSTALLED,
  "setup_completed_at": "$TIMESTAMP"
}
EOF


ok "Config written to $CONFIG_FILE"
echo -e "\n${BOLD}Setup complete.${RESET} Run ./ghostspend.sh (or /audit in Claude Code) any time."
