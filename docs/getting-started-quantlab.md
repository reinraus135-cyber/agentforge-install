# Getting Started: Quant Lab

You bought **Quant Lab ($499, one-time)**: everything in **Pro**, plus a
working algotrading development workspace -- backtest + walk-forward + Monte
Carlo validation suite, ML labeling/training pipeline, risk engine and
execution safeguards (paper-first), LLM trade-review layer, a worked example
strategy wired end-to-end, the test suite that covers it all, and the
methodology docs. Pay once, own it. We sell shovels, not signals.

## 1. Activate your license

```bash
ecc activate YOUR-LICENSE-KEY
```

This installs the full Pro set (all skills, agents, every domain template,
security hardening) AND downloads the Quant Lab content. Your license lands
in `~/.ecc/license.json`. If the Windows installer ran activation, skip
to step 2.

## 2. Deploy the lab

```bash
ecc quantlab --setup
```

This creates **`~/QuantLab`** -- your workspace -- and pre-warms its own
Python venv (`~/QuantLab/.venv`, takes a minute on first run). Then prove
everything works, offline, with zero keys:

```bash
ecc quantlab --doctor
```

Doctor checks the workspace, the venv, every lab package import, and runs
the example strategy's full pipeline (signals -> simulated trades -> metrics
-> walk-forward -> Monte Carlo) on a bundled synthetic fixture.

## 3. Read two files before anything else

```text
~/QuantLab/docs/DISCLAIMER.md    # the terms of engagement: tools, not advice
~/QuantLab/docs/METHODOLOGY.md   # how to measure a strategy without fooling yourself
```

The example strategy (SMA crossover) is a deliberately public-domain
teaching scaffold and it FAILS its own walk-forward gate on purpose -- you
should see what an honest failure report looks like before you trust any
pass.

## 4. The three commands that teach the lab

```bash
cd ~/QuantLab
.venv/bin/python -m strategies.sma_cross.backtest_example   # the full validation pipeline
.venv/bin/python -m strategies.sma_cross.paper_replay      # live exit plumbing + LLM-review layer
.venv/bin/python -m pytest tests/ -q                       # the shipped test suite -- run it
```

Then build your own: `~/QuantLab/docs/STRATEGY_DEV_GUIDE.md` walks
idea -> signal -> backtest -> sweep -> walk-forward -> review -> paper, by
copying the example package.

## 5. The Trading Command Deck

Open the cockpit (`ecc cockpit`) and use the deck switcher next to the
AgentForge logo (top-left) -- Quant Lab installs add a **Trading Deck**:

- **Paper runners** (the hero row) -- one live card per strategy, Strike AND
  ML side by side. Every card has the same transport: **Backtest** (your
  chosen window of recent real candles -- ML cards train walk-forward inside
  it), **Demo** (the bundled synthetic year, offline) and **Go live** (paper
  on the venue's real-time public feed, no keys). A finished backtest shows
  its **go/no-go gate verdict** right on the card, criterion by criterion --
  the shipped example fails its own gate by design, and that honesty is the
  product.
- **Strike** -- tune the rule-based methodology's geometry (TP/SL, holds,
  trailing, sizing, the example's SMA pair) with bounded, validated fields.
- **ML Lab** -- the ML profile's gates, labeling horizon, retrain cadence,
  daily limits, and the LLM reviewer (on/off, model, stance).
- **Bias** -- write your thesis for the day per pair (direction, conviction,
  why). The lab's `manual` bias source feeds it to reviewers and the ML
  long-veto gate as a soft input; it goes stale after 24h on purpose.
- **Add Strategy** -- name + one sentence of idea, and Claude opens a plan
  in the Deck terminal scaffolded from the worked example. The new section
  gets its own runner card automatically.

Edits write `~/QuantLab/config/bots.toml` (born from the example on first
save, timestamped backup kept) and apply on the next run. The Deck edits
geometry only -- no safety switch is reachable from the UI.

## 6. Your edits are safe across updates

Your WORK is what is protected, not stale copies: `ecc quantlab --update`
keeps any `config/` or `strategies/` file you EDITED exactly as you left it
(your baseline is carried forward release after release), while pristine
example files refresh with releases -- so the worked example keeps up with
the framework it teaches. Your own datasets under `data/` are never touched
(the bundled `data/fixtures/` refreshes like any framework file). Framework
files elsewhere that you modified are saved as `<file>.bak` before a refresh
replaces them.

```bash
ecc update             # refresh content (12 months of updates included)
ecc quantlab --update  # re-deploy the lab, preserving your work
ecc quantlab --doctor  # verify
```

## 7. Posture

Everything ships paper-only: `dry_run = true` defaults, paper/synthetic
adapters as the only wired execution paths, synthetic fixture data, and
generic ccxt plumbing for market data from whatever venue suits your
geography. Going beyond paper would be your own build, outside the product.
Read `~/QuantLab/docs/RISK.md` and `~/QuantLab/docs/DISCLAIMER.md`; you
assume all market and regulatory risk.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Quant Lab content not found` | `ecc update` (or re-run `ecc activate <key>`) |
| venv build fails | `sudo apt install python3-venv`, then `ecc quantlab --setup` |
| imports fail in doctor | `ecc quantlab --setup` (rebuilds venv when requirements changed) |
| want a clean workspace | move `~/QuantLab` aside, `ecc quantlab --setup` |

Stuck? support@agentforge.army
