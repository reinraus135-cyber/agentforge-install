# Getting Started with AgentForge

AgentForge is the AI team we run in production, packaged for your terminal. It is
a curated set of Claude Code skills, agents, rules, and domain templates. **Pay
once, own it** -- no subscription.

## Which guide do I need?

Pick the SKU you bought:

- **[Starter ($39)](getting-started-starter.md)** -- WSL + Ubuntu + Claude Code
  + 35 skills + 10 core agents. The 60-second setup.
- **[Builder ($99)](getting-started-builder.md)** -- Starter + the full
  multi-language toolkit + every domain template.
- **[Pro ($249)](getting-started-pro.md)** -- Builder + the cybersecurity
  hardening suite.

Not sure / want to upgrade later? Any SKU can run `ecc list --available` to see
locked content, and upgrading is just a new purchase plus `ecc activate`.

## Install

### Option A: Windows installer (easiest)

1. Download **AgentForge-Setup.exe** from [agentforge.army/download](https://agentforge.army/download)
2. Run it, click through, and enter your Anthropic API key and license key when prompted
3. Wait for the progress bar (~5 minutes)

The installer sets up WSL2, Ubuntu, Node.js, Claude Code, and AgentForge, then
activates your license.

### Option B: Manual (Linux / macOS / WSL)

```bash
# 1. Node.js 18+ and Claude Code
npm install -g @anthropic-ai/claude-code

# 2. Clone AgentForge
git clone https://github.com/reinraus135-cyber/agentforge-install.git ~/AgentForge

# 3. Activate your license (installs your SKU automatically)
~/AgentForge/ecc activate YOUR-LICENSE-KEY

# 4. Verify
ecc doctor
```

No license key yet? Buy at [agentforge.army/pricing](https://agentforge.army/pricing),
then `ecc activate <key>`. Content downloads only after your key validates.

## Useful commands

| Command | What it does |
|---|---|
| `ecc activate KEY` | Activate a one-time license and install its SKU |
| `ecc install` | Install your SKU (auto-detected from license) |
| `ecc install --template NAME` | Install a domain template (Builder/Pro: all) |
| `ecc install SKILL` | Install a single skill by name |
| `ecc list` | Show what is installed |
| `ecc list --available` | Show everything available, with your upgrade path |
| `ecc update` | Pull the latest and re-install |
| `ecc status` | Show SKU, license, and counts |
| `ecc status --license` | License details: SKU, dates, updates window |
| `ecc doctor` | Installation health check |
| `ecc security --check` | (Pro) cybersecurity hardening status |

## What you own

Every SKU is a one-time purchase with **12 months** of free patches, agent
updates, and security IOC updates. After 12 months your installed content keeps
working forever; an optional updates subscription will be offered for staying
current.

## Troubleshooting

### "jq is required"

```bash
sudo apt install jq
```

### "Claude Code not found"

```bash
source ~/.nvm/nvm.sh
npm install -g @anthropic-ai/claude-code --ignore-scripts=false
```

### "Manifest not found"

```bash
git clone https://github.com/reinraus135-cyber/agentforge-install.git ~/AgentForge
```

### "License validation failed"

- Check your internet connection
- Re-run: `ecc activate YOUR-KEY`
- Contact support@agentforge.army if it persists

## Next steps

- Browse everything available: `ecc list --available`
- Read your SKU guide (linked at the top)
- Full docs: [agentforge.army/docs](https://agentforge.army/docs)
