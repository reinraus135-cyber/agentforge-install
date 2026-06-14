# Getting Started: Pro

You bought **Pro ($249, one-time)**: everything in Builder -- including every
domain template -- plus the Quant Lab showcase, the Studio deploy-cockpit, and the
Shai-Hulud cybersecurity hardening suite we run in our own production bots. Pay
once, own it.

## 1. Activate your license

```bash
ecc activate YOUR-LICENSE-KEY
```

This installs everything: the full skill/agent set, every domain template, and the
security hardening (no-sudo mode). Your license is saved to
`~/.ecc/license.json`. If the Windows installer ran activation, skip to step 3.

## 2. What got installed

- Everything in **Starter** and **Builder** (full skill/agent toolkit + every
  domain template)
- **Every domain template**: `trading`, `prediction-markets`, `indie-saas`,
  `devops-infra`, `web` -- each in `~/.claude/templates/<name>/`
- The **cybersecurity hardening suite** (no-sudo parts installed automatically)
- The **Quant Lab showcase** deployed to `~/QuantLab` (see step 4)

```bash
ecc status      # SKU=pro
ecc list        # all skills, agents, and every template
```

> `trading` and `prediction-markets` ship a `DISCLAIMER.md`. Tools and research
> only; no live trading is wired. Read
> `~/.claude/templates/<name>/DISCLAIMER.md` before use.

## 3. Finish the security setup

Activation runs the no-sudo install. To add the C2 `/etc/hosts` blocklist (the
one piece that needs root):

```bash
ecc security --full      # includes C2 blocklist, prompts for sudo
ecc security --check     # show what is installed
ecc security --install   # re-run the no-sudo install
```

The suite gives you:

- File integrity monitoring (FIM) of your `~/.claude/` config
- Hook integrity check on every Claude Code session start
- A supply-chain C2 blocklist
- A daily 9 AM audit cron
- npm `ignore-scripts` hardening, pip-audit, and an encrypted secrets vault

### Turn on Telegram tamper alerts (optional)

Alerts use **your own** Telegram bot, so no data leaves your control:

1. Create a bot with [@BotFather](https://t.me/BotFather) and get its token.
2. Get your chat ID (message [@userinfobot](https://t.me/userinfobot)).
3. Edit `~/.secrets/security.env` and fill in `SECURITY_BOT_TOKEN` and
   `SECURITY_CHAT_ID`.
4. Reload your shell: `source ~/.bashrc`
5. Test: `~/.claude/.../fim-watchdog.sh --alert` should send an "all clear"
   message. (Path is shown by `ecc security --check`.)

## 4. The Quant Lab showcase

Pro deploys a production-shaped algotrading lab to `~/QuantLab` (its Python venv is
pre-warmed at install). It is a **showcase**: paper-first, tools not signals, no live
execution wired, and the bundled example deliberately fails its own go/no-go gate so you
see what honest validation looks like.

```bash
ecc quantlab --doctor    # health check + offline smoke backtest
ecc quantlab --setup     # (re)deploy the lab if needed
```

Quickstart:

```bash
cd ~/QuantLab
.venv/bin/python -m strategies.sma_cross.backtest_example   # full pipeline
.venv/bin/python -m pytest tests/ -q                        # the shipped test suite
ecc cockpit    # then open the Trading Deck (deck switcher, top-left)
```

> The lab is paper-only; you assume all market and regulatory risk. Read
> `~/QuantLab/docs/DISCLAIMER.md` before use. Your edits in `config/`, `strategies/`,
> and `data/` survive `ecc quantlab --update`.

## 5. First run

```bash
claude
```

**Meet your squads first** - type `/showcase`. You have every template, so it asks
which squad to meet first, then deploys it on a concrete bounded task while the Command
Deck lights up. Run it again for each of the others. See
[showcase-quickstart.md](showcase-quickstart.md).

Then pick the template that fits the job and follow its
`~/.claude/templates/<name>/WORKFLOW.md`.

## 6. Everyday commands

| Command | What it does |
|---|---|
| `ecc security --check` | Security install status |
| `ecc list` | All installed content (every template included) |
| `ecc install --template <name>` | Re-install a specific template |
| `ecc update` | Pull latest skills, agents, and IOC patches |
| `ecc status` | SKU, license, counts |
| `ecc doctor` | Health check |

## Updates and IOC patches

Pro includes **12 months** of free patches, agent updates, and security IOC
patches (new C2 domains, new compromised package versions, new hook signatures).
Run `ecc update` to pull them. The defensive checks themselves are open source at
the public `agentforge-security` repo; Pro is the curated, pre-wired, supported
delivery of them.

## Troubleshooting

- **`ecc security` says "Pro SKU feature"** -> confirm `ecc status` shows
  `SKU=pro`; if not, re-run `ecc activate YOUR-KEY`.
- **C2 blocklist not applied** -> run `ecc security --full` (needs sudo).
- **Telegram alerts not arriving** -> check `~/.secrets/security.env` has both
  values and you ran `source ~/.bashrc`.
- **"License validation failed"** -> re-run `ecc activate YOUR-KEY`, then email
  support@agentforge.army.
