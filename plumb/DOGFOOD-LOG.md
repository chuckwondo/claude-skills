# Plumb — dogfood log

*Real review-mode runs (and a few refinement actions), per step 2 ("Dogfood,
then tighten") of [REFINEMENT.md](REFINEMENT.md). Track what fired, what
co-fired, and what each run drove into the skill. Append-only, and deliberately
separate from REFINEMENT.md's rewrite-in-place design state so the log can grow
without churning it.*

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
  refs (5↔6 now co-flagged) — so any pre-2026-07-08 sounding number ≥6 (e.g.
  elsewhere in this log) is +1 under the new scheme. Rationale (for the tightening pass): the
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

- **2026-07-08 — covjson-msgspec `feat/validation-should-domain-type`** (#37, the
  domainType SHOULD/conflict validation checks; two runs on one feature, both
  altitudes — a second full instance of the "run at both altitudes" note after #14).

  *Plan run (guide→review on the proposed design).* Fired: headline **co-fire
  4 + 12 + 15** on the variant then named `CoverageRedundantDomainType` — the name
  "redundant" *lies* for the differ-case (a member declaring a *different* type than
  its collection is a §6.5 contradiction, not harmless redundancy), the two
  situations carry different severities (warning vs error), and the tag is a
  **one-way wire code** (ADR-0006) so the wrong frame hardens. Leverage from the
  downstream trace: a consumer filtering warnings-as-advisory silently downgrades a
  real inconsistency, and `mode="raise"` (errors-only) never catches it. **Drove the
  design** (not just a note): split into a warning (`NotOmitted`, equal) + an error
  (`Conflict`, differ). Sounding **12** also fired as a *process* — the run flagged
  rule (c) as ungrounded ("can't cite it"), which forced an actual spec fetch that
  flipped two decisions: (c) *is* a real SHOULD → kept; rule (b)'s SHOULD is
  conditional on an unfetchable remote domain → dropped (**co-fire 6 + 12**,
  sans-IO). **Affirmed:** the two-variant split, tier (11), dropping (b).

  *Diff run (review mode on the diff, after the code-review fixes).* Fired: headline
  **5 surfaced by 16** — the fix for a code-review finding *introduced* a
  one-source-of-truth drift: the JSON-pointer logic re-derived "which level declared
  the type" with `domain.domain_type is not None`, while `effective_domain_type`
  resolves the value by truthiness (`declared or ...`); they diverge on an
  empty-string `domainType`, so the emitted finding's payload (`"Grid"`) and its
  pointer (the empty domain member) contradict each other. Found only by probing the
  breaking edge (`""`). **Drove:** align the predicate to the same truthiness (one
  line), plus a doctest pinning the `""` case.

  **New signal for the tightening pass:** (1) *Second confirming instance of the
  "both altitudes catch different flaws" note* — plan caught the naming/modeling of
  the differ-case (4/12/15); diff caught a drift that only existed once code (a
  code-review fix) was written (5/16). (2) The diff-run finding was *created by a
  code-review fix* → argues for sequencing plumb-diff **after** code-review and its
  fixes, since a correctness fix can introduce structural debt plumb then catches.
  (3) Sounding 12 acted as a *forcing function for verification*, not just a grading
  rule — "can't cite it" was itself the finding that drove opening the spec; worth
  naming 12's dual role (grade proportionally **and** go verify) if the combine pass
  touches it.

- **2026-07-09 — covjson-msgspec #69 plan** (monotonic primitive-axis MUST
  validation; review mode on the design plan, after a long interactive design
  conversation, before any code). Fired: headline **co-fire 3 + 5** — the default
  checker's "which reference system orders, and how" was split across two
  mechanisms (`temporal_coordinates` for the temporal case, an `isinstance(system,
  (Geographic|Projected|Vertical)CRS)` chain for numeric) with an implicit
  `else: skip`, i.e. a non-total classification. Leverage from the downstream
  trace: a future *ordered* `ReferenceSystem` variant added to the union falls
  through the isinstance chain, is silently classed "skip", and a genuinely
  non-monotonic numeric axis passes `validate(check_values=True, mode="raise")`
  with no error AND no compiler nudge — a silent false-negative on a spec MUST.
  **Drove the design:** one total `_ordering_kind(system) -> Literal["numeric",
  "temporal"] | None`, exhaustive `match` + `assert_never`, which also became the
  single code home for the ADR's ordering registry (the 5 half) and forced the
  standard-calendar gate *inside* the classifier (a mirror hazard the trace
  surfaced: a non-standard-calendar `TemporalRS` would otherwise be fed to the
  Gregorian `resolve` and silently mis-compared). **15 + 9** on the
  `AxisOrderChecker(values, system)` signature — a public one-way door, resolved
  by the *cohesion* argument (the seam's one concern is coordinate-value ordering,
  so it takes `values`, not the whole `Axis`; bounds-ordering is a separate future
  check) and recorded as a deliberate door in the ADR rather than widened
  speculatively. **12** (mild) — the RS-ordering classification is our
  *interpretation* of §6.1.2's "natural ordering", not verbatim spec; drove an ADR
  framing note (cite 6.1.2, don't present it as a quoted enumeration). **5** again
  — the coord→system index duplicated xarray's private `_coordinate_systems`;
  since `_bridging.py` was already being opened for `is_standard_calendar`, drove
  lifting `coordinate_systems` there now (two consumers) and migrating xarray off
  its private copy. **Affirmed:** 6 (the injected-seam-with-shell-resolved-default
  *is* the design's spine — done well, so plumb's value shifted inward to the
  totality/purity of the injected default's internals), 11 (O(n) scan gated in
  `check_values`, not `__post_init__`), 14 (trivial default under `check_values`,
  strict via `require_monotonic(strict=True)`, full override via the seam), 7
  (temporal compare via `resolve`, no stored datetimes). Routed the `bool`-is-`int`
  and NaN-coordinate walk edges to code-review by name.

  **New signals for the tightening pass:** (1) *Plumb earned its keep on a
  heavily-deliberated plan.* The seam shape, its naming
  (`AxisOrderChecker`/`axis_order_checker`/`require_monotonic`), the `int | None`
  return, even the `None`-sentinel default had already been argued out over many
  rounds of interactive design — all *local* decisions — yet none surfaced the
  *global* totality/one-source gap that plumb's union-growth trace caught. Evidence
  that plan-altitude plumb is not redundant with careful iterative design; they
  optimize different scopes. (2) *Sounding 3 (totality) as a headline* is a first
  for the log (prior headlines: 4, 5, 12, 15, 16), and it co-fired with 5 the same
  way #14's runs coupled 1↔5 — "add a case → silently skipped" is a totality smell
  whose *leverage* is a one-source-of-truth drift; worth watching whether 3 and 5
  should be cross-flagged. (3) *When DI (6) is already done well, plumb's yield
  moves inward* — from "should this be injected?" to "is the injected default's
  core total and single-sourced?"; the flaw lived inside the well-chosen seam's
  default, not in the seam decision. (4) *Sounding 12 fired twice, once outside the
  formal run*: before the /plumb invocation, the user challenged a spec section
  number (our 6.1.1 vs the OGC HTML's 9.6.1.1), forcing an actual spec.md fetch
  (12's verify-against-the-source facet, the same forcing-function role noted in
  #37) — a reminder that 12 operates whenever a spec claim is made, not only inside
  a review.

- **2026-07-09 — titiler-covjson #44 plan** (`/position` Point-domain slice; review
  mode on the plan — and the log's first **re-review of a plan plumb had already
  reviewed once**, 2026-07-08, after a blocker-merge gap). Fired: headline **co-fire
  7 + 1** — the plan enshrined a phantom `(bands, 1)` axis on `PointInput.data` (a point
  sample is one-scalar-per-band = `(bands,)`); leverage from the downstream trace: the
  unfaithful shape forces a converter reshape, a `shape[1] == 1` guard, a *load-bearing
  warning comment* ("don't simplify this away"), and a `(2, 3)` test case — four
  consequences of one invented axis. The kicker: this **overturned first-pass finding
  2**, whose own empirical note ("`data[i]` on a 1-D array returns a bare `float32` for
  an unmasked band") was *correct but mis-diagnosed* — it concluded "keep `(bands, 1)`"
  when the real cause was integer-indexing, and a *slice* `data[i : i + 1].reshape(())`
  yields a proper 0-D `MaskedArray` on the honest `(bands,)` shape. Caught only by
  **running the counterfactual probe** (index vs slice, masked/unmasked, float/int), not
  by re-reading the note. **16 + 1** — `_parse_point_wkt` admits non-finite coords
  (`float("nan")`/`float("inf")`/overflow `float("1e400")` all parse), and a NaN
  coordinate serializes to a silent `"values":[null]` axis (verified by constructing
  `ValuesAxis` + dumping) → a dishonest 200; the parse boundary must yield a *trusted*
  `Position`. **5 + 13** — `_resolve_read_bands` should return `tuple[BandInfo, ...]`
  uniformly (build BandInfo for the expression case too) so both `_build_*_input`
  collapse to one call shape and become true mirrors. **5** — `reject_vertical_selection`
  reject-on-truthiness so a valueless `?z=` is absent, matching the codebase's
  empty-is-absent convention. **3 + 15** — keep each commit green: the `CoverageInput`
  union flip belongs with the modeler arm, not the `PointInput` definition, else
  `assert_never` is red between commits. **Affirmed:** the plan's spine — a real
  `GridInput | PointInput` union with exhaustive `match` (3), a dep-free `Position`
  value type (1/6), a pure modeler with WKT parsing confined to the shell (6), heavy
  symmetry with `/bbox` (13).

  **New signals for the tightening pass:** (1) *First logged re-review of the same
  plan, and it flipped a prior headline.* A finding is itself falsifiable by a later
  pass — and what caught the mis-diagnosis was **empirical discipline applied to the
  proposed fix, not only the design under review**: the first pass ran a probe but
  stopped at "the crash happens" without testing whether an alternative indexing avoids
  it. Argues for a Working-note nuance: when a fix is "keep shape X to avoid crash Y,"
  hunt the breaking edge (16) on *your own fix* — verify the counterfactual (does an
  alternative avoid Y without X?), not just that Y occurs. (2) *Faithfulness (7) as a
  headline* — new for the log (prior headlines: 4, 5, 15, 16, and 3 on #69), co-firing
  with 1 the way earlier runs coupled 1↔5 / 3↔5. Candidate heuristic: **a comment that
  *defends* a shape is evidence the shape is unfaithful** — the "don't simplify this
  away" warning was the tell that the trailing axis shouldn't exist. (3) *Both-altitudes
  note, new angle:* both passes were plan-altitude (not plan-vs-diff), yet the second
  still found what the first missed — because the first pass's *verification* was
  incomplete, not because the altitude differed. Distinct from the #14/#37 "plan vs diff
  catch different flaws" signal: this is "same altitude, stricter empirical discipline
  catches a mis-diagnosis," so re-review value isn't only altitude-switching. (4)
  *NaN-coordinate routing nuance:* #69 routed a NaN-coordinate walk to **code-review**;
  here the same class stayed in **plumb** because the assumption lived in the
  parse-*boundary*'s shape (a `Position` that promises trusted values but doesn't,
  sounding 1), not in a downstream value check. Rule of thumb: NaN-in-values →
  code-review; NaN-admitted-by-a-boundary-that-claims-to-produce-trusted-values → plumb.
