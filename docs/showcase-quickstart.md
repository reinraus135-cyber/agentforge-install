# Meet Your Army: the `/showcase` quickstart

You bought a team of specialized agents. `/showcase` is the fastest way to actually SEE
them work - one guided run, about ten minutes, that deploys your squad on a real task and
leaves you something you keep.

## Run it

In a fresh Claude Code session, type:

```
/showcase
```

That is it. It detects what you bought and runs the matching demo. Watch the **Command
Deck** while it runs - each agent lights up as it is deployed.

## What you'll see, by tier

| You have | `/showcase` deploys | You keep |
|---|---|---|
| **Starter** (no template) | planner -> tdd-guide -> code-reviewer -> security-reviewer | a small, tested, reviewed, security-checked utility |
| **Builder** (one template) | that template's domain squad | the template's real first deliverable |
| **Pro** (all four) | asks which squad first, then that one | that squad's deliverable (run again for the others) |

Per template, the squad and the kept artifact:

- **Trading** - market-research-analyst -> strategy-architect -> backtest-engineer ->
  risk-manager. You keep a pressure-tested hypothesis, a typed strategy spec, a backtest
  plan, and a risk review. Paper/research only.
- **AI Influencer** - content-strategist -> character-architect -> content-strategist. You
  keep a persona character sheet and three on-brand posts. (Rendering needs a GPU; the plan
  does not.)
- **Indie SaaS** - saas-product-strategist -> nextjs-app-architect -> auth-architect ->
  stripe-integrator. You keep a validated brief and the auth + billing scaffold plan.
- **Prediction Markets** - market-analyst -> event-researcher -> probability-calibrator. You
  keep a calibrated research brief. Research only, no trade recommendations.

## The point

In normal use you see mostly the orchestrator and the occasional agent - that is by design
(agents are trigger-based and every spawn costs tokens). `/showcase` is the one deliberate
moment you watch the whole team work, on purpose, once.

After it, you are back in command: at the start of any non-trivial build, AgentForge asks
how you want it run - **Rapid** (fast, solo) or **Deploy Your Army** (the full pipeline).
You choose per build. That choice is the product.

## Then what

- Open the artifacts `/showcase` produced - they are real, edit and build on them.
- Read your template's `WORKFLOW.md` (in `~/.claude/templates/<name>/`) for the full path
  beyond the bounded demo.
- Point your army at something real: just describe the task, and pick Rapid or Deploy Your
  Army when asked.
