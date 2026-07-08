# Plumb — refinement status & how to continue

*A design-review / design-guide skill, drafted collaboratively. This note captures
where the refinement stands and how to finish it — deliberately outside the
covjson-msgspec repo, since plumb is general engineering judgment, not
covjson-specific.*

## Locked decisions

- **Name:** `plumb` — measure against *true*, not against the incumbent codebase.
- **Term for the principles:** *soundings* (a plumb line takes a sounding; ties to
  *sound*ness). Rejected: "vector," "gauges," "lines."
- **All-clear phrase:** `Plumb is true.`
- **Two modes:** review (findings ranked by *leverage*) + guide (soundings as
  pre-build questions).
- **Defers, by name:** over-engineering / simplicity → `ponytail-review`;
  line-level bugs & cleanup → `code-review`. Plumb owns *modeling and structure*.
- **Stance:** judge against the ideal, not the incumbent; a widespread bad pattern
  is a *finding*, not an excuse. Works on greenfield (nothing to conform to) and
  brownfield (where the habit may be the fault).
- **Proportional-response sounding is spec-agnostic:** verify the governing source
  if one exists; else follow the project's own stated requirements; match the
  strength of the response to the strength of the requirement.
- **Boundary-sharpening is a standing lens:** sharpen each *sounding's* boundary and
  the *skill's* overall boundary to avoid *unnecessary* overlap with the arena
  (ponytail, code-review, and external neighbors). **Some overlap is acceptable** —
  if avoiding it would weaken a sounding or plumb's overall impact, keep it and
  *name* it (a `[combine?]` marker, or a **Boundary:** line in the sounding). Cut the
  accidental overlap; keep the load-bearing kind. Prior art & neighbor analysis lives
  in [LANDSCAPE.md](LANDSCAPE.md), a living snapshot kept fresh as plumb evolves.

## Candidate superset (pre-tighten, ~19)

Grouped into the clusters that emerged — these groups are the seams for merging.

- **Correct by construction:** make illegal states unrepresentable · model outcomes
  as values · totality (handle every case) · faithfulness (preserve the input) ·
  sound typing (types carry the invariants; no `Any`/escape hatches).
- **Purity & composition:** functional core / imperative shell · favor immutability
  · one source of truth / compose · testability (design for testing *without*
  mocks; heavy mocks = a coupling smell).
- **Seams / dependency injection:** *open for extension* — expose a seam at a real
  axis of variation so behavior can be swapped without modifying the core
  (`strategy=`, injected `Fetch`, the deferred `parse_time=`); ships with a default
  so it's non-breaking. Two faces with functional-core: core doesn't reach *out*
  (effects injected) / callers can plug *in* (policy injected) — candidate to merge
  the two into one "seams at the edges" sounding. **Explicit boundary with
  ponytail:** openness fires only when the variation is *real*; speculative
  flexibility (one implementation, no demand) is ponytail's to cut. (In the temporal
  work the seam was *deferred* on exactly this test — ponytail won that round.)
- **Structure & boundaries:** low coupling / clean boundaries · cohesion ·
  encapsulation · put the check in the right tier.
- **Interface shape:** names encode shape · trivial common path over a complete
  core · symmetry (paired operations mirror).
- **Judgment & process:** proportional response grounded in the real source ·
  reversibility (know the one-way vs two-way door) · hunt the breaking edge.
- **Overarching goal (NOT a sounding):** clarity of intent — what the soundings
  collectively produce.

### This round's verdicts on the eight proposed additions

- **Add standalone:** functional core / imperative shell (split out of the old "one
  source of truth") **— DONE 2026-07-08, now live sounding 6**; immutability;
  testability-without-mocks; sound typing.
- **Merge:** "smaller composable pure functions" → into compose + cohesion +
  purity; "completeness" → umbrella over totality + symmetry.
- **Defer:** simplicity → `ponytail-review` (total overlap).
- **Reframe:** clarity → plumb's stated *goal*, not a sounding.

## Open questions (the tightening pass)

1. **Tighten ~19 → a tight ~10–12.** The correct-by-construction and purity
   clusters double up in places (illegal-states / sound-typing / outcomes-as-values
   all lean on the same idea); decide the merges.
2. **Clarity:** overarching goal, or a narrowed "reads as its intent" sounding?
3. **Completeness:** keep as an umbrella, or drop (totality + symmetry cover it)?
4. **Presentation:** grouped-by-cluster vs one flat leverage-ranked list.
5. **Definition dose:** crisp definition + one-line payoff per sounding + a compact
   cluster reinforcement map — deep collaboration narrative to the CxC companion.

## Target end state

A tight, grouped set (~10–12 soundings) where each has: a one-line definition, a
one-line "what it buys you," a Smell, and a Move — plus a short "how the clusters
reinforce each other" map, and pointers to the Correct-by-Construction guide for
the why.

## How to continue (recommended)

1. **Move plumb out of this repo.** It's general, not covjson-specific — it belongs
   with your personal tooling, next to the Correct-by-Construction guide. Two homes,
   both useful:
   - `~/.claude/skills/plumb/SKILL.md` — installs it live so you can actually invoke
     it (`/plumb`) in any repo. Refinement without dogfooding is guesswork.
   - a personal skills/notes git repo — the versioned source of truth, alongside CxC.
2. **Dogfood, then tighten.** Run review mode on a few real diffs and guide mode on
   a real design. Track which soundings *fire*, which *never* do (cut candidates),
   which *co-fire* (merge candidates). Let usage drive the final list, not armchair
   debate.
3. **Do the combine pass** to land ~10–12, then write the definitions, payoffs, and
   reinforcement map.
4. **Cross-link with Correct by Construction.** Shared DNA (illegal-states, sum
   types, immutability, sound typing). Division of labor: CxC = the deep "why";
   plumb = the operational review/guide. Each references the other.
5. **Optional, once stable:** split into `plumb-review` / `plumb-guide` entry points
   (mirroring the ponytail family) if the two modes want separate triggers.

## Dogfood log

*Real review-mode runs, per step 2. Track what fired, what co-fired, and what
each run drove into the skill.*

- **2026-07-07 — covjson-msgspec `feat/temporal`** (temporal.py + the
  Result/Report rename). Fired: **15** (headline — a year-0000 date mislabeled
  `Unrepresentable` instead of `Malformed`; found only by *running* `resolve` and
  comparing a differential twin, `0000-13-01` vs `2020-13-01`, not by reading the
  type or docstring, both of which *claimed* correctness), **1** (`Moment` permits
  naive+`SECOND` — real, but parked: sole trusted constructor upholds it), **5**
  (`resolve` vs the three bridge parsers can diverge — deferred in ADR, sharpened
  the note). **Co-fire: 4 + 15 on the headline** — a name/type that lies, surfaced
  by a breaking edge. Its leverage came entirely from the *downstream trace*: the
  mislabel defeats `validate(check_values=True)`, which is what promoted it from
  nit to net. **Drove:** the "measure leverage by tracing to the consumer /
  fix-vs-park" Working note — one trace resolved both #1 (fix) and `Moment` (park).
  **New signal for the tightening pass:** plumb *affirming* a sound decision (the
  Result/Report split, sounding 4) was valuable output, not filler; the output
  format absorbed it as an "Affirmed true:" line with no spec change needed —
  worth explicitly sanctioning affirmations when the combine pass rewrites Output.
  **Also drove (from the follow-up exchange, not the run itself):** the "expand
  the load-bearing findings" Output rule. The parked `Moment` finding, left as a
  terse line, prompted a request to explain it; the illuminating answer's *shape*
  (concrete instance → failure scenario → why-the-fix-is-wrong) became the
  required expansion for the top finding and every park verdict. Note the
  provenance signal: a *park* verdict is the likeliest thing to trigger "explain
  that," so it earns the depth even when its leverage is low.

- **2026-07-08 — sourced enrichment of sounding 5 (not a review run).** Folded the
  I/O-decoupling lineage the user surfaced into sounding 5 (functional core):
  named the three altitudes (*functional core / imperative shell* as the general
  statement, *sans-IO* as its I/O specialization, *ports & adapters* as its
  architectural face); generalized the smell across effects (clock/RNG/env/global
  singleton/framework, not only I/O) with the BYO-transport case demoted to the
  *vivid special case* (baking in `requests`/`httpx`/`aiohttp` forces that dep on
  every consumer and welds logic to sync XOR async); move = *compute, never
  perform*, inject the effect as a value/capability; attached a *Lineage &
  sources* list (sans-IO how-to +
  firezone; Bernhardt "Boundaries" + FC/IS screencast + Google Testing Blog
  2025-10; Seemann ports-and-adapters). **Bears on Open question 1 and the §53
  "add FC/IS standalone" verdict:** the enrichment's mass tipped this from parked
  to done — **SPLIT EXECUTED the same session (see the next entry)**: FC/IS is now
  its own sounding 6, and sounding 5 is DRY/reuse only.

- **2026-07-08 — split executed (Option A).** Acted on the tension the enrichment
  surfaced: separated the two ideas fused in the old sounding 5. Sounding 5 is now
  **DRY/reuse only** ("one source of truth; compose"); the functional-core/effects
  material became its own **sounding 6, "Functional core; effects at the edges"**
  (carrying the FC/IS + sans-IO + ports-&-adapters lineage and the *Lineage &
  sources* list). Renumbered former 6–15 → 7–16 and fixed the `[combine?]` cross-
  refs (5↔6 now co-flagged) — so any pre-2026-07-08 sounding number ≥6 (e.g. in the
  dogfood log) is +1 under the new scheme. Rationale (for the tightening pass): the
  two are **independently violable** (a repeated formula in a pure module = DRY
  only; an inline `datetime.now()` in a used-once fn = functional-core only) and the
  fused title needed an "and" — a cohesion (sounding 9) smell in plumb itself.
  **Chose the narrow split (effects only), NOT the wider "seams at the edges"
  merge** that would also absorb *open-for-extension* (policy-injection): the two DI
  faces share a fix mechanism but differ in *strength* (pushing effects out is
  near-unconditional; opening for extension is conditional and ponytail-bounded), so
  fusing them would blur a proportional-response (sounding 12) distinction. That
  merge stays parked for the DI-cluster tightening — see the seams/DI cluster note.

- **2026-07-08 — landscape scan & boundary-sharpening (not a review run).** Swept the
  public skills ecosystem for prior art / neighbors (per "are we reinventing the
  wheel?"). Findings recorded in **[LANDSCAPE.md](LANDSCAPE.md)** (new living snapshot).
  Verdict: not reinventing it — one adjacent *review* skill exists (NTCoding
  `lightweight-design-analysis`, clean-code/OO/DDD), differing from plumb on **method**
  (dimension-completeness vs leverage-ranking), **stance** (no plumb-line vs judge-
  against-ideal), and **breadth** (6 soundings — 7, 11–16 — the OO tradition doesn't
  reach; that fidelity/decision-cost cluster is the moat). This drove four changes:
  (1) **Frontmatter re-led** — moved leverage-ranking + judge-against-ideal to the
  front so the router no longer opens with "make illegal states unrepresentable," the
  phrase bucket-1 skills own. (2) **Sounding 2 gained a Boundary line** — states plumb
  takes the errors-as-values side and where the fail-fast/throw seam sits, resolving the
  rival-tradition tension with NTCoding's "fail-fast, throw." (3) **Candidate sounding
  17 "Locality of behavior"** minted from NTCoding's feature-envy detector, carrying a
  `[combine? with 9, 10]` marker (its kernel — behavior-with-its-data, GRASP Information
  Expert — sits at the cohesion/encapsulation intersection; merge-or-keep deferred to
  the tightening pass). (4) **Boundary-sharpening added as a Locked decision** (standing
  lens; some overlap is acceptable if load-bearing — cut only the accidental kind).
  **Bears on the tightening pass:** sounding 17 is a fresh merge/split candidate to
  judge with the "independently violable?" criterion; LANDSCAPE.md's ❌-gap column is
  the distinctness evidence for keeping 7 and 11–16 through the combine pass.

- **2026-07-08 — covjson-msgspec #14 plan** (OpenAPI schema bridge; review mode on
  the *implementation plan*, before any code). Fired: **16 + 1** (headline — a
  host-app component-name collision: `component_schemas()` emits generically-named
  components (`Parameter`, `Unit`, `Domain`) that `dict.update`-merge into a host
  app's `components.schemas` and silently clobber a same-named host schema; found by
  tracing the merge to the real consumer, a titiler-style host with its own
  `Parameter`). This was the plan's OWN open question, parked as "we'll name them to
  avoid collisions" — plumb refused the park and promoted it to must-fix. **1 + 4**
  (untyped `schema_ref(type)` could mint a `$ref` to an unregistered component).
  **Affirmed:** 6 (pure core / thin adapter), 14 (trivial path over complete core),
  12 (version claims verified against the FastAPI / msgspec sources). **Drove (into
  the work, not the skill):** namespace every component under one
  `_REF_TEMPLATE` / `_NAMESPACE` constant (illegal state → unrepresentable, 1; also
  a single source of truth, 5); type `schema_ref` to `type[CoverageJSON]`.
  **Signal:** plumb on a *plan* caught a design flaw before code existed, so the
  namespacing / typing landed in the first implementation pass instead of as
  code-review churn.

- **2026-07-08 — covjson-msgspec #14 implementation** (review mode on the diff).
  Fired: **5** (headline — `_ROOT_TYPES` re-lists the `CoverageJSON` union
  membership; found by tracing the drift: a future 6th union member would be
  silently omitted by `component_schemas()` AND `schema_ref` (now typed to the
  union) would then mint a dangling `$ref` for it — reopening the exact door the
  plan-review closed — and the new exact-surface *test* would not catch it, being
  pinned to the same hand-list). **Drove:** `_ROOT_TYPES = get_args(CoverageJSON)`
  (the union becomes the single source), plus a bonus low-coupling (8) win
  (schema.py imports only the union, not each member). **Parked 5/16:** `schema_ref`
  derives the component name via `type.__name__` while `component_schemas` uses
  msgspec's key — two derivations that agree for our non-generic structs and are
  pinned by the parametrized test; real but parkable. **Affirmed:** 6, 1.
  **Signal:** the diff-review's headline (5, one source of truth) was a *different*
  sounding than the plan-review's (16 + 1) — evidence the two altitudes are
  complementary; folded into a Working note ("run plumb at both altitudes"). Also:
  sounding 6, split out earlier this same session, carried real weight in both #14
  runs — the split earned its keep immediately.

## Artifacts in scratchpad (ephemeral — relocate with the skill)

- `plumb-SKILL.md` — the working draft (15 soundings + folding notes).
- `plumb-refinement-status.md` — this note.
- `temporal-iteration-log.md` / `.html` — the case study plumb was distilled from.
