# ANTRHROPIC

<div align="center">

### [CLAUDE PLUGIN](https://www.skills.sh/p/qtjSwDWCq52yVpxi)

<p>
  <a href="https://www.skills.sh/p/qtjSwDWCq52yVpxi">
    <img
      alt="Install GhostSpend from skills.sh"
      src="https://img.shields.io/badge/Install%20GhostSpend-skills.sh%20pack-111111?style=for-the-badge&labelColor=111111"
    />
  </a>
</p>

</div>

<p align="center">
  <img
    src="https://cdn.danmackenzie.co.uk/development/ghostspend/hero/Premium%20GhostSpend%20README%20banner%20hero.png"
    alt="GhostSpend banner showing AI CLI spend auditing and remediation"
    width="100%"
  />
</p>

<div align="center">

### Built for real-world AI tooling

<a href="https://github.com/danmackenz/ghostspend/actions/workflows/ci.yml">
  <img
    alt="CI"
    src="https://img.shields.io/github/actions/workflow/status/danmackenz/ghostspend/ci.yml?branch=main&style=flat-square&label=build&labelColor=111827&color=15803D&logo=githubactions&logoColor=white"
  />
</a>
<a href="https://github.com/danmackenz/ghostspend/releases">
  <img
    alt="Latest release"
    src="https://img.shields.io/github/v/release/danmackenz/ghostspend?display_name=tag&style=flat-square&label=release&labelColor=111827&color=0F766E&logo=github"
  />
</a>
<a href="./LICENSE">
  <img
    alt="MIT license"
    src="https://img.shields.io/badge/license-MIT-6B7280?style=flat-square&labelColor=111827&logo=open-source-initiative&logoColor=white"
  />
</a>

</div>

<div align="center">

### Bash toolkit for finding hidden token and cost leakage across modern AI CLI workflows

<a href="#quick-install">Quick install</a> ·
<a href="#install-in-claude-desktop">Claude Desktop</a> ·
<a href="#installation-options">Other install methods</a> ·
<a href="#usage">Usage</a> ·
<a href="docs/config.md">Configuration</a> ·
<a href="examples/sample-audit-output.md">Example output</a> ·
<a href="ROADMAP.md">Roadmap</a> ·
<a href="SECURITY.md">Security</a>

</div>

<br>
<br>

<table width="100%">
  <thead>
    <tr>
      <th align="left" width="44%">What GhostSpend does</th>
      <th width="12%"></th>
      <th align="left" width="44%">Capability</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">⊘ Flags usage outside your known-tools baseline</td>
      <td></td>
      <td align="left">Unexpected spend detection</td>
    </tr>
    <tr>
      <td align="left">◉ Surfaces activity across Claude Code, Codex CLI, Gemini CLI, OpenCode, and related tooling</td>
      <td></td>
      <td align="left">Cross-provider visibility</td>
    </tr>
    <tr>
      <td align="left">⌘ Checks hooks, MCP servers, plugin builds, and project drift</td>
      <td></td>
      <td align="left">Configuration diagnostics</td>
    </tr>
    <tr>
      <td align="left">→ Points to exact commands and next steps to fix issues</td>
      <td></td>
      <td align="left">Guided remediation</td>
    </tr>
    <tr>
      <td align="left">∴ Separates expected activity from unexpected usage instead of only reporting totals</td>
      <td></td>
      <td align="left">Baseline-first auditing</td>
    </tr>
    <tr>
      <td align="left">⌁ Supports setup, audit, and guided fix workflows inside Claude environments</td>
      <td></td>
      <td align="left">Claude-native workflow</td>
    </tr>
  </tbody>
</table>

GhostSpend is a free, open-source Claude Code plugin and standalone Bash toolkit for finding hidden token and cost leakage across modern AI CLI workflows.

It audits Claude Code, Codex CLI, Gemini CLI, GitHub Copilot CLI, OpenCode, and related tooling for misfiring hooks, stale or duplicated MCP servers, failed plugin builds, project configuration drift, and spend from tools you did not realise were active.

> **More than a total:** GhostSpend creates a one-time baseline of tools you intentionally use, then flags observed usage outside that baseline as unexpected.

## Quick install

Install the GhostSpend Skills pack:

```bash
npx skills add [https://skills.sh/p/qtjSwDWCq52yVpxi](https://skills.sh/p/qtjSwDWCq52yVpxi)
```

[Open the GhostSpend Skills pack](https://www.skills.sh/p/qtjSwDWCq52yVpxi)

### Included skills

| Skill | Purpose |
| --- | --- |
| `ghostspend-setup` | Creates your first known-tools baseline |
| `ghostspend-audit` | Audits spend, configuration, and AI CLI tooling |
| `ghostspend-fix` | Guides remediation for supported findings |

After installing, initialise your baseline:

```text
/ghostspend-setup
```

Then run an audit or start guided remediation:

```text
/ghostspend-audit
/ghostspend-fix
```

## Install in Claude Desktop

Add GhostSpend as a marketplace from the repository:

1. Open **Claude Desktop**.
2. Go to **Settings → Plugins**.
3. Select **Add**, then choose **Add marketplace**.
4. Select **Add from a repository**.
5. Paste the repository URL:

   ```text
   https://github.com/danmackenz/ghostspend.git
   ```

6. Confirm the URL and select **Sync**.
7. When GhostSpend appears, select **Add**.
8. Choose an install scope: **User (global)**, **Project scoped**, or **Session only**.
9. Initialise your baseline:

   ```text
   /ghostspend-setup
   ```

[Open the GhostSpend repository](https://github.com/danmackenz/ghostspend)

## What GhostSpend checks

| Check | Purpose |
| --- | --- |
| Global hooks (`~/.claude/settings.json`) | Identifies hooks that can add overhead to every tool call |
| MCP server connectivity (`claude mcp list`) | Finds stale, failing, or duplicated MCP servers |
| Plugin build integrity | Detects plugin builds that fail silently or retry repeatedly |
| Project configuration drift | Identifies repository settings that duplicate or conflict with global settings |
| Cross-provider spend via `ccusage` | Brings Codex CLI, Gemini CLI, OpenCode, and other observed usage into one report |
| Unexpected-tool flagging | Compares activity with your known-tools baseline |
| Orphaned AI CLI processes | Finds zombie processes remaining after crashes or disconnected sessions |

## Installation options

### Skills pack

Recommended for a fast, agent-ready installation:

```bash
npx skills add [https://skills.sh/p/qtjSwDWCq52yVpxi](https://skills.sh/p/qtjSwDWCq52yVpxi)
```

### Claude Code plugin

Clone the repository and install the plugin files locally:

```bash
git clone [https://github.com/danmackenz/ghostspend.git](https://github.com/danmackenz/ghostspend.git)
mkdir -p ~/.claude/plugins/ghostspend

rsync -a \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='CONTRIBUTING.md' \
  --exclude='SECURITY.md' \
  --exclude='CODE_OF_CONDUCT.md' \
  ghostspend/ ~/.claude/plugins/ghostspend/

chmod +x ~/.claude/plugins/ghostspend/scripts/*.sh
```

Restart Claude Code, then run:

```text
/ghostspend-setup
/ghostspend-audit
```

### Standalone scripts

Use GhostSpend without Claude Code:

```bash
git clone [https://github.com/danmackenz/ghostspend.git](https://github.com/danmackenz/ghostspend.git)
cd ghostspend/scripts
chmod +x setup.sh ghostspend.sh
./setup.sh
./ghostspend.sh
```

`setup.sh` checks for [`ccusage`](https://www.npmjs.com/package/ccusage) and offers to install it when needed.

## Usage

### Claude Code commands

```text
/ghostspend-setup
/ghostspend-audit
/ghostspend-fix
```

You can also ask Claude to run an audit in natural language, for example:

> Run a GhostSpend audit across all my AI tools.

The `ghostspend-orchestrator` agent runs setup when required, performs the audit, surfaces unexpected findings, and can guide the supported remediation flow.

### Terminal commands

```bash
./scripts/setup.sh
./scripts/ghostspend.sh
./scripts/ghostspend.sh ~/Documents/GitHub "~/Documents/Claude Projects"
```

Quote every path that contains spaces.

### Provider drill-downs

```bash
ccusage codex daily
ccusage gemini daily
```

## Prerequisites

| Requirement | Purpose | Installation |
| --- | --- | --- |
| `git` | Clones the repository | macOS: `xcode-select --install`; Debian/Ubuntu: `sudo apt install git` |
| `bash` | Runs GhostSpend scripts | Included with macOS and most Linux distributions |
| Node.js and npm | Required by `ccusage` | macOS: `brew install node`; Debian/Ubuntu: `sudo apt install nodejs npm`; or [nodejs.org](https://nodejs.org) |
| Homebrew (optional) | Convenient package installation on macOS | [Install Homebrew](https://brew.sh) |

Contributors who edit the scripts should also install `shellcheck`:

```bash
brew install shellcheck
```

## Important limitations

- **On-demand audit:** GhostSpend is not real-time monitoring and does not send automatic spend alerts.
- **Normal permissions:** It uses Claude Code's existing Bash permission and approval model; it does not request a separate privileged access tier.
- **Confirmation-first remediation:** GhostSpend diagnoses and proposes changes, but does not apply changes without your confirmation.
- **Estimated Codex costs:** `ccusage` estimates Codex CLI spend from token counts and third-party pricing data; it is not an OpenAI-confirmed invoice.
- **Trigger attribution:** GhostSpend can identify unexpected activity and likely causes, but may not prove the exact process that initiated it.
- **macOS compatibility:** The scripts intentionally support stock macOS Bash 3.2; no Homebrew Bash upgrade is needed to run them.
- **Point-in-time MCP checks:** MCP connectivity is checked at audit time rather than continuously. See [ROADMAP.md](ROADMAP.md) for planned work.

## Troubleshooting

### `ccusage` is not installed

```bash
npm install -g ccusage
which ccusage
ccusage --version
```

### Scripts return `permission denied`

```bash
chmod +x scripts/*.sh
```

### A known tool is flagged unexpectedly

Re-run setup and include the tool in your baseline:

```text
/ghostspend-setup
```

You can also edit `~/.ghostspend/config.json` manually. See the [configuration reference](docs/config.md).

### No usage data appears today

If a provider usage cap or billing window limit has been reached, new requests may be blocked until it resets. A flat usage total immediately after a cap is reached does not prove a remediation worked; run another audit after the usage window resets.

### Windows support

GhostSpend is Bash-based and currently intended for macOS and Linux. On Windows, use WSL or Git Bash. Native PowerShell support is planned; see [ROADMAP.md](ROADMAP.md).

## Repository structure

```text
ghostspend/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── agents/
│   └── ghostspend-orchestrator.md
├── skills/
│   ├── ghostspend-setup/
│   │   └── SKILL.md
│   ├── ghostspend-audit/
│   │   └── SKILL.md
│   └── ghostspend-fix/
│       └── SKILL.md
├── commands/
│   ├── gs-setup.md
│   ├── gs-audit.md
│   └── gs-fix.md
├── scripts/
│   ├── setup.sh
│   └── ghostspend.sh
├── examples/
│   └── sample-audit-output.md
├── docs/
│   ├── config.md
│   └── gs-fix-dev-plan.md
├── .github/
├── CLAUDE.md
├── AGENTS.md
├── ROADMAP.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── package.json
└── README.md
```

## Contributing

Issues and pull requests are welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md), then review [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md) for project conventions.

Useful contributions include:

- Windows-native PowerShell support
- Provider-specific usage drill-downs
- Root-cause tracing for background AI CLI invocations
- Historical usage and spend trend tracking
- Expanded test coverage, including Bash 3.2 compatibility testing

## License

Released under the [MIT License](LICENSE).