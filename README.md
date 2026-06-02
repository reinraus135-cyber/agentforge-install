# AgentForge

**Your AI team. Ready in 60 seconds.**

AgentForge gives you a pre-built team of AI skills and agents for Claude Code -- covering development, security, testing, deployment, and more. Install once, use everywhere.

## Deploy Your Army

The feature no other Claude Code setup ships by default: before any complex or multi-phase build, AgentForge asks how you want it run, and you decide.

- **Rapid (solo)** -- the orchestrator builds directly. Fast, for prototypes and low-risk changes.
- **Deploy Your Army (full pipeline)** -- planner -> tdd-guide -> code-reviewer -> security-reviewer, each stage handing off to the next. Thorough, for production and security-sensitive work.

You command the army; you decide when to deploy it. Speed when you want it, rigor when it counts. Included in every tier.

## Quick Start

### Windows (recommended for beginners)

Download and run **[AgentForge-Setup.exe](https://agentforge.army/download)** -- it handles everything:
WSL2, Ubuntu, Node.js, Claude Code, and AgentForge.

### Linux / macOS / existing WSL

```bash
git clone https://github.com/reinraus135-cyber/agentforge-install.git ~/AgentForge
bash ~/AgentForge/ecc activate <your-license-key>
```

### Verify

```bash
ecc doctor    # health check
ecc status    # see what's installed
claude        # start using AI
```

## What You Get

Three one-time SKUs. Pay once, own it, with 12 months of free updates.

### Starter -- $39

| | Count | Examples |
|---|---|---|
| **Skills** | 35 | TDD workflow, deep research, security review, Python patterns, database migrations, Docker patterns |
| **Agents** | 10 | planner, code-reviewer, tdd-guide, build-error-resolver, security-reviewer |
| **Rules** | 89 | Coding style, git workflow, testing standards, performance, security |

### Builder -- $99

Everything in Starter, plus extended multi-language depth and **one** domain template you choose:

| | Count | Examples |
|---|---|---|
| **Skills** | +59 | Go, Rust, Java, C++, C#, Laravel, Django, NestJS, agent harness, eval harness, council, prompt optimizer |
| **Agents** | +31 | architect, e2e-runner, performance-optimizer, GAN pipeline, rust-reviewer, typescript-reviewer |
| **Template** | 1 of 4 | trading, ai-influencer, prediction-markets, indie-saas |

### Pro -- $249

Everything in Builder, plus **all four** templates and the Shai-Hulud cybersecurity hardening suite (file-integrity monitoring, hook-integrity checks, supply-chain C2 blocklist, daily audit, IOC patches for 12 months).

## Usage

```bash
# Activate your license (downloads and installs your SKU)
ecc activate YOUR-LICENSE-KEY

# Builder: install your chosen template (auto-selected from your license otherwise)
ecc install --template trading

# Browse what's available and your upgrade path
ecc list --available

# Update to the latest content (within your 12-month window)
ecc update

# Check health and license
ecc doctor
ecc status --license
```

## How It Works

AgentForge installs skills, agents, and rules into your `~/.claude/` directory. Claude Code picks them up automatically -- no configuration needed.

- **Skills** teach Claude how to do specific tasks (TDD, security review, research patterns)
- **Agents** are specialized roles Claude can delegate to (code-reviewer, architect, e2e-runner)
- **Rules** enforce standards across all your work (coding style, testing coverage, security checks)

## Requirements

- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- Anthropic API key
- Node.js 18+ (22 LTS recommended)
- jq, git, curl

The Windows installer handles all of these automatically.

## License

AgentForge is a one-time purchase (Starter $39, Builder $99, Pro $249) with 12 months of free updates. Licenses are issued via [agentforge.army](https://agentforge.army/pricing).

## Support

- Docs: [agentforge.army/docs](https://agentforge.army/docs)
- Discord: [agentforge.army/discord](https://agentforge.army/discord)
- Email: support@agentforge.army
