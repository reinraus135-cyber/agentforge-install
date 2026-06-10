# Getting Started: Builder

You bought **Builder ($99, one-time)**: everything in Starter, plus the full
multi-language developer toolkit and **one** production-ready domain template of
your choice. Pay once, own it.

## 1. Activate your license

```bash
ecc activate YOUR-LICENSE-KEY
```

This validates your key, installs all Builder content, and **auto-installs the
template you picked at checkout**. The template choice rides on your purchase, so
there is nothing extra to select. Your license is saved to `~/.ecc/license.json`.

If the Windows installer ran activation for you, skip to step 3.

## 2. What got installed

- Everything in **Starter** (35 skills, 10 agents)
- The **Builder toolkit**: 59 more skills and 31 more agents covering Go, Rust,
  C++, Java/Spring, C#/.NET, Laravel, Django, NestJS, agent-harness tooling,
  and more
- **One domain template** (your checkout choice) with its agents, skills,
  sample config, and workflow guide

```bash
ecc status      # confirms SKU=builder and your template
ecc list        # shows everything installed
```

## 3. Your template

Builder includes exactly one of these four:

| Template | For | Note |
|---|---|---|
| `trading` | Quant research, backtesting, paper trading | ships a DISCLAIMER, read it first |
| `ai-influencer` | Image/video/lip-sync content pipelines | |
| `prediction-markets` | Polymarket/Kalshi/Manifold analytics | read-only research, ships a DISCLAIMER |
| `indie-saas` | Stripe + Next.js + auth side projects | |

Your template's guide, sample config, and starter prompt land in
`~/.claude/templates/<name>/`. Start there:

```bash
cat ~/.claude/templates/<name>/WORKFLOW.md
cat ~/.claude/templates/<name>/starter-prompt.md
```

**Picked the wrong one, or activation could not detect your choice?** Install any
template explicitly (you still get one with Builder):

```bash
ecc install --template indie-saas
```

You can also override before activating with `AGENTFORGE_TEMPLATE=<name>`.

> The `trading` and `prediction-markets` templates ship a `DISCLAIMER.md`. They
> are tools and research only -- no live trading is wired. Read the disclaimer in
> `~/.claude/templates/<name>/DISCLAIMER.md` before use.

## 4. First run

```bash
claude
```

**Meet your squad first** - type `/showcase`. It deploys your template's domain
agents on one concrete, bounded task and leaves you a real first deliverable, while
the Command Deck lights up with each agent. About ten minutes. See
[showcase-quickstart.md](showcase-quickstart.md).

Then follow your template's `WORKFLOW.md`. For example, the indie-saas flow walks
from product strategy through Stripe integration, auth, and deployment; the
trading flow walks from hypothesis through backtest and risk review to paper
trading.

## 5. Everyday commands

| Command | What it does |
|---|---|
| `ecc list --available` | All content; Pro items show as locked |
| `ecc install --template <name>` | Install a domain template |
| `ecc install <skill>` | Install a single skill |
| `ecc update` | Pull latest and re-install |
| `ecc status` | SKU, license, template, counts |
| `ecc doctor` | Health check |

## 6. Want every template + security?

**Pro ($249)** unlocks all four templates and the Shai-Hulud cybersecurity
hardening suite. See [getting-started-pro.md](getting-started-pro.md). Buy at
[agentforge.army/buy](https://agentforge.army/buy), then `ecc activate` the new key.

## Updates

Free patches, agent updates, and IOC updates for **12 months**. Run `ecc update`.

## Troubleshooting

- **Template did not auto-install** -> `ecc install --template <name>` (Builder includes one).
- **"jq is required"** -> `sudo apt install jq`
- **"License validation failed"** -> re-run `ecc activate YOUR-KEY`, then email support@agentforge.army.
