# Getting Started: Builder

You bought **Builder ($99, one-time)**: everything in Starter, plus the full
multi-language developer toolkit and **every** production-ready domain template.
Pay once, own it.

## 1. Activate your license

```bash
ecc activate YOUR-LICENSE-KEY
```

This validates your key and installs all Builder content, including **every domain
template** -- there is nothing to pick at checkout. Your license is saved to
`~/.ecc/license.json`.

If the Windows installer ran activation for you, skip to step 3.

## 2. What got installed

- Everything in **Starter** (35 skills, 10 agents)
- The **Builder toolkit**: 59 more skills and 31 more agents covering Go, Rust,
  C++, Java/Spring, C#/.NET, Laravel, Django, NestJS, agent-harness tooling,
  and more
- **Every domain template**, each with its agents, skills, sample config, and
  workflow guide

```bash
ecc status      # confirms SKU=builder
ecc list        # shows everything installed, templates included
```

## 3. Your templates

Builder includes all of these:

| Template | For | Note |
|---|---|---|
| `trading` | Quant research, backtesting, paper trading | ships a DISCLAIMER, read it first |
| `prediction-markets` | Polymarket/Kalshi/Manifold analytics | read-only research, ships a DISCLAIMER |
| `indie-saas` | Stripe + Next.js + auth side projects | |

Each template's guide, sample config, and starter prompt land in
`~/.claude/templates/<name>/`. Start with the one that fits your project:

```bash
cat ~/.claude/templates/<name>/WORKFLOW.md
cat ~/.claude/templates/<name>/starter-prompt.md
```

Need to re-install a specific template (for example after editing it)?

```bash
ecc install --template indie-saas
```

> The `trading` and `prediction-markets` templates ship a `DISCLAIMER.md`. They
> are tools and research only -- no live trading is wired. Read the disclaimer in
> `~/.claude/templates/<name>/DISCLAIMER.md` before use.

## 4. First run

```bash
claude
```

**Meet your squads first** - type `/showcase`. You have every template, so it asks
which squad to meet first, then deploys it on one concrete, bounded task and leaves
you a real first deliverable, while the Command Deck lights up with each agent. Run
it again for each of the others. About ten minutes per run. See
[showcase-quickstart.md](showcase-quickstart.md).

Then follow your chosen template's `WORKFLOW.md`. For example, the indie-saas flow
walks from product strategy through Stripe integration, auth, and deployment; the
trading flow walks from hypothesis through backtest and risk review to paper
trading.

## 5. Everyday commands

| Command | What it does |
|---|---|
| `ecc list --available` | All content; Pro items show as locked |
| `ecc install --template <name>` | Re-install a domain template |
| `ecc install <skill>` | Install a single skill |
| `ecc update` | Pull latest and re-install |
| `ecc status` | SKU, license, counts |
| `ecc doctor` | Health check |

## 6. Want the cybersecurity suite?

**Pro ($249)** adds the Shai-Hulud cybersecurity hardening suite we run on our own
production agents (FIM, hook-integrity checks, a supply-chain C2 blocklist, daily
audit cron, and 12 months of IOC patches). See
[getting-started-pro.md](getting-started-pro.md). Buy at
[agentforge.army/buy](https://agentforge.army/buy), then `ecc activate` the new key.

## Updates

Free patches, agent updates, and IOC updates for **12 months**. Run `ecc update`.

## Troubleshooting

- **A template did not install** -> `ecc install --template <name>`.
- **"jq is required"** -> `sudo apt install jq`
- **"License validation failed"** -> re-run `ecc activate YOUR-KEY`, then email support@agentforge.army.
