# Getting Started: Pro

You bought **Pro ($249, one-time)**: everything in Builder, plus **all four**
domain templates and the Shai-Hulud cybersecurity hardening suite we run in our
own production bots. Pay once, own it.

## 1. Activate your license

```bash
ecc activate YOUR-LICENSE-KEY
```

This installs everything: the full skill/agent set, all four templates, and the
security hardening (no-sudo mode). Your license is saved to
`~/.ecc/license.json`. If the Windows installer ran activation, skip to step 3.

## 2. What got installed

- Everything in **Starter** and **Builder** (full skill/agent toolkit)
- **All four templates**: `trading`, `ai-influencer`, `prediction-markets`,
  `indie-saas` -- each in `~/.claude/templates/<name>/`
- The **cybersecurity hardening suite** (no-sudo parts installed automatically)

```bash
ecc status      # SKU=pro
ecc list        # all skills, agents, and four templates
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

## 4. First run

```bash
claude
```

**Meet your squads first** - type `/showcase`. You have all four templates, so it asks
which squad to meet first, then deploys it on a concrete bounded task while the Command
Deck lights up. Run it again for each of the others. See
[showcase-quickstart.md](showcase-quickstart.md).

Then pick the template that fits the job and follow its
`~/.claude/templates/<name>/WORKFLOW.md`.

## 5. Everyday commands

| Command | What it does |
|---|---|
| `ecc security --check` | Security install status |
| `ecc list` | All installed content (four templates included) |
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
