# Getting Started: Starter

You bought **Starter ($39, one-time)**: a fully configured Claude Code
environment with 35 curated developer skills and 10 core agents. Pay once, own
it. This guide gets you from license key to first prompt.

## 1. Activate your license

If you used the **Windows installer**, it set everything up and you can skip to
step 3. Otherwise, activate from the terminal:

```bash
ecc activate YOUR-LICENSE-KEY
```

This validates your key and automatically installs your Starter content. Your
license is saved to `~/.ecc/license.json` and is yours for life.

No key yet? Buy Starter at [agentforge.army/pricing](https://agentforge.army/pricing),
then run the `activate` command above. Your content downloads only after your key
validates, so activation is the first step.

## 2. What got installed

- **35 skills** into `~/.claude/skills/ecc/` (TDD workflow, code standards,
  API design, Python patterns, research, deployment, security review, and more)
- **10 agents** into `~/.claude/agents/` (planner, code-reviewer, tdd-guide,
  build-error-resolver, security-reviewer, and others)
- The full **ECC rules** set into `~/.claude/rules/ecc/`

Verify any time:

```bash
ecc status      # SKU, license, and counts
ecc doctor      # installation health check
ecc list        # everything installed
```

## 3. First run

```bash
claude
```

Claude Code now has your skills and agents. Try:

```
Build a REST API for user auth with JWT. Plan it first, then write tests.
```

Claude uses the **planner** agent to design it, **tdd-guide** to write tests
first, and **code-reviewer** to check the result.

For complex, multi-phase work, AgentForge first asks how you want it run: **Rapid**
(build it directly, fast) or **Deploy Your Army** (planner -> tdd-guide -> code-reviewer
-> security-reviewer, thorough). You pick the speed-vs-rigor tradeoff on every build.
This is included in every tier.

```
Review this file for security vulnerabilities.
```

The **security-reviewer** agent checks against the OWASP Top 10.

## 4. Everyday commands

| Command | What it does |
|---|---|
| `ecc list` | Show installed skills, agents, templates |
| `ecc list --available` | Show everything (locked items show your upgrade path) |
| `ecc install <skill>` | Install a single skill by name |
| `ecc update` | Pull the latest and re-install your set |
| `ecc status` | SKU, license, and counts |
| `ecc doctor` | Health check with fix suggestions |

## 5. Want more?

- **Builder ($99)** adds the full multi-language toolkit (59 more skills, 31
  more agents) and one domain template of your choice. See
  [getting-started-builder.md](getting-started-builder.md).
- **Pro ($249)** adds all four templates and the cybersecurity hardening suite.
  See [getting-started-pro.md](getting-started-pro.md).

`ecc list --available` shows locked Builder/Pro content and how to unlock it.
Upgrades are a new purchase at [agentforge.army/buy](https://agentforge.army/buy);
activate the new key with `ecc activate` and your content expands in place.

## Updates

Your purchase includes free patches, agent updates, and security IOC updates for
**12 months**. Run `ecc update` to pull them.

## Troubleshooting

- **"jq is required"** -> `sudo apt install jq`
- **"Claude Code not found"** -> `source ~/.nvm/nvm.sh && npm install -g @anthropic-ai/claude-code --ignore-scripts=false`
- **"License validation failed"** -> check your connection, re-run `ecc activate YOUR-KEY`, then email support@agentforge.army if it persists.
