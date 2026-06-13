# Strategy Workshop -- 2026-06-13 (Project Re-scope)

> Internal. **Supersedes the tier-model + "build everything" portions of
> `strategy-workshop-20260612.md`.** Held mid-session after the operator flagged that the
> labs and Ultimate tiers had drifted from the core product. Decisions here are operator-locked
> unless marked OPEN.

---

## 0. The correction

AgentForge is **a Claude Code agent-team + working-environment installer**. The value is the
**team that helps people build** (orchestrator + pattern subagents + skills + rules + hooks +
security + showcase). The project had drifted into shipping **standalone vertical products**
(Quant Lab as a trading product, Studio Lab as an AI-influencer content studio) and **Ultimate
fleet/ops layers** that are hard to maintain and, for AI-influencer, off-domain (content creation,
not software building). This workshop refocuses on the team-environment product and drops the
product-portfolio + fleet drift.

## 1. Why this is right (not a retreat)

1. **Maintenance.** The labs/fleets are the entire 12-month-update liability (ComfyUI / PuLID /
   model / exchange / RunComfy churn). The agent team + rules + skills + security suite are stable
   by comparison. Only the team-environment is sustainable for a one-person-plus-Claude shop.
2. **Market.** "Agent-team environment for Claude Code builders" is a far broader pool than
   "AI-influencer operators who run WSL." Sharper pitch, wider buyer, at the same time.
3. **Distribution.** Still the binding constraint from 06-12 (graded D; revenue $0; no storefront).
   Dropping the labs frees the weeks that must go to a storefront + audience.

## 2. The re-scoped ladder

| Tier | Price | Contents |
|---|---|---|
| **Starter** | $39 | Foundation working environment: Claude Code + rules + the agent team (orchestrator + pattern subagents) + skills. Correct as-is. |
| **Builder** | $99 | + **ALL 5 domain templates** + **showcase-as-project-kickoff** |
| **Pro** | **$249** (intro **$149**, first 1000) | Builder + **Quant Lab as a showcase** + the **Studio deploy-cockpit** + the **cybersecurity suite** |
| **Ultimate** | -- | **OFF the ladder.** Internal docs kept; the fleet/ops paths are separate future projects. |

## 3. Builder -- the 5 domains + showcase-kickoff

- **5 professional software-building domains: prediction markets, web, saas, trading, DevOps/Infra.**
  AI-influencer is **dropped** (content creation, not software building). Prediction stays ("fashion
  at the moment").
- **DevOps/Infra (the chosen 5th)** -- agent team: infra-architect, IaC (Terraform) writer, CI/CD
  builder, container/K8s specialist, observability + cloud-cost reviewer. Builds IaC, CI/CD
  pipelines, Docker/K8s, deploy automation, monitoring. Chosen for breadth (every other domain
  deploys) + synergy with the cybersecurity suite.
- **Showcase becomes a project kickoff:** running it scaffolds a real **project-base folder** the
  buyer starts building on, not just a demo.

## 4. Pro -- the Studio deploy-cockpit (the heart of the re-scope)

**Purpose:** make the **purchased agent teams visibly + practically usable** -- proof-of-purchase --
even though the backend is Claude's three models (opus / sonnet / haiku) wearing the agent
definitions. (The agents are real roles/patterns, just backed by shared models; the Studio is how
the buyer SEES and USES what they bought.) The cockpit's Agents pane already lights up named agents
as they run; the Studio operationalizes that.

**Three panel types:**
1. **Discipline panels** -- general professional disciplines for any project (plan/architecture,
   testing/TDD, code review, security, refactor, docs, performance, build/CI). **Start deploy** ->
   orchestrator + that discipline's agents plan + execute.
2. **Add panel (features)** -- the buyer gives a prompt -> orchestrator is spawned to plan + build it.
3. **Team buttons** -- each agent team sold in a template maps to a button that spawns that whole
   team/army on the buyer's project.

**It is mostly reuse, not new product:** the cockpit shell (panels = the existing deck grammar),
the showcase machinery (the spawn/orchestration engine + the project-kickoff), `terminalInject`
(deck -> the buyer's Claude, the same pattern trading's Add-Strategy uses), and the agent panes
(visibility). Low new build, low maintenance, on-mission.

## 5. Dispositions (locked)

- **Quant Lab = showcase-only.** No maintenance promise; **not responsible for any client trading**.
  Kept as the worked example of what a deploy produces (the trading-domain team in action).
- **AI-influencer / Studio Lab = dropped from AgentForge.** Parked on `feature/studio-lab`
  (committed `0c2e2bf`, unmerged, NOT on main). May be relocated into the existing `AI_Influencer`
  project as a future project (follow-up; it fits better there).
- **Ultimate = off the ladder.** Internal docs retained; the paths are separate future projects.

## 6. What this supersedes from 06-12

- Tier-model-v3 ($499 lab-in-Pro, Ultimate fleet) -> the ladder in section 2.
- The "build EVERYTHING pre-launch (all labs + fleet)" ruling -> build the team-environment product;
  do **not** build more labs / fleets / standalone products.
- Pro $499 -> **$249** (intro $149, first 1000).

## 7. Next (post-workshop; each gets its own plan when picked up)

The binding constraint remains **DISTRIBUTION**. Priority order:
1. **Reposition the ladder** across product surfaces (manifest SKUs, `deriveSku`, LS products,
   `what-you-get`, getting-started docs, installer SKU display, storefront copy) to the re-scoped
   model + $249/$149.
2. **Build the DevOps/Infra template** (5th domain) + the **showcase-as-project-kickoff** output.
3. **Build the Studio deploy-cockpit** (reuse cockpit + showcase + terminalInject; discipline panels
   + Add panel + team buttons).
4. **Reposition Quant Lab** as a Pro showcase.
5. **Storefront + distribution** -- the actual revenue blocker.

## 8. Open knobs

- Exact Studio default discipline panels + the per-template team-button mapping.
- Showcase-kickoff scaffolded-folder contents per domain.
- Builder $99 now carries all 5 templates (was 1 in the v3 draft); confirm the $99 -> $249 delta
  (Quant Lab showcase + Studio cockpit + security) reads as worth it.
- `AI_Influencer` relocation: do it now or leave parked.
