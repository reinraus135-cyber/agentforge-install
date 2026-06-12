# Strategy Workshop -- 2026-06-12

> Internal. Stripped from the public bootstrap repo (lives in `docs/`).
> Operator agenda: (1) port the Quant Lab framework to the remaining templates,
> (2) per-tier earned-value case, (3) whole-project assessment + next path.
> Items marked **OPEN** are operator decisions. Comparable prices are workshop-grade;
> verify before any of them reach storefront copy.

---

## 0. Snapshot

Product machinery is built, tested, and live on the gateway (content-v2.1.1; Trading
Deck v2 accepted on `feature/trading-deck-live`, unmerged). Revenue is $0 because
nothing is publicly buyable: Phase 5 storefront is unbuilt and the decided strategy is
build-everything-launch-once. The project is inventory-rich and distribution-poor.
That asymmetry drives every recommendation below.

| Dimension | Grade | Note |
|---|---|---|
| Product / engineering | A | Deep, tested (822/469/246/286 gates), differentiated (labs, deck, security suite) |
| Productization (install/activate/update) | A- | b20 verified end-to-end; b21 backlog open (INST-1..10) |
| Value-perception engineering | B+ | Showcase + Deck built; unproven with strangers |
| Monetization machinery | B | Gateway + LS live and e2e-verified; no public store |
| Distribution / audience | D | No public presence, no list, no content cadence; launch-once concentrates all marketing risk into one event |
| Legal / compliance posture | B | Disclaimers in place; labs raise stakes (trading, influencer likeness/NSFW) |

The grade distribution is the argument: the next unit of effort belongs to the D row,
not to another A.

---

## 1. The Lab grammar: porting Quant Lab to the other templates

### 1.1 The pattern, named

What Quant Lab actually is, as six reusable components:

1. **Sanitized domain lab extracted from real working code.** Not a toy: the
   operator's production system with the alpha and secrets stripped. The
   credibility claim is "we run what we sell."
2. **A worked example that honestly fails its own go/no-go gate.** SMA-cross fails
   walk-forward on purpose. The product teaches the buyer to measure, and proves
   the instrument is honest because it indicts its own example.
3. **`ecc <domain> --doctor`**: one-command offline smoke. No keys, no network,
   bundled fixtures.
4. **A dedicated cockpit Deck view**: parameter racks (bounded, validated fields
   writing the buyer's toml) + live runner cards (demo / real-data / live modes,
   freshness, config-echo, one-click restart).
5. **Honest-methodology docs**: METHODOLOGY + DEV_GUIDE + RISK + DISCLAIMER.
6. **A premium tier above Pro** ($499, includes Pro).

**Template vs Lab, the product-line distinction:** a template is the *team*
(agents + skills + workflow docs). A Lab is the *instrumented workspace*: code,
fixtures, gates, deck, doctor. Pro sells the teams; a Lab sells the workbench with
a truth-telling gate bolted to it. This sentence is storefront-ready.

**The chassis is now amortized.** Roughly half the Quant Lab effort was platform
work that is now reusable: the `ecc <domain>` lifecycle (setup/update/doctor),
gated packaging + leak gates (`verify.sh` pattern), the runner-card/poll grammar,
deck racks writing validated toml, the METHODOLOGY doc voice, the
fails-its-own-gate pedagogy. Lab #2 onward is mostly *domain* work: fixtures, the
gate metric, the worked example, and the domain deck cards.

### 1.2 AI Influencer -> **Studio Lab** ($499)

The strongest port. The raw material already exists and is battle-tested:

| Pattern component | What exists today (operator's own R&D) | What to build |
|---|---|---|
| Real working code | t2i (Flux 2 Klein + LoRA), i2i, i2i+pose, S2V lip sync, I2V, I2V action-transfer+audio; RunComfy client with the hard-won overrides (sdpa, node bypasses, curl-not-urllib); local ComfyUI client | Sanitize into `~/StudioLab`: pipeline orchestration, job specs, output/run conventions (the PLAN.md phase-I/O discipline, productized) |
| The honest gate | **The ArcFace identity harness with numeric thresholds (mean >= 0.65, no frame < 0.45) plus LPIPS flicker check.** This is a real, operator-proven go/no-go gate | Ship the scorer + a worked example that FAILS it: a public-provenance character run through a baseline I2V config that drifts by frame 48, exactly the operator's own LTX finding. Pedagogy: "most video pipelines lose your character; measure before you publish" |
| Doctor | ArcFace runs on CPU (insightface/onnxruntime) | `ecc studio --doctor`: venv, ffmpeg, model fetch, then score **bundled pre-rendered fixture clips** offline against a bundled reference sheet. GPU/venue needed only for the buyer's own runs (same split as quantlab's synthetic fixture vs live venue) |
| Deck view | Trading Deck grammar | **Studio Deck**: character rack (canonical sheet + thresholds), pipeline rack (model/steps/LoRA-strength/face_strength bounded fields), job cards (queued/running/~15min ETA), score strips with a **per-frame similarity sparkline** (direct port of the equity sparkline), candidate-picker grid (the operator's own select-best-candidate flow) |
| Docs | PLAN.md is already a model of honest methodology (phases, exit criteria, persisted failures) | METHODOLOGY (identity drift, eval kits), CHARACTER_DEV_GUIDE (canonical sheet, eval set, LoRA pointers), CONSISTENCY (the gate), ETHICS + DISCLAIMER |
| Excluded (the "alpha") | -- | Aletta herself (LoRA, references, tuned configs), RunComfy deployment IDs/keys. Sell the studio, not the star |

- **Proof asset:** Aletta fronts the marketing (already decided in ROADMAP). "This
  lab is how Aletta is made" gives the same we-run-what-we-sell symmetry the
  trading fleet gives Quant Lab. Both flagships would then have labs.

**Execution model (operator-LOCKED in workshop, 2026-06-12):**

1. **Managed ComfyUI, never redistributed.** `ecc studio --setup` installs or
   attaches ComfyUI: pinned WSL clone, or the `.exe` installer's optional
   "ComfyUI Portable" component fetched from official upstream at install time;
   detect-and-attach for an existing install (incl. the Windows-portable +
   `--listen` pattern). Deploys the pinned custom-node set and our
   version-locked workflow JSONs. Our tarball ships manifests + hashes only
   (GPL boundary stays clean: HTTP API, separate process).
2. **Model downloads with per-model license gating.** `ecc studio --models`
   fetches each model from its official source only after the buyer explicitly
   accepts THAT model's license; acceptances recorded in a local click-through
   ledger (timestamp, model, license version). Research-only models
   (InsightFace/ArcFace) are always buyer-fetched, never shipped.
3. **Dual execution per job: local HW or cloud.** Local requires the published
   minimum-specs table, enforced by doctor + the VRAM/RAM preflight, with a
   below-spec disclaimer. Specs from our own measured runs: scoring = CPU-only;
   t2i inference ~12GB (Klein nvfp4, proven on the 5070); LoRA training
   16-24GB recommended; video = 16GB for ~5s clips, 48GB-class beyond
   (effectively cloud for most buyers). Cloud = buyer's own provider key;
   **RunComfy serverless deployments = the proposed reference venue** (our
   proven path incl. the Cloudflare/curl and node-override gotchas), adapter
   kept venue-agnostic (the ccxt-equivalent). Keys live in the secrets vault
   (Pro suite is included in the tier), never in toml.
4. **Character LoRA creation IS in scope, same dual path.** Dataset prep from
   the buyer's character sheet -> captioning -> training workflow (local if
   specs allow, else RunComfy) -> **the loop closes through the gate**: fresh
   LoRA -> eval-set generation -> ArcFace identity gate -> pass/fail. Character
   creation becomes a gated, measurable workflow; the worked example doubles as
   "a LoRA that fails the gate + the methodology to pass."
5. **Cost honesty as a feature.** Every cloud submission shows an estimated
   cost (GPU tier x typical runtime from our logs: ~12-20 min video on
   48GB-class, ~30 min cold-start S2V) and requires confirmation. Docs carry
   the explicit investment disclaimer: below minimum local compute, cloud
   spend is required. The trading lab's risk-warning posture, ported.

- **Risks:** (a) heavy external deps; the offline story must be eval-only + bundled
  fixtures (solved above). (b) model churn (Wan/Flux versions move fast) +
  third-party venue churn (RunComfy API/pricing): venue-agnostic adapter,
  pinned workflows, manifest updated with content releases. (c) fixture
  licensing: the shipped character must be generated with documented provenance,
  no real-person source; verify FLUX.2 klein license text at build time.
  (d) LoRA training on low VRAM is fragile: be honest that 12GB-class boxes
  train in the cloud. (e) NSFW stance **DECIDED 2026-06-12: SFW by default.**
  All shipped workflows are SFW (Flux 2 guardrails as the natural backstop);
  no NSFW nodes or prompt text in anything we ship, video workflows included;
  beyond that it is the buyer's own path, covered by an explicit
  buyer-responsibility disclaimer.
- **Effort:** ~2-2.5 weeks of sessions (was 1.5-2; LoRA-training orchestration
  adds dataset prep, captioning, a training workflow, and the gate-closed eval
  loop. Fixture generation is real GPU work; deck and lifecycle are ports).

### 1.3 Indie SaaS -> **Launch Lab** ($499)

The most self-referential port: **AgentForge itself is the worked example.** The
buyer literally experienced the machinery when they bought the product.

- **The lab:** a production-shaped *gated digital product* business in a box:
  license-key gateway pattern (the Vercel gateway, sanitized to a local mock +
  deployable skeleton), Lemon Squeezy/Stripe webhook handling with signature
  verification, activation/lifecycle (purchase -> activate -> update -> support),
  release packaging + flip + verify loop, ops runbooks as code, the documented
  footguns (Vercel env REST workaround, LS slot management). Opinionated slice:
  "sell and operate a gated digital product," not generic-SaaS CRUD. That slice is
  differentiated; most boilerplates stop at auth + billing.
- **The gate:** the **launch gate**, checklist-as-code (the productized
  `ops-checklist-launch.md`). The worked example product fails ~4 of 12 checks out
  of the box (unverified webhook signature, no license-recovery path, no refund
  page, no rollback plan); doctor names each; the guide walks them green. Same
  honest-gate grammar, fail-then-fix pedagogy.
- **Doctor:** `ecc launch --doctor`: example product's test suite, webhook
  signature smoke with a test secret, env completeness, license round-trip against
  the local mock gateway. Fully offline.
- **Deck:** launch-gate rack (red/green LED per check), webhook event tail,
  license/activation test console, release-pipeline card (package -> flip ->
  verify, the exact loop this repo uses).
- **Risks:** scope sprawl is the killer; hold the gated-product slice. Stripe vs LS
  duplication: pick LS first (it is what the proof runs on), Stripe as docs.
- **Effort:** ~2-3 weeks (the example product is the scope risk).

### 1.4 Prediction Markets -> **Forecast Lab** ($499, or $399 if differentiating)

The weakest proof but the cheapest build, and the gate is genuinely novel.

- **The lab:** `~/ForecastLab`: Polymarket/Kalshi/Manifold public-data adapters
  (keyless market data), orderbook snapshots, a **forecast journal** (the buyer's
  own timestamped probability estimates), resolution tracking, a **calibration
  engine** (Brier score, log loss, reliability curves, sharpness), edge-vs-market
  EV analysis, paper portfolio marked to market price, LLM event-researcher layer
  on the buyer's Claude session (the `agents/base.py` no-API-key trick). **No
  execution anywhere**: the template's research-only disclaimer is the lab's
  stance too. Borrowed from the trading stack: datafeed grammar, journal/state
  conventions, the bias/thesis registry, deck cards.
- **The gate:** the **calibration gate**: over the bundled fixture of ~200
  resolved markets, your forecaster must beat the market's own price on Brier
  skill across N >= 50 forecasts. The worked example (a naive base-rate +
  contrarian-nudge forecaster) FAILS it, because the market is well-calibrated and
  beating it is hard. Perfect parallel to "most strategies fail walk-forward."
- **Doctor:** offline fixture + calibration smoke + optional keyless live-API
  reachability.
- **Deck:** forecast cards (your p vs market p, drift since entry), calibration
  scoreboard, reliability chart, event-watch rack.
- **Weaknesses:** no operator proof asset (we do not run a forecasting operation);
  smallest template (6 skills / 4 agents); Polymarket US-geoblock and CFTC framing
  need careful RISK docs. Mitigation: position as "the Quant Lab validation
  discipline, applied to forecasting," or build a small public forecast journal
  for some weeks pre-launch as the proof.
- **Effort:** ~1.5 weeks (no execution layer, free public data).

### 1.5 Sequencing + pricing architecture

**Recommendation: blueprint now, build post-launch, demand-ordered.**

- Zero labs are publicly buyable today. Building more labs before the store exists
  compounds inventory, defers revenue, and adds maintenance surface under the
  12-month-updates promise. The amortized chassis is exactly what makes deferral
  safe: any lab is ~2 weeks from go-signal.
- Build order when triggered: **Studio Lab -> Launch Lab -> Forecast Lab.**
  Studio first because the gate + raw code already exist, Aletta marketing
  produces its demo content anyway, and it completes the "both flagships have
  labs" story. (If one lab were pulled pre-launch for storefront impact, it is
  Studio, at the cost of ~2 more unpaid weeks. Not recommended.)
**Pricing architecture v3 (operator-DIRECTED in-workshop 2026-06-12: the Lab
folds INTO Pro -> four tiers, one vertical axis):**

The buyer picks a business case at Builder and deepens within it. Four tiers,
no parallel product lines: the Lab is Pro's hero feature, the fleet is
Ultimate's. (Supersedes the 5-rung v2 drafted earlier in this section; the
operator's lab-in-Pro move resolves the "vertical Pro has no content" objection
directly.)

| Tier | Price | Contents | Status |
|---|---|---|---|
| Starter | $39 | Foundation | live |
| Builder | $99 | + your business case's template (1 of 4) | live |
| Pro | $499 | + your vertical's LAB (the instrumented workspace) + the security suite | Trading = Quant Lab, live (rename); Studio/Launch/Forecast = blueprints |
| Ultimate | $999-1,499 by vertical | + your vertical's fleet/ops layer (Command Deck Fleet Ops) | raw material = `operator-panel`; trading first, post-launch |

Per-vertical upper-rung definitions: trading Pro/Ultimate = Quant Lab /
multi-strategy live ops (approvals, reporting, baselines, kill switches);
influencer = Studio Lab / run a content STUDIO not a character (roster,
scheduled pipelines, publishing queues); saas = Launch Lab / run a product
PORTFOLIO (deploys, webhooks, licenses, support, cross-product metrics);
forecast = Forecast Lab / run a research DESK (watchlists, scheduled
event-research agents, cross-market journal).

Mechanics + consequences:

- **The old $249 all-templates Pro RETIRES.** Pre-launch, with zero public
  customers and test-only LS products, this is the cheapest moment the
  restructure will ever have. Known trade-off: the ladder loses its mid-price
  impulse rung (conversion at $249 was never validated anyway); buyers who
  wanted "everything dev, no lab" land at Builder + add-ons.
- **Breadth survives as ADD-ONS, not tiers:** extra template (+$49-99), second
  vertical's lab (+$399-class). Keeps the 4-tier page clean while serving
  agencies/multi-vertical buyers; the "both flagships" upsell becomes an
  add-on story.
- **Security suite moves into Pro** (every vertical) and Ultimate.
  Starter/Builder stay without it (upsell driver preserved).
- **Branding:** SKU names = Starter / Builder / Pro / Ultimate with a vertical
  badge ("Pro -- Trading"); "Quant Lab" / "Studio Lab" remain the FEATURE
  brand inside Pro (docs, deck, `ecc quantlab` command untouched). Rename
  surface: manifest skus, deriveSku, LS products, gateway shapes,
  what-you-get, getting-started docs, installer SKU display. ~1-2 sessions.
- **Uniform Pro $499 doubles as a quality bar:** a vertical's lab ships only
  when it deserves the same $499 the Quant Lab earns (246 tests, deck, five
  docs). No diluted labs.
- **Ultimate priced by category anchor:** trading **$1,299** recommended
  (category lifetime licenses cluster at $1,497-1,499: NinjaTrader,
  MultiCharts, Build Alpha; slight newcomer undercut), other verticals
  $999-class, set when built. Every Ultimate carries the fleet cost-honesty
  note: Anthropic bills headless/autonomous agent usage from a separate
  API-rate credit pool (since June 15, 2026), so fleets cost the buyer tokens
  on top of the license.
- **The $99 -> $499 jump is defensible** (the product class changes: team ->
  instrumented workspace; trading-market analogy: TradingView subs vs
  MultiCharts $1,497 coexist) and softened by upgrade-anytime-pay-the-difference
  via the gateway.
- **Launch presentation for lab-less verticals:** at launch only Trading shows
  all four rungs; influencer/saas/forecast show Starter/Builder with Pro
  "coming to this track" (honest roadmap tease). Post-launch lab build order
  becomes demand-driven: which Pro do people ask for.
- **Subscriptions stay out of the tiers.** The only justified subscription
  remains an optional hosted/maintained layer ON TOP of Ultimate (post-launch;
  `subscription-v1` revival candidate).
- **OPEN price knobs for Phase 5:** exact add-on prices, uniform-vs-per-vertical
  Ultimate pricing, upgrade-credit mechanics.

---

## 2. Earned value per tier: what does the buyer EARN

### 2.1 The framing

Sell earnings, not inventory (ROADMAP lever 4: counts set up the "I only see 2
agents" letdown). Every tier answers four questions: time saved, capability
unlocked, risk avoided, and "compared to what." The honest math is ranges, not
fake precision. The product's unique credibility move stays central: the worked
example fails its own gate; we sell the instrument, not the dream.

### 2.2 Starter -- $39

- **Earns:** the working environment a Claude Code power user builds over a
  weekend+ of curation (skills, agents, rules, hooks), installed in ~60 seconds,
  maintained for 12 months. 10-20 hours of setup/curation labor avoided; at
  $50-100/h that is $500-2,000 of labor for $39. Honest version: "you could DIY
  this free; you are buying the curated, tested, *maintained* assembly."
- **Risk avoided:** one bad hook or unsafe workflow footgun avoided pays for it.
- **Compared to:** courses ($20-200) teach it, you still assemble; free awesome-lists
  point at parts, you still curate, test, and maintain.
- **Pitch line:** "Skip the weekend of setup. A serious Claude Code environment,
  installed in 60 seconds."

### 2.3 Builder -- $99

- **Earns:** Starter + full language depth (94 skills / 41 agents) + **one domain
  team** for the project they actually have. The template is days of bootstrap:
  domain agents, workflow guide, sample config, starter prompt. 2-5 days of
  project-bootstrap labor, $800-4,000 at freelance rates.
- **Compared to:** single-domain boilerplates (ShipFast-class, ~$199+, SaaS only).
  Builder is half that and the buyer picks the domain.
- **Pitch line:** "Start your project days ahead: deep language coverage plus the
  domain team for the thing you're building."

### 2.4 Pro -- $249 (the operator's question, answered)

Three legs, in order of honesty-weighted strength:

1. **The security suite (the differentiated leg).** Supply-chain defense for the
   AI-dev toolchain: FIM over `~/.claude/`, hook-integrity at session start,
   Shai-Hulud C2 blocklist, daily audit cron, npm/pip hardening, secrets vault,
   tamper alerts, auto-quarantine, 12 months of IOC patches. Shai-Hulud was a
   real 2025 npm worm; the suite exists because we needed it for production
   trading bots, and we run it there today. **No turnkey comparable exists** for
   Claude-Code-specific hardening; generic endpoint tools do not see hooks,
   skills, or MCP config. The buyer who runs Claude Code where API keys and money
   live is exactly the Pro buyer. One prevented credential exfiltration is worth
   more than 100x the price. This is insurance priced at a coffee budget.
2. **Both flagships, proof-backed.** Trading (proven by a live fleet) + AI
   Influencer (proven by Aletta), plus the other two templates. The marginal $150
   over Builder buys the other three teams at $50 each, plus the suite.
3. **Production posture.** Rules + reviewers + gates as an always-on discipline
   layer. Do not invent defect-rate numbers; let the showcase receipt and the
   planned Deck impact log carry this leg with the buyer's own data.

- **Anchor:** $249 is roughly one hour of senior engineer time.
- **Pitch line:** "Run Claude Code like a production shop: both proof-backed
  flagship domains, every template, and the security suite we use to protect
  real-money trading bots."

### 2.5 Quant Lab -- $499

- **Earns:** the production-shaped plumbing that takes weeks to assemble and
  harden: backtest + walk-forward + Monte Carlo validation, risk engine with
  execution safeguards, LLM trade-review layer with hard guardrails, paper-first
  execution, the Trading Deck, 246 shipped tests, five methodology docs. The
  operator's own build history (months of hardened lessons) is the provenance.
- **Risk avoided (the real product):** the gate that says NO. "The $499 lab's job
  is to save you from the $5,000 mistake": one prevented bad live deployment
  dwarfs the price. The example strategy failing its own gate is the proof the
  instrument is honest; every competitor sells dreams.
- **Compared to:** QuantConnect (~$60+/mo, their cloud, their platform),
  BuildAlpha (~$1,990), quant courses ($300-2,000) that teach without shipping a
  lab. None are a local, owned, paper-first lab wired into Claude Code.
- **Pitch line:** "The lab that tells you your strategy is bad before the market
  does."

### 2.6 Where this feeds

Section 2 is the copy backbone for Phase 5 (storefront pricing page + per-tier
pages), the `what-you-get.md` refresh, and the showcase framing. Comparables need
verification before publication.

---

## 3. Whole-project assessment + the next path

### 3.1 The binding constraint

The constraint is no longer product; it is distribution. Every additional
pre-launch build week adds unsold inventory, zero buyer feedback, and more
12-month-update surface. The storefront converts ~3 months of build into a
testable business; nothing else on the candidate list does. Within Phase 4's
original scope, Quant Lab shipping means the monetization-stream concept is
*proven*; education and fleet do not need to exist to launch.

Named gap inside the constraint: **audience.** A single-event launch with no list,
no content cadence, and no public presence launches to crickets. Revenue = traffic
x conversion x price; price exists, conversion machinery is nearly done, traffic
is unaddressed. This is the project's #1 strategic gap, bigger than the storefront
build itself, and it has lead time (audiences compound). Aletta + build-in-public
+ the honest-gate story are unusually good content raw material.

### 3.2 Candidates, verdicts

| Candidate | Verdict | Reasoning |
|---|---|---|
| SHIP content-v2.2.0 (Deck v2) | **Do now** (~half a day) | Accepted, finished inventory sitting unshipped; also the storefront's lead demo asset |
| Phase 5 storefront | **Do now, the main build** | The critical path to revenue; everything else optimizes unsold inventory |
| Distribution workstream | **Add to Phase 5 explicitly** | See 3.1; storefront and audience build in parallel (Aletta explainer, demo videos, launch list, posting cadence) |
| b21 installer bugfix | Pre-launch, not now | Front door quality gates conversion, but nothing public points at it yet; slot it just before launch |
| ML-runner fast-follow | Post-launch | Approved and small, but polish on a SKU nobody can buy |
| Studio Lab (first new lab) | Post-launch, demand-checked | Blueprint ready (section 1); ~2 weeks from go-signal thanks to the chassis |
| Education stream | Post-launch | Stronger with real buyer questions; content-heavy |
| Fleet tier | Later | Largest build, explicitly sequenced last already |

### 3.3 Recommended sequence

1. **Now:** merge + ship content-v2.2.0 (operator gate, then the standard loop:
   package -> REST env flip -> key round-trip verify -> bootstrap push -> box e2e).
2. **Now -> next ~2-4 weeks: Phase 5 storefront**, with this workshop as input:
   section 2 = copy backbone; section 1.5 = pricing-page architecture (tiers +
   Labs grammar). Plus the **distribution workstream** running alongside.
3. **Just before launch:** b21 installer pass (INST-1..10 triage: fix the
   conversion-relevant ones, defer the rest).
4. **Launch** (Phase 6, single event, per the decided strategy).
5. **Post-launch, demand-ordered:** ML-runner fast-follow -> Studio Lab ->
   education -> Forecast/Launch Labs -> fleet tier.

### 3.4 Decisions needed (OPEN)

1. **Re-scope Phase 4 pre-launch to "Quant Lab only"** (education + fleet + new
   labs move post-launch), green-lighting Phase 5 as the next build. Recommended: yes.
2. **Ship v2.2.0 now** (merge `feature/trading-deck-live`, push, package, flip).
   Recommended: yes.
3. **Labs = blueprint-only pre-launch** (vs pulling Studio Lab forward at ~2 weeks
   cost). Recommended: blueprint-only.
4. **Add the distribution/audience workstream to Phase 5** as a named deliverable
   set (launch list, Aletta explainer + demo videos, posting cadence, launch-day
   plan). Recommended: yes, and start it first; audiences have lead time.
5. ~~NSFW stance~~ **DECIDED 2026-06-12**: SFW by default; all shipped
   workflows SFW (Flux 2 guardrails as backstop); no NSFW nodes or prompts in
   anything we ship; buyer's own path beyond that, with explicit disclaimer.
6. ~~Tier architecture~~ **DECIDED 2026-06-12 (operator-directed v3)**: four
   tiers, one vertical axis -- Starter $39 / Builder $99 / Pro $499 (= Builder
   + the vertical's Lab + security suite) / Ultimate $999-1,499 (= Pro + the
   vertical's fleet). Old $249 all-templates Pro retires; breadth becomes
   add-ons. Remaining knobs (Phase 5): add-on prices, per-vertical Ultimate
   pricing, upgrade credits. NOTE: section 2's per-tier value cases must be
   re-mapped to the 4-tier model in the Phase 5 copy pass (old 2.4 Pro case +
   2.5 lab case merge into the new Pro; Ultimate inherits the fleet/ops story).

### 3.5 Profitability check of the v3 cost model (added in-workshop)

**Structure vs market: PASS.** Four-tier good-better-best(+) with a vertical
axis chosen at Builder matches how the market already behaves: JetBrains'
single-IDE choice under an all-pack ceiling, boilerplate two/three-tier
ladders, add-ons for breadth. Nothing exotic for a buyer to decode.

**Price points vs market:**

| Tier | Verdict | Anchor |
|---|---|---|
| Starter $39 | Safe (funnel) | Courses $20-200; the REAL competitor is free OSS, so the value is curation + install + 12mo updates |
| Builder $99 | Safe, arguably modest | ShipFast $199-299; ours is agents/docs, not deployable code -- $99 is honest |
| Pro $499 (trading) | **Strong** | Category one-times: Build Alpha $1,497, MultiCharts $1,497, NinjaTrader $1,499; QuantConnect $720+/yr. We undercut ~3x with the honest-gate story |
| Pro $499 (studio) | Credible for OUR buyer | Higgsfield Ultra ~$1,188/yr: "own your studio, stop renting" beats ~6 months of rent. Caveat: buyer pool = (wants AI-influencer business) INTERSECT (runs WSL/Claude Code) -- narrower than the hosted mass market |
| Pro $499 (launch/saas) | Hardest anchor fight | Sits ABOVE ShipFast $199-299; justified only by the gated-product ops slice no boilerplate ships |
| Pro $499 (forecast) | Unproven demand | No comparable market exists; correctly sequenced last |
| Ultimate $1,299 (trading) | Category-normal | Lifetime licenses cluster at $1,497-1,499 |
| Ultimate $999 (others) | Decide when built | Sub-normalized markets need the own-vs-rent story to land |

**The honest profitability equation.** Marginal cost is ~0 (LS ~5% + $0.50,
infra <$50/mo). The real costs are operator TIME (build, support, the
12-month update promise, Claude Code platform churn -- already a proven
ongoing load) and marketing. Therefore profitability is NOT decided by price
points; it is decided by qualified traffic x conversion:

- Practitioner heuristics (ranges, not citations): cold traffic to a new
  dev-tool storefront converts ~0.5-2%; warm/audience traffic 2-5%+.
  High-ticket ($499+) from COLD traffic on a brand with no reviews, no
  community, no track record is the weakest link in the chain. Trading buyers
  at this price do due diligence: the Build Alpha precedent is YEARS of
  content marketing preceding the $1,497 sale.
- Scenario sketch (launch month): 3k visits x 1% x ~$120 AOV = ~$3.6k.
  10k visits x 1.5% x ~$180 AOV = ~$27k. The variable that moves revenue 10x
  is TRAFFIC, not a $100 price tweak. This is section 3.1's distribution gap,
  restated in money.

**Levers that protect profitability:**

1. **Launch pricing mechanics:** keep list $499; a single launch-event intro
   offer (e.g. -20% via LS discount code) creates urgency without
   re-anchoring. "Intro price" framing, no fake strikethroughs (EU
   price-indication rules; a new product has no genuine reference price). LS
   as merchant of record handles VAT and the digital-content withdrawal
   waiver, but the refund POLICY is ours: recommend a 14-day money-back, it
   is near-mandatory for cold high-ticket conversion.
2. **Distribution-first** (3.1): the honest-gate story ("our own example
   fails its gate, and that is the point") is genuinely content-marketable in
   trading circles; Aletta carries the studio story.
3. **Demand-driven vertical expansion:** build no further Pro/Ultimate until
   trading Pro proves conversion. The v3 model makes this the natural default.
4. **Support cost caps:** define per-tier SLA NOW (community for $39/$99,
   email for Pro+, no white-glove) so the time cost stays bounded as units sell.
5. **Deferred recurring line:** the optional post-12-months updates
   subscription remains the fix for one-time pricing's flat LTV; decide
   post-launch with real renewal-demand data.

**Bottom line:** the model is clean and market-aligned; trading Pro/Ultimate
are outright strongly positioned, studio is credible, launch/forecast carry
known caveats and are sequenced accordingly. Because marginal cost is ~0 the
model is profitable at almost any sales volume; whether it is MEANINGFULLY
profitable is decided by the distribution workstream and by whether trading
Pro converts cold traffic. Green-light the model; gate further vertical
builds on trading conversion data.

### 3.6 Support capacity plan: one human + Claude (added in-workshop)

**Decompose the promise first.** "12 months" applies to UPDATES, which are
one-to-many: one content release serves every buyer; the cost scales with
Claude Code platform churn, not customer count, and it is work that keeps the
product alive anyway. Support RESPONSE has no promised SLA anywhere in
`what-you-get.md` ("docs, Discord, email support"); the SLA is ours to define,
and must be defined BEFORE launch, not discovered under load. Note the rolling
nature of the promise: a sale in month 12 obligates updates to month 24.

**The product's unique property: the support agent is pre-installed.** Every
buyer has Claude Code running. First-line support ships INSIDE the product:

1. `ecc doctor` (exists) = self-diagnosis; every failure mode found in the
   box2-class forensics becomes a doctor check + a KB entry.
2. A shipped **`support` skill**: buyer's own Claude reads doctor output + the
   shipped troubleshooting KB and fixes locally (the box2 debug journals are
   the seed content). The buyer's first support interaction is with the
   product itself.
3. **`ecc support --bundle`** (small build): collects doctor output + logs +
   versions into a REDACTED zip. Tickets arrive pre-triaged or not at all.

**Operator-side stack (the human + me):** support@ inbox triaged by Claude
(classify, draft replies, flag the rare real bug), operator approves/sends;
repro on the two test boxes; fix ships as a content release (machinery is
cheap and proven). Discord = community lane + pinned KB; no calls, no
screen-share, no white-glove at any tier.

**Structural caps (write them into the storefront support policy page):**
- Per-tier SLA: Starter/Builder = community + docs; Pro/Ultimate = email,
  2-business-day response target. Nothing else promised.
- Scope: support covers OUR product (install, activation, update, doctor-green,
  cockpit). NOT general Claude Code consulting, NOT strategy/character/product
  debugging, NOT custom development. The labs' disclaimer posture extends to
  support scope.
- EU note: conformity obligations (product works as described) exist
  regardless of SLA -- which is an argument for honest descriptions + doctor
  coverage, not for more support hours. LS as MoR absorbs payment/VAT/refund
  mechanics.

**The math.** Well-documented dev products see ~5-20% of units generate a
contact; install-class products sit at the high end (Windows diversity is
brutal -- box2 proved it). At 100 units/month that is 10-20 tickets, mostly
install-class, mostly doctor-resolvable: a few hours/week for one human with
Claude triage. At 1,000/month it is a real queue -- and revenue at that volume
funds the fix. The DANGER scenario is a traffic spike landing on a broken
installer: every b21 item fixed pre-launch is N tickets prevented. **b21 is
support-cost prevention, which upgrades its priority rationale** (it was
already sequenced pre-launch; this is WHY).

**Escalation valves if volume outruns capacity:** L1 contractor (Discord/email
triage is delegable with the KB + bundle tooling), raise prices (works for
high-ticket), pause sales per-SKU via LS, slow vertical expansion. The
one-time model means no per-customer service obligation accumulates beyond
updates conformity.

### 3.7 Operator rulings (recorded at session close, 2026-06-12)

1. Phase 4 re-scope: **NO -- build EVERYTHING pre-launch** (all three remaining
   labs, the fleet/Ultimate layer, education). The original
   build-everything-launch-once strategy stands. This supersedes: section
   3.3's sequence, section 1.5's "trading-only full ladder at launch" bullet,
   and section 3.5's "demand-driven vertical expansion" lever. At launch every
   vertical shows Starter/Builder/Pro; trading shows Ultimate, other Ultimates
   as the fleet generalization reaches them.
2. Ship content-v2.2.0: **YES -- GO recorded.** Next session opens with the
   ship loop; no further approval needed.
3. Labs: **NO to blueprint-only -- all three labs are built pre-launch.**
4. Distribution workstream: **YES.** With the longer all-prelaunch runway it
   starts NOW, not at Phase 5: every lab build becomes build-in-public
   material, and Aletta content production rides the Studio Lab build.

**Suggested pre-launch build order** (synergy-ordered; operator may reorder):
ship v2.2.0 -> ML-runner fast-follow (already approved, small) -> **Studio
Lab** (Aletta marketing synergy) -> **Fleet/Ultimate, trading** (the v3
ladder's top rung; generalize `operator-panel` on the cockpit shell) ->
**Launch Lab** -> **Forecast Lab** -> **Education** (teaches the finished
product) -> **b21 installer pass** -> **Phase 5 storefront** (SKU rename to
v3 + section 2 copy re-map + the three support build items) -> **LAUNCH**.
Distribution runs continuously from today.

Honest runway note at recent session pace: ~4-6 months to launch. The
distribution head start is what converts that runway into launch-day traffic
instead of crickets; treat the audience build as a parallel workstream with
weekly output, not a Phase 5 task.
