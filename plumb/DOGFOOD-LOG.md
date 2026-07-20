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

- **2026-07-09 — covjson-msgspec #69 diff review** (the monotonic-axis feature as
  implemented; review mode on the diff, AFTER the earlier #69 *plan* review and AFTER an
  xhigh *code*-review that found + fixed a NaN-coordinate edge). Outcome: **net "Plumb is
  true."** The plan-pass's load-bearing fixes all landed in code and hold — **affirmed:**
  3 (`_ordering_kind` present and total, `assert_never` over the real `ReferenceSystem`
  union), 5 (`coordinate_systems` lifted to `_bridging`, xarray migrated off its private
  copy), 6 (pure check, the ordering policy injected as a seam), 11 (O(n) scan gated in
  `check_values`), 15 (the `(values, system)` one-way-door signature kept narrow). The
  single live finding was a **6-vs-5 wash:** the seam's default (`None →
  require_monotonic()`) resolves at the *leaf* (`_axis_monotonic_issues`, once per
  domain) rather than the *edge* (`validate`, once per call) the plan's wording implied.
  Traced to the consumer: **no wrong output** — the only cost is a per-coverage closure
  rebuild inside a `CoverageCollection`, nanoseconds against the O(total values) scan.
  Parked as a wash because edge resolution *can't cleanly deliver* the sounding-6 purity
  win: `_axis_monotonic_issues` must keep a `None` fallback for its own direct doctest
  regardless, so moving resolution to `validate` only *adds a second* site (a sounding-5
  cost) for a negligible gain. Two tiny parks: 1 (the `keyed` "mutually comparable"
  invariant lives in the docstring, not the type — but a single trusted caller upholds
  it) and 2 (`_temporal_keys` returns `None` = "declined to order" vs `[]` = "trivially
  ordered" — distinct honest meanings, no consumer conflates them).

  **New signals for the tightening pass:** (1) *A thorough plan-review can front-load the
  structural fixes so the diff-review is confirmatory, not corrective.* This is the
  **complement** of the #14/#37 "plan vs diff catch *different* flaws" signal: there each
  pass earned its keep by finding a distinct defect; here the diff-pass came back
  essentially clean *because* the plan-pass was thorough (`_ordering_kind`, the dedup, the
  seam signature were all designed and then implemented faithfully). "Diff-review returned
  Plumb-is-true" is itself a positive signal about plan-review thoroughness, not a wasted
  pass — worth naming so a clean diff-pass isn't read as "plumb found nothing, skip it
  next time." (2) *A finding can resolve to "the code is right, the plan/narrative was
  wrong."* The diff-review caught the implementation deviating from the plan's stated
  shape ("resolve once in the shell"), then judged the deviation an **improvement** (the
  doctest-direct-call convention forced the cleaner single-site leaf form), so the
  resolution was to correct the design doc's mental model, not the code — plumb judging
  the artifact against the *ideal* (its core stance) vindicated the implementation over
  its own plan. Distinct from every prior entry where a drift-from-plan was a regression
  to fix. (3) *Skill-partition confirmed again* (per #37's sequencing note): diff-plumb
  ran after code-review and its NaN fix, correctly left the NaN in code-review's lane, and
  stayed structural — the two skills partitioned cleanly with no double-coverage.

- **2026-07-09 — titiler-covjson #44 diff, commit 1** (the Point input layer; review
  mode on the staged diff, the complement to the same-day #44 *plan* re-review earlier
  in this log, run after the code plus an interleaved ponytail-review and code-review).
  **Verdict: Plumb is true** — the plan re-review had already caught the one load-bearing
  shape issue (the `(bands,)` flip) and it landed faithfully, so this pass produced one
  park plus affirmations, no fix. **Headline park (4 / 1 / 13)** — `GridInput.bounds:
  tuple[float,float,float,float]` vs the diff's new `PointInput.position: Position`: the
  diff models Point's location as a named value type with no empty state, while the
  sibling models its extent as a bare 4-tuple whose `(west,south,east,north)` order is
  positional convention (`(minx,maxx,miny,maxy)` is equally constructible — a
  sounding-1/4 smell). The park flags the **incumbent** `bounds`, not the diff; the move
  is "make `bounds` a value type to match," deferred as out-of-scope (internal, two-way
  door, tested). **Affirmed:** 7 (`data = point.array` at `(bands,)`, no reshape — the
  plan headline, built as designed); **5** (`_require_crs` is now the single home for CRS
  resolution, message via `type(source).__name__`, shared by both converters); 1 + 11
  (`Position` has no empty state; checks at the construction tier); 6 + 8 (rio-tiler under
  `TYPE_CHECKING`, pure converters). Deferred by name: the `crs or source.crs` truthiness
  edge → code-review; the trimmed converter surface → the deliberate ponytail cut.

  **New signals for the tightening pass:** (1) *A diff that introduces a BETTER shape than
  its sibling yields a park that flags the sibling, not the diff.* "Judge against the
  ideal, not the incumbent" produced a **precedent-setting** park: the diff did the right
  thing (`Position`), which by contrast marks the older `bounds` 4-tuple as the weaker
  modeling. The move is never "make the diff worse to match the incumbent"; it is "the
  incumbent should adopt the diff's shape," parked when out-of-scope. A park whose subject
  is a *different line than the diff touched* is a distinct verdict shape worth naming.
  (2) *Sounding 5 at diff altitude, opposite polarity to #14.* The affirmed `_require_crs`
  is a one-source-of-truth structure that did NOT exist at plan time — it emerged from the
  interleaved code-review's dedup finding. #14's diff-run CAUGHT a one-source-of-truth
  *drift* that only existed once code was written; here the diff-run *affirmed* a
  one-source-of-truth structure that only existed post-code. Same axis (5 at diff
  altitude), inverse polarity (drift-caught vs structure-affirmed) — evidence that
  post-plan structure introduced by sibling reviews is exactly what a diff-pass is
  positioned to judge. (3) *Second same-day instance of the entry-directly-above's
  signal* — a thorough plan-review front-loading the fixes so the diff-review is
  confirmatory (covjson-msgspec #69 above; titiler #44 here). Two projects, one day:
  corroboration, noted not re-derived.

- **2026-07-09 — covjson-msgspec #18 plan + artifact iteration** (the
  covjson-pydantic benchmark harness; review mode on the *design plan*, then a
  long user-driven refinement of the rendered artifact — the log's first run on
  a **measurement/comparison artifact** rather than library modeling).

  *Plan run.* Fired: headline **co-fire 16 + 13 + 12** — the operation matrix
  measured the fairness story on one side only (msgspec structural `decode` vs
  pydantic's fused decode+validate+datetime), so the assumption
  "decode-vs-decode is fair" had no case testing its boundary (16), the
  comparison was asymmetric (13), and the number would read as the foregone
  conclusion the issue's own methodology warns against (12). Leverage from the
  trace: the headline would claim a pure speed win while a real slice of
  pydantic's cost is datetime parsing msgspec merely *deferred*. **Drove the
  design:** a cumulative msgspec ladder up to `decode +
  validate(check_values=True) + to_datetime(t)`, the only honest like-for-like,
  the datetime rung conditional on a temporal axis. Also **5** (render
  `results.md` *from* the one result structure → the two artifacts can't drift),
  **2** (a non-measured cell is an explicit `Skipped(reason)`, never an omitted
  row), **15** (`results.json` is a #22-facing contract → document its schema).

  *Artifact iteration (soundings firing outside the formal run, user-driven).*
  **13 recurred, un-propagated** — the plan-pass fixed the asymmetry in the
  *decode* ladder but the identical one in *round-trip* (msgspec structural
  decode+encode vs pydantic full decode+dump) survived; caught by eye, fixed
  with two round-trip anchors mirroring the decode ladder. **12 marathon** on
  the validation-conformance scorecard: (a) an asserted claim ("pydantic doesn't
  check value-vs-dataType") was *false* — a verify-against-source violation in
  the wielder's own output, caught only when the user demanded empirical proof;
  (b) the "is malformed-temporal a warning?" challenge exposed the scorecard
  grading a **SHOULD** (Spec 5.2) as if MUST and marking pydantic's hard-reject
  *compliant* — fixed by grading every row by requirement level (MUST→error,
  SHOULD→warn) and re-marking pydantic's SHOULD-overreach. **7** — probe
  failures render the library's *verbatim* raised exception (`raises <Type>:
  <message>`), not a paraphrase; **2** — the null reverse-direction stated
  explicitly, `n/a` (not-applicable) kept distinct from `raises` (rejected).

  **New signals for the tightening pass:** (1) *A symmetry (13) fix must
  propagate to sibling operations.* The plan-pass scoped the fix to where the
  flaw was spotted (decode); the same structure in round-trip survived because
  it was one line in the plan and its internal asymmetry only became salient
  once written out. Candidate Working-note: when a fix is "make comparison X
  fair," apply it to every sibling sharing the structure — the fix's blast
  radius is a leverage question too. A third flavor of both-altitudes: plan
  caught the class, use exposed an un-propagated member. (2) *Sounding 12's
  verify-facet turned on the wielder.* The reviewed artifact was mine, and I
  repeatedly asserted pydantic/spec behavior from memory with the user as the
  12-enforcer — reinforces that "verify, don't assert" binds the reviewer's own
  claims, not only the code's. (3) *First run on a comparison/measurement
  artifact*, whose entire value is honest, verified, proportional claims —
  sounding 12 *is* the artifact's correctness condition, not a side-check; every
  scorecard cell is a spec-conformance claim, so MUST/SHOULD grading (12) and
  verbatim errors (7) were load-bearing. (4) *16 fired on the benchmark's own
  fairness assumption*, not on a code input — the breaking-edge probe applies to
  a *methodology's* hidden assumption ("this comparison is like-for-like") the
  same way it applies to a parser's.

- **2026-07-10 — covjson-msgspec #77 plan + diff** (model the five
  `CoverageCollection`-inheritance members with `msgspec.UNSET` instead of
  `X | None`, so decode rejects a spec-forbidden `null` and "omitted" stops
  aliasing "explicit null"; two runs, both altitudes — plan-review inside plan
  mode, diff-review after implementation + an xhigh code-review).

  *Plan run.* Fired: headline **3 + 1** — the `is None`→`is UNSET` swaps in
  `_resolve` and the missing-parameters check assume the five fields are never
  runtime-`None`, but `msgspec.Struct.__init__` doesn't type-check construction,
  so `None` stays *representable* though the annotation forbids it; a smuggled
  `None` skips the "absent" branch it used to hit (e.g. falls into the
  parameter-group validator, which expects a dict). Leverage from the trace: no
  consumer can *reach* the bad state except a mis-constructor, and strict
  mypy/basedpyright forbid every internal `None`-construction — so the finding is
  real-but-guarded, discharged by naming the invariant + its typecheck guarantor
  (do NOT write `is UNSET or is None`, which re-merges the two states the change
  exists to separate). **12** — the entire reject-`null` decision rests on "the
  spec forbids `null` here"; flagged as assert-from-memory, which forced an
  actual spec.md fetch (§6.4/§6.5: members typed object/string/array, inheritance
  on *absence*, `null` nowhere permitted) before the ADR could cite it. **16** —
  a present-empty `{}` must *suppress* inheritance (it is not absence); untested.
  **Drove:** the load-bearing-invariant callout + guarantor in the plan, the
  ADR's spec-citation requirement, and the `{}`-suppression test. **Affirmed:**
  11 (reject-`null` is tier-1 decode typing, not a `validate()` job — a `null`
  for an object-typed field is a field-*type* mismatch, the same class as
  `"parameters": 5`), 7 (reject over silently coercing `null`→absent).

  *Implementation confirmed the plan headline mechanically.* The totality (3)
  prediction was discharged not by hand-enumeration but by the *typechecker* —
  mypy named the missed consumers (`_validate_ranges`, `_member_domain_type_
  issues`) — and by the *corpus*: a "normalize at the boundary" fix
  (`parameters or None`) silently collapsed present-empty `{}`→`None`, defeating
  `range-without-parameter`; the negative fixture caught it, and the fix narrowed
  to `None if parameters is UNSET else parameters` (a **7** faithfulness save
  *inside* the normalization). A latent *wrong plan instruction* neither the plan
  nor the plan-review caught — "the `self.<field> is not None` guards can stay" —
  surfaced only at implementation, because `UNSET is not None` is `True` (an
  inverted-guard bug the type-checker can't see but reasoning did).

  *Diff run (after implementation + an xhigh code-review that returned clean).*
  Fired: headline **5 + 16** — the diff carries five UNSET-handling idioms
  (`is UNSET`, `X or None`, `None if is UNSET else X`, bare truthiness,
  `X or UNSET`), and two are *not* interchangeable: `_resolve`'s explicit
  `is UNSET` **cannot** be "simplified" to `if not coverage.parameters`, because
  a present empty `{}`/`()` is falsy yet is not absence — the swap silently
  reinstates the graft-on-empty bug the change exists to kill. Surfaced by
  probing the breaking edge (present-empty vs absent). **Drove:** a comment
  pinning why truthiness is wrong **and** promoting the `{}`-suppression test into
  a comprehensive, labeled *regression tripwire* (`parameters={}` *and*
  `parameter_groups=()`), verified to *fail* the instant `_resolve` uses
  truthiness. **Affirmed:** 11, 7, 6 (`effective_domain_type` as the projection
  that contains `UnsetType`, never leaking it to a `str | None` consumer), 13
  (xarray's `or UNSET` on construct / `or None` on read — a clean symmetric
  normalization pair).

  **New signals for the tightening pass:** (1) *"Make illegal states
  unrepresentable" (1) can be UNREACHABLE — and when it is, the strongest
  available guard is an enforcing test, not a comment.* Asked "can we guard the
  truthiness-regression more robustly than a comment?", the honest answer is a
  gradient — type-level (make `if not x` a type error) > test (fails on the
  regression) > comment (informs) — with the top rung *closed here* because
  `UnsetType.__bool__` is `False` (truthiness is type-clean) and the sentinel
  can't be swapped (msgspec needs `UNSET`). So the guard dropped to a *test*,
  which *enforces* where a comment only *informs*. Candidate Working-note: when
  sounding 1's ideal is unreachable, don't settle at a comment — reach for the
  test that pins the invariant. (2) *Not every idiom-repetition is a
  one-source-of-truth (5) violation.* The five UNSET idioms *looked* like a 5
  smell, and a unifying `_omitted()` predicate was considered — then **correctly
  declined**, because the variants encode *different decisions* (`or None`
  deliberately collapses `{}`; `None if is UNSET else x` preserves it), so a
  shared helper would *flatten* the load-bearing distinction. Refines 5:
  distinguish "the same knowledge in N places" (dedup) from "similar-looking
  idioms encoding different semantics" (pin with a test, don't merge). (3) *A
  totality (3) finding at plan altitude is discharged by the typechecker + tests,
  not by enumeration* — and the discharging step can itself introduce a
  faithfulness (7) regression (the `{}`-collapse) that only the corpus catches,
  so "normalize the retyped value at each boundary" is a move to audit per-site,
  not apply reflexively. (4) *Both-altitudes, the #14/#37 "distinct flaws"
  flavor, not #69's "confirmatory":* plan caught the invariant/citation/scope;
  diff caught the idiom-consistency/regression-guard — a genuinely different
  defect, so the diff-pass earned its keep. Wrinkle: the plan carried a *wrong*
  instruction the plan-review missed (the `is not None` guards), caught only when
  implementation forced the type-checker to speak — a reminder that plan-review
  judges the plan's *stated shape*, and some errors are only legible once code
  exists.

  **Candidate refinement (sounding 5), from signal (2).** Sounding 5 currently
  reads any repeated decision as a dedup target, but this run's *decline* shows a
  false-positive class it should name explicitly. Proposed **Boundary** line for
  5 (mirroring the Boundary line sounding 2 carries): *"Repetition of a **shape**
  is not automatically a 5 violation. Before extracting, ask whether the repeated
  sites encode the **same** decision or **different** ones: `parameters or None`
  (collapse empty→absent) and `None if x is UNSET else x` (preserve empty) look
  alike but decide oppositely on `{}`, so a shared helper would **flatten** that
  load-bearing distinction. Dedup 'the same knowledge in N places'; leave
  'similar-looking idioms encoding different semantics' alone, and pin each with a
  test. The tell: could one helper serve every site **without** a parameter that
  re-encodes the very difference? If not, it is not one source of truth — it is N
  sources wearing the same coat, and merging them hides a decision."* This also
  sharpens the split between 5 (genuine single-source) and the *guard* mechanism:
  where variation is intentional, the invariant is pinned by a **test** (signal 1's
  gradient), not by a helper. Merge-or-keep deferred to the combine pass; flag it
  next to the existing `[combine? with 6, 14]` marker on 5.

- **2026-07-11 — covjson-msgspec #21 documentation plan** (the contributor-docs /
  single-sourcing architecture: `CONTRIBUTING.md` as the crisp contributor
  one-stop, design tenets in `docs/design/tenets.md`, ADRs canonical for specific
  decisions, a slimmed `CLAUDE.md` spine that `@import`s the human files, the docs
  site for orientation / concepts / design narrative). **Plan altitude, and a
  first for this log: the reviewed artifact is a *documentation information
  architecture*, not code — a system of Markdown files and canonical homes.** The
  soundings transferred cleanly: "types" became "canonical files"; "make illegal
  states unrepresentable" became "don't let one fact have two canonical homes that
  can drift"; coupling / cohesion / right-tier / reversibility read straight
  across.

  **Headline — co-fire 12 + 8, and 12 turned on the review *itself*.** The whole
  design cantilevered off Claude Code's `@import`. Per sounding 12 ("verified
  against it and cited, never asserted from memory"), I *fetched the Claude Code
  memory docs before ranking findings* rather than assert `@import`'s behaviour —
  and the verification **changed the findings, it did not merely confirm them**.
  It (a) *dissolved* a wrongly-framed candidate headline (my first instinct,
  "moving conventions out of CLAUDE.md weakens their authority", was false:
  imported content loads with **equal** authority to inline), and (b) *surfaced
  the true headline, invisible until the mechanism was checked*: `@import` **loads
  the target in full and does not reduce context**, and the docs' own guidance is
  that **longer instructions reduce adherence**. So making a warm, human-verbose
  `CONTRIBUTING.md` the canonical file `CLAUDE.md` imports **trades agent
  adherence for human friendliness** — the two audiences pull opposite directions
  on the *same bytes* (a coupling / cohesion smell, 8/9: one artifact, two
  consumers, conflicting requirements). Concrete instance: today's
  `CLAUDE.md#conventions` is terse and specific; a human guide wraps each rule in
  welcome prose; `@import`ed wholesale it bloats the launch context. Failure
  scenario: `CONTRIBUTING.md` grows to a friendly ~400 lines, imported past the
  ~200-line adherence budget, and the agent follows the conventions *less*
  reliably than today — the single-source win silently costs enforcement, with
  nothing warning you.

  **The fix was co-produced with the reviewee.** My adherence-finding alone
  pointed at "just keep `CONTRIBUTING.md` crisp", which the user correctly
  countered *loses the deeper reasoning a human needs* (this repo's conventions
  already carry real rationale, e.g., the two-underscore private-module passage).
  The synthesis is the **two-layer split**: a **crisp layer** (one-line rule /
  principle-plus-implication tenet, `@import`ed, lean for adherence and scannable
  by humans) over a **deep layer** (the multi-paragraph "why", canonical in the
  rendered docs, *linked not imported*). Single-source per layer: the *rule* is
  stated once, the *reasoning* once, linked. Neither pole alone produced it.

  **Second finding — 5 applied unevenly.** The design single-sourced conventions /
  tenets fastidiously but left **orientation triplicated** (README + CLAUDE.md +
  docs) — its own core principle, unapplied to its most multi-homed content.
  *Sharpened while folding:* "orientation" was itself **three conflated things** —
  the *pitch* (→ README), the *code module map* (→ CONTRIBUTING.md), the
  *data-model concepts* (→ docs) — and only the act of assigning *one* canonical
  home forced the decomposition. **Third — 9/4, a fuzzy seam:** rules-vs-tenets has
  no decidable boundary ("build from small composable functions" is both),
  inviting the duplication the design fights; move = state the split test (a
  *tenet* explains why and is cited by the design docs; a *convention* is a
  do/don't a reviewer checks). **Parked — 5:** the install/extras matrix restates
  `pyproject.toml` (low leverage, named as a choice, not an oversight).
  **Affirmed:** **5** done right where it matters most — the API reference is
  *generated from the docstrings*, not restated; **15** — the whole thing is a
  two-way door (Markdown, `mv` + fix links), which *routed the "is three rounds of
  IA refinement over-care" question to ponytail-review by name* rather than
  manufacturing a plumb finding.

  **New signals for the tightening pass:**
  (1) **Plumb runs at non-code altitude.** A documentation / instruction-file
  architecture is squarely in scope; the soundings are about *structure and
  modeling of any knowledge-artifact system*, not code specifically. Candidate:
  sanction "docs / config / instruction architectures" explicitly, with the
  illegal-state analog spelled out ("one fact, two canonical homes that can
  drift").
  (2) **Sounding 12 can turn on the review itself, and the verification can
  *invert the ranking*, not just confirm a claim.** Checking `@import` dissolved a
  false top-finding and surfaced the real one that was invisible beforehand.
  Candidate Working-note: *when a design cantilevers off an external mechanism's
  behaviour, verify that mechanism before ranking; the verification is not
  due-diligence garnish — it can change what the headline is.* Strongest instance
  yet of "the largest wins come from an assumption left unverified".
  (3) **A finding's *resolution* can be co-produced with the reviewee**, and the
  synthesis beats either pole. The two-layer model came from the collision of the
  reviewer's adherence-concern and the reviewee's human-depth counter-concern.
  Mirrors the temporal run's "a park invites 'explain that'" provenance, one level
  up: here a *proposed fix* invited a counter-concern that *improved* it.
  Candidate Output note: a proposed fix (not only a park) is a legitimate
  reopening point; hold the fix loosely enough to let the reviewee's constraint
  reshape it.
  (4) **When a structural design's integrity rests on using a mechanism one
  specific way, that discipline is part of the design and must be stated.** The
  two-layer split *only holds* if deep-layer pointers are plain Markdown links
  (inert at launch), never `@path` (which recursively imports, up to four hops,
  reloading the deep layer). A syntactic rule ("@import vs link") became a
  first-class design constraint. Candidate: a structural finding may carry a
  *usage-discipline rider*; name it, don't leave it implicit.
  (5) **Applying a single-source (5) fix is itself a decomposition exercise:**
  "what is the *one* thing?" repeatedly reveals it was several (orientation →
  pitch / map / concepts surfaced only under the pressure of naming one home).

  **Pending diff pass.** Plan altitude only. The complementary diff run on the
  eventual docs PR should probe whether the disciplines survived implementation:
  did any deep-layer pointer accidentally use `@`; did `CONTRIBUTING.md` stay crisp
  under the ~200-line budget; did the rules-vs-tenets test get applied
  consistently. Expect the #14/#37 "distinct flaws" flavour (plan caught the
  architecture; diff would catch the discipline-drift).

- **2026-07-10/11 — zarr-python full structural audit** (review mode on a large
  **third-party / upstream** codebase — a *first* for this log; every prior entry
  is the wielder's own greenfield covjson-msgspec/titiler. 40k LOC, mature,
  multi-author, brownfield; multi-session, spanning released `main` @ `13279cac`
  (== upstream zarr-developers main, verified same SHA) plus two active PRs
  #3885/#4049). **The "judge against the ideal, not the incumbent; conforming to
  bad precedent is itself a finding" stance did the heavy lifting** — the keystone
  (an `ArrayV3Metadata` DTO that runs the codec pipeline and reaches into
  `ShardingCodec` via lazy import) is an *established, load-bearing* pattern a
  conform-to-the-codebase review passes; plumb flagged it, and the code's own TODO
  agreed.

  Fired (main): headline **8 + 9 + 17** (metadata DTO → concrete codec, coupling
  cycle papered by a lazy import + feature-envy); **13 + 12 cross-sibling** (the
  "great find", below); **5** (NaN-safe `__eq__`/`__hash__` copy-pasted across
  both metadata classes; a codec-parse function triplicated); **6 + 11 + 15**
  (rectilinear grid reads global config inside a frozen `__post_init__` on the
  read path, and mints an unreleased RLE wire format — a two-way door about to
  become one-way); **1 + 10** (`ConsolidatedMetadata` `frozen=True` but its dict
  is mutated in place). **indexing.py returned essentially "Plumb is true"** — the
  selection types are structural unions resolved by *nominal accessor dispatch*
  (`OIndex`/`VIndex`/`BlockIndex` + an `Indexer` protocol), the right shape for
  numpy's inherent value-type ambiguity; **declined to manufacture** a sum-type
  finding to fill the file.

  **Headline (G1) — co-fire 13 + 12, cross-sibling-against-spec.**
  `GroupMetadata.from_dict` lacks the v3 `must_understand` extra-fields handling
  that its sibling `ArrayV3Metadata.from_dict` has, so a spec-legal v3 group
  carrying a `must_understand:false` extension **crashes** (`TypeError`). Leverage
  from the downstream trace: external blast radius (any v3 group with an extension,
  written by *any* implementation, is unopenable here) atop a violated spec MUST —
  and it is **invisible reviewing either class alone**. Confirmed empirically
  (3-line repro → `TypeError`) and against upstream (same SHA). **Drove (into the
  work):** the finding + repro + fix (share the allowed-extra-fields logic across
  Array/Group metadata). **Affirmed:** dtype sum-types + boundary TypeGuards
  (1/2/4); `Array` as a pure sync shell over the async core (6); the error/warning
  taxonomy (2/12); and in PR #3885 the `chunk_utils` shared per-chunk compute core
  (5/6 done well — read/write *twins* parameterized by `decode`/`encode`
  callables, so sync/async can't drift), which moved plumb's yield *inward* to two
  seams (Finding A: `chunk_utils` leaf lazy-imports UP into the pipeline — 8;
  Finding B: the batch orchestrator branches `isinstance(pipeline, Fused…)` instead
  of taking an injected strategy the way its own per-chunk layer does — 8/9/3).

  **New signals for the tightening pass:**
  (1) **First third-party / brownfield-at-scale run — "judge against the ideal" is
  load-bearing here in a way greenfield can't exercise.** On greenfield the
  incumbent is usually absent; here the incumbent pattern often *is* the fault, and
  a self-flagging TODO is *corroboration*, not a reason to defer. Candidate:
  sanction external/brownfield audit explicitly in scope.
  (2) **A new co-fire shape: 13 × 12 across *sibling types*.** Prior 13 fired
  within one artifact (a decoder with no encoder; an asymmetric comparison). G1 is
  13 across two independently-written siblings diffed against a shared external
  authority (12). The reusable move: *when two types implement the same external
  rule, diff them against the rule, not just against each other* — the asymmetry is
  invisible per-class. Candidate 12↔13 cross-flag.
  (3) **Sounding 12 must bind the review's OWN substrate: pin the revision under
  review.** The run's real process failure — I asserted findings, then made a
  *wrong* hedge ("may not be upstream") because I had not pinned the exact
  branch/SHA. "Fork vs upstream" changes a finding's blast radius completely (G1 as
  a fork-only nit vs an upstream spec bug). Candidate Working-note: *a review
  finding is incomplete without the exact source revision it is against* — extend
  12's "cite the source, never assert from memory" from the spec to the **code
  under review**. Strongest actionable skill gap this audit produced.
  (4) **Check the tracker before ranking a finding "dead" / low-leverage.** A
  code-only scan flagged `ChunkTransform` as stranded/deletable; the issue tracker
  (#3720 roadmap, an 8-PR plan by a core maintainer) showed it is live, championed
  *foundation* awaiting its consumer PR — the "delete it" call was exactly
  backwards. Extends the "measure leverage by tracing to the consumer" Working note:
  on a codebase mid-migration the consumer may be a **future** one, visible only in
  the tracker. Leverage is a function of *trajectory*, not just current structure.
  (5) **"Contained" ≠ "right shape": a containment affirmation (6/8) can
  rubber-stamp a design whose *existence* is the question.** A first-pass verdict
  ("the sync bridge is a well-contained imperative shell") affirmed *local*
  containment while the real question was "should the sync path traverse the event
  loop at all" — the user's push, then a microbenchmark (24.6× / ~171µs pure
  overhead), reframed it; then 12-verify (the maintainer's own PR had measured the
  same thing) reframed *again* from "critique" to "correct problem, already
  championed." Candidate nuance on 6: distinguish "the effect is contained" (local,
  affirmable) from "should this effect be on this path at all" (architectural) — a
  clean containment verdict is not a clean architecture verdict.

  **Pending.** Whole audit delivered in chat only (no report file/artifact); the
  upstream issue/PR for G1 not yet filed. Provenance rider for any future pass:
  main-branch findings are @ `13279cac`; the #3885/#4049 verdicts (Finding A/B line
  numbers) are against PR-head branches and will drift.

- **2026-07-12 — covjson-msgspec #74 value-screen + #18 benchmark continuation**
  (a full working session under **ponytail mode**, plumb *never invoked* — the
  log's first entry where soundings fired **organically, on live design
  decisions**, not in a `/plumb` run. Continues the 2026-07-10 #18 artifact entry.)

  *Design-decision 1 — reject the `Raw` alternative (2 + 6 + 7).* User proposed
  typing `NdArray.values` as `msgspec.Raw` + deferred narrow-decode to push the
  value-type check to C. Works mechanically, wrong shape: a narrow typed-decode
  **raises** where `validate()` is an errors-as-values issue stream (2, and 6's
  "raise confined to the edge"), stopping at the first bad element — defeats
  validate's "report every mismatch with a pointer" contract *and* #74's own
  "identical Issue output" acceptance criterion; and it drags strictness **into
  decode**, breaking permissive/byte-faithful load (7, ADR-0002). Leverage from
  the downstream trace (the contract + the acceptance test), not the mechanism.
  **Affirmed the actual design:** the `msgspec.convert` screen as a fast *path*
  with the per-element scan as fallback keeps the issue stream identical, earning
  the C-speed win without touching the contract.

  *Design-decision 2 — `values_as()` shape (4 + 6, + 5/7).* "Does the screen give
  typed accessors for free?" The same convert primitive yields the narrowed tuple,
  so a `values_as(dtype)` projection is ~free — **but** the narrowing must come
  from a caller type via `@overload`, else the return is a useless 3-way union (4);
  it raises, distinct from validate's stream (6/2); faithful union stays stored,
  precision is an opt-in *view* (5/7 = the "typed projection over a faithful core"
  tenet, ADR-0004). Filed #89.

  *Benchmark artifact — circularity (5 + 6).* `run.py` hard-coded conclusions about
  its own output ("grid-large stays slower") — a one-source/circular smell specific
  to *generated* artifacts: the doc argues against its own numbers the moment they
  change. Drove the template/data split (pure data-gen → `results.json`; authored
  prose in `results.template.md`; number-dependent interpretation in README, not the
  generator) + a compliance-parity layer. Also **5 + 9** — split README (methodology)
  from results.md (reading), one canonical home per audience (echoes the #21 IA entry).

  **New signals for the tightening pass:**
  (1) **Plumb fires organically, on a design *decision*, no invocation, under a
  competing mode.** Two instances (Raw-reject, values_as-shape) from latent triggers
  ("would that let us…?", "…for free?"). The structural lens self-selected over
  ponytail/code-review — confirmed from outside, user never named plumb. Candidate:
  recognize "would X work / does this give us Y for free / better ergonomics for Z"
  as design-review triggers.
  (2) **A project's locked tenets ARE soundings instantiated, and one tenet decides
  multiple proposals.** "Faithful core, precision as opt-in projection" (4/5/6/7) was
  load-bearing in *both* the Raw-reject and the values_as-shape. When a repo has
  written its tenets down (ADR-0002/0004, tenets.md), plumb's job is largely "check
  this proposal against them," and their leverage is that a violation defeats a
  *documented* contract — maximally citeable (12-adjacent).
  (3) **Circularity as a generated-artifact (5) smell:** a generator asserting
  conclusions about its own output. Fix = separate deterministic data-gen from
  authored interpretation. Extends the 2026-07-10 #18 signal 5 ("render from one
  structure so they can't drift") one level up: single-source the *claims*, not just
  the data, and keep them out of the generator.
  (4) **Same-artifact re-touch across sessions:** the #18 benchmark came back and was
  driven much harder. A logged artifact isn't "done"; a later session can raise its bar.

- **2026-07-12 — covjson-msgspec #92 JSON-Pointer deferral (two `/plumb` passes:
  plan, then diff — the first entry where the "run at both altitudes" working note
  is exercised end to end on one feature)**

  Context: `validate()` built a JSON Pointer string at every node of its tree walk
  (threaded a pre-joined `path: str` down through every check), when a pointer is
  only needed at `Issue` emit — profiled at ~44% of a conformant call. The fix
  defers materialization: thread a component tuple, join only at emit.

  *Plan pass (5 + 10, with 7-in-docs).* Headline: the proposed root representation
  `("",)` (an empty-string first element so `"/".join` reproduces the leading
  slash) **splits the RFC 6901 format between `_ptr` and a root-seed convention
  every caller and doctest must know** — the leading slash lives in the sentinel,
  the separators in `_ptr`. One-source-of-truth move: root `()`, and `_ptr` owns
  the whole format (`"".join(f"/{esc(t)}"…)`). The trace that set leverage: the
  sentinel was chosen to preserve "byte-identical doctest output," but the only
  outputs that differ between the two models are ~25 `#/…` doctests illustrating a
  shape real `validate()` (seeded `""` → `/…`) **never emits** — Model A was
  protecting a *fiction* (7 applied to examples, not the data model). Also
  clarified, off-sounding, that deferral **subsumes** the micro-opt on the hot
  path (post-defer `_ptr` runs only at emit), so they're one issue at two ambition
  levels, not alternatives. User folded Model B in before approving.

  *Diff pass (affirm 5/10; new 1; park 5).* The plan fix landed — `_ptr` owns the
  format, verified against the built hunks. The **new** finding was a bonus the
  plan pass didn't claim: choosing `()` over `("",)` didn't just centralize the
  format (5), it **retired the one place an empty-string token was mandatory**, so
  a mid-path empty reference token (`(*path, "", …)` → a stray `//`) is now
  **unrepresentable by construction (1)** — a *higher* sounding than the plan
  pass's headline, visible only once built. Parked (5): `(*path, "coverages", i)`
  is computed twice, 3 lines apart, in `_validate_collection` — but it can't drift
  (identical literal tuple-builds, not a derived decision) and the "fix" (bind a
  `member_path` local) fights the language, since it lives inside a
  `chain(…) for … in enumerate(…)` genexpr that can't bind a local without
  unrolling into something clunkier; the fix is uglier than the smell. **Verdict:
  Plumb is true.**

  **Drove:** the entire implementation followed the plan-pass fix (root `()`,
  `_ptr`-owns-format, `_escape` leaf). Byte-identical real output (differential
  across 99 corpus files), `validate()` 2.0×, `validate(check_values)` 1.6×, the
  temporal `coverage-collection` `validate(values)` rung flipped 0.8× loss → 1.3×
  win. **Affirmed:** the deferral itself as functional-core (6) — compute
  components inward, perform the join at the edge. Merged as PR #93.

  **New signals for the tightening pass:**
  (1) **Two-altitude run, novel shape: the diff pass's headline was a *higher*
  sounding than the plan pass's, and it was a bonus the plan fix produced without
  claiming.** Plan headline = 5/10 (where the format-truth lives); diff headline =
  1 (the chosen representation *also* made an illegal state unrepresentable). This
  is the cleanest instance yet of the "both altitudes catch different flaws" note,
  and refines it: the diff pass isn't only "did the fix land + what did writing it
  expose" — it can find that a plan-pass fix has a *structural dividend* at a
  sounding the plan never reasoned about. Candidate Working-note: on the diff pass,
  re-rank the plan fix against *all* soundings, not just the one that motivated it.
  (2) **The `("",)`-style sentinel is a recurring anti-pattern that fails 5 *and*
  1 at once, and one representation choice (`()`) fixes both.** A magic in-band
  root value both splits the format rule (5) and keeps a meaningless token
  (`""`) representable mid-sequence (1). Candidate: name "in-band sentinel for an
  empty/root case" as a co-fire 5×1 smell, with "make root the genuinely-empty
  container + let the operation own the boundary syntax" as the standard move.
  (3) **Faithfulness (7) has a surface plumb hadn't logged: examples/doctests, not
  the stored model.** The `#/…` doctests reproduced a pointer shape the code never
  emits; a data-model fix (root `()`) forced correcting them to `/…`. Candidate:
  extend 7's reach explicitly to "a runnable example reproduces *real* output" —
  an unfaithful example is a faithfulness defect even when the model is faithful.
  (4) **A park whose fix fights the language is a clean park.** The duplicated
  `(*path, "coverages", i)` — DRY says extract, but a Python genexpr can't bind a
  local, so the extraction costs a clean comprehension for a no-drift, no-value
  win. Sharpens the note-and-park test: weigh the fix's *own* structural cost, not
  just risk — a fix that trades a good shape for a DRY nit is worse than the nit.

- **2026-07-13 — covjson-msgspec #94 temporal `resolve()` dispatch** (two `/plumb`
  passes, plan then diff; a perf-track continuation after #74/#92, and the first
  entry where a plan-pass 5 finding's fix is to build *less*).

  Context: profiling `validate()` after #74 (value screen) and #92 (`_ptr`
  deferral) landed surfaced `resolve()` (temporal.py) as the dominant temporal
  cost. The datetime form, the common case, sat *last* in an ordered five-pattern
  chain, so every value ran 5 regex `fullmatch`es before matching. A companion
  micro-opt swaps `\d` for `[0-9]` and drops `re.ASCII` (measured ~7-9% on the
  datetime `fullmatch`).

  *Plan pass (headline 5 + 15; affirm 16; contingent 4).* The plan proposed a
  full sign/`T`/length dispatch (branch on `+/-`, then `"T"`, then `len ==
  4/7/10`), routing each form to one regex. Headline **5**: the dispatch's length
  literals `4`/`7`/`10` restate the digit-count signature the compiled patterns
  already own (`_YEAR = [0-9]{4}`, etc.), a second home for each form's shape; the
  plan's "disjoint signatures" argument proved the two homes *consistent* without
  noticing they were *two*. The interesting part of the trace: I first leaned
  "over-built," then tempered it by tracing the reduced-form win more carefully.
  The datetime form (last in the chain, 5→1) is the whole measured gain, but
  `date→1` (from 4) and `month→1` (from 3) are *real* for date-only / month-only
  **bulk** axes, an unshown-but-plausible workload. So the finding landed not as
  "it's wrong" but as a graded trade: the length branches buy a workload-gated win
  at the cost of three pattern-coupled literals, so take the one unambiguous
  high-value discriminator now and defer the rest. **Drove the design:** reshape
  to a single `"T" in value` fast-path guard (one *semantic* discriminator, "has a
  time component," not a restated digit count), leaving the reduced chain
  untouched with its dead `_DATETIME` arm removed; **defer the reduced-form length
  dispatch behind a measurement** (co-fire **15**, two-way door) until a
  date/month bulk workload is shown. **16** fired affirmingly: I probed the
  disjoint-signature claim with the *legal* inputs that would break it (a Unicode
  minus `−` U+2212, a space separator, a lowercase `t`), and it held, because
  `[+-]` and the literal `T` are ASCII/uppercase-only, so each still routes to
  `Malformed` identically. **4** (contingent): the plan's `_year_result` helper
  was typed `TemporalResult` yet never returns `Malformed` (only `Moment |
  Unrepresentable`); moot once the guard shape dropped the helper. The
  `[0-9]`/drop-`re.ASCII` swap is **Plumb-is-true and slightly improves 5**:
  retiring the flag moves the ASCII intent *into* the pattern rather than
  splitting it between pattern and flag (a private, two-way-door representation
  change, 15).

  *Diff pass (verdict: Plumb is true).* The implementation is faithful to the
  plumbed plan: the `"T"` guard is the sole discriminator, no `len == 4/7/10`
  crept back, the reduced chain is behavior-identical, and a 20,128-string
  equivalence fuzz confirms byte-identical output. One **4**-legibility **park**:
  the year branch's user-requested walrus (`1 <= (year := int(value)) <= 9999`)
  binds `year` on the condition line but *uses* it one line above in the ternary's
  then-arm, reading use-before-definition (correct at runtime, since the condition
  evaluates first). Parked because it was in the **approved plan** (the user asked
  for walrus where sensible) and is idiomatic: a deliberate wash, the one spot
  where the walrus is neutral rather than a win, named so it stays a conscious
  call. Routed to code-review by name: a pre-existing year-truthiness vs
  date-`is not None` inconsistency the diff didn't introduce.

  **Drove:** the whole implementation followed the plan-pass reshape (guard, not
  full dispatch). Byte-identical output; the temporal `validate(values)+datetime`
  rungs dropped 6-11% (resolve micro-bench 2.88 → 1.42 us/value), non-temporal
  cells flat. Committed; PR #96.

  **New signals for the tightening pass:**
  (1) **A one-source-of-truth (5) finding whose fix is to build *less*, co-firing
  with reversibility (15).** Nearly every prior 5 headline drove *extraction* (add
  a shared home: `_ROOT_TYPES = get_args`, lift `coordinate_systems`,
  render-from-one-structure). Here 5 fired against a duplication a plan was *about
  to introduce*, and the fix was subtractive: don't create the second home, take
  the one semantic discriminator, defer the rest. Candidate Working-note: 5
  applies to duplication a plan is about to add, not only existing drift, and its
  move can be "build the smaller shape" rather than a dedup; when the duplicated
  half buys only a workload-gated win, 5 co-fires with 15 (defer it), and the
  leverage line is "don't pay a permanent structural cost for an unproven win."
  (2) **A leverage estimate that *tempered* under tracing, not sharpened.** The
  first read ("full dispatch is over-built") softened once I traced the
  reduced-form win concretely (date 4→1 is genuine for date-only bulk). Most log
  entries show the trace *promoting* a nit to a headline; this one shows it
  *demoting* a headline to a conscious trade. The inverse of the usual note:
  tracing to the consumer can reveal the flagged thing is *more* defensible than
  the first read, and the honest output is then a graded trade ("decide
  consciously; defer"), not a verdict.
  (3) **Third confirmatory-diff instance (after #69, #44 commit 1): a thorough
  plan-pass makes the diff-pass "Plumb is true."** Contrast #92, whose diff-pass
  found a *higher* bonus sounding. Emerging pattern: when the plan-pass reshape is
  a *removal* (build less), the diff-pass tends confirmatory, since there is less
  new structure to grow a dividend or a drift; when it is an *addition* (a new
  representation, like #92's `()` root), the diff-pass can find a structural
  dividend. Worth watching whether "subtractive plan fix → confirmatory diff"
  holds.
  (4) **A user-accepted style instruction can mint a park the diff-pass should
  name, not swallow.** The "walrus where sensible" request produced one
  inverted-read spot; the diff-pass neither manufactured a fix nor passed
  silently: it parked it, with "it was in the approved plan" as the park
  rationale. Candidate: a stylistic choice ratified during planning is a
  legitimate park subject at diff altitude, and its provenance (approved-in-plan,
  user-requested) is itself the cost-vs-risk line.

- **2026-07-13 — covjson-msgspec #90 resolve-each-temporal-axis-once** (diff
  altitude only; the plan was a parked, pre-designed plan from a prior session,
  not re-plumbed this session, so no both-altitudes pair). **Headline: a plumb
  MISS, caught by a later code-review.**

  Context: `validate(check_values=True)` resolved every temporal string twice per
  domain; the fix threads a once-resolved map to both value-scans and factors the
  monotonic policy into a single `_default_break`.

  *Diff pass (verdict at the time: "Plumb is true").* Affirmed 5 (`_default_break`
  is the single policy home the plan set out to build), 6 (thread resolved *data*,
  not a memoized callable: functional core), 3 (totality via the exhaustive
  `_ordering_kind`), 16 (breaking edge: the `coord in domain.axes` short-circuit
  guard, the `results is None` inline-resolve fallback), 7 (raw strings stay on
  the model). Noted a bonus 5/efficiency dividend (the change collapses two
  per-domain `referencing` scans into one) and a dropped-unused-`domain`-param
  cleanup. Byte-identical output verified over 44 corpus files + a mixed
  collection.

  **The miss (the signal).** A subsequent code-review (reuse angle, xhigh) found a
  **5** the plumb diff pass did not: `_resolved_temporal_axes` re-implemented the
  "standard-calendar temporal system" predicate (`isinstance(system, TemporalRS)
  and is_standard_calendar(system)`) that `_ordering_kind` already owns, a rule
  with a fresh second home, exactly plumb's 5 smell ("a rule with several homes
  that can drift"). The fix is plumb's 5 move verbatim: `_ordering_kind(system) ==
  "temporal"`. Failure it guards: add a new orderable temporal system to
  `_ordering_kind` and `_resolved_temporal_axes` silently stops pre-resolving it,
  losing the dedup: a silent perf drift no test catches. Why plumb missed it: the
  diff pass anchored on "did the plan's 5 fix LAND?" (yes, `_default_break` is the
  single home) and did not independently sweep the NEW code for FRESH 5 debt the
  implementation introduced.

  **New signals for the tightening pass:**
  (1) **A diff pass can MISS structural debt, not only find dividends: the inverse
  of #92's signal.** #92's diff pass found a *higher* sounding as a bonus
  dividend; #90's diff pass MISSED a co-located instance of the SAME sounding it
  was affirming. Refines the "re-rank the plan fix against all soundings" note:
  the diff pass must sweep the new code for fresh violations *per sounding*, not
  stop at "the headline fix is in." Candidate Working-note: AFFIRMING a sounding
  landed is the cue to hunt that same sounding's OTHER instances in the diff, not
  to close it out. "The 5 fix landed" and "the diff introduces a new 5" are
  independent.
  (2) **"Plumb is true" from a diff pass is not self-certifying: a parallel
  code-review reuse angle found a 5 plumb owns.** 5 is plumb's turf, yet
  code-review's *reuse* angle covers the same ground and here caught what plumb
  missed (redundant coverage that paid off). Sharpen 5's smell list to name the
  shape missed: **a predicate / classifier re-implemented inline in a new helper
  instead of calling the existing one** (not just "the same constant in three
  files"). The tell: a new `isinstance(...) and foo(...)` chain duplicating an
  existing total classifier.
  (3) **Diff-only (no plan pass) correlates with the miss.** #90's parked plan was
  not re-plumbed this session, so there was no plan-altitude pass to catch the
  predicate choice before code. Weak evidence, but consistent with "the two
  altitudes catch different things": skipping the plan pass removed one of the two
  nets.

  **Skill-partition note (clean).** Ponytail-review and code-review both flagged
  the `_temporal_keys` single-caller wrapper (a simplification); the plumb diff
  pass correctly did NOT, since that is a granularity / ponytail concern, not a
  modeling one, so plumb stayed in its lane there. The miss was specifically a 5,
  which plumb DOES own: the partition held everywhere except the one 5 plumb
  should have caught.

- **2026-07-13 — covjson-msgspec benchmarking (#97 / #99) — not a review run; one
  method signal.** No review-mode run this session (benchmark-cell instrumentation,
  profiling, and issue drafting; no design review). Signal worth keeping: **#99**
  (native-parse `resolve()`'s datetime form via msgspec's C decoder) pre-registers
  a **differential test locking msgspec's accepted-form space to the ADR-0008
  contract** as an explicit *acceptance criterion* — msgspec accepts a naive
  datetime and a lowercase `z` that our spec form rejects, so borrowing its parser
  silently widens what we accept unless pinned. That is **sounding 16 (hunt the
  breaking edge) / the differential-twin method** — the same method behind this
  log's first headline (2026-07-07 year-0000 mislabel, numbered "15" pre-renumber)
  — now applied **prospectively, written into the issue before code exists**.
  Extends the #14-plan signal ("plumb-on-a-plan caught a flaw before code"): there
  plumb-as-reviewer caught it; here the method is baked into how the issue is
  *specified*, not a review finding. **Bears on the tightening pass:** consider
  naming an explicit move — *when a plan / issue borrows an external primitive,
  pre-register the breaking-edge (a differential test pinning the borrowed
  contract) as an AC* — i.e., sounding 16 as a design-time output, not only a
  review-time finding. **Secondary (not novel):** the #74 rescope reconfirmed
  entry-1's "trace to the real source before pronouncing" — a glib "close it" was
  corrected only by reading the two distinct scans (value-vs-`dataType`, done in C
  by #91, vs the still-pure-Python monotonic walk).

- **2026-07-13 — titiler-covjson #41 sub-pixel-thin bbox reject** (two `/plumb`
  passes, plan + diff, both read "true"; a later `/code-review` caught a
  mainstream ship-blocker both affirmed past — the log's first *both-altitudes*
  plumb miss, and a second same-day plumb-miss-caught-by-code-review after #90).

  Context: `/bbox` rejected a box thinner than half a pixel on the same-CRS path
  but silently served it as a degenerate 1-px strip when the read reprojects
  (`get_vrt_transform` floors the window to a 1-px minimum). Fix: recover the
  pre-floor size and reject on both paths — the recovery called
  `calculate_default_transform` with the **unclamped** dataset bounds.

  *Plan pass (5 headline).* Flagged the reject and the sizing deriving the
  reprojected resolution from **two computations that can diverge**
  (`calculate_default_transform` vs `get_vrt_transform`, which clamps
  WGS84→WebMercator to ±85.06° first). "Resolved" it with a gate (recover only
  when an axis floored to 1) and **parked the residual as "bounded,
  safe-direction, confined to floored-to-1 boxes at extreme latitude."**

  *Diff pass (affirm 5/6; new 16).* Affirmed the shape; 16 fired and found a real
  test-gap (the serve side of the discrimination boundary) — but the *convenient*
  edge, not the load-bearing one. Verdict: essentially "Plumb is true."

  *The miss (independent code-review correctness finder, single vote).* The
  divergence is **not** latitude-bounded. `calculate_default_transform` returns a
  **dataset-wide** resolution; for a global WGS84 raster it is ~8× coarser than
  the clamped resolution `get_vrt_transform` actually uses, and that one wrong
  number is applied to **every** box — so an ordinary narrow **equatorial** read
  of any global dataset in WebMercator gets a false 400. Confirmed end to end
  (0.25° global dataset, 40 km equatorial box → 400 where `part` serves 1×56).
  Refixed to measure on the **source pixel grid** (uniform at every latitude),
  which is what "half a **source** pixel" meant all along.

  **New signals for the tightening pass:**
  (1) **5 × 16 co-fire: 16 is how you *discharge* a 5-divergence, and skipping
  its *execution* is the false-negative.** When 5 flags a value derived two ways
  that can diverge, the rank comes from **constructing the input that maximizes
  the divergence and running it.** I *named* the clamp assumption in both passes
  and argued it "bounded/negligible" — that is naming the edge, not hunting it. A
  parked "bounded / safe-direction" verdict on a 5-divergence is itself the
  trigger to build the maximizing input. Candidate Working-note: a
  "bounded/negligible" park is un-earned until that input has been run.
  (2) **Trace what a value *is*, not just where it flows.** The consumer-trace on
  5 stopped at "where it's used" (the guard) → "floored-to-1 boxes at extreme
  latitude." The real trace was into what the value *denotes*: a **dataset-wide
  average** posing as a **local** resolution — that category error is the whole
  bug, and re-ranks the finding from park to load-bearing. Extends "measure
  leverage by tracing to the consumer" with *what quantity the value represents*.
  (3) **16 can fire, find *an* edge, and still miss the *load-bearing* edge.**
  The diff pass caught the discrimination-boundary test-gap (a real add) but not
  the global-dataset edge that attacks the design's stated assumption. Prefer the
  edge that breaks the assumption the design *rests on* over an adjacent untested
  branch — the tell is an assumption written into a comment ("acceptable for a
  degenerate-input guard"), a standing 16 target until an input has tried it.
  (4) **Self-authored design defeats *reasoned* soundings; only a *run* survives
  confirmation bias.** Two plumb passes + a separate design stress-test all
  rationalized the same false "clamp is negligible" claim because the reviewer
  authored it; one adversarial finder that *built the global dataset* refuted it.
  When the reviewer is the author/champion, 16's "construct and run" is
  mandatory, not optional. Sharpens the zarr-audit "'contained' ≠ 'right shape'"
  signal: there the affirmation was local containment, here "the divergence is
  bounded," and in both only an *execution* refuted the reasoned affirmation.

  **Pairs with #90 (same day) — two plumb-miss-caught-by-code-review entries,
  different mechanisms.** #90 missed a *fresh* 5 the diff introduced (it did not
  sweep the new code per-sounding); this missed a *pre-existing* 16 that both
  altitudes *named* and neither *ran*. Synthesis: a pass closes a sounding by
  **argument** — "the fix landed" (#90), "the edge is bounded" (this) — when the
  real discharge is an **action**: sweep the new code (#90), or construct and run
  the breaking input (this). "Affirmed" is not "closed."

  **Boundary note (scope, clean).** The false-reject *is* a correctness bug,
  which plumb defers to code-review — so this is not "plumb should have owned the
  fix." The narrower signal: 5 correctly named the exact seam and 16 was the
  right sounding to rank it, but 16 was applied by *argument* instead of
  *execution*. The gap is depth-of-discharge on a co-fire plumb already surfaced,
  not a missing sounding.

- **2026-07-13 (later) — covjson-msgspec #99: plumb on the plan, then the run that
  discharged it.** Extends the same-day "#97/#99 method signal" entry (which predated
  the review). **Headline: the positive instance of the #90 / titiler-#41 lesson —
  16 discharged by *execution*, not argument.** Those two logged a 16 *named but not
  run* (a miss); here the plan-review's 16 findings were **constructed and run**, and
  execution immediately caught what reasoning had only flagged.

  **Plan altitude (review on the plan) — fired 5 (headline), 16, 4.**
  - **5 — the spec tz rule gets a second home.** `_has_spec_timezone`'s positional
    check (`value[-6] in "+-" and value[-3] == ":"`) re-encodes the `_DATETIME` regex
    tail (`(?:Z|[+-][0-9]{2}:[0-9]{2})`). Trace: a later edit to the offset grammar
    touches `_DATETIME` (fallback + oracle) but not the guard; the fast path silently
    diverges. **Why not the obvious fix:** single-sourcing via a hot-path
    `_SPEC_TZ.search` puts a regex back on the path #99 exists to remove, ~halving the
    win. Proportional (12) resolution: keep the duplication but make it *deliberate and
    enforced* (a comment binding the guard to `_DATETIME`'s tail; the fuzz differential
    as the CI-enforced sync). **New 5-Move signal (tightening pass):** under a perf
    constraint, 5 resolves to "deliberate duplication + an enforced differential test,"
    not the reflexive "extract to one home" — single-sourcing is wrong when the single
    source taxes the hot path.
  - **16 — the fuzz differential only bites on msgspec-*accepted* inputs** (rejects
    fall back and equal the oracle by construction; a junk generator passes vacuously).
    Drove: bias the generator to valid skeletons across the whole tz-designator axis,
    and assert a `Moment` floor.
  - **4 — `_resolve_datetime_strict` implies the fast path is looser** (both enforce
    the same form; they differ in mechanism). Renamed `_resolve_datetime_form`.
  - **Affirmed 12** (keep-strict grounded by *fetching* CoverageJSON §5.2 verbatim, not
    memory: it writes `+|-HH:MM`, colon included, so `+0500` → Malformed is faithful;
    SHOULD → warning); **2 / 7** (union + raw-string faithfulness untouched; a speedup
    behind a behavior-preserving oracle).

  **Run altitude — 16 discharged by execution paid off twice (why this entry matters).**
  - **The fuzz-vacuity finding was prophetic.** Building the generator, the differential
    *immediately* caught a real generator bug: a non-`T` junk string (`"0339"`) reached
    the oracle, which only classifies `T`-strings. The abstract plan-finding became a
    caught bug within minutes — because the test was *run*, not reasoned about.
  - **The breaking edge surfaced a genuine behavior divergence.** A parity spot-check
    (differential twins, the 16 method) found msgspec *rounds* a sub-microsecond
    fractional second where `fromisoformat` *truncated* — a real change the plan's "no
    behavior change" claim had missed. Found by running twins; resolved proportionally
    (accept + document + pin) and surfaced to the user.
  - **A quantitative claim, unverified until run (12 extended to a measurement source).**
    The plan asserted "~3-4x"; the micro-bench corrected it to ~1.5x (it compared *raw*
    `convert` to *wrapped* `resolve`). 12's "verify the claim against its source" holds
    for a *number* too.

  **Synthesis with #90 / #41.** Those: 16 *affirmed by argument* → miss. This: 16
  *discharged by execution* → catch. Same-day confirmation that "'Affirmed' is not
  'closed'; the discharge is an action" — stated there from misses, shown here from the
  win when the action was taken. Reviewer was again the author (self-authored plan,
  self-run review), so it also confirms #41's "only a run survives confirmation bias":
  the reasoned review affirmed the fuzz/guard; the *execution* caught the holes.

- **2026-07-14 — covjson-msgspec #62: plumb reframed an ADR's *argument*, and the
  run falsified a subagent's code-read.** Plumb-on-plan then implementation, same
  shape as the #99 entry above, but two new signals. Issue #62 ("route the export
  bridges' temporal classification through `resolve` for one classifier of
  record") was settled as decide-not-refactor, recorded in ADR-0015.

  **Plan altitude — fired 5 (headline, *inverted*), 3/16, 12.**
  - **5 — the headline was the ADR's argument structure, not code.** The plan
    concluded "don't route," arguing it as "we *declined* to consolidate" (three
    costs: calendar-blindness, naive→`Malformed` output change, vectorization).
    5 fired not as "duplication exists, extract it" but as its inverse: the three
    parsers (`resolve`, `maybe_datetime`, `_parse_times`) have different
    **codomains** (`Moment|Unrepresentable|Malformed` vs `DatetimeIndex|strings`
    vs `datetime64|cftime`) — there is *nothing* to unify; the "triplication" is
    surface similarity ("string in, time out"). Leverage came from the deliverable
    being an **ADR**: "we chose not to consolidate (cost)" is re-litigable ("but
    consistency!"); "these are different functions (structural fact)" closes it,
    and demotes the three costs to *consequences* of the codomain mismatch. **New
    5 signal (tightening pass):** the "apparent duplication" family now has THREE
    resolutions — (i) real dup → extract to one home; (ii) real dup taxing a hot
    path → deliberate dup + enforced differential test (the #99 entry, same repo,
    one day earlier); (iii) **not dup, different codomains → don't unify, and make
    the design doc argue from the codomain root, not a cost tradeoff.** Plumb run
    on the *argument*, not just the code.
  - **3/16 — the decision was enforced only in prose** (ADR + a code comment). A
    deliberate divergence (the bridges parse a naive no-`Z` time that `resolve`
    rejects) with no test is a "hoped-for edit." Move: promote a
    divergence-pinning test from "optional" to *required* (a change that makes a
    bridge reject naive input must trip it). **This finding built the instrument
    the run then used** (below) — the plan-finding and the run-catch are causally
    linked.
  - **12 — "confined to non-spec input" asserted from memory.** Gated the ADR
    claim on *fetching* CoverageJSON §5.2 (same discipline as #99). The fetch
    (datetime form is `Z` **or** `±HH:MM`) both made the claim faithful *and*
    **discharged a suspected finding with NO finding**: `_has_spec_timezone`
    accepting offsets is spec-*correct*, not over-lenient. **New 12 signal: verify
    can close a suspected finding, not only sharpen a real one.**

  **Run altitude — 16 by execution, third instance, *new provenance*.**
  - **A subagent's code-read was falsified by running the promoted test.** An
    Explore agent, reading `with suppress(ValueError, OverflowError):
    np.array(..., "datetime64[ns]")`, *asserted* "out-of-range → raises → cftime
    fallback." Running the 3/16-promoted test showed numpy int64-overflow-**wraps**
    instead of raising (`2300-01-15` → `1715-06-27`, numpy#9956): the suppress
    catches nothing, the fallback is dead for standard-calendar out-of-range
    dates, and the bridge silently corrupts them. Filed as its own issue (#109);
    the ADR consequence was corrected from a reasoned-but-wrong "offset-drop"
    guess to the verified wrap. **Extends the "only a run survives confirmation
    bias" note (#41 / #90 / #99):** the false claim came not from the author's
    reasoning but from an authoritative-sounding **subagent code-trace**. A
    code-reading, however careful, is still reasoning until run.
  - **12 extended to a number, again.** The issue's own framing ("dedup the
    ~287µs `validate`→`to_datetime` double-parse") was falsified by tracing the
    code: `validate` never double-parses; the 287µs is an API-*composition*
    artifact. Verify-the-claim held for a *remembered quantitative premise* too
    (cf. #99's ~3-4x → 1.5x).

  **Synthesis.** #99 logged 5-under-perf → deliberate-dup-plus-test, and
  16-discharged-by-execution. #62 adds the two inverses: 5 can resolve to "*not*
  duplication — argue the design doc from the structural root," and
  16-by-execution catches a **subagent's** false code-read, not only the author's
  bias. Reviewer was again the author (self-run), so #41's "only a run survives
  confirmation bias" holds a third time — here against a delegated trace, the most
  authoritative-feeling form of reasoning.

- **2026-07-14 — first landing off the consolidated signal ledger (not a review
  run).** Built **[TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md)**, a deduplicated
  harvest of every "New signals for the tightening pass" scattered across this log
  (Section A = land-ready operating rules ranked by leverage; B = combine dossier,
  assembled not executed; F = recommended landing order). Then landed the top of that
  order — the refinements that change *notes*, not the sounding count. **The 19→~10–12
  combine stays deferred** per REFINEMENT.md's "let usage drive, not armchair debate";
  this ledger is its input, not its trigger.
  - **A1 — "'Affirmed' is not 'closed'; discharge is an action, not an argument."**
    Sharpened sounding **16**'s Move to demand *construct and run* the breaking input
    ("a 'bounded/negligible' verdict is un-earned until that input has actually run"),
    and added a Working note generalizing it: affirming a sounding *landed* is the cue
    to hunt its *other* instances, not close it out; when the reviewer authored the
    design, running the edge is mandatory (only a run survives confirmation bias — a
    careful code-read, even a subagent's, is still reasoning until run). Drawn from the
    only two misses in this log (#90 swept-nothing, #41 named-not-run) and their
    positive inverses (#99, #62, discharged-by-execution) — the sharpest signal the
    harvest surfaced, and the one that closes the miss class.
  - **A4 — sounding 5 Boundary line.** Added the #77-drafted Boundary ("similar-looking
    idioms encoding *different* decisions are not a 5 violation; pin with a test, don't
    merge"), **generalized off its covjson-specific `UNSET`/`parameters or None` example**
    to keep the skill repo-agnostic (per REFINEMENT.md's "plumb is general, not
    covjson-specific"). The insight is verbatim; only the illustration changed.
  - **E1/E2 — doc fixes.** Deleted SKILL.md's stale "one-word swap if you prefer
    `gauges`" line (REFINEMENT.md locks *soundings*, rejects "gauges"). Repointed
    LANDSCAPE.md's rescan-log step off the nonexistent REFINEMENT.md changelog to this
    file / its own `## Changelog`, and corrected its line-4 claim that REFINEMENT.md is
    "append-only history" — REFINEMENT.md is rewrite-in-place; *this* log is the
    append-only one.
  - **Deferred (named, not lost):** A2 (both-altitudes sub-cases), A3 (sounding-12
    verify-the-source riders: pin-the-revision, quantitative-claim, verify-can-close),
    A5 (unreachable-invariant → enforcing test), and the #90 smell-shape for 5 (a
    classifier re-implemented inline in a new helper). See TIGHTENING-SIGNALS.md §F.
  - **How this gets validated:** not by a test — a skill is verified by dogfooding.
    Watch the next reviews where 16 fires: does the sharpened Move actually force
    build-and-run instead of a reasoned "bounded"? That is the next log entry, not a
    green check.

- **2026-07-14 (later) — covjson-msgspec #89 values_as(): the first post-A1-landing
  run — A1 confirmed, and A1's next frontier exposed by a miss.** Two /plumb passes
  (plan, diff) plus interleaved ponytail- and code-review on one feature (an opt-in
  typed-value projection over NdArray's faithful union). This is the entry the
  2026-07-14 landing asked for ("watch whether the sharpened 16 forces build-and-run").

  *Plan altitude — headline co-fire 2 + 15.* values_as raising `msgspec.ValidationError`
  vs the library's `CovJSONValidationError` is a public one-way door (15); the same
  logical failure (value-vs-dataType) otherwise surfaces as two exception types by
  door (2). Resolved deliberately: keep msgspec.ValidationError (mirrors decode, not
  the validate pass), named in the docstring + pinned by a test. Affirmed 7/14/5/11/13;
  whole-struct narrowing (NdArrayFloat/Int/Str) weighed and rejected as reopening the
  multi-type shape ADR-0004 rejects.

  *Diff altitude — 16 discharged by execution paid off (A1 confirmed).* Running
  `values_as(float)` on `10**400` produced `SystemError`, NOT the documented
  ValidationError — a decode-reachable legal input (a bare huge-int JSON literal). A
  reasoned pass would have said "int->float, fine." Drove: an upstream report
  (msgspec#1122) + a guard normalizing OverflowError/SystemError to the documented
  contract, forward-compatible with a fixed msgspec. The over-trigger boundary was
  also *run* (10**308 converts, 10**309 raises), and the A4 #5-Boundary fired and was
  discharged by running both idioms (screen keeps `(5,)`, values_as coerces `(5.0,)` --
  different codomains, not merged; 2nd confirmation after #62). Sibling sweep (5/13):
  grepped every coercion site, *ran* validate on the huge int to confirm the screen is
  overflow-safe (keeps int), found to_numpy the one unguarded sibling -> filed #110.

  *The miss (headline signal) — A1's construct-and-run did not reach the TEST.* The
  diff-review returned "Plumb is true" and affirmed "correct and tested." But the
  promotion unit test was a FALSE GUARD: `(5, 6.5, None) == (5.0, 6.5, None)` is True
  in Python, so it passes whether or not the int->float promotion (the projection's
  whole point) happens. Plumb ran the code's breaking edges but never ran a mutation
  against the test defending the core behavior. Worse: the *ponytail* pass then
  asserted "test 1 already pins the promotion" to justify DELETING the parity-pin test
  -- a false coverage-subsumption claim that survived both plumb and ponytail. Only the
  independent /code-review (language-pitfall/test-coverage angle) caught it; the fix's
  own mutation stub ("non-promoted passes new assertion? False") was run only AFTER,
  proving the technique works and was applied one skill too late.

  **New signals for the tightening pass:**
  (1) **A1's "construct and run" extends from the behavior claim to the COVERAGE
  claim.** When plumb affirms "it's tested," that half is itself a claim to discharge
  by *mutating the behavior and confirming the test fails* -- a false-guard test reads
  fine; only the mutation-run reveals it. Same root as #41 ("only a run survives
  confirmation bias"), one level out: not "is the code right" but "does the test catch
  the code being wrong." Candidate 16/Working-note rider: an "affirmed: tested" verdict
  is un-earned until a regression mutation has been run against the guarding test.
  (2) **A coverage-subsumption deletion argument ("X already covers this, delete Y") is
  a discharge-by-running claim.** The ponytail test-deletion leaned on "test 1 pins
  promotion," which was false (numeric equality). Before deleting a test on the grounds
  another subsumes it, run the mutation against the surviving test. Ties the A1 mandate
  to ponytail-review's deletion calls, not only to affirmations.
  (3) **Cross-skill dance exposed the blind spot: plumb affirmed -> ponytail deleted on
  a false premise -> code-review caught.** Test-*validity* is code-review's lane, so the
  lesson is not "plumb should hunt test bugs" but "plumb must not AFFIRM 'tested' (nor
  accept a subsumption to justify deletion) without the mutation-run." When plumb makes
  a coverage claim, it owns discharging it.
  (4) **First post-A1-landing run = A1 validated by dogfooding, as REFINEMENT.md
  demands** ("a skill is verified by dogfooding, not a green check"). 16-by-execution
  caught the SystemError; the A4 Boundary fired and was discharged by a run. The single
  gap is scope, not soundness: the mandate hadn't yet been pointed at tests.

- **2026-07-14 (even later) — titiler-covjson /area (#56): plumb's affirmed-decision ×
  fixed-guard blind spot, caught by /code-review's construct-and-run.** A plumb workflow
  reviewed the finished /area slice (WKT-polygon zonal reduction → Polygon coverage) and
  drove four fixes — **A** the pre-read cell ceiling measured the *source* grid,
  under-counting a reprojected read, so it now measures the *destination* grid feature()
  produces (5 + 16); **B** extract a shared `_covjson_response` (5); **C** name the
  read/reduce helpers by output shape (4); **D** thread the reduction stat into each
  band's description/unit (1 + 5, the dtype-single-source family). Affirmed and parked:
  permissive geometry (11 + 16 — closure/finiteness are the O(1)-local invariants;
  simplicity/containment is heavier and `rasterize` tolerates it) and the
  out-of-bounds/all-nodata → `null` collapse (2/7).

  *The miss (headline).* Fix A closed **one** instance of "the ceiling measures a
  different extent than feature() reads" — the reproject stretch (source vs destination
  grid). It left a **sibling** on the *same* guard: `Polygon.bounds` measured only the
  exterior ring (`rings[0]`), while feature() bounds **all** rings via
  `rasterio.features.bounds`. The affirmed permissive-geometry decision *explicitly
  allows* a hole reaching past the exterior — so a 1×1 exterior with a full-extent hole
  slips the tiny exterior past the pre-read guard and feature() allocates the huge
  all-rings extent, tripping only the post-read backstop (allocation already happened =
  the DoS). Two individually-sound plumb outputs — "Fix A: bound the read" and "affirm:
  geometry stays permissive" — whose **product** is the bug. Plumb ran neither the
  permissive input through the fixed guard nor a grep of "who else derives the polygon's
  extent." Caught later the same session, only by the xhigh /code-review's build-and-run
  of every candidate: a hole-beyond-exterior polygon allocated a 16×16 = 256-cell grid
  against a 16-cell ceiling (the pre-read guard saw the 1-cell exterior and passed).

  **New signals for the tightening pass:**
  (1) **A1's sibling-sweep must cross AFFIRMED decisions, not only re-scan for clones of
  the fix.** #89's sweep grepped every *coercion* site (syntactic siblings of the
  change). This miss lived at the *intersection* of a fix (5/16, bound the read) and an
  affirmation (11/16, permissive geometry) — a semantic sibling the clone-grep can't see.
  Candidate Working-note rider: when a review both *fixes a guard* and *affirms a
  permissive/faithful decision* (7/11), it must **construct and run the affirmed-permissive
  input through the fixed guard** — the affirmation and the fix are co-dependent, and their
  product is where the breaking edge (16) hides.
  (2) **Sounding 5 governs DERIVED EXTENTS, not just constants and formulas.**
  `polygon.bounds` and `featureBounds(geometry)` are two derivations of one quantity —
  the polygon's spatial extent — that *must* agree because one gates a read the other
  performs. The tell plumb had and skipped: `bounds` read `rings[0]` while the geometry
  dict handed feature **all** `rings`. Generalizes #89's "grep every coercion site" to
  "grep every derivation of the load-bearing quantity" — here, every place the read
  extent is computed.
  (3) **This is a genuine plumb MISS, not a lane boundary** (contrast #89, where
  test-validity was rightly code-review's lane). Two sources of truth for a
  security-load-bearing extent is a textbook sounding-5 drift; plumb owned it and had the
  exact tool (16's construct-and-run) but never pointed it at the affirmation × fix
  interaction. The whole-stack payoff: the "only a run survives confirmation bias"
  mandate now pays out *across* skills — /code-review's discipline of building every
  candidate is what the self-authored plumb pass most needed and lacked.

- **2026-07-15 — titiler-covjson #37 (ADR authoring, plumb not invoked): A1's
  "construct and run" reaches a prose security *claim*.** No `/plumb` run — #37 records
  an already-settled decision (dataset open/read failures stay HTTP `500`, overridable
  per deployment) as ADR-0003 plus a README override recipe. But authoring the ADR
  reproduced the A1 signal in a medium this log hadn't caught it in: a **security claim
  written in prose**.

  *Overclaim, closed by a run.* The ADR asserted a flat property — "`500` never leaks
  existence or authorization" — which reads true from the status-code-oracle argument
  alone (a uniform `500` is not a 404-vs-500 existence oracle). Running the system to
  verify the *override recipe* (bad `url` → `500` default, `400` remapped) incidentally
  falsified the *claim*: the real response body renders the raw exception message into
  `detail` (`"…: No such file or directory"`), so existence leaks via the **body**, not
  the status line — and an existing-but-non-raster file (`/etc/hostname`) returned the
  *same* misleading "No such file or directory", so the body signal is itself noise.
  Fix: scope the claim to the status code, add a body caveat. The oracle *argument*
  held; the *unqualified* claim did not, and only the running output showed the gap.

  **New signals for the tightening pass:**
  (1) **A1 / sounding 16 governs a runtime-behavior claim asserted in prose, not only
  code, tests, and plans.** #21 put plumb at doc-*architecture* altitude; this is one
  notch more specific — a doc claiming what the system *does*. The maximizing input for
  such a claim is *running the system and reading its real output* (the HTTP body here,
  plus one adversarial-but-valid input, `/etc/hostname`), never re-reading the argument
  that makes it look true. Candidate: name "a factual/behavioral claim in prose (ADR,
  README, spec)" as an A1 target, discharged by "run it and read the output."
  (2) **Positive, self-caught instance (#99 / #62 family), and the discharging run was
  aimed elsewhere.** The run targeted the override recipe; it surfaced the unrelated
  affirmed-claim overclaim as a side effect — "run the thing" pays out past the claim it
  was aimed at. Corroboration that A1 generalizes to a new medium, not a new sounding.

- **2026-07-15 — titiler-covjson #57/#65 (roadmap realignment, plumb not invoked): A1/16 reaches a *validation harness* — "a green check you never fed a known-red input is unearned."** No `/plumb` run — the task was reclassifying `/trajectory` (Trajectory domain) as temporal, splitting out MultiPoint, and realigning the backlog. But the load-bearing fact was won by an A1/16 move against inherited *affirmations*, and it exposed a sounding-11 trap in the test harness itself.

  *The affirmation, falsified by a run.* Three inherited artifacts affirmed that a spatial-only sampled line is a valid **Trajectory** with `["x","y"]` composite tuples: `docs/02`'s worked example, the roadmap story, and — decisively — `covjson-pydantic` itself, which *constructs and serializes* a `t`-less Trajectory without complaint (sounding 1: the type leaves the illegal state representable). Taking any of them at their word ships a schema-invalid domain. Constructing the three instances (`t`-less Trajectory, `[t,x,y]` Trajectory, `[x,y]` MultiPoint) and running them through the vendored CoverageJSON schema falsified it: the spec forbids a `t`-less Trajectory (tuples must be `["t","x","y"]`/`["t","x","y","z"]`); a spatial-only path is valid **only** as MultiPoint. Resolution (sounding 7, faithfulness): pick the domain by the data's actual shape — spatial-only → MultiPoint via the EDR Position verb (`/position` + `MULTIPOINT`, #65); time-bearing → Trajectory (#57, temporal) — rather than synthesize a fake `t`, the same honesty rule ADR-0001 used to reject a no-op `/cube` `z`.

  *The sounding-11 trap: the check that would "verify" it is asleep.* The invariant lives at three tiers — the pydantic type (doesn't enforce), the named-`"domain"` schema definition, and the full-`Coverage` schema — and is enforced at only **one**. Worse, the test helper's ergonomic default, `assert_schema_valid(model, "domain")`, runs a tier that **silently skips** it: the constraint is a draft-07 `dependencies` keyword, and the stripped `"domain"` wrapper carries no `$schema`, so `jsonschema` selects the Draft2020-12 validator, which ignores `dependencies` and passes the invalid instance. Only `assert_schema_valid(model)` (full `Coverage`, draft-07) actually enforces. A test that *looks* like it validates the domain would have green-lit the exact bug.

  **New signals for the tightening pass:**
  (1) **A1 / sounding 16 governs a *validation harness*, not only fixes, claims, and plans.** The maximizing input for "does this check enforce X?" is a **known-X-violating instance run through the check** — never re-reading the schema/type that makes it look enforced. Extends the A1 thread (#89 fix×affirmation, #37 prose claim) to the verification seam itself: *trust no green check you did not feed a known-red input.* Candidate rider: when a review leans on "we schema-/type-validate it," discharge it by feeding the validator one deliberately-invalid instance and confirming it goes red.
  (2) **Sounding 11 has a verification corollary: know which *tier* your check runs at, because a convenience wrapper can silently drop the constraint it appears to test.** Here a JSON Schema draft-version mismatch (draft-07 `dependencies` ignored by Draft2020-12) turned the ergonomic `validate(…, "domain")` path into a no-op for the invariant under test. "Put the check in the right tier" (11) implies "run the *check* at the tier that still carries the constraint."
  (3) **Positive, plumb-not-invoked instance; the falsifying run also drove the design.** As with #37, the construct-and-run aimed at "which domain is valid?" simultaneously killed the inherited affirmation and exposed the harness trap. Corroboration that A1/16 generalizes to a new medium (the validator), not a new sounding.

  *Aside (sounding 5, process altitude):* the same session found the roadmap had drifted because two sources of truth — a narrative `docs/05` and the milestones/ADRs — were never reconciled; the fix was to retire `docs/05` to a single source of truth (milestones + ADRs). A one-source-of-truth instance at doc/process altitude, noted but not novel.

- **2026-07-15 — covjson-msgspec #113 (custom reference-system types): a three-altitude sequence (guide → plan → diff), each altitude catching a different class of flaw.** The log's richest altitude-differentiation to date: an interactive guide-mode modeling analysis, a `/plumb` plan-review after the plan and ADR were written, and a `/plumb` diff-review after implementation plus a ponytail cut and an xhigh `/code-review`. (Merged as PR #124.)

  *Guide run (`Skill(plumb)` on the modeling fork, mid-design).* Model reference systems (five known kinds plus an open §7.2 custom `type`) as a permissive grab-bag core or a sum-type-with-catch-all? Headline **1 against a house tenet**, resolved by inverting the usual "prefer unrepresentable." The grab-bag makes illegal states representable (a `GeographicCRS` core carrying `calendar=None`; ~5 legal of 128 field combinations), which sounding 1 flags. But the grab-bag permissive core is the structural *face* of permissive decode (ADR-0002): a sum type decodes strictly (reject, or route to a catch-all), fighting the codebase's cornerstone "a slightly-nonconformant document still loads." Synthesis: **illegal states unrepresentable at the CONSUMPTION boundary (an opt-in `refine()` projecting the core to clean per-kind variants), permissive at the INGEST boundary (the faithful core)**, i.e. parse-don't-validate applied at first *use*, not at decode. The sharpest new nuance on sounding 1 the log has produced. Drove idiom A (permissive core plus `refine()` → `ResolvedReferenceSystem` / `OpaqueRS`), every structural claim verified by a runnable probe (the closed-union `TypeError`; encode of a mixed tagged/untagged union field; the ADR-0012 re-encode behavior), per A1, since the design was self-authored.

  *Plan run (`/plumb` on the written plan and ADR).* Three findings, all different soundings from the guide run. Headline **16**: the typed core admits a breaking edge the plan overclaimed away. `{"type":"uor:X","calendar":123}` *fails to decode* (a custom member colliding with a known field name at an incompatible JSON type), run-confirmed, while the ADR said "custom types load" unqualified. **4**: the projection was named `resolve()`, colliding with two existing verbs (`temporal.resolve`, `resolve_references`), a name meaning three operations; drove the rename to a method `.refine()` (also a locality/17 win). **8 + 5**: the shared required-member predicate that must drive both `refine()`'s gate and `validate()`'s error cannot live as a `referencing` private imported by `validation` (repo convention), forcing a new `_reference_invariants` module as the single home for the interop invariant. All fixed before code.

  *Diff run (`/plumb` on the implementation).* Headline **3 + 12, a proactive A1 coverage instance**: the two new `validate()` errors (`temporal.missing-calendar`, `identifier.missing-target-concept`) were emitted by code but asserted by no test, caught by grepping the test tree (they were imported only to satisfy a `_describe` exhaustive match), not by affirming "tested." Discharged by *running* `validate()` on a malformed domain to confirm the feature works (so it is a coverage gap, not a bug), then adding an interop test pinning the refine↔validate invariant. **4/10**: the exported `ResolvedReferenceSystem` union raises a cryptic msgspec `TypeError` if a user decodes *into* it (it mixes tagged variants with the untagged `OpaqueRS`); parked as loud-and-immediate, later softened by an attribute docstring steering to `ReferenceSystem`. Parked: variant-in-core-field (msgspec skips construction typechecks; mypy-guarded, inherent to every field); empty/miscased `type_` (defensible, §5 is case-sensitive); redundant `refine()` in `to_xarray` (efficiency, O(1)).

  **New signals for the tightening pass:**
  (1) **Three altitudes, three disjoint flaw classes: the strongest altitude-differentiation instance in the log.** Guide caught the modeling shape (permissive core vs sum type); plan caught naming, shared-home, and a breaking edge (4/8/16); diff caught untested new behavior (3/12). Prior entries top out at two altitudes (plan plus diff). Evidence that guide-mode modeling, plan-review, and diff-review are three genuinely different scopes, not two.
  (2) **Sounding 1 reconciled with a permissive-decode house tenet: unrepresentable at CONSUMPTION, permissive at INGEST.** The grab-bag core is not a 1-violation to fix; it is the structural face of ADR-0002 ("a slightly-nonconformant document still loads"), which a sum type fights, and the clean variants live at `refine()` (first use), not at decode. Candidate refinement: sounding 1's "parse-don't-validate at the edge" carries a *layer* choice, where the edge can be first-consumption (a lazy projection over a faithful core), not only decode; naming this reconciles 1 with 7 (faithfulness) and 11 (permissive load) where they appear to conflict. First time the log has had 1 *resolve toward the grab-bag* rather than away from it.
  (3) **A1 coverage-discipline, proactive and positive.** The recent A1 thread (#89/#56/#37/#57/#65) was mostly "an 'affirmed: tested' verdict is unearned until a red-input run." Here the diff-review never affirmed tested; it *checked* (grepped for the test pinning the new behavior), found the gap, ran the behavior to confirm it works, and added the test. Confirms A1 as a standing diff-review move: when a diff adds behavior, grep for the test that pins it; absence is the finding, discharged by running the behavior and adding the case.
  (4) **Clean skill partition across four passes (plumb ×2, ponytail, code-review).** ponytail cut a no-value `.custom()` builder (structure plumb had affirmed fine); `/code-review` then owned test-*validity* (a totality test asserting distinctness, not the tag→variant mapping, so a variant swap would pass it) and the finer coverage gaps (`Concept.id`, custom-encode round-trip), plus a behavior narrowing (i18n suppressed on a malformed RS) and a doc overscope. Test-validity stayed code-review's lane (per #89) while plumb's diff-review owned the coarser "new behavior unverified"; the two coverage lenses nested rather than double-covered.

- **2026-07-16 — covjson-msgspec, the `Sequence`-vs-`tuple` member question (NOT a review run; logged as an A1 near-miss).** Plumb was never invoked; logged because the session reproduced **A1's failure mode in a direction A1 has not yet recorded**, and because the miss is the author's own.

  *What happened.* A parked perf idea (annotate sequence members `Sequence[T]` rather than `tuple[T, ...]`; msgspec converts a variable-length tuple via a list, so `Sequence` decodes straight to a list) was measured to decide it. The first instrument was a **hand-built struct standing in for `NdArray`**, which reported **1.34x** and was relayed to the user as "~34% of real decode." It was wrong. Patching the **real** member and A/B-ing it in one session (measure, `git checkout --` revert, measure) gave **1.07x** — wrong by ~5x. The idea was then rejected on structure rather than on the number anyway: a `list` member forfeits hashability on precisely the structs that still have it (`NdArray`, `Axis`, `ReferenceSystemConnection`), foreclosing half of the project's `frozendict` endgame, and falsifies the house tenet's "cannot be corrupted by a caller" (`frozen=True` blocks rebinding, not `array.values[0] = 99.0`). Recorded as an ADR-0016 alternative (PR #126).

  *Why this is a near-miss and not a win.* The bad number was not caught by method. It was caught by an **anomaly too glaring to ignore** — the real full-document decode came in *lower* than the isolated struct that was supposedly a component of it, which is impossible and forced a re-measure. Had the proxy erred in the flattering direction (understating rather than overstating), nothing would have contradicted it and the 1.34x would have stood. Luck, not discipline, and the intermediate claim reached the user before the correction did.

  **New signal for the tightening pass:** **A1's un-earned verdict runs in both directions, and the thing that lies can be a *proxy*, not an argument.** Every logged A1 instance argues a concern *away* (`#41` "bounded/negligible", `#90` "the fix landed"). This one argued a concern **in**: a stand-in artifact inflated a payoff and made a dead idea look worth pursuing. Same failure mode, opposite sign — which sharpens what A1 is actually about. The defect is neither optimism nor pessimism about the verdict; it is **substituting an argument, or a proxy, for a run of the real thing**. A quantitative claim earns its number exactly the way a 16 "negligible" park earns its verdict: by constructing and running the real artifact. Bears on A1's Proposed target, whose Working-note wording currently covers only the dismissive direction. Secondary, weaker: sounding 16's Move is written around breaking-edge *inputs*; here the thing that broke the assumption was a substituted artifact, so if 16 ever widens from "inputs" to "un-earned verdicts generally," this is the second data point.

- **2026-07-16 — covjson-msgspec PR #130 (an outside contributor's axis `bounds`-length check), review-mode diff run: the review changed the *project* more than the PR.** First run on a diff authored by someone else, and the first whose net output is mostly commits to `main` rather than comments on the branch. The reviewed PR is still open awaiting rebase; the run produced three merged PRs (#134 taxonomy rename, #135 category-rule gap, #136 corpus enforcement + ADR README), a reworded issue (#129), and one new issue (#133). **Every load-bearing finding was a stated claim nobody had opened, and three of the four were the project's own, not the newcomer's.**

  *Headline **12** — the cited MUST does not exist, and the project wrote it.* The PR's issue-class docstring, its checker docstring, and its PR body all said "Spec 6.1.1 ... MUST contain exactly two values" per coordinate. Fetching §6.1.1 says: "An axis object **MAY** have axis value bounds ... where the value is an array of values of length `len*2`". No MUST. This bites in *this* codebase specifically because severity is graded off the RFC 2119 keyword by house convention (`DomainMissingDomainType`: "RECOMMENDS ... so this is a warning"; `TemporalLexicalForm`: "SHOULD"), so a fabricated MUST short-circuits the very reasoning that picks the grade. The verdict survived anyway (`error` is right) but for a different reason that had to be *found*: the `MAY` governs **presence**; once present the spec **defines** the length, so a wrong-length array fails to be a bounds array at all — the same definitional-without-keyword phrasing the repo already enforces at construction for empty `values`. **The origin is the finding.** The wording came from the project's own issue #129 ("completeness of the §6.1.1 MUST coverage"); the contributor transcribed it faithfully. Fixed the issue, not just the diff. Co-fire **12 + 15**: a second, quieter 12 in the same docstring — `2 * len(axis)` for a *regular* axis is **derived**, not stated (§6.1.1 defines `len` over the `"values"` array; a regular axis has none), and the repo has an explicit convention of labeling derivations (`axis.py:193`) that the PR presented as flat spec text.

  ***4 + 15** — a one-way door the diff would have wedged open.* The PR opened a new `axis.*` code namespace while `domain.axis-not-monotonic` was *also* a §6.1.1 axis-object rule: two of the same rule class in two namespaces with no stated rule for the next one. `code` is the msgspec `tag_field` (ADR-0006), the wire discriminant a report round-trips through, so it freezes at first release. The contributor's instinct was **right** (and matched #129's own proposal); the incumbent was the misfit. Resolved by renaming *the incumbent* (#134) and writing the rule into the module docstring, so the PR follows a precedent instead of adjudicating a taxonomy it did not choose.

  ***3** — an invariant asserted in prose, unenforced, already false.* `tests/corpus/negative/manifest.toml` promised the corpora "cover every code validation.py emits." Nothing checked it; **three codes already had no document** and the suite was green. The PR would have made it four, silently. Note the contrast that made the finding legible: `_describe`'s `assert_never` *forced* the contributor to classify the new variant and they did, correctly — the exhaustiveness that was mechanized held, the one written as a sentence had rotted. Filed #133, fixed in #136, and the fix derives its expectation from `get_args(Issue)` so the claim can never drift again.

  *Also fired:* **2** (the new tests select on `i.code == "..."` then read typed payload — 148 mypy errors against a clean `main` baseline, and precisely the anti-pattern the module docstring warns about); **5** (the same tier rationale in three homes, the call-site comment restating the checker docstring near-verbatim, while sibling call sites carry only call-site-local ordering rationale); **5** again (ADR-0018 says this rule is "unchecked/unimplemented" in two places, and the `bounds` row is that ADR's *separator case* — landing the check promotes its central argument from hypothetical to real); **16** (the composite axis, **constructed and run**: the check was *already correct*, so the finding became "add a test" rather than "fix a bug", and the misreading it pins — `2 * values * coords` — is live because `Axis.tuple_`/`polygon` do not even expose `bounds`).

  **New signals for the tightening pass:**
  (1) **A1 extends from verdicts and proxies to *citations*, and the incumbent docs lie as readily as the diff.** The 07-16 near-miss added sub-rule (e) (a *proxy* can argue a concern *in*). This adds the next surface: **a cited authority is a claim, un-earned until opened** — and the four that lied here were the PR's spec citation, a manifest header, an ADR README's own rule, and *my own* "44 references" (a diffstat skim; the truth was 22 insertions/22 deletions with 15 lines mentioning the term), caught only because I checked before publishing into the very document about treating the record honestly. Sounding 12 already says "verified against it and cited — never asserted from memory," so this is 12 firing *because* A1's discipline was applied; the new part is **where to look**.
  (2) **12's smell list is written as if the reviewee over-claims; here the over-claim was upstream of the diff.** "'the spec says MUST' without opening it" reads as the author's error. The contributor's docstring was *faithful to its source* — the project's own issue. A diff can conform perfectly to a bad citation, which is the citation-shaped version of plumb's standing stance ("conforming to bad precedent is itself a finding"). **Candidate refinement:** 12's Move should say to open the source *the diff is implementing* (the issue, the ADR, the manifest header), not only the external authority it names, and that the fix may belong upstream rather than in the diff. First logged instance where a finding's correct home was an *issue body*.
  (3) **A brownfield review whose leverage was almost entirely on the incumbent.** Ranked by leverage, the top four findings all resolved to changes on `main`, not the branch: rename the incumbent code, write the missing rule, enforce the unenforced invariant, correct the issue's wording. The contributor's actual defects were CI-mechanical (mypy narrowing, ruff). Practical corollary the run drove: **when the fix is the project's decision, take it off the contributor's plate** — doing #134 ourselves also caught that the blast-radius list I had drafted for them was *already wrong* (ADR-0011 had two occurrences; my first grep had filtered that file out, and the second occurrence's article split across an 80-column line break, invisible to any line-based grep). Had they followed my list, they would have shipped a half-sweep.
  (4) **A1 discipline on the reviewer's own artifact, twice.** Beyond the "44 references" catch: the corpus-enforcement test in #136 was verified by **negative control** (drop a code → confirm it fails; add a typo'd code → confirm equality-not-containment catches that too) rather than by observing it pass. A test asserting `set() == set()` also passes. Consistent with A1(d): the author of a check is the last person entitled to affirm it works.

- **2026-07-17 -- covjson-msgspec #131/#127/#128 (the §6.1.1 composite-axis cluster): a self-authored plan-review at THREE escalating passes, then a diff-review, then ponytail + xhigh code-review.** Merged as PR #141 (green CI). The log's strongest *same-altitude re-probe* evidence: prior entries differentiate altitudes (guide/plan/diff), but here re-running `/plumb` on the *same plan* three times was not redundant. Each pass found a different failure class, and all three would have passed unit tests built from Python literals. The diff-review then found two more the plan could not, and a separate `/code-review` caught a correctness leak plumb correctly routed away.

  *Plan pass 1 (sounding 5-boundary + 16).* The plan's single `axis.composite-arity` rule gated on `dataType in ("tuple","polygon")`. Fetching §6.1.1 (verified against the spec, not recalled): a tuple's size "corresponds to the number of coordinate identifiers" (depth 1, value length vs identifier count), but a polygon's coordinates give "the order of coordinates" *inside* each GeoJSON position (depth 3, value→ring→position). Run-confirmed against real values: for a legal one-polygon axis the gated check compares `len(coordinates)=2` to `len(value)=1` (the ring count) and **fires on a conformant document**. Sounding 5's `[combine?]` boundary test applied exactly ("could one helper serve every site *without* a parameter that re-encodes the very difference?"): the dataType gate IS that re-encoding, so the rule split tuple-only and polygon spun off (#138).

  *Plan pass 2 (16, the duck-typed edge).* Decode `{"values":["abc"],"dataType":"tuple","coordinates":["t","x","y"]}`: a JSON string is a legal `AxisValue`, `len("abc")==3==len(coordinates)`, so the arity check *passes* and the bridges then read `t='a', x='b', y='c'`. The new rule does not miss the garbage, it **certifies** it. Move: shape must gate arity, and shape must be a positive `isinstance(v,(list,tuple))`, never a `len`/iterability test a `str` satisfies.

  *Plan pass 3 (16, the wire vs the literal).* `AxisValue = ... | tuple[Any, ...]` annotates only the outer level; msgspec decodes the `Any` interior to `list`, so a *wire-decoded* polygon is a tuple *of lists of lists*. A symmetric "tuple all the way down" shape check fires on every legal polygon. Surfaced *only* by decoding from bytes: a Python-literal fixture constructs all-tuples and hides it. New rider on 16 (below).

  *Diff pass (16 vacuous-truth; 13 symmetry).* Two flaws the three-pass plan could not have, because they exist only in code. Headline: the polygon shape check used `all(map(_is_position_array, rings))`, and `all()` over an empty sequence is vacuously `True`, so an empty polygon `()` and empty ring `[]` pass. The empty polygon then **crashes shapely** (`not enough values to unpack`), the exact leaked-internal the PR exists to kill, run-confirmed against RFC 7946 (which §6.1.1 defers to and which requires a non-empty ring array). Second (13): the new `_require_composite_axis` checked `dataType` but did `domain.axes["composite"]`, so a missing axis raised a raw `KeyError` where the sibling wrong-`dataType` path raised a clean `ValueError`. The guard half-did its job.

  *The lens that was not plumb.* Neither plan nor diff plumb pass flagged the pandas/xarray `coordinate_identifiers` change (turning `axis.coordinates or ()` into a one-element default, so `row[0]` indexes a `float` and leaks a `TypeError`), because it is a *line-level correctness bug*, not a shape flaw. xhigh `/code-review` caught it; plumb had deferred that class *by name*. Its fix (a shared `composite_columns` guard) was then itself a structural/altitude improvement, so the lenses handed off in both directions: plumb shaped, code-review found the leak, the fix rose back to shared infrastructure.

  **New signals for the tightening pass:**
  (1) **Same-altitude re-probe is not redundant: the log's first three-pass single-artifact run, three disjoint failure classes.** The "run at both altitudes" Working note frames plan-vs-diff as the differentiation. This adds a second axis: re-running the *same* pass finds more, because each pass hunts a *different breaking edge* (spec-depth misread, then duck-typing, then decode-type). Candidate: the note could gain "and re-probe a self-authored artifact more than once; a clean pass is weak evidence when the reviewer is the author."
  (2) **Sounding 16 rider for codec/wire code: construct the breaking input the way it *arrives*, not the way it is convenient.** Pass 3's tuple-of-lists finding was invisible to a literal-built fixture and visible only from `msgspec.json.decode(bytes)`. A decoded value's runtime type can differ from the same literal typed by hand (`tuple[Any,...]` outer, `list` interior). Candidate Move addition on 16: "for a decoder, build the case by decoding bytes; a hand-constructed instance can carry runtime types the wire never produces, hiding the edge."
  (3) **A1 under maximal pressure (self-authored, three times) held, and every pass falsified the author's reading.** Pass 1 I believed the arity gate correct; the run showed the false positive. In the diff I *wrote* the empty-array check believing it complete; the run showed vacuous `all()`. Strongest A1 corroboration in the log that a self-authored clean read is worth nearly nothing until fed a red input, now across three consecutive passes.
  (4) **The three-lens partition held on a self-authored diff (plumb ×2 / ponytail / code-review), and plumb's routing was vindicated.** ponytail returned "lean, ship" (nothing to cut). code-review owned the one correctness leak plumb explicitly routes away, and that leak's deepest fix was structural, so the handoff ran both directions (plumb defers correctness → code-review finds it → the fix rises to shared infrastructure). Corroborates the 07-15 partition entry on a diff where plumb found *no* correctness bug, only shape, exactly as scoped.

  *Aside (15 vs 17).* The resolver's home was decided on reversibility, not the Information Expert. `Domain` holds both the axis and its identifier, so `Domain.coordinate_identifiers(name)` is the locality-17 shape, but a public method is a one-way door (ADR-0018's own reasoning), so it landed as a private `_bridging` helper (two-way) with a promotion path noted. Sounding 15 outranked 17 on a two-versus-one-way-door basis. A related design thread the same session (return types: `Sequence` for decoupled outputs, `tuple`/`frozenset` for concrete stored members) sharpened #119 but was policy work, not a plumb run.

- **2026-07-17 -- covjson-msgspec #129 diff** (`axis.bounds-length` validation rule; review mode on the diff, self-authored, run *after* an xhigh code-review + its fixes and a ponytail-review had already passed over the same branch). **Verdict: the diff is structurally true; the headline is an out-of-scope park routed to a filed follow-up.** (Merged as PR #143.)

  The change itself affirmed cleanly: **2 + 3** (`AxisBoundsLength` is a closed-union variant carrying `expected`/`got`, exhaustive `_describe` forces the update), **11** (the load-bearing decision -- validate() tier, not `__post_init__`, because a wrong-length `bounds` leaves the axis interpretable and droppable; ADR-0018 earns it as the *separator case*), **12** (severity `error` is attributed to ADR-0002's judgment and quotes §6.1.1's actual `MAY`, *not* a false spec `MUST` -- grounded, verified against the fetched wording, not vibes), **7** (bounds stored raw, only length-checked), **6** (pure generator), **13** (symmetric with `AxisCompositeArity`). No fix to the diff.

  **Headline (3 / 16 on `subset.py:482`, parked → issue #142).** The feature *detects* a wrong-length `bounds` via `validate()`, but `_select_axis` still indexes `bounds[2*i]`/`[2*i+1]` with no guard, so the exact input the new rule flags still raises a bare `IndexError: tuple index out of range`. Discharged by **running the public API** (`isel(cov, x=1)` on a short-bounds axis), not the private helper I first probed -- the run is what promoted it from a hand-wave to a filed issue. The finding is reachable *and* load-bearing, yet the correct move was **park**, because it is out of the diff's agreed **scope**: #129 scoped the work to the `validate()` rule, and subset's repair (drop vs. diagnostic-raise) is a separate decision that may want an ADR. Also noted lightly (folded into #142's constraints): **5** -- the "2 per value" bounds layout is now encoded in both validation (`len == 2*len`) and subset (`bounds[2*i]`), a candidate single-source when subset is fixed.

  **New signals for the tightening pass:**
  (1) **A park's reason can be *scope*, not unreachability -- and its discharge is a filed follow-up, not a log line.** The current fix-vs-park Working note splits on reachability ("a defect whose bad state has no path to a consumer... is parkable"). This finding had a path to a consumer (confirmed by running `isel`) and real leverage, yet parked because the fix lives outside the change's charter. The discharge was a **routed, traceable issue (#142)** -- an action, per "a discharge is an action, not an argument" -- not a note that rots. Distinct from #44-commit-1's "park flags the *incumbent* sibling, a different line": here the subject is a reachable crash and the boundary is *scope*. Candidate: name "out-of-scope, routed to a follow-up" as a first-class park class beside "unreachable / sole trusted constructor," its discharge a filed issue.
  (2) **Leverage measured against the *charter*, not only a consumer.** Every prior headline traced a flaw to what *consumes* it downstream. This one traced the diff against **the stated goal of the work it closes**: #129's own motivation named the subset `IndexError` as "a poor diagnosis of a malformed document," and the feature delivered only the *detection* half. The leverage question was "does the change deliver its charter, or only part of it?" -- a diff can be structurally true in what it *does* and still under-deliver the issue it claims to close. Candidate Working-note beside "measure leverage by tracing to the consumer": a second trace target is the work's **charter** (the issue's own motivation); a half-delivered charter is a leverage finding even when the delivered half is flawless.
  (3) **Corroboration (noted, not re-derived):** (a) self-authored **construct-and-run** again changed the outcome -- probing the *public* entry point (not the private `_select_axis`) is what justified filing rather than musing; (b) the **three-review partition held cleanly** across one session -- code-review took the type-narrowing/CI risk (the walrus-vs-member-access idiom), ponytail took a redundant test case, plumb took the structural charter-gap -- no double-coverage, per the #37/#69 skill-partition signal.

- **2026-07-17 -- titiler-covjson #65 (`/position` MULTIPOINT → MultiPoint), diff review: a self-authored 12/16 finding the reviewee OVERTURNED -- "a doc states intent; a bug is a failure to meet the words, not a reason to reword the doc."** A `/plumb` diff-review of the finished MultiPoint slice (9-commit branch already built), then interleaved ponytail + xhigh code-review. Structural verdict "plumb-true": the parse boundary returns a real sum type (`Position | MultiPoint | InvalidCoords`), the modeler dispatches with `match`/`assert_never`, geometry owns its invariants, functional-core/shell split is clean. Three low findings; the headline was **wrong**, and the reviewee's correction is the entry.

  *The mis-framed headline (a discharged 16 wrongly recast as a live 12).* The `/position` route description said a MULTIPOINT position "outside the dataset (or on nodata) becomes a null value rather than an error." I had *constructed and run* the breaking edge (16, A1-clean): a `?nodata=` override on a dataset-edge position trips a rio-tiler off-by-one (WarpedVRT boundless read) and 500s -- a real hole, **already discharged** by a pinning test (`pytest.raises(match="boundless")`) and filed as #73. Correct so far. The error was the *resolution*: I promoted the discharged edge into a live **sounding-12 "the public docs over-promise"** finding and proposed **rewording the description** to match the current buggy behavior (drop "or on nodata"), reading the gap between the honest internal `_read_multipoint` docstring ("any other reader error still propagates") and the confident public description as an inconsistency to fix by weakening the description.

  *The reviewee's correction (the signal).* The user refused: *"you're building in wording to account for a known bug -- shouldn't the wording describe the intention? a bug indicates we are failing to do what the words say, but doesn't mean we should choose different wording when a bug is found."* Right, and it deletes the finding. A description states the **intended contract**; #73 is a *failure to meet* it, tracked in the issue + the pinning test + the implementation-level docstring (a maintainer audience, distinct from the public contract). Rewording the contract to match the defect **enshrines the bug as spec** and *drifts*: when #73 lands upstream, reality re-aligns with the *original* wording and someone must remember to change it back (the pinning test is designed to flag exactly that moment). Correct plumb output: "the edge is real and already discharged by the test; the description correctly states intent; **no change**." Reverted the reword; the finding produced no commit.

  *The other two (handled correctly).* **3** -- the route dispatched Point-vs-MultiPoint with an `isinstance` if/else while the sibling modeler uses `match`/`assert_never`; drove a mirror refactor, discharged A1-clean (signal 3). **5 (parked)** -- `_resolve_read_bands` (keyed by `read.band_names`) and `_resolve_unread_bands` (positional by `indexes`) are two selectors over the *same* band-name source that must agree; parked as essential divergence (one path has a read, one does not), pinned by a doctest + unit test. The A4 #5-boundary applied cleanly: "could one helper serve both *without* a parameter re-encoding the read-vs-no-read difference?" -- no, so genuinely different, not one-source-wearing-a-coat; leave it. Routed the `parse_position_coords` double-regex-match to ponytail by name.

  **New signals for the tightening pass:**
  (1) **A discharged breaking edge (16) must not be re-escalated into a "reword the contract" finding when the edge is a *tracked bug*.** A new failure mode in the A1/16 family: the *edge* was run and confirmed (A1-clean), but the *resolution* over-reached, treating a doc that states **intent** as if it must describe **current buggy behavior**. The correct home for the bug is the tracker + pinning test + implementation-level docstring (maintainer audience); the public contract stays as the intent. **Discriminator vs #37** (the ADR "500 never leaks" overclaim, which *was* reworded): reword a doc only when **intent itself is overclaimed** -- when the deviation is a *permanent property the design does not intend to fix* (#37: the body genuinely leaks, so the guarantee was false). Do **not** reword when a *tracked, fixable bug* deviates from a correct intent (#65: the design intends null; #73 deviates and will be fixed upstream). One rule covers both: **ground a doc in the intended behavior; reword only if the intent is what's wrong, never to match a bug that will be fixed** (doing so enshrines the defect and drifts on the fix). Candidate: sounding 12 gains a rider naming *which source* a contract/spec/description is grounded in (the intended behavior, not the current buggy implementation). First logged finding whose defect was **the resolution of a correctly-run edge**, not the edge itself.
  (2) **The reviewee overturned a self-authored finding -- second flavor, and it *deleted* the finding.** #44 logged a *re-review* flipping a prior headline via empirical discipline on the fix. Here the flip came from the **reviewee's principle**, not a run: the user supplied the intent-vs-implementation distinction the wielder's confirmation bias had collapsed. Corroborates that a self-authored review's weakest point is not the edge-run (A1 covers that) but the *framing of the resolution* -- and the reviewee is positioned to catch a mis-framed fix the author cannot. Mirrors #21's "a proposed fix is a legitimate reopening point," sharpened: here the reopening *deleted* the finding rather than improving the fix.
  (3) **A1 construct-and-run, on a type-level exhaustiveness guard (positive).** The sounding-3 refactor (`isinstance` → `match`/`assert_never`) was discharged not by reading "the match is exhaustive" but by *removing the `case Position()` arm and running mypy*, confirming it errors (`assert_never` receives `Position`, not `Never`). Green mypy on the *correct* code proves nothing about whether the guard catches a *missing* case; only the red-input probe does. Extends the A1 "feed the validator a known-red instance" thread (the 2026-07-15 #57/#65 harness run, #130 the corpus) to **the type-checker as the validator** -- a totality guard's whole value is compiler-enforced exhaustiveness, un-earned until a case is deleted and the compiler goes red. The three-lens partition held: plumb owned structure, ponytail cut a single-caller helper + redundant tests, code-review caught the inherited #72 nodata-expression *correctness* leak (a fabricated value at a masked pixel), which plumb correctly routed away by name.

- **2026-07-18 -- covjson-msgspec #142 diff** (subset's wrong-length `bounds` diagnostic; review mode on the self-authored diff, run alongside a ponytail-review and an xhigh `/code-review`). **Verdict: Plumb is true -- and the value is the resolution of the sounding-5 candidate #129 parked here two days ago, not the (confirmatory) structural verdict.** (Merged as PR #144.)

  *Confirmatory, noted not re-derived.* The structural verdict re-fires two logged signals: **11** -- guard-at-consumer is the right tier, not `__post_init__` (which would break permissive decode) and not eager-at-the-`isel`-boundary (confirmed by **running** the untouched-axis probe: subsetting `x` on a coverage whose *unrelated* axis `z` has malformed bounds succeeds, `z` preserved); and **1 reconciled with permissive decode** exactly as #113 framed it -- the wrong-length `bounds` is representable by design, so the clean state is enforced at the *consuming* tier (`_select_axis`), not at ingest.

  **Headline -- #129's parked 5, resolved as *don't dedup*, for a reason A4 does not cover.** #129 noted the `2 * len` bounds layout now lives in both `validation` and `subset`, "a candidate single-source when subset is fixed." A4 (the existing 5-boundary) leaves *different-deciding* idioms alone; here the two sites encode the **same** decision, yet extraction is still wrong -- because `2 * len` is a **fixed spec constant (§6.1.1 `len*2`) that cannot drift**, and dedup debt presupposes drift. New sub-case: *same knowledge, N places, but un-driftable → a shared helper is a ponytail-1 wrapper, not one-source-of-truth.*

  **Co-fire 5 + 4/10, surfaced by the reviewee.** The tempting *mechanism* for sharing was the user's own proposal -- construct `AxisBoundsLength` and harvest its `__str__`. Declined: it (a) couples `subset → validation` (a new import between two independent feature modules over the shared model, against #142's own constraint), and (b) needs a **fabricated `at` JSON-Pointer** -- a *located* finding with no location -- to fill a required field the message never reads, misrepresenting what the type *is* (a report-finding wielded as a message template). The kicker: the "dup" was not one -- subset's message carries its own tail, so there was no shared string to protect (the reviewee: *"i didn't read the message closely enough to see that it's not actually a dup"*).

  **New signals for the tightening pass:**
  (1) **Sounding 5 needs a *drift-capability* gate, orthogonal to A4's *same-decision* gate.** A4 asks "same decision or different?" and spares different-deciding idioms. This adds the second axis: even when the sites *do* encode the same decision, dedup is debt only if the knowledge can **drift**. A fixed external constant (a spec `len*2`, an RFC magic number) stated on a report-path and a raise-path is not one-source debt -- it is one immutable fact written twice, and extracting it is arithmetic-wrapping. Candidate: 5 now carries **two** false-positive classes -- *different-semantics* (A4) and *un-driftable constant*.
  (2) **The sharing *mechanism* is in scope for 5, and can trip 4/10.** A dedup proposal is not automatically an improvement: constructing a domain type to harvest one method, when that means fabricating its other required, semantically-loaded fields, is a type-abuse a "reduce duplication" instinct hides. The tell: *does sharing require constructing a thing that is not the thing* (a located finding with no location)? If so, the duplication is the cheaper honesty. First logged dedup declined on **type-integrity** grounds, distinct from A4's different-semantics decline.
  (3) *(Watch-item, not a headline.)* **Guard *granularity* slipped from plumb to code-review.** Plumb affirmed the *tier* (11) but did not probe the guard's *scope* -- whole-axis vs per-position -- and `/code-review`'s removed-behavior angle caught the resulting behavior change (a narrow `isel(cov, x=0)` over a short-bounds axis, served in-range by the old per-position indexing, now raises; **confirmed by running**). Arguably clean partition (behavior-diff-on-a-legal-input is code-review's lane), arguably a plumb miss ("at what scope does this guard fire, and does that re-classify a previously-valid input?" is a shape question adjacent to 11). The new behavior is correct (refuse a malformed axis wholesale, don't propagate two bounds of unknown correctness), so it resolved to *keep + note*. Candidate: when a diff **adds a guard**, record not only *where* it fires (tier) but *how much* it rejects (scope).
  (4) **Three-lens partition held again** (corroboration, not re-derived): plumb owned the structural charter (the 5 resolution), ponytail found only convention-earned verbosity ("lean already, ship"), code-review owned the granularity behavior-change plus two doc-accuracy nits (a Raises note implying `validate()` *repairs*, and a comment saying `2 * len(values)` for a `len(axis)` that also covers the regular form) -- no double-coverage, per the #37/#69/#131 thread.

- **2026-07-18 -- covjson-msgspec #137 diff** (`validate()` misses §6.1.1's `coordinates` MUST NOT; review mode on the self-authored diff, after a user-driven scope correction and alongside a ponytail-review + xhigh `/code-review`). **Verdict: Plumb is true on the code -- the value was catching a *false rationale* on a correct diff, plus a third sounding-5 don't-dedup sub-case.** (PR #146, open.)

  *The scope correction that mattered came from the reviewee, before plumb ran.* The first cut was dataType-agnostic (`coordinates == (name,)` for any axis). The **user**, reading §6.1.1, caught that flagging `tuple`/`polygon` is wrong -- their `coordinates` is arity-defining and can't be the one-element default -- and narrowed scope to non-composite axes. That was a sounding-16 defect (a *misleading diagnosis*: "omit your coordinates" fired on a malformed polygon whose real fault is position arity), caught by inspection, not plumb. Plumb ran only on the already-narrowed diff, so it could **confirm** scope, not originate it. **Reinforces the "run plumb on the plan/first diff, not only the polished one" Working note with a concrete miss:** sounding 16 on the first version -- probe a polygon with `coordinates: ["x"]` -- is exactly the input that exposes the misleading diagnosis.

  **Headline -- a correct diff carrying a *lying* docstring (16 surfacing 4).** The narrowed code was right; its docstring justified the exclusion as one fact -- "composite `coordinates` can never be the one-element default." **Running** the excluded case (a legal 1-wide `tuple` at key `x` with `coordinates: ["x"]`) emitted `[]` and proved that claim *false for tuple*: a 1-tuple **can** carry a one-element `coordinates`, so it is excluded by an *interpretation* (read `coordinates` as required for a composite axis), not by impossibility. Only polygon's exclusion is a tautology (a GeoJSON position is >=2 components). The prose stated a **decision as a structural fact** -- a sounding-4 defect (a rationale lying about the design's shape), latent because a maintainer trusting "can never" could drop the `dataType` filter as a no-op and silently start flagging degenerate tuples. Drove the sole plumb-pass change: **split the two exclusion reasons in the docstring** (polygon structural, tuple interpretive); no code change. The park (the 1-tuple under-report) discharged into *documentation of the decision*, not code. Same family as the 2026-07-07 headline (a docstring that "claimed correctness" while the type lied, caught only by running) -- now extended from a *type's* claim to an *exclusion's stated reason*.

  **Sounding 5 -- third don't-dedup sub-case, largely confirming #142.** Candidate: the default `(name,)` lives in both `coordinate_identifiers` (resolve) and the new check (detect). Declined and **proven** by running: `coordinate_identifiers` returns `(name,)` for *both* the violation (`coordinates=("x",)`) and the conformant-omitted case (`coordinates=None`), so it **flattens the present-vs-absent distinction the detect exists to draw** -- reuse would hide the decision (A4's "N sources wearing the same coat," inverted: the tempting shared helper is *lossy* for the second consumer's purpose). Also confirms #142's **un-driftable-constant** gate -- `(name,)` is a frozen spec default. Two independent reasons the reuse is wrong (lossy-for-purpose + un-driftable), neither being A4's different-decision case.

  **New signals for the tightening pass:**
  (1) **Sounding 16 discharges the *reason* for a boundary, not just the boundary.** "Is this edge bounded?" has a second half: "does the *stated reason* survive the run?" A structural-impossibility rationale is falsified by constructing the input the structure supposedly forbids (here, the 1-tuple the docstring called impossible). A correct filter can carry a false why, and the false why is the latent defect. Candidate Working note: **when a design excludes a case, run the excluded case -- a green exclusion proves the filter fires, not that its reason is true.**
  (2) **Three-lens partition held (corroboration).** Plumb owned structure (scope confirmation + rationale honesty); ponytail found nothing to cut ("lean already, ship," and correctly *refused* to cut the polygon test case, which guards the `"polygon"` member of the exclusion tuple); xhigh code-review returned **0 findings without padding** (honoring "emit what you have"). The sounding-5 candidate stayed plumb's, never mis-routed as a code-review dup.

- **2026-07-18 -- covjson-msgspec #138 (guide + diff, one session)** (polygon depth-3 MUSTs: position arity, ring length, ring closure). **First full guide -> build -> diff-review pair in the log, and both altitudes earned their keep on *different* findings** -- the "run plumb on the plan and again on the diff" working note, corroborated with a clean instance. Guide produced the plan; the diff-review's whole value was one run-surfaced park routed to a new issue. (PR #148, open; follow-up #147 filed.)

  **Guide headline -- sounding 16 discharged against the *downstream consumer*, before a line of code.** The design's leverage ranking came not from reasoning but from *running shapely* (the geo bridge's engine) on the three violations: a short position -> `IndexError` (hard crash), an unclosed or three-position ring -> shapely *auto-closes and accepts* (silent), a two-position ring -> `ValueError`. That produced a leverage table ranking the three MUSTs by downstream consequence (position arity is load-bearing, it guards a real crash; closure is pure conformance, no consumer breaks), which shaped the whole design (arity its own code for sure; the ring rules the mergeable pair). Also fetched RFC 7946 3.1.1/3.1.6 to ground severity (§12), not asserted from memory.

  **Diff headline -- the park that became #147, surfaced only by a run.** Probe #5 (a polygon that *omits* `coordinates`) showed the new arity check resolves the default to `(name,)`=1 and floods N per-position "position has 2 components but 1 identifier" issues: a *misleading* diagnosis (points at positions; the real fault is the missing `coordinates`), where the geo bridge's own "lacks x/y" message is clearer. Parked (the documented guide-mode scope boundary: a polygon's `coordinates` must be >=2, a distinct rule) and *routed to a follow-up issue* (#147, the #129 park-to-issue pattern). The structural verdict was a plain "Plumb is true"; the run is where the value was -- the structural read alone would have shipped clean and missed it.

  **Discharged by running, not reasoning (self-authored, eight probes):** §13 symmetry -- probe #7 confirmed an arity-green polygon bridges with no IndexError (the arity check's whole point: sharing `coordinate_identifiers` with the bridge makes the crash unreachable for validated docs); plus emit-both, the shape-gate (scalar / list-of-strings / empty-position reach no deep read, no `len(str)` crash), conformant-3D silent, and closure where int `0` vs float `0.0` reads as *closed*, matching RFC's "identical values" MUST over its representation SHOULD. The structural read would have affirmed all eight un-run.

  **New signals for the tightening pass:**
  (1) **§16 in guide mode targets the downstream consumer, and is runnable *pre-code*.** Hunting the breaking edge before code exists usually means reasoning about your own unwritten function; but the *consumer* (here shapely) already exists and can be run. Its tolerance profile -- crash vs silent-repair vs reject -- ranks your planned rules by leverage before you write one. Candidate Working note: **guide-mode §16 = run the consumer against each violation you plan to catch; its failure mode sets the rule's priority** (a hard crash outranks a silently-tolerated conformance nit).
  (2) **TypeGuard-vs-TypeIs is a soundness call, not a style one (§1/§3).** The reviewee pushed narrowing `_is_polygon_array` from a cast to a guard; `TypeIs` was *unsound* because the predicate is *stricter* than the narrowed type -- it returns False for an empty `()`, which IS a `tuple`, so TypeIs's negative-branch narrowing would wrongly strip `tuple` from the else-branch. `TypeGuard` (positive-branch only) is correct. Candidate sounding-adjacent rule: **when a predicate narrows a type, ask whether it is stricter than that type; if so only a positive-only guard (TypeGuard) is sound, never the bidirectional TypeIs.**
  (3) **Both altitudes, different headlines (corroboration + clean instance).** Guide's headline (the leverage-ranked granularity, from running the consumer) could not have come from the diff; the diff's headline (the omitted-coords misdiagnosis, from running the *built* code on a legal input) could not have come from the plan. Three-lens partition also held: ponytail "lean, ship" (declined to cut a realistic geo fixture), code-review 0 findings unpadded.

- **2026-07-19, covjson-msgspec #147** (composite-axis `coordinates`: a `validate()` rule that moved to construction, and reversed a prior ADR). Guide mode, then a long design dialogue, then a diff review; spanned two days. Shipped and merged (PR #149, CI green). Wrote ADR-0019, which supersedes a sub-decision of ADR-0018.

  **Headline: ADR-0018 had already decided this exact case the opposite way, and #147 reversed it by *resolving* the default instead of *reasoning* about it.** ADR-0018 applied ADR-0002's "name the repair / is the repair usable?" criterion to a composite axis that omits `coordinates` and concluded *keep it below construction*: §6.1.1's default is "a single spec-defined repair," so the axis stays interpretable; it even called `Axis(values=((1.0,),), data_type="tuple")` "a legal one-tuple axis." #147 applied the identical criterion but followed the default to the value it actually produces: for a composite axis (keyed literally `"composite"` in every Common Domain Type) the default resolves to `("composite",)`, the axis's kind-label, which names no component. Is that repair *usable*? No. So the same criterion, applied to the resolved value rather than to "the default" as an abstraction, flips the tier from `validate()` to construction. The lesson is a §16 one wearing an ADR's clothes: **a sounding applied to a *description* of a value, not the value itself, can give the wrong answer; ADR-0018 reasoned about the repair without resolving it.** Cost of the miss: a tier decision recorded backwards, reversed a year later. (ADR-0019 rebuts ADR-0018 by name in Alternatives; ADR-0018's Status notes the partial supersession.)

  **§1 beat the guard, and it was not a departure from permissive decode.** My first #147 design was a `validate()` rule plus a guard to suppress the arity flood the nonsensical default causes downstream (#138's per-position scan compares each position to the defaulted count of 1). Chuck pushed to first principles: composite-omission is *uninterpretable in isolation*, equivalent to a supplied-but-empty `[]`, which is ADR-0002's own construction-tier carve-out. Moving the check into `__post_init__` made the illegal state unrepresentable, which deleted *both* the flood and the guard: a bad-`coordinates` composite axis can no longer construct, so it never reaches the value-scan. The §1-vs-permissive-decode tension I had assumed dissolved: they do not conflict when the state is genuinely uninterpretable. **Signal: when you reach for a guard to suppress downstream noise from an illegal state, the guard is often the symptom of a check sitting one tier too low; ask whether the state should be unrepresentable instead.**

  **Self-critique: I defaulted to the incumbent tier, twice.** I placed #147 in `validate()` by pattern-matching #137 and #138 (both `validate()` checks that landed days earlier) without re-deriving whether #147's greater locality (O(1), name-free, single-object) changed the tier answer against ADR-0002's actual criterion. I also over-unified *missing* and *too-few* into one `raw < floor` rule when Chuck wanted them separated by cause. Both wrong defaults came from conforming to the freshly-established shape rather than the principle: **"judge against the ideal, not the incumbent" turned inward, where the incumbent is a pattern *I* set two issues ago.** The design got better through the reviewee's pushback, not the guide pass.

  **Diff-review, downstream: a tier reversal turns docs into lies.** Making the omitted-composite state unrepresentable meant every doc that *described handling* it became a stale contradiction. The diff review caught `concepts.md` asserting the removed guard was "over-strict, removed by #131" (the exact opposite of the ship), plus two `validation.py` docstrings and `geo.py`'s `_horizontal_indices` narrating the now-impossible omitted-composite path. **Signal (faithfulness / one source of truth): after a decision reverses, grep the *prose* for the old behavior, not only the code; nothing compiles a stale doc, so no checker flags it.**

  **Breaking edge: the polygon floor is a construction check for a reason independent of omission.** Even setting the omitted case aside, a self-consistent 1-D polygon (one-element positions that match its single declared identifier, so `1 == 1`) *passes* #138's `validate()` position-arity scan while still violating RFC 7946's two-or-more-per-position rule. The value-scan compares position length to identifier count; it structurally cannot catch "the identifier count itself is too low" when the positions agree with it. Only a check on the count, at construction, catches it. A distinct edge that earns the tier on its own.

  **Process + recurring.** Guide mode produced the plan, but the load-bearing move (the tier reversal) came in the *dialogue after* it, from Chuck's pushback, not from the guide questions; the "run plumb on plan and diff" note gains a third altitude, the long design dialogue between them. Shipped as two checks *by authority* rather than a floor dict, one message per real requirement ("requires `coordinates`" vs "requires at least 2 `coordinates`, got N"). Recurring style: double-dash overuse called out again (logged); `"custom"` de-backticked because backticks imply a literal token but *custom* is a category, not a `dataType` literal (a §4 names nuance). `gh pr create` with a heredoc inside `$()` mangled the PR #149 body on macOS bash 3.2; always `--body-file`.

- **2026-07-19, #147 implementation session** (building + reviewing the diff the entry above planned; distinct session, distinct findings).

  **Headline (§13 symmetry): a mirror test earns nothing when its failure mode is already the conjunction of existing tests over one shared path.** The file pairs construction+decode for some checks, so a short-polygon *decode* test looked owed. Traced instead: the missing-coords *decode* test already pins the decode->`__post_init__` wiring, and the short-polygon *construction* test already pins the check; msgspec runs `__post_init__` exactly once, on an already-populated struct, so the decoded `("x",)` and the constructed `("x",)` are the same value by the time the check runs. No seam exists for a short-*decode* to break through independently. "What would the extra test buy us?" resolved to *documentation symmetry, not coverage*: a test that cannot fail independently of two existing ones is upkeep, not a guarantee. Declined (ponytail YAGNI-on-tests + §13 satisfied by decomposition). Signal: **before adding a mirror test, ask whether it can fail alone; if its failure is the conjunction of existing tests over a single code path, symmetry is served by the decomposition, not a new case.**

  **Plumb's diff-altitude earned its keep on prose no build executes.** Sharpening the design entry's "docs as lies": `pytest --doctest-modules` runs *src docstring* doctests, so a stale runnable example fails loudly, but `docs/*.md` narrative prose is executed by nothing, so `concepts.md` asserting the removed guard was "over-strict, removed by #131" (the exact inverse of the ship) had *no* failing check. A deliberate grep of the prose was the only thing that caught it. Signal: **after a reversal, rank stale-artifact risk by what no build executes: narrative .md prose is the top risk, above docstrings (doctested) and code (typechecked/tested).**

  **§5/§4: the floor dict was a false symmetry, pre-empted before it was written.** The first shape was `{"tuple": 1, "polygon": 2}[dt]`, one "floor" lookup. Rejected for two checks *by authority*: the uniform number hides that `tuple: 1` means "present at all" (the §6.1.1-default-is-degenerate rule) while `polygon: 2` is an RFC 7946 magic number. One lookup table wearing one coat over two different sources (§5's "N sources in one coat"), caught at design-of-the-check time, not as a found dup. One message per real requirement followed.

  **Self-authored review discharged by running, not reading (corroboration).** Every accept/reject sounding confirmed by a constructed 5-case decode matrix plus the full 909-test + doctest run, per "only a run survives confirmation bias." Three-lens partition held: plumb owned the prose catch + the §13 decomposition call; ponytail owned the declined mirror test and a *deleted* dead fixture (a polygon-restates-default case the new construction rule made unconstructable); code-review owned line-level correctness.

- **2026-07-19 (later), covjson-msgspec #139** (enforce the Common Domain Types composite coordinate identifiers in `validate()`; guide mode -> build -> plumb/ponytail/code-review -> ship). Distinct session, builds directly on the #147 pair above. Shipped as PR #152 (Closes #139), all local tests + `act` type-checkers green (basedpyright strict 0/0/0).

  **Headline (§12 grounded-in-source, co-firing §1/§4): opening the actual spec revealed the requirement's *shape*, not just its strength -- the issue's prose paraphrase was one keystroke from becoming the type.** The issue proposed `composite_coordinates: tuple[str, ...]` and an acceptance criterion "a Trajectory whose coordinates are not `[t,x,y]` is reported." Fetching domain-types.md verbatim (the issue's *own* constraint: verify against the spec, not our fixtures) showed several types permit *alternatives* -- Trajectory is `[t,x,y,z]` **or** `[t,x,y]`, MultiPoint is `[x,y,z]` **or** `[x,y]`. A single tuple cannot represent that, and the stated criterion would have false-positived a conformant 4-D Trajectory (reporting a legal document as broken). The field became `tuple[tuple[str, ...], ...]`, a *set* of orderings checked by membership. **Signal: §12's "grounded in the real source" is usually invoked for severity (MUST -> error); this is the case where the source governs the *type's shape*. The author's one-line paraphrase ("Trajectory is `[t,x,y]`") was about to be encoded as a single-tuple field; only opening the spec caught that the requirement is a set of alternatives. Verify the shape against the source, not the ticket's summary of it.**

  **§16-adjacent: the issue's own stated constraint was stale, invalidated by a merge from hours earlier.** #139's Constraints said a composite axis omitting `coordinates` "resolves to `("composite",)`, which would violate this rule." But #147 / ADR-0019 (the entry above, merged the *same day*) had just made that unreachable -- such an axis now fails at construction. The guide had to reconcile the issue against current HEAD rather than take its premises at face value; the rule's real target is a *constructible but wrong* ordering (a Trajectory declaring `[x,y]`), not the omitted case. **Signal (the #147 "docs as lies after a reversal" note, one level up): a reversal invalidates not only docs but *sibling issues* that depended on the old behavior. When a guide runs against a ticket, check its stated constraints against HEAD -- a recently-merged dependency can have turned a premise into a lie that nothing flags.**

  **Self-authored §16 discharge = hunt the edges your *earlier* sweep skipped, not re-run the ones you ran.** Implementation ran a 7-case edge sweep (all green). The mandatory diff-review discharge could have re-run those; instead it noticed the sweep had *omitted the polygon family* (PolygonSeries / MultiPolygon / MultiPolygonSeries) and a polygon-with-wrong-identifiers case, and constructed-and-ran those, plus a registry-sanity loop (every composite entry's allowed set non-empty and dataType-consistent) and a re-confirmation that the corpus fixture emits *exactly* one issue under `check_values=True`. All passed -- but the value was catching the gap in my own coverage, not re-affirming what I had already shown. **Signal: for the self-authored run, "construct and run the breaking input" means the inputs your first pass did not cover; a discharge that only re-runs the already-run cases is confirmation bias wearing a lab coat.**

  **Three-lens partition held, with one §5 dup sitting on the plumb/code-review seam.** plumb-review = true (3 low-leverage parks); ponytail = lean, ship; xhigh code-review = no correctness bugs (3 low cleanups). The one finding that surfaced in *two* lenses independently: a duplicated dataType-match predicate (`composite.data_type == rule.composite_data_type` re-derived in the coords rule, the negation of what `_composite_data_type_issue` already computes). Both lenses flagged it; both parked it (a one-token `==`; extract a shared predicate only if it grows). **Note: the partition holds but is not a clean cut -- a low-leverage §5 dup is visible from the plumb altitude (two homes for one decision) and the code-review altitude (simplification) alike. Co-visibility is not redundancy; it is the same dup seen at two focal lengths, and both lenses correctly ranked it *park*.**

  **Process.** Guide reshaped the issue *before* code (the arc the "run plumb on the plan" note wants), and the issue *body* was corrected before implementing, per the repo's draft-issues-first agreement. An API-shape call -- carry `actual` in the finding, or just `expected` like its sibling? -- was settled by *running msgspec* to see that its `ValidationError` echoes the bad value only for enum/literal mismatches (the nearest analog to this check), rather than asserting a convention: §12's discipline applied to a neighbor library's observed behavior, not a spec. No new ADR (rests on ADR-0019, which already names #139). Spun off a docs follow-up (#151: the `decode -> validate -> bridge` recipe plus a loud / silent-nonconformant / silent-erroneous bridge-failure taxonomy, with the scenarios to be *run* at authoring time). `--body-file` used throughout (the macOS bash 3.2 backtick trap, logged again).

- **2026-07-19 (later still), covjson-msgspec #109** (the xarray bridge silently corrupted spec-valid dates outside numpy's `datetime64[ns]` window: 2300 came back as 1715). Guide mode on a *bug fix*, then build, then plumb/ponytail/code-review, then ship. PR #154 (Closes #109); all local tests, the `act` lowest-direct floor leg, and the four type-checkers green. *(Prose here written without the em-dash double-hyphen: recurring feedback landed mid-session, so colons/commas replace it.)*

  **Headline (§16 turned on my own verification math, which overflowed twice before it was right).** The bug is a guard against a failure that never fires: numpy int64-*wraps* an out-of-range date instead of raising, so `suppress(ValueError, OverflowError)` was a no-op. Fine, and easy to see. But *building* the fix meant computing numpy's ns limits to range-check against them, and my first two attempts silently overflowed doing exactly that: `ns_min.astype("datetime64[us]")` wrapped the min to the max, even when the min was built from a string. The landmine caught the mine-detector. Only running the bounds computation (asserting a known-in-range date actually classifies as in-range) exposed it; a careful read of the "compute the bounds, then compare" code looked correct and was not. **Signal: §16's "a bounded verdict is unearned until run" applies to the *verification code*, not only the input under review. When the domain is a known trap (int64 datetime overflow, float epsilon, timezone math), the tool you reach for to check the boundary is subject to the same trap. Run the check; do not trust that it computes what it reads as computing.**

  **The better *shape* came from running a sibling, not the code under change (§4/§5/§7).** The issue proposed "route out-of-range dates to cftime," and ADR-0015 had recorded that codomain. Running the *pandas* bridge on the same input showed pandas does not corrupt: it widens the datetime64 resolution (or falls back to strings), never cftime. That surfaced Option B (widen the unit), a shape neither the issue nor the ADR considered, and reframed the question to "what does the cftime arm *mean*?" cftime means "a calendar numpy cannot represent"; an out-of-range Gregorian date *is* representable, only not at ns precision, so it is a *resolution* matter, not a *calendar* one. Routing it to cftime overloads the arm's meaning; widening the unit keeps the two axes orthogonal (calendar-kind picks cftime-vs-datetime64, range picks the unit). **Signal (sharper than #139's "run msgspec to settle a detail"): a sibling implementation did not settle a detail here, it revealed the whole correct shape. When one path of an N-path design is buggy, ask what its siblings actually *do* with the same input before adopting the buggy path's own proposed fix. A sibling that already handles it names the shape.**

  **A §7 design verdict carried its cost in a *different dimension* (dependency reach), exposed only by running on the declared floor.** Option B (widen) is the faithful, leaner shape, but it depends on xarray *preserving* a non-ns datetime64 rather than coercing it back to ns, a capability newer than the declared floor. Running B against `xarray==2024.10` (the floor) *hard-failed* with `OutOfBoundsDatetime`: the design that passes on dev (xarray 2026.4) does not exist on the minimum supported version. So "B is cleaner" came bundled with "B forces a floor raise," and the exact floor was pinned by the oracle (invoking the repo's own uv-minimum-versions skill: 2025.01.1 fails, 2025.01.2 is the first that preserves), not by judgment. **Signal: a "the better design" verdict is unearned until run on the *oldest supported environment*, not just dev; a design's viability can live in a dependency version. Where a sounding (here §7 faithfulness) trades against a dimension it does not own (dependency reach), name the trade and let the owner decide. One PR both fixed the bug and raised the floor, the floor proven by the lowest-direct CI leg.**

  **Self-authored diff-review §16, a second instance of #139's signal: run the exact assumption, not the cases already run.** `_fits_ns_window` uses a one-second-inside margin and its docstring claims "conservative, so no out-of-range value slips through." The diff-review discharged *that claim* by running the exact margin (a value at `2262-04-11T23:47:16`, one in the excluded last second, one just past), confirming the accepted set is a strict subset of the representable set and that every ns-narrowed value equals its us parse (no wrap). The already-run repro and edge cases never touched the margin; the sentence in the docstring was the thing to run.

  **Process + recurring.** Guide reshaped the fix against *both* the issue's proposal and an accepted ADR's codomain (ADR-0015 updated, not superseded). The A-vs-B representation choice and the floor raise were surfaced as explicit `AskUserQuestion` decisions, since a codomain change on a public bridge and a floor raise are the user's calls. code-review's conventions angle caught a comment-style miss (test comments narrating past behavior plus an issue ref) against a *user-memory* convention, not a CLAUDE.md rule; the user then caught double-dash overuse in the *code I wrote*, not only chat. The structural lenses do not own house prose style, so it rides on the conventions angle and the human.

- **2026-07-20, covjson-msgspec #153** (the export bridges handled a spec-valid `±hh:mm` temporal offset three inconsistent ways: xarray flattened to naive-UTC but leaked numpy's tz `UserWarning`, pandas kept it tz-aware, a mixed naive+offset axis silently degraded to raw strings). Guide mode on a *bug fix*, then build, then plumb diff-review, ponytail-review, xhigh code-review, then ship. PR #155 (Closes #153); all local tests and the four `act` type-checkers (basedpyright strict 0/0/0) green. #153 was the last open bug, so clearing it satisfied the repo's "close open bugs first" gate. *(Prose without the em-dash double-hyphen, per standing feedback.)*

  **Guide headline: the issue's own framing was falsified by a three-line run (§12 × §5, surfaced by §16).** The ticket framed the fix as "suppress the stray warning; the bridges already flatten to naive-UTC." Running the three temporal paths side by side (xarray/numpy, pandas, `resolve`/`to_datetime`) on one offset value showed they *disagree*: xarray flattens with a warning, pandas keeps it tz-aware, `resolve` keeps it tz-aware. So the "consistent naive-UTC default" the issue leaned on did not exist, and the real task was "choose the offset projection and make the two bridges agree," not "silence a warning." **Signal, sharpening #109's "a sibling reveals the shape": that move works in *guide* mode, before any code, and against the *issue text* itself. A one-paragraph run of the sibling implementations can overturn the ticket's stated premise, so guide mode must run the siblings, not reason from the issue.**

  **Self-authored §16 miss: I wrote an escape-hatch claim into the docs, and only a user-prompted run falsified it.** In the guide and the docstrings I stated `to_datetime` is the faithful escape hatch for a caller who wants the offset preserved, and applied it to *both* the standard and cftime paths. It is wrong for cftime: `resolve`/`to_datetime` is calendar-blind (it parses proleptic-Gregorian), so `to_datetime("2020-02-30T00:00:00+05:00")` returns `None`, because Feb 30 is a real `360_day` date and not a Gregorian one. The claim read as correct and had already been written into a docstring and the guide; the correction came only when the user asked "what scenario would even hit the cftime path with tz worth preserving?", which prompted the run. **Signal: "affirmed is not closed" covers self-authored *prose*, not only code, and a plausible cross-subsystem cross-reference (`to_datetime` to the cftime bridge) is reasoning until the boundary input is run. Provenance: I did not self-trigger the discharge, the *user's* question did. A self-authored design does not reliably run its own claims even when the skill says to, so an external prompt (a reviewer who is not the author) stays the likeliest trigger.**

  **Diff-review §16 turned on a test's assertion-scope: a guard that cannot catch what it guards.** The regression test asserted "no tz warning leaks" by filtering on the *exact numpy message string* the production code suppresses. If numpy ever rewords that message, the production filter stops matching (the warning leaks again) and the test's filter stops matching too (the leaked warning is not escalated to an error, so the test stays green). The guard shared its predicate with the thing it guards, so it was blind to precisely its own failure mode. Fix: assert on *any* `UserWarning`, keeping the production filter narrow. **Signal: §16 applies to a test's own assumption, not only the input under review; a test whose predicate is copied from the code it guards cannot detect that predicate going stale. (It later went moot when the fix moved to fold-before-parse and emits no warning at all, but the structural point stands.)**

  **A dependency-floor viability question, answered by running the whole version line, and closed by the user spotting the gap (§7 traded against a dimension it does not own; the uv-minimum-versions oracle).** The user asked for a thread-safe alternative to the process-global `warnings.catch_warnings()`. Two shapes: fold the offset to naive-UTC before numpy sees it (self-contained, chosen as Option F), or route the standard parse through pandas' vectorized parser (faster on an all-offset axis, but its out-of-ns support is version-gated). Pinning the pandas floor for the pandas route meant *running a version matrix*: 2.1, 2.2, and 2.3 all raise `OutOfBoundsDatetime` on an out-of-ns date, only 3.0 widens to `datetime64[us]`, so that route would force `pandas>=3.0` versus the current `>=2.0`. I first tested 2.1/2.2/2.3.0 and concluded "floor is 3.0"; the user then asked "any 2.x with minor > 3?", which drove testing the *final* 2.x release (2.3.3, published after 3.0.0, the likeliest home for a backport): it still raises. **Signal, echoing #109's "viability lives in a dependency version, run the floor": a "the floor is X" claim is unearned until the *entire* version line below the boundary is run, including the last patch of the last pre-boundary minor. And again the author under-ran (stopped at 2.3.0), the user closed the version-space gap.**

  **Process + recurring.** Guide reshaped the fix against the issue's own framing (ADR-0015 updated, not superseded), with the offset semantics and the deferred pandas floor logged as decisions in the ADR. ponytail merged two near-identical pandas tests into one parametrize (the repo's stated preference). xhigh code-review's conventions angle again caught a comment narrating past behavior plus an issue ref (the same user-memory convention #109 tripped), and then the user challenged a `# pragma: no cover` on `maybe_datetime`'s malformed-fallback: running a malformed value proved the branch reachable, so the pragma became a test. **Signal: a `# pragma: no cover` is a claim ("this cannot or should not be tested") that rots as the surrounding code changes, so treat it like any other unearned verdict and run the branch before trusting it.**

- **2026-07-20, second A1 landing off the ledger (not a review run).** A scoped harvest-and-land pass, prompted by a "how are things looking" status check after the log had raced 9 entries (07-17 titiler #65 to 07-20 #153) ahead of the ledger and SKILL.md. Read the 9 unharvested entries, confirmed A1/§16 was the runaway theme (it fired in all 9, in new directions the first landing's one-sentence Move did not cover), and landed only that, one focused edit, per the workflow's "isolate the behavior-changing edit" rule. **Landed into SKILL.md:** sounding 16's Move gained "the run target is wider than the input under review" (run the excluded case to test its stated reason, the downstream consumer to rank leverage pre-code, and the check itself: delete a case arm to see the type-checker go red, run the boundary on the oldest supported environment; resolve a default to the value it produces, not its description); the "Affirmed is not closed" Working note gained "the claim need not be code" (a docstring, a narrative .md nothing executes, a test predicate copied from the code it guards, a `# pragma: no cover`), "the discharge hunts un-swept ground," and the provenance rule (the author under-runs even when the skill says to, so an external prompt is the likeliest trigger). **Ledger:** §A1 sub-rules (h) through (m) recorded with cites (#65/#137/#138/#139/#109/#147/#153), marked landed; §F item 1 flipped to done. **Deliberately deferred:** (f) citation-is-a-claim and (g) decode-the-bytes (pre-07-17, route through sounding 12 / already ledgered); the full re-harvest of 07-18 to 07-20 (ranking unchanged, so make-work now); and A2/A3/A5/A6/A7 plus the two new sub-themes (prose-drift-after-reversal; run-the-sibling-to-find-the-shape), each to its own isolated window. **Validation:** same as the first pass, dogfooding not a test, watch whether runs where 16 fires now reach for the excluded case / consumer / verification-code by default.
