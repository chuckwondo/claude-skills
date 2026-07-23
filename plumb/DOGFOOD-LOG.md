# Plumb: dogfood log

*Real review-mode runs (and a few refinement actions), per step 2 ("Dogfood,
then tighten") of [REFINEMENT.md](REFINEMENT.md). Track what fired, what
co-fired, and what each run drove into the skill. Append-only, and deliberately
separate from REFINEMENT.md's rewrite-in-place design state so the log can grow
without churning it.*

*New entries carry the `Corpus:` and `Unhomed:` tags defined in
[CORPUS.md](CORPUS.md), so fire-frequency can be stratified by corpus rather than
pooled. Review runs before 2026-07-20 are all `self-plumbed · clean · python`, shape
`library` or `service`, except two: the **zarr-python audit** (`external-reviewed ·
mixed · python · library · brownfield`) and **PR #130** (`external-raw`, an outside
contributor's diff). Those two are the only existing non-`self` data.*

- **2026-07-07: covjson-msgspec `feat/temporal`** (temporal.py + the
  Result/Report rename). Fired: **15** (headline, a year-0000 date mislabeled
  `Unrepresentable` instead of `Malformed`; found only by *running* `resolve` and
  comparing a differential twin, `0000-13-01` vs `2020-13-01`, not by reading the
  type or docstring, both of which *claimed* correctness), **1** (`Moment` permits
  naive+`SECOND`: real, but parked: sole trusted constructor upholds it), **5**
  (`resolve` vs the three bridge parsers can diverge: deferred in ADR, sharpened
  the note). **Co-fire: 4 + 15 on the headline**, a name/type that lies, surfaced
  by a breaking edge. Its leverage came entirely from the *downstream trace*: the
  mislabel defeats `validate(check_values=True)`, which is what promoted it from
  nit to net. **Drove:** the "measure leverage by tracing to the consumer /
  fix-vs-park" Working note: one trace resolved both #1 (fix) and `Moment` (park).
  **New signal for the tightening pass:** plumb *affirming* a sound decision (the
  Result/Report split, sounding 4) was valuable output, not filler; the output
  format absorbed it as an "Affirmed true:" line with no spec change needed,
  worth explicitly sanctioning affirmations when the combine pass rewrites Output.
  **Also drove (from the follow-up exchange, not the run itself):** the "expand
  the load-bearing findings" Output rule. The parked `Moment` finding, left as a
  terse line, prompted a request to explain it; the illuminating answer's *shape*
  (concrete instance → failure scenario → why-the-fix-is-wrong) became the
  required expansion for the top finding and every park verdict. Note the
  provenance signal: a *park* verdict is the likeliest thing to trigger "explain
  that," so it earns the depth even when its leverage is low.

- **2026-07-08: sourced enrichment of sounding 5 (not a review run).** Folded the
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
  to done: **SPLIT EXECUTED the same session (see the next entry)**: FC/IS is now
  its own sounding 6, and sounding 5 is DRY/reuse only.

- **2026-07-08: split executed (Option A).** Acted on the tension the enrichment
  surfaced: separated the two ideas fused in the old sounding 5. Sounding 5 is now
  **DRY/reuse only** ("one source of truth; compose"); the functional-core/effects
  material became its own **sounding 6, "Functional core; effects at the edges"**
  (carrying the FC/IS + sans-IO + ports-&-adapters lineage and the *Lineage &
  sources* list). Renumbered former 6–15 → 7–16 and fixed the `[combine?]` cross-
  refs (5↔6 now co-flagged), so any pre-2026-07-08 sounding number ≥6 (e.g.
  elsewhere in this log) is +1 under the new scheme. Rationale (for the tightening pass): the
  two are **independently violable** (a repeated formula in a pure module = DRY
  only; an inline `datetime.now()` in a used-once fn = functional-core only) and the
  fused title needed an "and": a cohesion (sounding 9) smell in plumb itself.
  **Chose the narrow split (effects only), NOT the wider "seams at the edges"
  merge** that would also absorb *open-for-extension* (policy-injection): the two DI
  faces share a fix mechanism but differ in *strength* (pushing effects out is
  near-unconditional; opening for extension is conditional and ponytail-bounded), so
  fusing them would blur a proportional-response (sounding 12) distinction. That
  merge stays parked for the DI-cluster tightening: see the seams/DI cluster note.

- **2026-07-08: landscape scan & boundary-sharpening (not a review run).** Swept the
  public skills ecosystem for prior art / neighbors (per "are we reinventing the
  wheel?"). Findings recorded in **[LANDSCAPE.md](LANDSCAPE.md)** (new living snapshot).
  Verdict: not reinventing it, one adjacent *review* skill exists (NTCoding
  `lightweight-design-analysis`, clean-code/OO/DDD), differing from plumb on **method**
  (dimension-completeness vs leverage-ranking), **stance** (no plumb-line vs judge-
  against-ideal), and **breadth** (6 soundings: 7, 11–16, the OO tradition doesn't
  reach; that fidelity/decision-cost cluster is the moat). This drove four changes:
  (1) **Frontmatter re-led**: moved leverage-ranking + judge-against-ideal to the
  front so the router no longer opens with "make illegal states unrepresentable," the
  phrase bucket-1 skills own. (2) **Sounding 2 gained a Boundary line**: states plumb
  takes the errors-as-values side and where the fail-fast/throw seam sits, resolving the
  rival-tradition tension with NTCoding's "fail-fast, throw." (3) **Candidate sounding
  17 "Locality of behavior"** minted from NTCoding's feature-envy detector, carrying a
  `[combine? with 9, 10]` marker (its kernel: behavior-with-its-data, GRASP Information
  Expert: sits at the cohesion/encapsulation intersection; merge-or-keep deferred to
  the tightening pass). (4) **Boundary-sharpening added as a Locked decision** (standing
  lens; some overlap is acceptable if load-bearing: cut only the accidental kind).
  **Bears on the tightening pass:** sounding 17 is a fresh merge/split candidate to
  judge with the "independently violable?" criterion; LANDSCAPE.md's ❌-gap column is
  the distinctness evidence for keeping 7 and 11–16 through the combine pass.

- **2026-07-08: covjson-msgspec #14 plan** (OpenAPI schema bridge; review mode on
  the *implementation plan*, before any code). Fired: **16 + 1** (headline, a
  host-app component-name collision: `component_schemas()` emits generically-named
  components (`Parameter`, `Unit`, `Domain`) that `dict.update`-merge into a host
  app's `components.schemas` and silently clobber a same-named host schema; found by
  tracing the merge to the real consumer, a titiler-style host with its own
  `Parameter`). This was the plan's OWN open question, parked as "we'll name them to
  avoid collisions": plumb refused the park and promoted it to must-fix. **1 + 4**
  (untyped `schema_ref(type)` could mint a `$ref` to an unregistered component).
  **Affirmed:** 6 (pure core / thin adapter), 14 (trivial path over complete core),
  12 (version claims verified against the FastAPI / msgspec sources). **Drove (into
  the work, not the skill):** namespace every component under one
  `_REF_TEMPLATE` / `_NAMESPACE` constant (illegal state → unrepresentable, 1; also
  a single source of truth, 5); type `schema_ref` to `type[CoverageJSON]`.
  **Signal:** plumb on a *plan* caught a design flaw before code existed, so the
  namespacing / typing landed in the first implementation pass instead of as
  code-review churn.

- **2026-07-08: covjson-msgspec #14 implementation** (review mode on the diff).
  Fired: **5** (headline, `_ROOT_TYPES` re-lists the `CoverageJSON` union
  membership; found by tracing the drift: a future 6th union member would be
  silently omitted by `component_schemas()` AND `schema_ref` (now typed to the
  union) would then mint a dangling `$ref` for it: reopening the exact door the
  plan-review closed, and the new exact-surface *test* would not catch it, being
  pinned to the same hand-list). **Drove:** `_ROOT_TYPES = get_args(CoverageJSON)`
  (the union becomes the single source), plus a bonus low-coupling (8) win
  (schema.py imports only the union, not each member). **Parked 5/16:** `schema_ref`
  derives the component name via `type.__name__` while `component_schemas` uses
  msgspec's key: two derivations that agree for our non-generic structs and are
  pinned by the parametrized test; real but parkable. **Affirmed:** 6, 1.
  **Signal:** the diff-review's headline (5, one source of truth) was a *different*
  sounding than the plan-review's (16 + 1): evidence the two altitudes are
  complementary; folded into a Working note ("run plumb at both altitudes"). Also:
  sounding 6, split out earlier this same session, carried real weight in both #14
  runs: the split earned its keep immediately.

- **2026-07-08: covjson-msgspec `feat/validation-should-domain-type`** (#37, the
  domainType SHOULD/conflict validation checks; two runs on one feature, both
  altitudes: a second full instance of the "run at both altitudes" note after #14).

  *Plan run (guide→review on the proposed design).* Fired: headline **co-fire
  4 + 12 + 15** on the variant then named `CoverageRedundantDomainType`: the name
  "redundant" *lies* for the differ-case (a member declaring a *different* type than
  its collection is a §6.5 contradiction, not harmless redundancy), the two
  situations carry different severities (warning vs error), and the tag is a
  **one-way wire code** (ADR-0006) so the wrong frame hardens. Leverage from the
  downstream trace: a consumer filtering warnings-as-advisory silently downgrades a
  real inconsistency, and `mode="raise"` (errors-only) never catches it. **Drove the
  design** (not just a note): split into a warning (`NotOmitted`, equal) + an error
  (`Conflict`, differ). Sounding **12** also fired as a *process*: the run flagged
  rule (c) as ungrounded ("can't cite it"), which forced an actual spec fetch that
  flipped two decisions: (c) *is* a real SHOULD → kept; rule (b)'s SHOULD is
  conditional on an unfetchable remote domain → dropped (**co-fire 6 + 12**,
  sans-IO). **Affirmed:** the two-variant split, tier (11), dropping (b).

  *Diff run (review mode on the diff, after the code-review fixes).* Fired: headline
  **5 surfaced by 16**: the fix for a code-review finding *introduced* a
  one-source-of-truth drift: the JSON-pointer logic re-derived "which level declared
  the type" with `domain.domain_type is not None`, while `effective_domain_type`
  resolves the value by truthiness (`declared or ...`); they diverge on an
  empty-string `domainType`, so the emitted finding's payload (`"Grid"`) and its
  pointer (the empty domain member) contradict each other. Found only by probing the
  breaking edge (`""`). **Drove:** align the predicate to the same truthiness (one
  line), plus a doctest pinning the `""` case.

  **New signal for the tightening pass:** (1) *Second confirming instance of the
  "both altitudes catch different flaws" note*: plan caught the naming/modeling of
  the differ-case (4/12/15); diff caught a drift that only existed once code (a
  code-review fix) was written (5/16). (2) The diff-run finding was *created by a
  code-review fix* → argues for sequencing plumb-diff **after** code-review and its
  fixes, since a correctness fix can introduce structural debt plumb then catches.
  (3) Sounding 12 acted as a *forcing function for verification*, not just a grading
  rule: "can't cite it" was itself the finding that drove opening the spec; worth
  naming 12's dual role (grade proportionally **and** go verify) if the combine pass
  touches it.

- **2026-07-09: covjson-msgspec #69 plan** (monotonic primitive-axis MUST
  validation; review mode on the design plan, after a long interactive design
  conversation, before any code). Fired: headline **co-fire 3 + 5**, the default
  checker's "which reference system orders, and how" was split across two
  mechanisms (`temporal_coordinates` for the temporal case, an `isinstance(system,
  (Geographic|Projected|Vertical)CRS)` chain for numeric) with an implicit
  `else: skip`, i.e. a non-total classification. Leverage from the downstream
  trace: a future *ordered* `ReferenceSystem` variant added to the union falls
  through the isinstance chain, is silently classed "skip", and a genuinely
  non-monotonic numeric axis passes `validate(check_values=True, mode="raise")`
  with no error AND no compiler nudge: a silent false-negative on a spec MUST.
  **Drove the design:** one total `_ordering_kind(system) -> Literal["numeric",
  "temporal"] | None`, exhaustive `match` + `assert_never`, which also became the
  single code home for the ADR's ordering registry (the 5 half) and forced the
  standard-calendar gate *inside* the classifier (a mirror hazard the trace
  surfaced: a non-standard-calendar `TemporalRS` would otherwise be fed to the
  Gregorian `resolve` and silently mis-compared). **15 + 9** on the
  `AxisOrderChecker(values, system)` signature: a public one-way door, resolved
  by the *cohesion* argument (the seam's one concern is coordinate-value ordering,
  so it takes `values`, not the whole `Axis`; bounds-ordering is a separate future
  check) and recorded as a deliberate door in the ADR rather than widened
  speculatively. **12** (mild): the RS-ordering classification is our
  *interpretation* of §6.1.2's "natural ordering", not verbatim spec; drove an ADR
  framing note (cite 6.1.2, don't present it as a quoted enumeration). **5** again
: the coord→system index duplicated xarray's private `_coordinate_systems`;
  since `_bridging.py` was already being opened for `is_standard_calendar`, drove
  lifting `coordinate_systems` there now (two consumers) and migrating xarray off
  its private copy. **Affirmed:** 6 (the injected-seam-with-shell-resolved-default
  *is* the design's spine: done well, so plumb's value shifted inward to the
  totality/purity of the injected default's internals), 11 (O(n) scan gated in
  `check_values`, not `__post_init__`), 14 (trivial default under `check_values`,
  strict via `require_monotonic(strict=True)`, full override via the seam), 7
  (temporal compare via `resolve`, no stored datetimes). Routed the `bool`-is-`int`
  and NaN-coordinate walk edges to code-review by name.

  **New signals for the tightening pass:** (1) *Plumb earned its keep on a
  heavily-deliberated plan.* The seam shape, its naming
  (`AxisOrderChecker`/`axis_order_checker`/`require_monotonic`), the `int | None`
  return, even the `None`-sentinel default had already been argued out over many
  rounds of interactive design: all *local* decisions, yet none surfaced the
  *global* totality/one-source gap that plumb's union-growth trace caught. Evidence
  that plan-altitude plumb is not redundant with careful iterative design; they
  optimize different scopes. (2) *Sounding 3 (totality) as a headline* is a first
  for the log (prior headlines: 4, 5, 12, 15, 16), and it co-fired with 5 the same
  way #14's runs coupled 1↔5: "add a case → silently skipped" is a totality smell
  whose *leverage* is a one-source-of-truth drift; worth watching whether 3 and 5
  should be cross-flagged. (3) *When DI (6) is already done well, plumb's yield
  moves inward*: from "should this be injected?" to "is the injected default's
  core total and single-sourced?"; the flaw lived inside the well-chosen seam's
  default, not in the seam decision. (4) *Sounding 12 fired twice, once outside the
  formal run*: before the /plumb invocation, the user challenged a spec section
  number (our 6.1.1 vs the OGC HTML's 9.6.1.1), forcing an actual spec.md fetch
  (12's verify-against-the-source facet, the same forcing-function role noted in
  #37): a reminder that 12 operates whenever a spec claim is made, not only inside
  a review.

- **2026-07-09: titiler-covjson #44 plan** (`/position` Point-domain slice; review
  mode on the plan, and the log's first **re-review of a plan plumb had already
  reviewed once**, 2026-07-08, after a blocker-merge gap). Fired: headline **co-fire
  7 + 1**: the plan enshrined a phantom `(bands, 1)` axis on `PointInput.data` (a point
  sample is one-scalar-per-band = `(bands,)`); leverage from the downstream trace: the
  unfaithful shape forces a converter reshape, a `shape[1] == 1` guard, a *load-bearing
  warning comment* ("don't simplify this away"), and a `(2, 3)` test case: four
  consequences of one invented axis. The kicker: this **overturned first-pass finding
  2**, whose own empirical note ("`data[i]` on a 1-D array returns a bare `float32` for
  an unmasked band") was *correct but mis-diagnosed*: it concluded "keep `(bands, 1)`"
  when the real cause was integer-indexing, and a *slice* `data[i : i + 1].reshape(())`
  yields a proper 0-D `MaskedArray` on the honest `(bands,)` shape. Caught only by
  **running the counterfactual probe** (index vs slice, masked/unmasked, float/int), not
  by re-reading the note. **16 + 1**: `_parse_point_wkt` admits non-finite coords
  (`float("nan")`/`float("inf")`/overflow `float("1e400")` all parse), and a NaN
  coordinate serializes to a silent `"values":[null]` axis (verified by constructing
  `ValuesAxis` + dumping) → a dishonest 200; the parse boundary must yield a *trusted*
  `Position`. **5 + 13**: `_resolve_read_bands` should return `tuple[BandInfo, ...]`
  uniformly (build BandInfo for the expression case too) so both `_build_*_input`
  collapse to one call shape and become true mirrors. **5**: `reject_vertical_selection`
  reject-on-truthiness so a valueless `?z=` is absent, matching the codebase's
  empty-is-absent convention. **3 + 15**: keep each commit green: the `CoverageInput`
  union flip belongs with the modeler arm, not the `PointInput` definition, else
  `assert_never` is red between commits. **Affirmed:** the plan's spine, a real
  `GridInput | PointInput` union with exhaustive `match` (3), a dep-free `Position`
  value type (1/6), a pure modeler with WKT parsing confined to the shell (6), heavy
  symmetry with `/bbox` (13).

  **New signals for the tightening pass:** (1) *First logged re-review of the same
  plan, and it flipped a prior headline.* A finding is itself falsifiable by a later
  pass, and what caught the mis-diagnosis was **empirical discipline applied to the
  proposed fix, not only the design under review**: the first pass ran a probe but
  stopped at "the crash happens" without testing whether an alternative indexing avoids
  it. Argues for a Working-note nuance: when a fix is "keep shape X to avoid crash Y,"
  hunt the breaking edge (16) on *your own fix*: verify the counterfactual (does an
  alternative avoid Y without X?), not just that Y occurs. (2) *Faithfulness (7) as a
  headline*: new for the log (prior headlines: 4, 5, 15, 16, and 3 on #69), co-firing
  with 1 the way earlier runs coupled 1↔5 / 3↔5. Candidate heuristic: **a comment that
  *defends* a shape is evidence the shape is unfaithful**: the "don't simplify this
  away" warning was the tell that the trailing axis shouldn't exist. (3) *Both-altitudes
  note, new angle:* both passes were plan-altitude (not plan-vs-diff), yet the second
  still found what the first missed, because the first pass's *verification* was
  incomplete, not because the altitude differed. Distinct from the #14/#37 "plan vs diff
  catch different flaws" signal: this is "same altitude, stricter empirical discipline
  catches a mis-diagnosis," so re-review value isn't only altitude-switching. (4)
  *NaN-coordinate routing nuance:* #69 routed a NaN-coordinate walk to **code-review**;
  here the same class stayed in **plumb** because the assumption lived in the
  parse-*boundary*'s shape (a `Position` that promises trusted values but doesn't,
  sounding 1), not in a downstream value check. Rule of thumb: NaN-in-values →
  code-review; NaN-admitted-by-a-boundary-that-claims-to-produce-trusted-values → plumb.

- **2026-07-09: covjson-msgspec #69 diff review** (the monotonic-axis feature as
  implemented; review mode on the diff, AFTER the earlier #69 *plan* review and AFTER an
  xhigh *code*-review that found + fixed a NaN-coordinate edge). Outcome: **net "Plumb is
  true."** The plan-pass's load-bearing fixes all landed in code and hold: **affirmed:**
  3 (`_ordering_kind` present and total, `assert_never` over the real `ReferenceSystem`
  union), 5 (`coordinate_systems` lifted to `_bridging`, xarray migrated off its private
  copy), 6 (pure check, the ordering policy injected as a seam), 11 (O(n) scan gated in
  `check_values`), 15 (the `(values, system)` one-way-door signature kept narrow). The
  single live finding was a **6-vs-5 wash:** the seam's default (`None →
  require_monotonic()`) resolves at the *leaf* (`_axis_monotonic_issues`, once per
  domain) rather than the *edge* (`validate`, once per call) the plan's wording implied.
  Traced to the consumer: **no wrong output**, the only cost is a per-coverage closure
  rebuild inside a `CoverageCollection`, nanoseconds against the O(total values) scan.
  Parked as a wash because edge resolution *can't cleanly deliver* the sounding-6 purity
  win: `_axis_monotonic_issues` must keep a `None` fallback for its own direct doctest
  regardless, so moving resolution to `validate` only *adds a second* site (a sounding-5
  cost) for a negligible gain. Two tiny parks: 1 (the `keyed` "mutually comparable"
  invariant lives in the docstring, not the type, but a single trusted caller upholds
  it) and 2 (`_temporal_keys` returns `None` = "declined to order" vs `[]` = "trivially
  ordered", distinct honest meanings, no consumer conflates them).

  **New signals for the tightening pass:** (1) *A thorough plan-review can front-load the
  structural fixes so the diff-review is confirmatory, not corrective.* This is the
  **complement** of the #14/#37 "plan vs diff catch *different* flaws" signal: there each
  pass earned its keep by finding a distinct defect; here the diff-pass came back
  essentially clean *because* the plan-pass was thorough (`_ordering_kind`, the dedup, the
  seam signature were all designed and then implemented faithfully). "Diff-review returned
  Plumb-is-true" is itself a positive signal about plan-review thoroughness, not a wasted
  pass: worth naming so a clean diff-pass isn't read as "plumb found nothing, skip it
  next time." (2) *A finding can resolve to "the code is right, the plan/narrative was
  wrong."* The diff-review caught the implementation deviating from the plan's stated
  shape ("resolve once in the shell"), then judged the deviation an **improvement** (the
  doctest-direct-call convention forced the cleaner single-site leaf form), so the
  resolution was to correct the design doc's mental model, not the code: plumb judging
  the artifact against the *ideal* (its core stance) vindicated the implementation over
  its own plan. Distinct from every prior entry where a drift-from-plan was a regression
  to fix. (3) *Skill-partition confirmed again* (per #37's sequencing note): diff-plumb
  ran after code-review and its NaN fix, correctly left the NaN in code-review's lane, and
  stayed structural: the two skills partitioned cleanly with no double-coverage.

- **2026-07-09: titiler-covjson #44 diff, commit 1** (the Point input layer; review
  mode on the staged diff, the complement to the same-day #44 *plan* re-review earlier
  in this log, run after the code plus an interleaved ponytail-review and code-review).
  **Verdict: Plumb is true**, the plan re-review had already caught the one load-bearing
  shape issue (the `(bands,)` flip) and it landed faithfully, so this pass produced one
  park plus affirmations, no fix. **Headline park (4 / 1 / 13)**: `GridInput.bounds:
  tuple[float,float,float,float]` vs the diff's new `PointInput.position: Position`: the
  diff models Point's location as a named value type with no empty state, while the
  sibling models its extent as a bare 4-tuple whose `(west,south,east,north)` order is
  positional convention (`(minx,maxx,miny,maxy)` is equally constructible: a
  sounding-1/4 smell). The park flags the **incumbent** `bounds`, not the diff; the move
  is "make `bounds` a value type to match," deferred as out-of-scope (internal, two-way
  door, tested). **Affirmed:** 7 (`data = point.array` at `(bands,)`, no reshape, the
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
  is a one-source-of-truth structure that did NOT exist at plan time: it emerged from the
  interleaved code-review's dedup finding. #14's diff-run CAUGHT a one-source-of-truth
  *drift* that only existed once code was written; here the diff-run *affirmed* a
  one-source-of-truth structure that only existed post-code. Same axis (5 at diff
  altitude), inverse polarity (drift-caught vs structure-affirmed): evidence that
  post-plan structure introduced by sibling reviews is exactly what a diff-pass is
  positioned to judge. (3) *Second same-day instance of the entry-directly-above's
  signal*: a thorough plan-review front-loading the fixes so the diff-review is
  confirmatory (covjson-msgspec #69 above; titiler #44 here). Two projects, one day:
  corroboration, noted not re-derived.

- **2026-07-09: covjson-msgspec #18 plan + artifact iteration** (the
  covjson-pydantic benchmark harness; review mode on the *design plan*, then a
  long user-driven refinement of the rendered artifact: the log's first run on
  a **measurement/comparison artifact** rather than library modeling).

  *Plan run.* Fired: headline **co-fire 16 + 13 + 12**, the operation matrix
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
  **13 recurred, un-propagated**: the plan-pass fixed the asymmetry in the
  *decode* ladder but the identical one in *round-trip* (msgspec structural
  decode+encode vs pydantic full decode+dump) survived; caught by eye, fixed
  with two round-trip anchors mirroring the decode ladder. **12 marathon** on
  the validation-conformance scorecard: (a) an asserted claim ("pydantic doesn't
  check value-vs-dataType") was *false*: a verify-against-source violation in
  the wielder's own output, caught only when the user demanded empirical proof;
  (b) the "is malformed-temporal a warning?" challenge exposed the scorecard
  grading a **SHOULD** (Spec 5.2) as if MUST and marking pydantic's hard-reject
  *compliant*: fixed by grading every row by requirement level (MUST→error,
  SHOULD→warn) and re-marking pydantic's SHOULD-overreach. **7**: probe
  failures render the library's *verbatim* raised exception (`raises <Type>:
  <message>`), not a paraphrase; **2**: the null reverse-direction stated
  explicitly, `n/a` (not-applicable) kept distinct from `raises` (rejected).

  **New signals for the tightening pass:** (1) *A symmetry (13) fix must
  propagate to sibling operations.* The plan-pass scoped the fix to where the
  flaw was spotted (decode); the same structure in round-trip survived because
  it was one line in the plan and its internal asymmetry only became salient
  once written out. Candidate Working-note: when a fix is "make comparison X
  fair," apply it to every sibling sharing the structure: the fix's blast
  radius is a leverage question too. A third flavor of both-altitudes: plan
  caught the class, use exposed an un-propagated member. (2) *Sounding 12's
  verify-facet turned on the wielder.* The reviewed artifact was mine, and I
  repeatedly asserted pydantic/spec behavior from memory with the user as the
  12-enforcer: reinforces that "verify, don't assert" binds the reviewer's own
  claims, not only the code's. (3) *First run on a comparison/measurement
  artifact*, whose entire value is honest, verified, proportional claims:
  sounding 12 *is* the artifact's correctness condition, not a side-check; every
  scorecard cell is a spec-conformance claim, so MUST/SHOULD grading (12) and
  verbatim errors (7) were load-bearing. (4) *16 fired on the benchmark's own
  fairness assumption*, not on a code input: the breaking-edge probe applies to
  a *methodology's* hidden assumption ("this comparison is like-for-like") the
  same way it applies to a parser's.

- **2026-07-10: covjson-msgspec #77 plan + diff** (model the five
  `CoverageCollection`-inheritance members with `msgspec.UNSET` instead of
  `X | None`, so decode rejects a spec-forbidden `null` and "omitted" stops
  aliasing "explicit null"; two runs, both altitudes: plan-review inside plan
  mode, diff-review after implementation + an xhigh code-review).

  *Plan run.* Fired: headline **3 + 1**, the `is None`→`is UNSET` swaps in
  `_resolve` and the missing-parameters check assume the five fields are never
  runtime-`None`, but `msgspec.Struct.__init__` doesn't type-check construction,
  so `None` stays *representable* though the annotation forbids it; a smuggled
  `None` skips the "absent" branch it used to hit (e.g. falls into the
  parameter-group validator, which expects a dict). Leverage from the trace: no
  consumer can *reach* the bad state except a mis-constructor, and strict
  mypy/basedpyright forbid every internal `None`-construction, so the finding is
  real-but-guarded, verified by naming the invariant + its typecheck guarantor
  (do NOT write `is UNSET or is None`, which re-merges the two states the change
  exists to separate). **12**: the entire reject-`null` decision rests on "the
  spec forbids `null` here"; flagged as assert-from-memory, which forced an
  actual spec.md fetch (§6.4/§6.5: members typed object/string/array, inheritance
  on *absence*, `null` nowhere permitted) before the ADR could cite it. **16**:
  a present-empty `{}` must *suppress* inheritance (it is not absence); untested.
  **Drove:** the load-bearing-invariant callout + guarantor in the plan, the
  ADR's spec-citation requirement, and the `{}`-suppression test. **Affirmed:**
  11 (reject-`null` is tier-1 decode typing, not a `validate()` job: a `null`
  for an object-typed field is a field-*type* mismatch, the same class as
  `"parameters": 5`), 7 (reject over silently coercing `null`→absent).

  *Implementation confirmed the plan headline mechanically.* The totality (3)
  prediction was verified not by hand-enumeration but by the *typechecker*:
  mypy named the missed consumers (`_validate_ranges`, `_member_domain_type_
  issues`), and by the *corpus*: a "normalize at the boundary" fix
  (`parameters or None`) silently collapsed present-empty `{}`→`None`, defeating
  `range-without-parameter`; the negative fixture caught it, and the fix narrowed
  to `None if parameters is UNSET else parameters` (a **7** faithfulness save
  *inside* the normalization). A latent *wrong plan instruction* neither the plan
  nor the plan-review caught: "the `self.<field> is not None` guards can stay",
  surfaced only at implementation, because `UNSET is not None` is `True` (an
  inverted-guard bug the type-checker can't see but reasoning did).

  *Diff run (after implementation + an xhigh code-review that returned clean).*
  Fired: headline **5 + 16**, the diff carries five UNSET-handling idioms
  (`is UNSET`, `X or None`, `None if is UNSET else X`, bare truthiness,
  `X or UNSET`), and two are *not* interchangeable: `_resolve`'s explicit
  `is UNSET` **cannot** be "simplified" to `if not coverage.parameters`, because
  a present empty `{}`/`()` is falsy yet is not absence: the swap silently
  reinstates the graft-on-empty bug the change exists to kill. Surfaced by
  probing the breaking edge (present-empty vs absent). **Drove:** a comment
  pinning why truthiness is wrong **and** promoting the `{}`-suppression test into
  a comprehensive, labeled *regression tripwire* (`parameters={}` *and*
  `parameter_groups=()`), verified to *fail* the instant `_resolve` uses
  truthiness. **Affirmed:** 11, 7, 6 (`effective_domain_type` as the projection
  that contains `UnsetType`, never leaking it to a `str | None` consumer), 13
  (xarray's `or UNSET` on construct / `or None` on read: a clean symmetric
  normalization pair).

  **New signals for the tightening pass:** (1) *"Make illegal states
  unrepresentable" (1) can be UNREACHABLE, and when it is, the strongest
  available guard is an enforcing test, not a comment.* Asked "can we guard the
  truthiness-regression more robustly than a comment?", the honest answer is a
  gradient: type-level (make `if not x` a type error) > test (fails on the
  regression) > comment (informs): with the top rung *closed here* because
  `UnsetType.__bool__` is `False` (truthiness is type-clean) and the sentinel
  can't be swapped (msgspec needs `UNSET`). So the guard dropped to a *test*,
  which *enforces* where a comment only *informs*. Candidate Working-note: when
  sounding 1's ideal is unreachable, don't settle at a comment: reach for the
  test that pins the invariant. (2) *Not every idiom-repetition is a
  one-source-of-truth (5) violation.* The five UNSET idioms *looked* like a 5
  smell, and a unifying `_omitted()` predicate was considered, then **correctly
  declined**, because the variants encode *different decisions* (`or None`
  deliberately collapses `{}`; `None if is UNSET else x` preserves it), so a
  shared helper would *flatten* the load-bearing distinction. Refines 5:
  distinguish "the same knowledge in N places" (dedup) from "similar-looking
  idioms encoding different semantics" (pin with a test, don't merge). (3) *A
  totality (3) finding at plan altitude is verified by the typechecker + tests,
  not by enumeration*, and the verifying step can itself introduce a
  faithfulness (7) regression (the `{}`-collapse) that only the corpus catches,
  so "normalize the retyped value at each boundary" is a move to audit per-site,
  not apply reflexively. (4) *Both-altitudes, the #14/#37 "distinct flaws"
  flavor, not #69's "confirmatory":* plan caught the invariant/citation/scope;
  diff caught the idiom-consistency/regression-guard: a genuinely different
  defect, so the diff-pass earned its keep. Wrinkle: the plan carried a *wrong*
  instruction the plan-review missed (the `is not None` guards), caught only when
  implementation forced the type-checker to speak: a reminder that plan-review
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
  re-encodes the very difference? If not, it is not one source of truth: it is N
  sources wearing the same coat, and merging them hides a decision."* This also
  sharpens the split between 5 (genuine single-source) and the *guard* mechanism:
  where variation is intentional, the invariant is pinned by a **test** (signal 1's
  gradient), not by a helper. Merge-or-keep deferred to the combine pass; flag it
  next to the existing `[combine? with 6, 14]` marker on 5.

- **2026-07-11: covjson-msgspec #21 documentation plan** (the contributor-docs /
  single-sourcing architecture: `CONTRIBUTING.md` as the crisp contributor
  one-stop, design tenets in `docs/design/tenets.md`, ADRs canonical for specific
  decisions, a slimmed `CLAUDE.md` spine that `@import`s the human files, the docs
  site for orientation / concepts / design narrative). **Plan altitude, and a
  first for this log: the reviewed artifact is a *documentation information
  architecture*, not code: a system of Markdown files and canonical homes.** The
  soundings transferred cleanly: "types" became "canonical files"; "make illegal
  states unrepresentable" became "don't let one fact have two canonical homes that
  can drift"; coupling / cohesion / right-tier / reversibility read straight
  across.

  **Headline: co-fire 12 + 8, and 12 turned on the review *itself*.** The whole
  design cantilevered off Claude Code's `@import`. Per sounding 12 ("verified
  against it and cited, never asserted from memory"), I *fetched the Claude Code
  memory docs before ranking findings* rather than assert `@import`'s behaviour,
  and the verification **changed the findings, it did not merely confirm them**.
  It (a) *dissolved* a wrongly-framed candidate headline (my first instinct,
  "moving conventions out of CLAUDE.md weakens their authority", was false:
  imported content loads with **equal** authority to inline), and (b) *surfaced
  the true headline, invisible until the mechanism was checked*: `@import` **loads
  the target in full and does not reduce context**, and the docs' own guidance is
  that **longer instructions reduce adherence**. So making a warm, human-verbose
  `CONTRIBUTING.md` the canonical file `CLAUDE.md` imports **trades agent
  adherence for human friendliness**: the two audiences pull opposite directions
  on the *same bytes* (a coupling / cohesion smell, 8/9: one artifact, two
  consumers, conflicting requirements). Concrete instance: today's
  `CLAUDE.md#conventions` is terse and specific; a human guide wraps each rule in
  welcome prose; `@import`ed wholesale it bloats the launch context. Failure
  scenario: `CONTRIBUTING.md` grows to a friendly ~400 lines, imported past the
  ~200-line adherence budget, and the agent follows the conventions *less*
  reliably than today: the single-source win silently costs enforcement, with
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

  **Second finding: 5 applied unevenly.** The design single-sourced conventions /
  tenets fastidiously but left **orientation triplicated** (README + CLAUDE.md +
  docs): its own core principle, unapplied to its most multi-homed content.
  *Sharpened while folding:* "orientation" was itself **three conflated things**,
  the *pitch* (→ README), the *code module map* (→ CONTRIBUTING.md), the
  *data-model concepts* (→ docs), and only the act of assigning *one* canonical
  home forced the decomposition. **Third: 9/4, a fuzzy seam:** rules-vs-tenets has
  no decidable boundary ("build from small composable functions" is both),
  inviting the duplication the design fights; move = state the split test (a
  *tenet* explains why and is cited by the design docs; a *convention* is a
  do/don't a reviewer checks). **Parked: 5:** the install/extras matrix restates
  `pyproject.toml` (low leverage, named as a choice, not an oversight).
  **Affirmed:** **5** done right where it matters most, the API reference is
  *generated from the docstrings*, not restated; **15**: the whole thing is a
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
  due-diligence garnish: it can change what the headline is.* Strongest instance
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

- **2026-07-10/11: zarr-python full structural audit** (review mode on a large
  **third-party / upstream** codebase: a *first* for this log; every prior entry
  is the wielder's own greenfield covjson-msgspec/titiler. 40k LOC, mature,
  multi-author, brownfield; multi-session, spanning released `main` @ `13279cac`
  (== upstream zarr-developers main, verified same SHA) plus two active PRs
  #3885/#4049). **The "judge against the ideal, not the incumbent; conforming to
  bad precedent is itself a finding" stance did the heavy lifting**: the keystone
  (an `ArrayV3Metadata` DTO that runs the codec pipeline and reaches into
  `ShardingCodec` via lazy import) is an *established, load-bearing* pattern a
  conform-to-the-codebase review passes; plumb flagged it, and the code's own TODO
  agreed.

  Fired (main): headline **8 + 9 + 17** (metadata DTO → concrete codec, coupling
  cycle papered by a lazy import + feature-envy); **13 + 12 cross-sibling** (the
  "great find", below); **5** (NaN-safe `__eq__`/`__hash__` copy-pasted across
  both metadata classes; a codec-parse function triplicated); **6 + 11 + 15**
  (rectilinear grid reads global config inside a frozen `__post_init__` on the
  read path, and mints an unreleased RLE wire format: a two-way door about to
  become one-way); **1 + 10** (`ConsolidatedMetadata` `frozen=True` but its dict
  is mutated in place). **indexing.py returned essentially "Plumb is true"**: the
  selection types are structural unions resolved by *nominal accessor dispatch*
  (`OIndex`/`VIndex`/`BlockIndex` + an `Indexer` protocol), the right shape for
  numpy's inherent value-type ambiguity; **declined to manufacture** a sum-type
  finding to fill the file.

  **Headline (G1): co-fire 13 + 12, cross-sibling-against-spec.**
  `GroupMetadata.from_dict` lacks the v3 `must_understand` extra-fields handling
  that its sibling `ArrayV3Metadata.from_dict` has, so a spec-legal v3 group
  carrying a `must_understand:false` extension **crashes** (`TypeError`). Leverage
  from the downstream trace: external blast radius (any v3 group with an extension,
  written by *any* implementation, is unopenable here) atop a violated spec MUST,
  and it is **invisible reviewing either class alone**. Confirmed empirically
  (3-line repro → `TypeError`) and against upstream (same SHA). **Drove (into the
  work):** the finding + repro + fix (share the allowed-extra-fields logic across
  Array/Group metadata). **Affirmed:** dtype sum-types + boundary TypeGuards
  (1/2/4); `Array` as a pure sync shell over the async core (6); the error/warning
  taxonomy (2/12); and in PR #3885 the `chunk_utils` shared per-chunk compute core
  (5/6 done well: read/write *twins* parameterized by `decode`/`encode`
  callables, so sync/async can't drift), which moved plumb's yield *inward* to two
  seams (Finding A: `chunk_utils` leaf lazy-imports UP into the pipeline, 8;
  Finding B: the batch orchestrator branches `isinstance(pipeline, Fused…)` instead
  of taking an injected strategy the way its own per-chunk layer does: 8/9/3).

  **New signals for the tightening pass:**
  (1) **First third-party / brownfield-at-scale run: "judge against the ideal" is
  load-bearing here in a way greenfield can't exercise.** On greenfield the
  incumbent is usually absent; here the incumbent pattern often *is* the fault, and
  a self-flagging TODO is *corroboration*, not a reason to defer. Candidate:
  sanction external/brownfield audit explicitly in scope.
  (2) **A new co-fire shape: 13 × 12 across *sibling types*.** Prior 13 fired
  within one artifact (a decoder with no encoder; an asymmetric comparison). G1 is
  13 across two independently-written siblings diffed against a shared external
  authority (12). The reusable move: *when two types implement the same external
  rule, diff them against the rule, not just against each other*: the asymmetry is
  invisible per-class. Candidate 12↔13 cross-flag.
  (3) **Sounding 12 must bind the review's OWN substrate: pin the revision under
  review.** The run's real process failure: I asserted findings, then made a
  *wrong* hedge ("may not be upstream") because I had not pinned the exact
  branch/SHA. "Fork vs upstream" changes a finding's blast radius completely (G1 as
  a fork-only nit vs an upstream spec bug). Candidate Working-note: *a review
  finding is incomplete without the exact source revision it is against*, extend
  12's "cite the source, never assert from memory" from the spec to the **code
  under review**. Strongest actionable skill gap this audit produced.
  (4) **Check the tracker before ranking a finding "dead" / low-leverage.** A
  code-only scan flagged `ChunkTransform` as stranded/deletable; the issue tracker
  (#3720 roadmap, an 8-PR plan by a core maintainer) showed it is live, championed
  *foundation* awaiting its consumer PR: the "delete it" call was exactly
  backwards. Extends the "measure leverage by tracing to the consumer" Working note:
  on a codebase mid-migration the consumer may be a **future** one, visible only in
  the tracker. Leverage is a function of *trajectory*, not just current structure.
  (5) **"Contained" ≠ "right shape": a containment affirmation (6/8) can
  rubber-stamp a design whose *existence* is the question.** A first-pass verdict
  ("the sync bridge is a well-contained imperative shell") affirmed *local*
  containment while the real question was "should the sync path traverse the event
  loop at all": the user's push, then a microbenchmark (24.6× / ~171µs pure
  overhead), reframed it; then 12-verify (the maintainer's own PR had measured the
  same thing) reframed *again* from "critique" to "correct problem, already
  championed." Candidate nuance on 6: distinguish "the effect is contained" (local,
  affirmable) from "should this effect be on this path at all" (architectural): a
  clean containment verdict is not a clean architecture verdict.

  **Pending.** Whole audit delivered in chat only (no report file/artifact); the
  upstream issue/PR for G1 not yet filed. Provenance rider for any future pass:
  main-branch findings are @ `13279cac`; the #3885/#4049 verdicts (Finding A/B line
  numbers) are against PR-head branches and will drift.

- **2026-07-12: covjson-msgspec #74 value-screen + #18 benchmark continuation**
  (a full working session under **ponytail mode**, plumb *never invoked*: the
  log's first entry where soundings fired **organically, on live design
  decisions**, not in a `/plumb` run. Continues the 2026-07-10 #18 artifact entry.)

  *Design-decision 1: reject the `Raw` alternative (2 + 6 + 7).* User proposed
  typing `NdArray.values` as `msgspec.Raw` + deferred narrow-decode to push the
  value-type check to C. Works mechanically, wrong shape: a narrow typed-decode
  **raises** where `validate()` is an errors-as-values issue stream (2, and 6's
  "raise confined to the edge"), stopping at the first bad element: defeats
  validate's "report every mismatch with a pointer" contract *and* #74's own
  "identical Issue output" acceptance criterion; and it drags strictness **into
  decode**, breaking permissive/byte-faithful load (7, ADR-0002). Leverage from
  the downstream trace (the contract + the acceptance test), not the mechanism.
  **Affirmed the actual design:** the `msgspec.convert` screen as a fast *path*
  with the per-element scan as fallback keeps the issue stream identical, earning
  the C-speed win without touching the contract.

  *Design-decision 2: `values_as()` shape (4 + 6, + 5/7).* "Does the screen give
  typed accessors for free?" The same convert primitive yields the narrowed tuple,
  so a `values_as(dtype)` projection is ~free, **but** the narrowing must come
  from a caller type via `@overload`, else the return is a useless 3-way union (4);
  it raises, distinct from validate's stream (6/2); faithful union stays stored,
  precision is an opt-in *view* (5/7 = the "typed projection over a faithful core"
  tenet, ADR-0004). Filed #89.

  *Benchmark artifact: circularity (5 + 6).* `run.py` hard-coded conclusions about
  its own output ("grid-large stays slower"): a one-source/circular smell specific
  to *generated* artifacts: the doc argues against its own numbers the moment they
  change. Drove the template/data split (pure data-gen → `results.json`; authored
  prose in `results.template.md`; number-dependent interpretation in README, not the
  generator) + a compliance-parity layer. Also **5 + 9**: split README (methodology)
  from results.md (reading), one canonical home per audience (echoes the #21 IA entry).

  **New signals for the tightening pass:**
  (1) **Plumb fires organically, on a design *decision*, no invocation, under a
  competing mode.** Two instances (Raw-reject, values_as-shape) from latent triggers
  ("would that let us…?", "…for free?"). The structural lens self-selected over
  ponytail/code-review: confirmed from outside, user never named plumb. Candidate:
  recognize "would X work / does this give us Y for free / better ergonomics for Z"
  as design-review triggers.
  (2) **A project's locked tenets ARE soundings instantiated, and one tenet decides
  multiple proposals.** "Faithful core, precision as opt-in projection" (4/5/6/7) was
  load-bearing in *both* the Raw-reject and the values_as-shape. When a repo has
  written its tenets down (ADR-0002/0004, tenets.md), plumb's job is largely "check
  this proposal against them," and their leverage is that a violation defeats a
  *documented* contract: maximally citeable (12-adjacent).
  (3) **Circularity as a generated-artifact (5) smell:** a generator asserting
  conclusions about its own output. Fix = separate deterministic data-gen from
  authored interpretation. Extends the 2026-07-10 #18 signal 5 ("render from one
  structure so they can't drift") one level up: single-source the *claims*, not just
  the data, and keep them out of the generator.
  (4) **Same-artifact re-touch across sessions:** the #18 benchmark came back and was
  driven much harder. A logged artifact isn't "done"; a later session can raise its bar.

- **2026-07-12: covjson-msgspec #92 JSON-Pointer deferral (two `/plumb` passes:
  plan, then diff: the first entry where the "run at both altitudes" working note
  is exercised end to end on one feature)**

  Context: `validate()` built a JSON Pointer string at every node of its tree walk
  (threaded a pre-joined `path: str` down through every check), when a pointer is
  only needed at `Issue` emit: profiled at ~44% of a conformant call. The fix
  defers materialization: thread a component tuple, join only at emit.

  *Plan pass (5 + 10, with 7-in-docs).* Headline: the proposed root representation
  `("",)` (an empty-string first element so `"/".join` reproduces the leading
  slash) **splits the RFC 6901 format between `_ptr` and a root-seed convention
  every caller and doctest must know**: the leading slash lives in the sentinel,
  the separators in `_ptr`. One-source-of-truth move: root `()`, and `_ptr` owns
  the whole format (`"".join(f"/{esc(t)}"…)`). The trace that set leverage: the
  sentinel was chosen to preserve "byte-identical doctest output," but the only
  outputs that differ between the two models are ~25 `#/…` doctests illustrating a
  shape real `validate()` (seeded `""` → `/…`) **never emits**: Model A was
  protecting a *fiction* (7 applied to examples, not the data model). Also
  clarified, off-sounding, that deferral **subsumes** the micro-opt on the hot
  path (post-defer `_ptr` runs only at emit), so they're one issue at two ambition
  levels, not alternatives. User folded Model B in before approving.

  *Diff pass (affirm 5/10; new 1; park 5).* The plan fix landed: `_ptr` owns the
  format, verified against the built hunks. The **new** finding was a bonus the
  plan pass didn't claim: choosing `()` over `("",)` didn't just centralize the
  format (5), it **retired the one place an empty-string token was mandatory**, so
  a mid-path empty reference token (`(*path, "", …)` → a stray `//`) is now
  **unrepresentable by construction (1)**: a *higher* sounding than the plan
  pass's headline, visible only once built. Parked (5): `(*path, "coverages", i)`
  is computed twice, 3 lines apart, in `_validate_collection`, but it can't drift
  (identical literal tuple-builds, not a derived decision) and the "fix" (bind a
  `member_path` local) fights the language, since it lives inside a
  `chain(…) for … in enumerate(…)` genexpr that can't bind a local without
  unrolling into something clunkier; the fix is uglier than the smell. **Verdict:
  Plumb is true.**

  **Drove:** the entire implementation followed the plan-pass fix (root `()`,
  `_ptr`-owns-format, `_escape` leaf). Byte-identical real output (differential
  across 99 corpus files), `validate()` 2.0×, `validate(check_values)` 1.6×, the
  temporal `coverage-collection` `validate(values)` rung flipped 0.8× loss → 1.3×
  win. **Affirmed:** the deferral itself as functional-core (6), compute
  components inward, perform the join at the edge. Merged as PR #93.

  **New signals for the tightening pass:**
  (1) **Two-altitude run, novel shape: the diff pass's headline was a *higher*
  sounding than the plan pass's, and it was a bonus the plan fix produced without
  claiming.** Plan headline = 5/10 (where the format-truth lives); diff headline =
  1 (the chosen representation *also* made an illegal state unrepresentable). This
  is the cleanest instance yet of the "both altitudes catch different flaws" note,
  and refines it: the diff pass isn't only "did the fix land + what did writing it
  expose": it can find that a plan-pass fix has a *structural dividend* at a
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
  extend 7's reach explicitly to "a runnable example reproduces *real* output":
  an unfaithful example is a faithfulness defect even when the model is faithful.
  (4) **A park whose fix fights the language is a clean park.** The duplicated
  `(*path, "coverages", i)`: DRY says extract, but a Python genexpr can't bind a
  local, so the extraction costs a clean comprehension for a no-drift, no-value
  win. Sharpens the note-and-park test: weigh the fix's *own* structural cost, not
  just risk: a fix that trades a good shape for a DRY nit is worse than the nit.

- **2026-07-13: covjson-msgspec #94 temporal `resolve()` dispatch** (two `/plumb`
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

- **2026-07-13: covjson-msgspec #90 resolve-each-temporal-axis-once** (diff
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

- **2026-07-13: covjson-msgspec benchmarking (#97 / #99), not a review run; one
  method signal.** No review-mode run this session (benchmark-cell instrumentation,
  profiling, and issue drafting; no design review). Signal worth keeping: **#99**
  (native-parse `resolve()`'s datetime form via msgspec's C decoder) pre-registers
  a **differential test locking msgspec's accepted-form space to the ADR-0008
  contract** as an explicit *acceptance criterion*: msgspec accepts a naive
  datetime and a lowercase `z` that our spec form rejects, so borrowing its parser
  silently widens what we accept unless pinned. That is **sounding 16 (hunt the
  breaking edge) / the differential-twin method**: the same method behind this
  log's first headline (2026-07-07 year-0000 mislabel, numbered "15" pre-renumber)
: now applied **prospectively, written into the issue before code exists**.
  Extends the #14-plan signal ("plumb-on-a-plan caught a flaw before code"): there
  plumb-as-reviewer caught it; here the method is baked into how the issue is
  *specified*, not a review finding. **Bears on the tightening pass:** consider
  naming an explicit move: *when a plan / issue borrows an external primitive,
  pre-register the breaking-edge (a differential test pinning the borrowed
  contract) as an AC*: i.e., sounding 16 as a design-time output, not only a
  review-time finding. **Secondary (not novel):** the #74 rescope reconfirmed
  entry-1's "trace to the real source before pronouncing": a glib "close it" was
  corrected only by reading the two distinct scans (value-vs-`dataType`, done in C
  by #91, vs the still-pure-Python monotonic walk).

- **2026-07-13: titiler-covjson #41 sub-pixel-thin bbox reject** (two `/plumb`
  passes, plan + diff, both read "true"; a later `/code-review` caught a
  mainstream ship-blocker both affirmed past: the log's first *both-altitudes*
  plumb miss, and a second same-day plumb-miss-caught-by-code-review after #90).

  Context: `/bbox` rejected a box thinner than half a pixel on the same-CRS path
  but silently served it as a degenerate 1-px strip when the read reprojects
  (`get_vrt_transform` floors the window to a 1-px minimum). Fix: recover the
  pre-floor size and reject on both paths: the recovery called
  `calculate_default_transform` with the **unclamped** dataset bounds.

  *Plan pass (5 headline).* Flagged the reject and the sizing deriving the
  reprojected resolution from **two computations that can diverge**
  (`calculate_default_transform` vs `get_vrt_transform`, which clamps
  WGS84→WebMercator to ±85.06° first). "Resolved" it with a gate (recover only
  when an axis floored to 1) and **parked the residual as "bounded,
  safe-direction, confined to floored-to-1 boxes at extreme latitude."**

  *Diff pass (affirm 5/6; new 16).* Affirmed the shape; 16 fired and found a real
  test-gap (the serve side of the discrimination boundary), but the *convenient*
  edge, not the load-bearing one. Verdict: essentially "Plumb is true."

  *The miss (independent code-review correctness finder, single vote).* The
  divergence is **not** latitude-bounded. `calculate_default_transform` returns a
  **dataset-wide** resolution; for a global WGS84 raster it is ~8× coarser than
  the clamped resolution `get_vrt_transform` actually uses, and that one wrong
  number is applied to **every** box, so an ordinary narrow **equatorial** read
  of any global dataset in WebMercator gets a false 400. Confirmed end to end
  (0.25° global dataset, 40 km equatorial box → 400 where `part` serves 1×56).
  Refixed to measure on the **source pixel grid** (uniform at every latitude),
  which is what "half a **source** pixel" meant all along.

  **New signals for the tightening pass:**
  (1) **5 × 16 co-fire: 16 is how you *verify* a 5-divergence, and skipping
  its *execution* is the false-negative.** When 5 flags a value derived two ways
  that can diverge, the rank comes from **constructing the input that maximizes
  the divergence and running it.** I *named* the clamp assumption in both passes
  and argued it "bounded/negligible": that is naming the edge, not hunting it. A
  parked "bounded / safe-direction" verdict on a 5-divergence is itself the
  trigger to build the maximizing input. Candidate Working-note: a
  "bounded/negligible" park is un-earned until that input has been run.
  (2) **Trace what a value *is*, not just where it flows.** The consumer-trace on
  5 stopped at "where it's used" (the guard) → "floored-to-1 boxes at extreme
  latitude." The real trace was into what the value *denotes*: a **dataset-wide
  average** posing as a **local** resolution: that category error is the whole
  bug, and re-ranks the finding from park to load-bearing. Extends "measure
  leverage by tracing to the consumer" with *what quantity the value represents*.
  (3) **16 can fire, find *an* edge, and still miss the *load-bearing* edge.**
  The diff pass caught the discrimination-boundary test-gap (a real add) but not
  the global-dataset edge that attacks the design's stated assumption. Prefer the
  edge that breaks the assumption the design *rests on* over an adjacent untested
  branch: the tell is an assumption written into a comment ("acceptable for a
  degenerate-input guard"), a standing 16 target until an input has tried it.
  (4) **Self-authored design defeats *reasoned* soundings; only a *run* survives
  confirmation bias.** Two plumb passes + a separate design stress-test all
  rationalized the same false "clamp is negligible" claim because the reviewer
  authored it; one adversarial finder that *built the global dataset* refuted it.
  When the reviewer is the author/champion, 16's "construct and run" is
  mandatory, not optional. Sharpens the zarr-audit "'contained' ≠ 'right shape'"
  signal: there the affirmation was local containment, here "the divergence is
  bounded," and in both only an *execution* refuted the reasoned affirmation.

  **Pairs with #90 (same day): two plumb-miss-caught-by-code-review entries,
  different mechanisms.** #90 missed a *fresh* 5 the diff introduced (it did not
  sweep the new code per-sounding); this missed a *pre-existing* 16 that both
  altitudes *named* and neither *ran*. Synthesis: a pass closes a sounding by
  **argument**: "the fix landed" (#90), "the edge is bounded" (this), when the
  real verification is an **action**: sweep the new code (#90), or construct and run
  the breaking input (this). "Affirmed" is not "closed."

  **Boundary note (scope, clean).** The false-reject *is* a correctness bug,
  which plumb defers to code-review, so this is not "plumb should have owned the
  fix." The narrower signal: 5 correctly named the exact seam and 16 was the
  right sounding to rank it, but 16 was applied by *argument* instead of
  *execution*. The gap is depth-of-verification on a co-fire plumb already surfaced,
  not a missing sounding.

- **2026-07-13 (later): covjson-msgspec #99: plumb on the plan, then the run that
  verified it.** Extends the same-day "#97/#99 method signal" entry (which predated
  the review). **Headline: the positive instance of the #90 / titiler-#41 lesson,
  16 verified by *execution*, not argument.** Those two logged a 16 *named but not
  run* (a miss); here the plan-review's 16 findings were **constructed and run**, and
  execution immediately caught what reasoning had only flagged.

  **Plan altitude (review on the plan): fired 5 (headline), 16, 4.**
  - **5: the spec tz rule gets a second home.** `_has_spec_timezone`'s positional
    check (`value[-6] in "+-" and value[-3] == ":"`) re-encodes the `_DATETIME` regex
    tail (`(?:Z|[+-][0-9]{2}:[0-9]{2})`). Trace: a later edit to the offset grammar
    touches `_DATETIME` (fallback + oracle) but not the guard; the fast path silently
    diverges. **Why not the obvious fix:** single-sourcing via a hot-path
    `_SPEC_TZ.search` puts a regex back on the path #99 exists to remove, ~halving the
    win. Proportional (12) resolution: keep the duplication but make it *deliberate and
    enforced* (a comment binding the guard to `_DATETIME`'s tail; the fuzz differential
    as the CI-enforced sync). **New 5-Move signal (tightening pass):** under a perf
    constraint, 5 resolves to "deliberate duplication + an enforced differential test,"
    not the reflexive "extract to one home": single-sourcing is wrong when the single
    source taxes the hot path.
  - **16: the fuzz differential only bites on msgspec-*accepted* inputs** (rejects
    fall back and equal the oracle by construction; a junk generator passes vacuously).
    Drove: bias the generator to valid skeletons across the whole tz-designator axis,
    and assert a `Moment` floor.
  - **4: `_resolve_datetime_strict` implies the fast path is looser** (both enforce
    the same form; they differ in mechanism). Renamed `_resolve_datetime_form`.
  - **Affirmed 12** (keep-strict grounded by *fetching* CoverageJSON §5.2 verbatim, not
    memory: it writes `+|-HH:MM`, colon included, so `+0500` → Malformed is faithful;
    SHOULD → warning); **2 / 7** (union + raw-string faithfulness untouched; a speedup
    behind a behavior-preserving oracle).

  **Run altitude: 16 verified by execution paid off twice (why this entry matters).**
  - **The fuzz-vacuity finding was prophetic.** Building the generator, the differential
    *immediately* caught a real generator bug: a non-`T` junk string (`"0339"`) reached
    the oracle, which only classifies `T`-strings. The abstract plan-finding became a
    caught bug within minutes, because the test was *run*, not reasoned about.
  - **The breaking edge surfaced a genuine behavior divergence.** A parity spot-check
    (differential twins, the 16 method) found msgspec *rounds* a sub-microsecond
    fractional second where `fromisoformat` *truncated*: a real change the plan's "no
    behavior change" claim had missed. Found by running twins; resolved proportionally
    (accept + document + pin) and surfaced to the user.
  - **A quantitative claim, unverified until run (12 extended to a measurement source).**
    The plan asserted "~3-4x"; the micro-bench corrected it to ~1.5x (it compared *raw*
    `convert` to *wrapped* `resolve`). 12's "verify the claim against its source" holds
    for a *number* too.

  **Synthesis with #90 / #41.** Those: 16 *affirmed by argument* → miss. This: 16
  *verified by execution* → catch. Same-day confirmation that "'Affirmed' is not
  'closed'; verifying is an action": stated there from misses, shown here from the
  win when the action was taken. Reviewer was again the author (self-authored plan,
  self-run review), so it also confirms #41's "only a run survives confirmation bias":
  the reasoned review affirmed the fuzz/guard; the *execution* caught the holes.

- **2026-07-14: covjson-msgspec #62: plumb reframed an ADR's *argument*, and the
  run falsified a subagent's code-read.** Plumb-on-plan then implementation, same
  shape as the #99 entry above, but two new signals. Issue #62 ("route the export
  bridges' temporal classification through `resolve` for one classifier of
  record") was settled as decide-not-refactor, recorded in ADR-0015.

  **Plan altitude: fired 5 (headline, *inverted*), 3/16, 12.**
  - **5: the headline was the ADR's argument structure, not code.** The plan
    concluded "don't route," arguing it as "we *declined* to consolidate" (three
    costs: calendar-blindness, naive→`Malformed` output change, vectorization).
    5 fired not as "duplication exists, extract it" but as its inverse: the three
    parsers (`resolve`, `maybe_datetime`, `_parse_times`) have different
    **codomains** (`Moment|Unrepresentable|Malformed` vs `DatetimeIndex|strings`
    vs `datetime64|cftime`): there is *nothing* to unify; the "triplication" is
    surface similarity ("string in, time out"). Leverage came from the deliverable
    being an **ADR**: "we chose not to consolidate (cost)" is re-litigable ("but
    consistency!"); "these are different functions (structural fact)" closes it,
    and demotes the three costs to *consequences* of the codomain mismatch. **New
    5 signal (tightening pass):** the "apparent duplication" family now has THREE
    resolutions: (i) real dup → extract to one home; (ii) real dup taxing a hot
    path → deliberate dup + enforced differential test (the #99 entry, same repo,
    one day earlier); (iii) **not dup, different codomains → don't unify, and make
    the design doc argue from the codomain root, not a cost tradeoff.** Plumb run
    on the *argument*, not just the code.
  - **3/16: the decision was enforced only in prose** (ADR + a code comment). A
    deliberate divergence (the bridges parse a naive no-`Z` time that `resolve`
    rejects) with no test is a "hoped-for edit." Move: promote a
    divergence-pinning test from "optional" to *required* (a change that makes a
    bridge reject naive input must trip it). **This finding built the instrument
    the run then used** (below): the plan-finding and the run-catch are causally
    linked.
  - **12: "confined to non-spec input" asserted from memory.** Gated the ADR
    claim on *fetching* CoverageJSON §5.2 (same discipline as #99). The fetch
    (datetime form is `Z` **or** `±HH:MM`) both made the claim faithful *and*
    **verified a suspected finding with NO finding**: `_has_spec_timezone`
    accepting offsets is spec-*correct*, not over-lenient. **New 12 signal: verify
    can close a suspected finding, not only sharpen a real one.**

  **Run altitude: 16 by execution, third instance, *new provenance*.**
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
  16-verified-by-execution. #62 adds the two inverses: 5 can resolve to "*not*
  duplication: argue the design doc from the structural root," and
  16-by-execution catches a **subagent's** false code-read, not only the author's
  bias. Reviewer was again the author (self-run), so #41's "only a run survives
  confirmation bias" holds a third time: here against a delegated trace, the most
  authoritative-feeling form of reasoning.

- **2026-07-14: first landing off the consolidated signal ledger (not a review
  run).** Built **[TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md)**, a deduplicated
  harvest of every "New signals for the tightening pass" scattered across this log
  (Section A = land-ready operating rules ranked by leverage; B = combine dossier,
  assembled not executed; F = recommended landing order). Then landed the top of that
  order: the refinements that change *notes*, not the sounding count. **The 19→~10–12
  combine stays deferred** per REFINEMENT.md's "let usage drive, not armchair debate";
  this ledger is its input, not its trigger.
  - **A1: "'Affirmed' is not 'closed'; verifying is an action, not an argument."**
    Sharpened sounding **16**'s Move to demand *construct and run* the breaking input
    ("a 'bounded/negligible' verdict is un-earned until that input has actually run"),
    and added a Working note generalizing it: affirming a sounding *landed* is the cue
    to hunt its *other* instances, not close it out; when the reviewer authored the
    design, running the edge is mandatory (only a run survives confirmation bias: a
    careful code-read, even a subagent's, is still reasoning until run). Drawn from the
    only two misses in this log (#90 swept-nothing, #41 named-not-run) and their
    positive inverses (#99, #62, verified-by-execution): the sharpest signal the
    harvest surfaced, and the one that closes the miss class.
  - **A4: sounding 5 Boundary line.** Added the #77-drafted Boundary ("similar-looking
    idioms encoding *different* decisions are not a 5 violation; pin with a test, don't
    merge"), **generalized off its covjson-specific `UNSET`/`parameters or None` example**
    to keep the skill repo-agnostic (per REFINEMENT.md's "plumb is general, not
    covjson-specific"). The insight is verbatim; only the illustration changed.
  - **E1/E2: doc fixes.** Deleted SKILL.md's stale "one-word swap if you prefer
    `gauges`" line (REFINEMENT.md locks *soundings*, rejects "gauges"). Repointed
    LANDSCAPE.md's rescan-log step off the nonexistent REFINEMENT.md changelog to this
    file / its own `## Changelog`, and corrected its line-4 claim that REFINEMENT.md is
    "append-only history": REFINEMENT.md is rewrite-in-place; *this* log is the
    append-only one.
  - **Deferred (named, not lost):** A2 (both-altitudes sub-cases), A3 (sounding-12
    verify-the-source riders: pin-the-revision, quantitative-claim, verify-can-close),
    A5 (unreachable-invariant → enforcing test), and the #90 smell-shape for 5 (a
    classifier re-implemented inline in a new helper). See TIGHTENING-SIGNALS.md §F.
  - **How this gets validated:** not by a test, a skill is verified by dogfooding.
    Watch the next reviews where 16 fires: does the sharpened Move actually force
    build-and-run instead of a reasoned "bounded"? That is the next log entry, not a
    green check.

- **2026-07-14 (later): covjson-msgspec #89 values_as(): the first post-A1-landing
  run: A1 confirmed, and A1's next frontier exposed by a miss.** Two /plumb passes
  (plan, diff) plus interleaved ponytail- and code-review on one feature (an opt-in
  typed-value projection over NdArray's faithful union). This is the entry the
  2026-07-14 landing asked for ("watch whether the sharpened 16 forces build-and-run").

  *Plan altitude: headline co-fire 2 + 15.* values_as raising `msgspec.ValidationError`
  vs the library's `CovJSONValidationError` is a public one-way door (15); the same
  logical failure (value-vs-dataType) otherwise surfaces as two exception types by
  door (2). Resolved deliberately: keep msgspec.ValidationError (mirrors decode, not
  the validate pass), named in the docstring + pinned by a test. Affirmed 7/14/5/11/13;
  whole-struct narrowing (NdArrayFloat/Int/Str) weighed and rejected as reopening the
  multi-type shape ADR-0004 rejects.

  *Diff altitude: 16 verified by execution paid off (A1 confirmed).* Running
  `values_as(float)` on `10**400` produced `SystemError`, NOT the documented
  ValidationError: a decode-reachable legal input (a bare huge-int JSON literal). A
  reasoned pass would have said "int->float, fine." Drove: an upstream report
  (msgspec#1122) + a guard normalizing OverflowError/SystemError to the documented
  contract, forward-compatible with a fixed msgspec. The over-trigger boundary was
  also *run* (10**308 converts, 10**309 raises), and the A4 #5-Boundary fired and was
  verified by running both idioms (screen keeps `(5,)`, values_as coerces `(5.0,)`:
  different codomains, not merged; 2nd confirmation after #62). Sibling sweep (5/13):
  grepped every coercion site, *ran* validate on the huge int to confirm the screen is
  overflow-safe (keeps int), found to_numpy the one unguarded sibling -> filed #110.

  *The miss (headline signal): A1's construct-and-run did not reach the TEST.* The
  diff-review returned "Plumb is true" and affirmed "correct and tested." But the
  promotion unit test was a FALSE GUARD: `(5, 6.5, None) == (5.0, 6.5, None)` is True
  in Python, so it passes whether or not the int->float promotion (the projection's
  whole point) happens. Plumb ran the code's breaking edges but never ran a mutation
  against the test defending the core behavior. Worse: the *ponytail* pass then
  asserted "test 1 already pins the promotion" to justify DELETING the parity-pin test
: a false coverage-subsumption claim that survived both plumb and ponytail. Only the
  independent /code-review (language-pitfall/test-coverage angle) caught it; the fix's
  own mutation stub ("non-promoted passes new assertion? False") was run only AFTER,
  proving the technique works and was applied one skill too late.

  **New signals for the tightening pass:**
  (1) **A1's "construct and run" extends from the behavior claim to the COVERAGE
  claim.** When plumb affirms "it's tested," that half is itself a claim to verify
  by *mutating the behavior and confirming the test fails*: a false-guard test reads
  fine; only the mutation-run reveals it. Same root as #41 ("only a run survives
  confirmation bias"), one level out: not "is the code right" but "does the test catch
  the code being wrong." Candidate 16/Working-note rider: an "affirmed: tested" verdict
  is un-earned until a regression mutation has been run against the guarding test.
  (2) **A coverage-subsumption deletion argument ("X already covers this, delete Y") is
  a verify-by-running claim.** The ponytail test-deletion leaned on "test 1 pins
  promotion," which was false (numeric equality). Before deleting a test on the grounds
  another subsumes it, run the mutation against the surviving test. Ties the A1 mandate
  to ponytail-review's deletion calls, not only to affirmations.
  (3) **Cross-skill dance exposed the blind spot: plumb affirmed -> ponytail deleted on
  a false premise -> code-review caught.** Test-*validity* is code-review's lane, so the
  lesson is not "plumb should hunt test bugs" but "plumb must not AFFIRM 'tested' (nor
  accept a subsumption to justify deletion) without the mutation-run." When plumb makes
  a coverage claim, it owns verifying it.
  (4) **First post-A1-landing run = A1 validated by dogfooding, as REFINEMENT.md
  demands** ("a skill is verified by dogfooding, not a green check"). 16-by-execution
  caught the SystemError; the A4 Boundary fired and was verified by a run. The single
  gap is scope, not soundness: the mandate hadn't yet been pointed at tests.

- **2026-07-14 (even later): titiler-covjson /area (#56): plumb's affirmed-decision ×
  fixed-guard blind spot, caught by /code-review's construct-and-run.** A plumb workflow
  reviewed the finished /area slice (WKT-polygon zonal reduction → Polygon coverage) and
  drove four fixes: **A** the pre-read cell ceiling measured the *source* grid,
  under-counting a reprojected read, so it now measures the *destination* grid feature()
  produces (5 + 16); **B** extract a shared `_covjson_response` (5); **C** name the
  read/reduce helpers by output shape (4); **D** thread the reduction stat into each
  band's description/unit (1 + 5, the dtype-single-source family). Affirmed and parked:
  permissive geometry (11 + 16: closure/finiteness are the O(1)-local invariants;
  simplicity/containment is heavier and `rasterize` tolerates it) and the
  out-of-bounds/all-nodata → `null` collapse (2/7).

  *The miss (headline).* Fix A closed **one** instance of "the ceiling measures a
  different extent than feature() reads": the reproject stretch (source vs destination
  grid). It left a **sibling** on the *same* guard: `Polygon.bounds` measured only the
  exterior ring (`rings[0]`), while feature() bounds **all** rings via
  `rasterio.features.bounds`. The affirmed permissive-geometry decision *explicitly
  allows* a hole reaching past the exterior, so a 1×1 exterior with a full-extent hole
  slips the tiny exterior past the pre-read guard and feature() allocates the huge
  all-rings extent, tripping only the post-read backstop (allocation already happened =
  the DoS). Two individually-sound plumb outputs: "Fix A: bound the read" and "affirm:
  geometry stays permissive": whose **product** is the bug. Plumb ran neither the
  permissive input through the fixed guard nor a grep of "who else derives the polygon's
  extent." Caught later the same session, only by the xhigh /code-review's build-and-run
  of every candidate: a hole-beyond-exterior polygon allocated a 16×16 = 256-cell grid
  against a 16-cell ceiling (the pre-read guard saw the 1-cell exterior and passed).

  **New signals for the tightening pass:**
  (1) **A1's sibling-sweep must cross AFFIRMED decisions, not only re-scan for clones of
  the fix.** #89's sweep grepped every *coercion* site (syntactic siblings of the
  change). This miss lived at the *intersection* of a fix (5/16, bound the read) and an
  affirmation (11/16, permissive geometry): a semantic sibling the clone-grep can't see.
  Candidate Working-note rider: when a review both *fixes a guard* and *affirms a
  permissive/faithful decision* (7/11), it must **construct and run the affirmed-permissive
  input through the fixed guard**: the affirmation and the fix are co-dependent, and their
  product is where the breaking edge (16) hides.
  (2) **Sounding 5 governs DERIVED EXTENTS, not just constants and formulas.**
  `polygon.bounds` and `featureBounds(geometry)` are two derivations of one quantity:
  the polygon's spatial extent: that *must* agree because one gates a read the other
  performs. The tell plumb had and skipped: `bounds` read `rings[0]` while the geometry
  dict handed feature **all** `rings`. Generalizes #89's "grep every coercion site" to
  "grep every derivation of the load-bearing quantity": here, every place the read
  extent is computed.
  (3) **This is a genuine plumb MISS, not a lane boundary** (contrast #89, where
  test-validity was rightly code-review's lane). Two sources of truth for a
  security-load-bearing extent is a textbook sounding-5 drift; plumb owned it and had the
  exact tool (16's construct-and-run) but never pointed it at the affirmation × fix
  interaction. The whole-stack payoff: the "only a run survives confirmation bias"
  mandate now pays out *across* skills: /code-review's discipline of building every
  candidate is what the self-authored plumb pass most needed and lacked.

- **2026-07-15: titiler-covjson #37 (ADR authoring, plumb not invoked): A1's
  "construct and run" reaches a prose security *claim*.** No `/plumb` run: #37 records
  an already-settled decision (dataset open/read failures stay HTTP `500`, overridable
  per deployment) as ADR-0003 plus a README override recipe. But authoring the ADR
  reproduced the A1 signal in a medium this log hadn't caught it in: a **security claim
  written in prose**.

  *Overclaim, closed by a run.* The ADR asserted a flat property: "`500` never leaks
  existence or authorization", which reads true from the status-code-oracle argument
  alone (a uniform `500` is not a 404-vs-500 existence oracle). Running the system to
  verify the *override recipe* (bad `url` → `500` default, `400` remapped) incidentally
  falsified the *claim*: the real response body renders the raw exception message into
  `detail` (`"…: No such file or directory"`), so existence leaks via the **body**, not
  the status line, and an existing-but-non-raster file (`/etc/hostname`) returned the
  *same* misleading "No such file or directory", so the body signal is itself noise.
  Fix: scope the claim to the status code, add a body caveat. The oracle *argument*
  held; the *unqualified* claim did not, and only the running output showed the gap.

  **New signals for the tightening pass:**
  (1) **A1 / sounding 16 governs a runtime-behavior claim asserted in prose, not only
  code, tests, and plans.** #21 put plumb at doc-*architecture* altitude; this is one
  notch more specific: a doc claiming what the system *does*. The maximizing input for
  such a claim is *running the system and reading its real output* (the HTTP body here,
  plus one adversarial-but-valid input, `/etc/hostname`), never re-reading the argument
  that makes it look true. Candidate: name "a factual/behavioral claim in prose (ADR,
  README, spec)" as an A1 target, verified by "run it and read the output."
  (2) **Positive, self-caught instance (#99 / #62 family), and the verifying run was
  aimed elsewhere.** The run targeted the override recipe; it surfaced the unrelated
  affirmed-claim overclaim as a side effect: "run the thing" pays out past the claim it
  was aimed at. Corroboration that A1 generalizes to a new medium, not a new sounding.

- **2026-07-15: titiler-covjson #57/#65 (roadmap realignment, plumb not invoked): A1/16 reaches a *validation harness*, "a green check you never fed a known-red input is unearned."** No `/plumb` run, the task was reclassifying `/trajectory` (Trajectory domain) as temporal, splitting out MultiPoint, and realigning the backlog. But the load-bearing fact was won by an A1/16 move against inherited *affirmations*, and it exposed a sounding-11 trap in the test harness itself.

  *The affirmation, falsified by a run.* Three inherited artifacts affirmed that a spatial-only sampled line is a valid **Trajectory** with `["x","y"]` composite tuples: `docs/02`'s worked example, the roadmap story, and, decisively, `covjson-pydantic` itself, which *constructs and serializes* a `t`-less Trajectory without complaint (sounding 1: the type leaves the illegal state representable). Taking any of them at their word ships a schema-invalid domain. Constructing the three instances (`t`-less Trajectory, `[t,x,y]` Trajectory, `[x,y]` MultiPoint) and running them through the vendored CoverageJSON schema falsified it: the spec forbids a `t`-less Trajectory (tuples must be `["t","x","y"]`/`["t","x","y","z"]`); a spatial-only path is valid **only** as MultiPoint. Resolution (sounding 7, faithfulness): pick the domain by the data's actual shape, spatial-only → MultiPoint via the EDR Position verb (`/position` + `MULTIPOINT`, #65); time-bearing → Trajectory (#57, temporal): rather than synthesize a fake `t`, the same honesty rule ADR-0001 used to reject a no-op `/cube` `z`.

  *The sounding-11 trap: the check that would "verify" it is asleep.* The invariant lives at three tiers, the pydantic type (doesn't enforce), the named-`"domain"` schema definition, and the full-`Coverage` schema, and is enforced at only **one**. Worse, the test helper's ergonomic default, `assert_schema_valid(model, "domain")`, runs a tier that **silently skips** it: the constraint is a draft-07 `dependencies` keyword, and the stripped `"domain"` wrapper carries no `$schema`, so `jsonschema` selects the Draft2020-12 validator, which ignores `dependencies` and passes the invalid instance. Only `assert_schema_valid(model)` (full `Coverage`, draft-07) actually enforces. A test that *looks* like it validates the domain would have green-lit the exact bug.

  **New signals for the tightening pass:**
  (1) **A1 / sounding 16 governs a *validation harness*, not only fixes, claims, and plans.** The maximizing input for "does this check enforce X?" is a **known-X-violating instance run through the check**, never re-reading the schema/type that makes it look enforced. Extends the A1 thread (#89 fix×affirmation, #37 prose claim) to the verification seam itself: *trust no green check you did not feed a known-red input.* Candidate rider: when a review leans on "we schema-/type-validate it," verify it by feeding the validator one deliberately-invalid instance and confirming it goes red.
  (2) **Sounding 11 has a verification corollary: know which *tier* your check runs at, because a convenience wrapper can silently drop the constraint it appears to test.** Here a JSON Schema draft-version mismatch (draft-07 `dependencies` ignored by Draft2020-12) turned the ergonomic `validate(…, "domain")` path into a no-op for the invariant under test. "Put the check in the right tier" (11) implies "run the *check* at the tier that still carries the constraint."
  (3) **Positive, plumb-not-invoked instance; the falsifying run also drove the design.** As with #37, the construct-and-run aimed at "which domain is valid?" simultaneously killed the inherited affirmation and exposed the harness trap. Corroboration that A1/16 generalizes to a new medium (the validator), not a new sounding.

  *Aside (sounding 5, process altitude):* the same session found the roadmap had drifted because two sources of truth, a narrative `docs/05` and the milestones/ADRs, were never reconciled; the fix was to retire `docs/05` to a single source of truth (milestones + ADRs). A one-source-of-truth instance at doc/process altitude, noted but not novel.

- **2026-07-15: covjson-msgspec #113 (custom reference-system types): a three-altitude sequence (guide → plan → diff), each altitude catching a different class of flaw.** The log's richest altitude-differentiation to date: an interactive guide-mode modeling analysis, a `/plumb` plan-review after the plan and ADR were written, and a `/plumb` diff-review after implementation plus a ponytail cut and an xhigh `/code-review`. (Merged as PR #124.)

  *Guide run (`Skill(plumb)` on the modeling fork, mid-design).* Model reference systems (five known kinds plus an open §7.2 custom `type`) as a permissive grab-bag core or a sum-type-with-catch-all? Headline **1 against a house tenet**, resolved by inverting the usual "prefer unrepresentable." The grab-bag makes illegal states representable (a `GeographicCRS` core carrying `calendar=None`; ~5 legal of 128 field combinations), which sounding 1 flags. But the grab-bag permissive core is the structural *face* of permissive decode (ADR-0002): a sum type decodes strictly (reject, or route to a catch-all), fighting the codebase's cornerstone "a slightly-nonconformant document still loads." Synthesis: **illegal states unrepresentable at the CONSUMPTION boundary (an opt-in `refine()` projecting the core to clean per-kind variants), permissive at the INGEST boundary (the faithful core)**, i.e. parse-don't-validate applied at first *use*, not at decode. The sharpest new nuance on sounding 1 the log has produced. Drove idiom A (permissive core plus `refine()` → `ResolvedReferenceSystem` / `OpaqueRS`), every structural claim verified by a runnable probe (the closed-union `TypeError`; encode of a mixed tagged/untagged union field; the ADR-0012 re-encode behavior), per A1, since the design was self-authored.

  *Plan run (`/plumb` on the written plan and ADR).* Three findings, all different soundings from the guide run. Headline **16**: the typed core admits a breaking edge the plan overclaimed away. `{"type":"uor:X","calendar":123}` *fails to decode* (a custom member colliding with a known field name at an incompatible JSON type), run-confirmed, while the ADR said "custom types load" unqualified. **4**: the projection was named `resolve()`, colliding with two existing verbs (`temporal.resolve`, `resolve_references`), a name meaning three operations; drove the rename to a method `.refine()` (also a locality/17 win). **8 + 5**: the shared required-member predicate that must drive both `refine()`'s gate and `validate()`'s error cannot live as a `referencing` private imported by `validation` (repo convention), forcing a new `_reference_invariants` module as the single home for the interop invariant. All fixed before code.

  *Diff run (`/plumb` on the implementation).* Headline **3 + 12, a proactive A1 coverage instance**: the two new `validate()` errors (`temporal.missing-calendar`, `identifier.missing-target-concept`) were emitted by code but asserted by no test, caught by grepping the test tree (they were imported only to satisfy a `_describe` exhaustive match), not by affirming "tested." Discharged by *running* `validate()` on a malformed domain to confirm the feature works (so it is a coverage gap, not a bug), then adding an interop test pinning the refine↔validate invariant. **4/10**: the exported `ResolvedReferenceSystem` union raises a cryptic msgspec `TypeError` if a user decodes *into* it (it mixes tagged variants with the untagged `OpaqueRS`); parked as loud-and-immediate, later softened by an attribute docstring steering to `ReferenceSystem`. Parked: variant-in-core-field (msgspec skips construction typechecks; mypy-guarded, inherent to every field); empty/miscased `type_` (defensible, §5 is case-sensitive); redundant `refine()` in `to_xarray` (efficiency, O(1)).

  **New signals for the tightening pass:**
  (1) **Three altitudes, three disjoint flaw classes: the strongest altitude-differentiation instance in the log.** Guide caught the modeling shape (permissive core vs sum type); plan caught naming, shared-home, and a breaking edge (4/8/16); diff caught untested new behavior (3/12). Prior entries top out at two altitudes (plan plus diff). Evidence that guide-mode modeling, plan-review, and diff-review are three genuinely different scopes, not two.
  (2) **Sounding 1 reconciled with a permissive-decode house tenet: unrepresentable at CONSUMPTION, permissive at INGEST.** The grab-bag core is not a 1-violation to fix; it is the structural face of ADR-0002 ("a slightly-nonconformant document still loads"), which a sum type fights, and the clean variants live at `refine()` (first use), not at decode. Candidate refinement: sounding 1's "parse-don't-validate at the edge" carries a *layer* choice, where the edge can be first-consumption (a lazy projection over a faithful core), not only decode; naming this reconciles 1 with 7 (faithfulness) and 11 (permissive load) where they appear to conflict. First time the log has had 1 *resolve toward the grab-bag* rather than away from it.
  (3) **A1 coverage-discipline, proactive and positive.** The recent A1 thread (#89/#56/#37/#57/#65) was mostly "an 'affirmed: tested' verdict is unearned until a red-input run." Here the diff-review never affirmed tested; it *checked* (grepped for the test pinning the new behavior), found the gap, ran the behavior to confirm it works, and added the test. Confirms A1 as a standing diff-review move: when a diff adds behavior, grep for the test that pins it; absence is the finding, verified by running the behavior and adding the case.
  (4) **Clean skill partition across four passes (plumb ×2, ponytail, code-review).** ponytail cut a no-value `.custom()` builder (structure plumb had affirmed fine); `/code-review` then owned test-*validity* (a totality test asserting distinctness, not the tag→variant mapping, so a variant swap would pass it) and the finer coverage gaps (`Concept.id`, custom-encode round-trip), plus a behavior narrowing (i18n suppressed on a malformed RS) and a doc overscope. Test-validity stayed code-review's lane (per #89) while plumb's diff-review owned the coarser "new behavior unverified"; the two coverage lenses nested rather than double-covered.

- **2026-07-16: covjson-msgspec, the `Sequence`-vs-`tuple` member question (NOT a review run; logged as an A1 near-miss).** Plumb was never invoked; logged because the session reproduced **A1's failure mode in a direction A1 has not yet recorded**, and because the miss is the author's own.

  *What happened.* A parked perf idea (annotate sequence members `Sequence[T]` rather than `tuple[T, ...]`; msgspec converts a variable-length tuple via a list, so `Sequence` decodes straight to a list) was measured to decide it. The first instrument was a **hand-built struct standing in for `NdArray`**, which reported **1.34x** and was relayed to the user as "~34% of real decode." It was wrong. Patching the **real** member and A/B-ing it in one session (measure, `git checkout --` revert, measure) gave **1.07x**: wrong by ~5x. The idea was then rejected on structure rather than on the number anyway: a `list` member forfeits hashability on precisely the structs that still have it (`NdArray`, `Axis`, `ReferenceSystemConnection`), foreclosing half of the project's `frozendict` endgame, and falsifies the house tenet's "cannot be corrupted by a caller" (`frozen=True` blocks rebinding, not `array.values[0] = 99.0`). Recorded as an ADR-0016 alternative (PR #126).

  *Why this is a near-miss and not a win.* The bad number was not caught by method. It was caught by an **anomaly too glaring to ignore**: the real full-document decode came in *lower* than the isolated struct that was supposedly a component of it, which is impossible and forced a re-measure. Had the proxy erred in the flattering direction (understating rather than overstating), nothing would have contradicted it and the 1.34x would have stood. Luck, not discipline, and the intermediate claim reached the user before the correction did.

  **New signal for the tightening pass:** **A1's un-earned verdict runs in both directions, and the thing that lies can be a *proxy*, not an argument.** Every logged A1 instance argues a concern *away* (`#41` "bounded/negligible", `#90` "the fix landed"). This one argued a concern **in**: a stand-in artifact inflated a payoff and made a dead idea look worth pursuing. Same failure mode, opposite sign, which sharpens what A1 is actually about. The defect is neither optimism nor pessimism about the verdict; it is **substituting an argument, or a proxy, for a run of the real thing**. A quantitative claim earns its number exactly the way a 16 "negligible" park earns its verdict: by constructing and running the real artifact. Bears on A1's Proposed target, whose Working-note wording currently covers only the dismissive direction. Secondary, weaker: sounding 16's Move is written around breaking-edge *inputs*; here the thing that broke the assumption was a substituted artifact, so if 16 ever widens from "inputs" to "un-earned verdicts generally," this is the second data point.

- **2026-07-16: covjson-msgspec PR #130 (an outside contributor's axis `bounds`-length check), review-mode diff run: the review changed the *project* more than the PR.** First run on a diff authored by someone else, and the first whose net output is mostly commits to `main` rather than comments on the branch. The reviewed PR is still open awaiting rebase; the run produced three merged PRs (#134 taxonomy rename, #135 category-rule gap, #136 corpus enforcement + ADR README), a reworded issue (#129), and one new issue (#133). **Every load-bearing finding was a stated claim nobody had opened, and three of the four were the project's own, not the newcomer's.**

  *Headline **12**: the cited MUST does not exist, and the project wrote it.* The PR's issue-class docstring, its checker docstring, and its PR body all said "Spec 6.1.1 ... MUST contain exactly two values" per coordinate. Fetching §6.1.1 says: "An axis object **MAY** have axis value bounds ... where the value is an array of values of length `len*2`". No MUST. This bites in *this* codebase specifically because severity is graded off the RFC 2119 keyword by house convention (`DomainMissingDomainType`: "RECOMMENDS ... so this is a warning"; `TemporalLexicalForm`: "SHOULD"), so a fabricated MUST short-circuits the very reasoning that picks the grade. The verdict survived anyway (`error` is right) but for a different reason that had to be *found*: the `MAY` governs **presence**; once present the spec **defines** the length, so a wrong-length array fails to be a bounds array at all: the same definitional-without-keyword phrasing the repo already enforces at construction for empty `values`. **The origin is the finding.** The wording came from the project's own issue #129 ("completeness of the §6.1.1 MUST coverage"); the contributor transcribed it faithfully. Fixed the issue, not just the diff. Co-fire **12 + 15**: a second, quieter 12 in the same docstring, `2 * len(axis)` for a *regular* axis is **derived**, not stated (§6.1.1 defines `len` over the `"values"` array; a regular axis has none), and the repo has an explicit convention of labeling derivations (`axis.py:193`) that the PR presented as flat spec text.

  ***4 + 15**: a one-way door the diff would have wedged open.* The PR opened a new `axis.*` code namespace while `domain.axis-not-monotonic` was *also* a §6.1.1 axis-object rule: two of the same rule class in two namespaces with no stated rule for the next one. `code` is the msgspec `tag_field` (ADR-0006), the wire discriminant a report round-trips through, so it freezes at first release. The contributor's instinct was **right** (and matched #129's own proposal); the incumbent was the misfit. Resolved by renaming *the incumbent* (#134) and writing the rule into the module docstring, so the PR follows a precedent instead of adjudicating a taxonomy it did not choose.

  ***3**: an invariant asserted in prose, unenforced, already false.* `tests/corpus/negative/manifest.toml` promised the corpora "cover every code validation.py emits." Nothing checked it; **three codes already had no document** and the suite was green. The PR would have made it four, silently. Note the contrast that made the finding legible: `_describe`'s `assert_never` *forced* the contributor to classify the new variant and they did, correctly, the exhaustiveness that was mechanized held, the one written as a sentence had rotted. Filed #133, fixed in #136, and the fix derives its expectation from `get_args(Issue)` so the claim can never drift again.

  *Also fired:* **2** (the new tests select on `i.code == "..."` then read typed payload, 148 mypy errors against a clean `main` baseline, and precisely the anti-pattern the module docstring warns about); **5** (the same tier rationale in three homes, the call-site comment restating the checker docstring near-verbatim, while sibling call sites carry only call-site-local ordering rationale); **5** again (ADR-0018 says this rule is "unchecked/unimplemented" in two places, and the `bounds` row is that ADR's *separator case*: landing the check promotes its central argument from hypothetical to real); **16** (the composite axis, **constructed and run**: the check was *already correct*, so the finding became "add a test" rather than "fix a bug", and the misreading it pins, `2 * values * coords`, is live because `Axis.tuple_`/`polygon` do not even expose `bounds`).

  **New signals for the tightening pass:**
  (1) **A1 extends from verdicts and proxies to *citations*, and the incumbent docs lie as readily as the diff.** The 07-16 near-miss added sub-rule (e) (a *proxy* can argue a concern *in*). This adds the next surface: **a cited authority is a claim, un-earned until opened**, and the four that lied here were the PR's spec citation, a manifest header, an ADR README's own rule, and *my own* "44 references" (a diffstat skim; the truth was 22 insertions/22 deletions with 15 lines mentioning the term), caught only because I checked before publishing into the very document about treating the record honestly. Sounding 12 already says "verified against it and cited, never asserted from memory," so this is 12 firing *because* A1's discipline was applied; the new part is **where to look**.
  (2) **12's smell list is written as if the reviewee over-claims; here the over-claim was upstream of the diff.** "'the spec says MUST' without opening it" reads as the author's error. The contributor's docstring was *faithful to its source*: the project's own issue. A diff can conform perfectly to a bad citation, which is the citation-shaped version of plumb's standing stance ("conforming to bad precedent is itself a finding"). **Candidate refinement:** 12's Move should say to open the source *the diff is implementing* (the issue, the ADR, the manifest header), not only the external authority it names, and that the fix may belong upstream rather than in the diff. First logged instance where a finding's correct home was an *issue body*.
  (3) **A brownfield review whose leverage was almost entirely on the incumbent.** Ranked by leverage, the top four findings all resolved to changes on `main`, not the branch: rename the incumbent code, write the missing rule, enforce the unenforced invariant, correct the issue's wording. The contributor's actual defects were CI-mechanical (mypy narrowing, ruff). Practical corollary the run drove: **when the fix is the project's decision, take it off the contributor's plate**, doing #134 ourselves also caught that the blast-radius list I had drafted for them was *already wrong* (ADR-0011 had two occurrences; my first grep had filtered that file out, and the second occurrence's article split across an 80-column line break, invisible to any line-based grep). Had they followed my list, they would have shipped a half-sweep.
  (4) **A1 discipline on the reviewer's own artifact, twice.** Beyond the "44 references" catch: the corpus-enforcement test in #136 was verified by **negative control** (drop a code → confirm it fails; add a typo'd code → confirm equality-not-containment catches that too) rather than by observing it pass. A test asserting `set() == set()` also passes. Consistent with A1(d): the author of a check is the last person entitled to affirm it works.

- **2026-07-17: covjson-msgspec #131/#127/#128 (the §6.1.1 composite-axis cluster): a self-authored plan-review at THREE escalating passes, then a diff-review, then ponytail + xhigh code-review.** Merged as PR #141 (green CI). The log's strongest *same-altitude re-probe* evidence: prior entries differentiate altitudes (guide/plan/diff), but here re-running `/plumb` on the *same plan* three times was not redundant. Each pass found a different failure class, and all three would have passed unit tests built from Python literals. The diff-review then found two more the plan could not, and a separate `/code-review` caught a correctness leak plumb correctly routed away.

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

- **2026-07-17: covjson-msgspec #129 diff** (`axis.bounds-length` validation rule; review mode on the diff, self-authored, run *after* an xhigh code-review + its fixes and a ponytail-review had already passed over the same branch). **Verdict: the diff is structurally true; the headline is an out-of-scope park routed to a filed follow-up.** (Merged as PR #143.)

  The change itself affirmed cleanly: **2 + 3** (`AxisBoundsLength` is a closed-union variant carrying `expected`/`got`, exhaustive `_describe` forces the update), **11** (the load-bearing decision, validate() tier, not `__post_init__`, because a wrong-length `bounds` leaves the axis interpretable and droppable; ADR-0018 earns it as the *separator case*), **12** (severity `error` is attributed to ADR-0002's judgment and quotes §6.1.1's actual `MAY`, *not* a false spec `MUST`: grounded, verified against the fetched wording, not vibes), **7** (bounds stored raw, only length-checked), **6** (pure generator), **13** (symmetric with `AxisCompositeArity`). No fix to the diff.

  **Headline (3 / 16 on `subset.py:482`, parked → issue #142).** The feature *detects* a wrong-length `bounds` via `validate()`, but `_select_axis` still indexes `bounds[2*i]`/`[2*i+1]` with no guard, so the exact input the new rule flags still raises a bare `IndexError: tuple index out of range`. Discharged by **running the public API** (`isel(cov, x=1)` on a short-bounds axis), not the private helper I first probed: the run is what promoted it from a hand-wave to a filed issue. The finding is reachable *and* load-bearing, yet the correct move was **park**, because it is out of the diff's agreed **scope**: #129 scoped the work to the `validate()` rule, and subset's repair (drop vs. diagnostic-raise) is a separate decision that may want an ADR. Also noted lightly (folded into #142's constraints): **5**, the "2 per value" bounds layout is now encoded in both validation (`len == 2*len`) and subset (`bounds[2*i]`), a candidate single-source when subset is fixed.

  **New signals for the tightening pass:**
  (1) **A park's reason can be *scope*, not unreachability, and its resolution is a filed follow-up, not a log line.** The current fix-vs-park Working note splits on reachability ("a defect whose bad state has no path to a consumer... is parkable"). This finding had a path to a consumer (confirmed by running `isel`) and real leverage, yet parked because the fix lives outside the change's charter. The resolution was a **routed, traceable issue (#142)**: an action, per "verifying is an action, not an argument", not a note that rots. Distinct from #44-commit-1's "park flags the *incumbent* sibling, a different line": here the subject is a reachable crash and the boundary is *scope*. Candidate: name "out-of-scope, routed to a follow-up" as a first-class park class beside "unreachable / sole trusted constructor," its resolution a filed issue.
  (2) **Leverage measured against the *charter*, not only a consumer.** Every prior headline traced a flaw to what *consumes* it downstream. This one traced the diff against **the stated goal of the work it closes**: #129's own motivation named the subset `IndexError` as "a poor diagnosis of a malformed document," and the feature delivered only the *detection* half. The leverage question was "does the change deliver its charter, or only part of it?": a diff can be structurally true in what it *does* and still under-deliver the issue it claims to close. Candidate Working-note beside "measure leverage by tracing to the consumer": a second trace target is the work's **charter** (the issue's own motivation); a half-delivered charter is a leverage finding even when the delivered half is flawless.
  (3) **Corroboration (noted, not re-derived):** (a) self-authored **construct-and-run** again changed the outcome, probing the *public* entry point (not the private `_select_axis`) is what justified filing rather than musing; (b) the **three-review partition held cleanly** across one session: code-review took the type-narrowing/CI risk (the walrus-vs-member-access idiom), ponytail took a redundant test case, plumb took the structural charter-gap, no double-coverage, per the #37/#69 skill-partition signal.

- **2026-07-17: titiler-covjson #65 (`/position` MULTIPOINT → MultiPoint), diff review: a self-authored 12/16 finding the reviewee OVERTURNED, "a doc states intent; a bug is a failure to meet the words, not a reason to reword the doc."** A `/plumb` diff-review of the finished MultiPoint slice (9-commit branch already built), then interleaved ponytail + xhigh code-review. Structural verdict "plumb-true": the parse boundary returns a real sum type (`Position | MultiPoint | InvalidCoords`), the modeler dispatches with `match`/`assert_never`, geometry owns its invariants, functional-core/shell split is clean. Three low findings; the headline was **wrong**, and the reviewee's correction is the entry.

  *The mis-framed headline (a verified 16 wrongly recast as a live 12).* The `/position` route description said a MULTIPOINT position "outside the dataset (or on nodata) becomes a null value rather than an error." I had *constructed and run* the breaking edge (16, A1-clean): a `?nodata=` override on a dataset-edge position trips a rio-tiler off-by-one (WarpedVRT boundless read) and 500s, a real hole, **already verified** by a pinning test (`pytest.raises(match="boundless")`) and filed as #73. Correct so far. The error was the *resolution*: I promoted the verified edge into a live **sounding-12 "the public docs over-promise"** finding and proposed **rewording the description** to match the current buggy behavior (drop "or on nodata"), reading the gap between the honest internal `_read_multipoint` docstring ("any other reader error still propagates") and the confident public description as an inconsistency to fix by weakening the description.

  *The reviewee's correction (the signal).* The user refused: *"you're building in wording to account for a known bug, shouldn't the wording describe the intention? a bug indicates we are failing to do what the words say, but doesn't mean we should choose different wording when a bug is found."* Right, and it deletes the finding. A description states the **intended contract**; #73 is a *failure to meet* it, tracked in the issue + the pinning test + the implementation-level docstring (a maintainer audience, distinct from the public contract). Rewording the contract to match the defect **enshrines the bug as spec** and *drifts*: when #73 lands upstream, reality re-aligns with the *original* wording and someone must remember to change it back (the pinning test is designed to flag exactly that moment). Correct plumb output: "the edge is real and already verified by the test; the description correctly states intent; **no change**." Reverted the reword; the finding produced no commit.

  *The other two (handled correctly).* **3**: the route dispatched Point-vs-MultiPoint with an `isinstance` if/else while the sibling modeler uses `match`/`assert_never`; drove a mirror refactor, verified A1-clean (signal 3). **5 (parked)**: `_resolve_read_bands` (keyed by `read.band_names`) and `_resolve_unread_bands` (positional by `indexes`) are two selectors over the *same* band-name source that must agree; parked as essential divergence (one path has a read, one does not), pinned by a doctest + unit test. The A4 #5-boundary applied cleanly: "could one helper serve both *without* a parameter re-encoding the read-vs-no-read difference?", no, so genuinely different, not one-source-wearing-a-coat; leave it. Routed the `parse_position_coords` double-regex-match to ponytail by name.

  **New signals for the tightening pass:**
  (1) **A verified breaking edge (16) must not be re-escalated into a "reword the contract" finding when the edge is a *tracked bug*.** A new failure mode in the A1/16 family: the *edge* was run and confirmed (A1-clean), but the *resolution* over-reached, treating a doc that states **intent** as if it must describe **current buggy behavior**. The correct home for the bug is the tracker + pinning test + implementation-level docstring (maintainer audience); the public contract stays as the intent. **Discriminator vs #37** (the ADR "500 never leaks" overclaim, which *was* reworded): reword a doc only when **intent itself is overclaimed**, when the deviation is a *permanent property the design does not intend to fix* (#37: the body genuinely leaks, so the guarantee was false). Do **not** reword when a *tracked, fixable bug* deviates from a correct intent (#65: the design intends null; #73 deviates and will be fixed upstream). One rule covers both: **ground a doc in the intended behavior; reword only if the intent is what's wrong, never to match a bug that will be fixed** (doing so enshrines the defect and drifts on the fix). Candidate: sounding 12 gains a rider naming *which source* a contract/spec/description is grounded in (the intended behavior, not the current buggy implementation). First logged finding whose defect was **the resolution of a correctly-run edge**, not the edge itself.
  (2) **The reviewee overturned a self-authored finding: second flavor, and it *deleted* the finding.** #44 logged a *re-review* flipping a prior headline via empirical discipline on the fix. Here the flip came from the **reviewee's principle**, not a run: the user supplied the intent-vs-implementation distinction the wielder's confirmation bias had collapsed. Corroborates that a self-authored review's weakest point is not the edge-run (A1 covers that) but the *framing of the resolution*, and the reviewee is positioned to catch a mis-framed fix the author cannot. Mirrors #21's "a proposed fix is a legitimate reopening point," sharpened: here the reopening *deleted* the finding rather than improving the fix.
  (3) **A1 construct-and-run, on a type-level exhaustiveness guard (positive).** The sounding-3 refactor (`isinstance` → `match`/`assert_never`) was verified not by reading "the match is exhaustive" but by *removing the `case Position()` arm and running mypy*, confirming it errors (`assert_never` receives `Position`, not `Never`). Green mypy on the *correct* code proves nothing about whether the guard catches a *missing* case; only the red-input probe does. Extends the A1 "feed the validator a known-red instance" thread (the 2026-07-15 #57/#65 harness run, #130 the corpus) to **the type-checker as the validator**: a totality guard's whole value is compiler-enforced exhaustiveness, un-earned until a case is deleted and the compiler goes red. The three-lens partition held: plumb owned structure, ponytail cut a single-caller helper + redundant tests, code-review caught the inherited #72 nodata-expression *correctness* leak (a fabricated value at a masked pixel), which plumb correctly routed away by name.

- **2026-07-18: covjson-msgspec #142 diff** (subset's wrong-length `bounds` diagnostic; review mode on the self-authored diff, run alongside a ponytail-review and an xhigh `/code-review`). **Verdict: Plumb is true, and the value is the resolution of the sounding-5 candidate #129 parked here two days ago, not the (confirmatory) structural verdict.** (Merged as PR #144.)

  *Confirmatory, noted not re-derived.* The structural verdict re-fires two logged signals: **11**, guard-at-consumer is the right tier, not `__post_init__` (which would break permissive decode) and not eager-at-the-`isel`-boundary (confirmed by **running** the untouched-axis probe: subsetting `x` on a coverage whose *unrelated* axis `z` has malformed bounds succeeds, `z` preserved); and **1 reconciled with permissive decode** exactly as #113 framed it: the wrong-length `bounds` is representable by design, so the clean state is enforced at the *consuming* tier (`_select_axis`), not at ingest.

  **Headline: #129's parked 5, resolved as *don't dedup*, for a reason A4 does not cover.** #129 noted the `2 * len` bounds layout now lives in both `validation` and `subset`, "a candidate single-source when subset is fixed." A4 (the existing 5-boundary) leaves *different-deciding* idioms alone; here the two sites encode the **same** decision, yet extraction is still wrong, because `2 * len` is a **fixed spec constant (§6.1.1 `len*2`) that cannot drift**, and dedup debt presupposes drift. New sub-case: *same knowledge, N places, but un-driftable → a shared helper is a ponytail-1 wrapper, not one-source-of-truth.*

  **Co-fire 5 + 4/10, surfaced by the reviewee.** The tempting *mechanism* for sharing was the user's own proposal: construct `AxisBoundsLength` and harvest its `__str__`. Declined: it (a) couples `subset → validation` (a new import between two independent feature modules over the shared model, against #142's own constraint), and (b) needs a **fabricated `at` JSON-Pointer**, a *located* finding with no location, to fill a required field the message never reads, misrepresenting what the type *is* (a report-finding wielded as a message template). The kicker: the "dup" was not one, subset's message carries its own tail, so there was no shared string to protect (the reviewee: *"i didn't read the message closely enough to see that it's not actually a dup"*).

  **New signals for the tightening pass:**
  (1) **Sounding 5 needs a *drift-capability* gate, orthogonal to A4's *same-decision* gate.** A4 asks "same decision or different?" and spares different-deciding idioms. This adds the second axis: even when the sites *do* encode the same decision, dedup is debt only if the knowledge can **drift**. A fixed external constant (a spec `len*2`, an RFC magic number) stated on a report-path and a raise-path is not one-source debt: it is one immutable fact written twice, and extracting it is arithmetic-wrapping. Candidate: 5 now carries **two** false-positive classes, *different-semantics* (A4) and *un-driftable constant*.
  (2) **The sharing *mechanism* is in scope for 5, and can trip 4/10.** A dedup proposal is not automatically an improvement: constructing a domain type to harvest one method, when that means fabricating its other required, semantically-loaded fields, is a type-abuse a "reduce duplication" instinct hides. The tell: *does sharing require constructing a thing that is not the thing* (a located finding with no location)? If so, the duplication is the cheaper honesty. First logged dedup declined on **type-integrity** grounds, distinct from A4's different-semantics decline.
  (3) *(Watch-item, not a headline.)* **Guard *granularity* slipped from plumb to code-review.** Plumb affirmed the *tier* (11) but did not probe the guard's *scope*: whole-axis vs per-position, and `/code-review`'s removed-behavior angle caught the resulting behavior change (a narrow `isel(cov, x=0)` over a short-bounds axis, served in-range by the old per-position indexing, now raises; **confirmed by running**). Arguably clean partition (behavior-diff-on-a-legal-input is code-review's lane), arguably a plumb miss ("at what scope does this guard fire, and does that re-classify a previously-valid input?" is a shape question adjacent to 11). The new behavior is correct (refuse a malformed axis wholesale, don't propagate two bounds of unknown correctness), so it resolved to *keep + note*. Candidate: when a diff **adds a guard**, record not only *where* it fires (tier) but *how much* it rejects (scope).
  (4) **Three-lens partition held again** (corroboration, not re-derived): plumb owned the structural charter (the 5 resolution), ponytail found only convention-earned verbosity ("lean already, ship"), code-review owned the granularity behavior-change plus two doc-accuracy nits (a Raises note implying `validate()` *repairs*, and a comment saying `2 * len(values)` for a `len(axis)` that also covers the regular form), no double-coverage, per the #37/#69/#131 thread.

- **2026-07-18: covjson-msgspec #137 diff** (`validate()` misses §6.1.1's `coordinates` MUST NOT; review mode on the self-authored diff, after a user-driven scope correction and alongside a ponytail-review + xhigh `/code-review`). **Verdict: Plumb is true on the code, the value was catching a *false rationale* on a correct diff, plus a third sounding-5 don't-dedup sub-case.** (PR #146, open.)

  *The scope correction that mattered came from the reviewee, before plumb ran.* The first cut was dataType-agnostic (`coordinates == (name,)` for any axis). The **user**, reading §6.1.1, caught that flagging `tuple`/`polygon` is wrong: their `coordinates` is arity-defining and can't be the one-element default, and narrowed scope to non-composite axes. That was a sounding-16 defect (a *misleading diagnosis*: "omit your coordinates" fired on a malformed polygon whose real fault is position arity), caught by inspection, not plumb. Plumb ran only on the already-narrowed diff, so it could **confirm** scope, not originate it. **Reinforces the "run plumb on the plan/first diff, not only the polished one" Working note with a concrete miss:** sounding 16 on the first version, probe a polygon with `coordinates: ["x"]`, is exactly the input that exposes the misleading diagnosis.

  **Headline: a correct diff carrying a *lying* docstring (16 surfacing 4).** The narrowed code was right; its docstring justified the exclusion as one fact: "composite `coordinates` can never be the one-element default." **Running** the excluded case (a legal 1-wide `tuple` at key `x` with `coordinates: ["x"]`) emitted `[]` and proved that claim *false for tuple*: a 1-tuple **can** carry a one-element `coordinates`, so it is excluded by an *interpretation* (read `coordinates` as required for a composite axis), not by impossibility. Only polygon's exclusion is a tautology (a GeoJSON position is >=2 components). The prose stated a **decision as a structural fact**: a sounding-4 defect (a rationale lying about the design's shape), latent because a maintainer trusting "can never" could drop the `dataType` filter as a no-op and silently start flagging degenerate tuples. Drove the sole plumb-pass change: **split the two exclusion reasons in the docstring** (polygon structural, tuple interpretive); no code change. The park (the 1-tuple under-report) resolved into *documentation of the decision*, not code. Same family as the 2026-07-07 headline (a docstring that "claimed correctness" while the type lied, caught only by running): now extended from a *type's* claim to an *exclusion's stated reason*.

  **Sounding 5: third don't-dedup sub-case, largely confirming #142.** Candidate: the default `(name,)` lives in both `coordinate_identifiers` (resolve) and the new check (detect). Declined and **proven** by running: `coordinate_identifiers` returns `(name,)` for *both* the violation (`coordinates=("x",)`) and the conformant-omitted case (`coordinates=None`), so it **flattens the present-vs-absent distinction the detect exists to draw**, reuse would hide the decision (A4's "N sources wearing the same coat," inverted: the tempting shared helper is *lossy* for the second consumer's purpose). Also confirms #142's **un-driftable-constant** gate: `(name,)` is a frozen spec default. Two independent reasons the reuse is wrong (lossy-for-purpose + un-driftable), neither being A4's different-decision case.

  **New signals for the tightening pass:**
  (1) **Sounding 16 verifies the *reason* for a boundary, not just the boundary.** "Is this edge bounded?" has a second half: "does the *stated reason* survive the run?" A structural-impossibility rationale is falsified by constructing the input the structure supposedly forbids (here, the 1-tuple the docstring called impossible). A correct filter can carry a false why, and the false why is the latent defect. Candidate Working note: **when a design excludes a case, run the excluded case, a green exclusion proves the filter fires, not that its reason is true.**
  (2) **Three-lens partition held (corroboration).** Plumb owned structure (scope confirmation + rationale honesty); ponytail found nothing to cut ("lean already, ship," and correctly *refused* to cut the polygon test case, which guards the `"polygon"` member of the exclusion tuple); xhigh code-review returned **0 findings without padding** (honoring "emit what you have"). The sounding-5 candidate stayed plumb's, never mis-routed as a code-review dup.

- **2026-07-18: covjson-msgspec #138 (guide + diff, one session)** (polygon depth-3 MUSTs: position arity, ring length, ring closure). **First full guide -> build -> diff-review pair in the log, and both altitudes earned their keep on *different* findings**: the "run plumb on the plan and again on the diff" working note, corroborated with a clean instance. Guide produced the plan; the diff-review's whole value was one run-surfaced park routed to a new issue. (PR #148, open; follow-up #147 filed.)

  **Guide headline: sounding 16 verified against the *downstream consumer*, before a line of code.** The design's leverage ranking came not from reasoning but from *running shapely* (the geo bridge's engine) on the three violations: a short position -> `IndexError` (hard crash), an unclosed or three-position ring -> shapely *auto-closes and accepts* (silent), a two-position ring -> `ValueError`. That produced a leverage table ranking the three MUSTs by downstream consequence (position arity is load-bearing, it guards a real crash; closure is pure conformance, no consumer breaks), which shaped the whole design (arity its own code for sure; the ring rules the mergeable pair). Also fetched RFC 7946 3.1.1/3.1.6 to ground severity (§12), not asserted from memory.

  **Diff headline: the park that became #147, surfaced only by a run.** Probe #5 (a polygon that *omits* `coordinates`) showed the new arity check resolves the default to `(name,)`=1 and floods N per-position "position has 2 components but 1 identifier" issues: a *misleading* diagnosis (points at positions; the real fault is the missing `coordinates`), where the geo bridge's own "lacks x/y" message is clearer. Parked (the documented guide-mode scope boundary: a polygon's `coordinates` must be >=2, a distinct rule) and *routed to a follow-up issue* (#147, the #129 park-to-issue pattern). The structural verdict was a plain "Plumb is true"; the run is where the value was: the structural read alone would have shipped clean and missed it.

  **Discharged by running, not reasoning (self-authored, eight probes):** §13 symmetry, probe #7 confirmed an arity-green polygon bridges with no IndexError (the arity check's whole point: sharing `coordinate_identifiers` with the bridge makes the crash unreachable for validated docs); plus emit-both, the shape-gate (scalar / list-of-strings / empty-position reach no deep read, no `len(str)` crash), conformant-3D silent, and closure where int `0` vs float `0.0` reads as *closed*, matching RFC's "identical values" MUST over its representation SHOULD. The structural read would have affirmed all eight un-run.

  **New signals for the tightening pass:**
  (1) **§16 in guide mode targets the downstream consumer, and is runnable *pre-code*.** Hunting the breaking edge before code exists usually means reasoning about your own unwritten function; but the *consumer* (here shapely) already exists and can be run. Its tolerance profile: crash vs silent-repair vs reject, ranks your planned rules by leverage before you write one. Candidate Working note: **guide-mode §16 = run the consumer against each violation you plan to catch; its failure mode sets the rule's priority** (a hard crash outranks a silently-tolerated conformance nit).
  (2) **TypeGuard-vs-TypeIs is a soundness call, not a style one (§1/§3).** The reviewee pushed narrowing `_is_polygon_array` from a cast to a guard; `TypeIs` was *unsound* because the predicate is *stricter* than the narrowed type: it returns False for an empty `()`, which IS a `tuple`, so TypeIs's negative-branch narrowing would wrongly strip `tuple` from the else-branch. `TypeGuard` (positive-branch only) is correct. Candidate sounding-adjacent rule: **when a predicate narrows a type, ask whether it is stricter than that type; if so only a positive-only guard (TypeGuard) is sound, never the bidirectional TypeIs.**
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

  **Self-authored review verified by running, not reading (corroboration).** Every accept/reject sounding confirmed by a constructed 5-case decode matrix plus the full 909-test + doctest run, per "only a run survives confirmation bias." Three-lens partition held: plumb owned the prose catch + the §13 decomposition call; ponytail owned the declined mirror test and a *deleted* dead fixture (a polygon-restates-default case the new construction rule made unconstructable); code-review owned line-level correctness.

- **2026-07-19 (later), covjson-msgspec #139** (enforce the Common Domain Types composite coordinate identifiers in `validate()`; guide mode -> build -> plumb/ponytail/code-review -> ship). Distinct session, builds directly on the #147 pair above. Shipped as PR #152 (Closes #139), all local tests + `act` type-checkers green (basedpyright strict 0/0/0).

  **Headline (§12 grounded-in-source, co-firing §1/§4): opening the actual spec revealed the requirement's *shape*, not just its strength, the issue's prose paraphrase was one keystroke from becoming the type.** The issue proposed `composite_coordinates: tuple[str, ...]` and an acceptance criterion "a Trajectory whose coordinates are not `[t,x,y]` is reported." Fetching domain-types.md verbatim (the issue's *own* constraint: verify against the spec, not our fixtures) showed several types permit *alternatives*, Trajectory is `[t,x,y,z]` **or** `[t,x,y]`, MultiPoint is `[x,y,z]` **or** `[x,y]`. A single tuple cannot represent that, and the stated criterion would have false-positived a conformant 4-D Trajectory (reporting a legal document as broken). The field became `tuple[tuple[str, ...], ...]`, a *set* of orderings checked by membership. **Signal: §12's "grounded in the real source" is usually invoked for severity (MUST -> error); this is the case where the source governs the *type's shape*. The author's one-line paraphrase ("Trajectory is `[t,x,y]`") was about to be encoded as a single-tuple field; only opening the spec caught that the requirement is a set of alternatives. Verify the shape against the source, not the ticket's summary of it.**

  **§16-adjacent: the issue's own stated constraint was stale, invalidated by a merge from hours earlier.** #139's Constraints said a composite axis omitting `coordinates` "resolves to `("composite",)`, which would violate this rule." But #147 / ADR-0019 (the entry above, merged the *same day*) had just made that unreachable, such an axis now fails at construction. The guide had to reconcile the issue against current HEAD rather than take its premises at face value; the rule's real target is a *constructible but wrong* ordering (a Trajectory declaring `[x,y]`), not the omitted case. **Signal (the #147 "docs as lies after a reversal" note, one level up): a reversal invalidates not only docs but *sibling issues* that depended on the old behavior. When a guide runs against a ticket, check its stated constraints against HEAD: a recently-merged dependency can have turned a premise into a lie that nothing flags.**

  **Self-authored §16 verification = hunt the edges your *earlier* sweep skipped, not re-run the ones you ran.** Implementation ran a 7-case edge sweep (all green). The mandatory diff-review verification could have re-run those; instead it noticed the sweep had *omitted the polygon family* (PolygonSeries / MultiPolygon / MultiPolygonSeries) and a polygon-with-wrong-identifiers case, and constructed-and-ran those, plus a registry-sanity loop (every composite entry's allowed set non-empty and dataType-consistent) and a re-confirmation that the corpus fixture emits *exactly* one issue under `check_values=True`. All passed, but the value was catching the gap in my own coverage, not re-affirming what I had already shown. **Signal: for the self-authored run, "construct and run the breaking input" means the inputs your first pass did not cover; a verification that only re-runs the already-run cases is confirmation bias wearing a lab coat.**

  **Three-lens partition held, with one §5 dup sitting on the plumb/code-review seam.** plumb-review = true (3 low-leverage parks); ponytail = lean, ship; xhigh code-review = no correctness bugs (3 low cleanups). The one finding that surfaced in *two* lenses independently: a duplicated dataType-match predicate (`composite.data_type == rule.composite_data_type` re-derived in the coords rule, the negation of what `_composite_data_type_issue` already computes). Both lenses flagged it; both parked it (a one-token `==`; extract a shared predicate only if it grows). **Note: the partition holds but is not a clean cut, a low-leverage §5 dup is visible from the plumb altitude (two homes for one decision) and the code-review altitude (simplification) alike. Co-visibility is not redundancy; it is the same dup seen at two focal lengths, and both lenses correctly ranked it *park*.**

  **Process.** Guide reshaped the issue *before* code (the arc the "run plumb on the plan" note wants), and the issue *body* was corrected before implementing, per the repo's draft-issues-first agreement. An API-shape call: carry `actual` in the finding, or just `expected` like its sibling?, was settled by *running msgspec* to see that its `ValidationError` echoes the bad value only for enum/literal mismatches (the nearest analog to this check), rather than asserting a convention: §12's discipline applied to a neighbor library's observed behavior, not a spec. No new ADR (rests on ADR-0019, which already names #139). Spun off a docs follow-up (#151: the `decode -> validate -> bridge` recipe plus a loud / silent-nonconformant / silent-erroneous bridge-failure taxonomy, with the scenarios to be *run* at authoring time). `--body-file` used throughout (the macOS bash 3.2 backtick trap, logged again).

- **2026-07-19 (later still), covjson-msgspec #109** (the xarray bridge silently corrupted spec-valid dates outside numpy's `datetime64[ns]` window: 2300 came back as 1715). Guide mode on a *bug fix*, then build, then plumb/ponytail/code-review, then ship. PR #154 (Closes #109); all local tests, the `act` lowest-direct floor leg, and the four type-checkers green. *(Prose here written without the em-dash double-hyphen: recurring feedback landed mid-session, so colons/commas replace it.)*

  **Headline (§16 turned on my own verification math, which overflowed twice before it was right).** The bug is a guard against a failure that never fires: numpy int64-*wraps* an out-of-range date instead of raising, so `suppress(ValueError, OverflowError)` was a no-op. Fine, and easy to see. But *building* the fix meant computing numpy's ns limits to range-check against them, and my first two attempts silently overflowed doing exactly that: `ns_min.astype("datetime64[us]")` wrapped the min to the max, even when the min was built from a string. The landmine caught the mine-detector. Only running the bounds computation (asserting a known-in-range date actually classifies as in-range) exposed it; a careful read of the "compute the bounds, then compare" code looked correct and was not. **Signal: §16's "a bounded verdict is unearned until run" applies to the *verification code*, not only the input under review. When the domain is a known trap (int64 datetime overflow, float epsilon, timezone math), the tool you reach for to check the boundary is subject to the same trap. Run the check; do not trust that it computes what it reads as computing.**

  **The better *shape* came from running a sibling, not the code under change (§4/§5/§7).** The issue proposed "route out-of-range dates to cftime," and ADR-0015 had recorded that codomain. Running the *pandas* bridge on the same input showed pandas does not corrupt: it widens the datetime64 resolution (or falls back to strings), never cftime. That surfaced Option B (widen the unit), a shape neither the issue nor the ADR considered, and reframed the question to "what does the cftime arm *mean*?" cftime means "a calendar numpy cannot represent"; an out-of-range Gregorian date *is* representable, only not at ns precision, so it is a *resolution* matter, not a *calendar* one. Routing it to cftime overloads the arm's meaning; widening the unit keeps the two axes orthogonal (calendar-kind picks cftime-vs-datetime64, range picks the unit). **Signal (sharper than #139's "run msgspec to settle a detail"): a sibling implementation did not settle a detail here, it revealed the whole correct shape. When one path of an N-path design is buggy, ask what its siblings actually *do* with the same input before adopting the buggy path's own proposed fix. A sibling that already handles it names the shape.**

  **A §7 design verdict carried its cost in a *different dimension* (dependency reach), exposed only by running on the declared floor.** Option B (widen) is the faithful, leaner shape, but it depends on xarray *preserving* a non-ns datetime64 rather than coercing it back to ns, a capability newer than the declared floor. Running B against `xarray==2024.10` (the floor) *hard-failed* with `OutOfBoundsDatetime`: the design that passes on dev (xarray 2026.4) does not exist on the minimum supported version. So "B is cleaner" came bundled with "B forces a floor raise," and the exact floor was pinned by the oracle (invoking the repo's own uv-minimum-versions skill: 2025.01.1 fails, 2025.01.2 is the first that preserves), not by judgment. **Signal: a "the better design" verdict is unearned until run on the *oldest supported environment*, not just dev; a design's viability can live in a dependency version. Where a sounding (here §7 faithfulness) trades against a dimension it does not own (dependency reach), name the trade and let the owner decide. One PR both fixed the bug and raised the floor, the floor proven by the lowest-direct CI leg.**

  **Self-authored diff-review §16, a second instance of #139's signal: run the exact assumption, not the cases already run.** `_fits_ns_window` uses a one-second-inside margin and its docstring claims "conservative, so no out-of-range value slips through." The diff-review verified *that claim* by running the exact margin (a value at `2262-04-11T23:47:16`, one in the excluded last second, one just past), confirming the accepted set is a strict subset of the representable set and that every ns-narrowed value equals its us parse (no wrap). The already-run repro and edge cases never touched the margin; the sentence in the docstring was the thing to run.

  **Process + recurring.** Guide reshaped the fix against *both* the issue's proposal and an accepted ADR's codomain (ADR-0015 updated, not superseded). The A-vs-B representation choice and the floor raise were surfaced as explicit `AskUserQuestion` decisions, since a codomain change on a public bridge and a floor raise are the user's calls. code-review's conventions angle caught a comment-style miss (test comments narrating past behavior plus an issue ref) against a *user-memory* convention, not a CLAUDE.md rule; the user then caught double-dash overuse in the *code I wrote*, not only chat. The structural lenses do not own house prose style, so it rides on the conventions angle and the human.

- **2026-07-20, covjson-msgspec #153** (the export bridges handled a spec-valid `±hh:mm` temporal offset three inconsistent ways: xarray flattened to naive-UTC but leaked numpy's tz `UserWarning`, pandas kept it tz-aware, a mixed naive+offset axis silently degraded to raw strings). Guide mode on a *bug fix*, then build, then plumb diff-review, ponytail-review, xhigh code-review, then ship. PR #155 (Closes #153); all local tests and the four `act` type-checkers (basedpyright strict 0/0/0) green. #153 was the last open bug, so clearing it satisfied the repo's "close open bugs first" gate. *(Prose without the em-dash double-hyphen, per standing feedback.)*

  **Guide headline: the issue's own framing was falsified by a three-line run (§12 × §5, surfaced by §16).** The ticket framed the fix as "suppress the stray warning; the bridges already flatten to naive-UTC." Running the three temporal paths side by side (xarray/numpy, pandas, `resolve`/`to_datetime`) on one offset value showed they *disagree*: xarray flattens with a warning, pandas keeps it tz-aware, `resolve` keeps it tz-aware. So the "consistent naive-UTC default" the issue leaned on did not exist, and the real task was "choose the offset projection and make the two bridges agree," not "silence a warning." **Signal, sharpening #109's "a sibling reveals the shape": that move works in *guide* mode, before any code, and against the *issue text* itself. A one-paragraph run of the sibling implementations can overturn the ticket's stated premise, so guide mode must run the siblings, not reason from the issue.**

  **Self-authored §16 miss: I wrote an escape-hatch claim into the docs, and only a user-prompted run falsified it.** In the guide and the docstrings I stated `to_datetime` is the faithful escape hatch for a caller who wants the offset preserved, and applied it to *both* the standard and cftime paths. It is wrong for cftime: `resolve`/`to_datetime` is calendar-blind (it parses proleptic-Gregorian), so `to_datetime("2020-02-30T00:00:00+05:00")` returns `None`, because Feb 30 is a real `360_day` date and not a Gregorian one. The claim read as correct and had already been written into a docstring and the guide; the correction came only when the user asked "what scenario would even hit the cftime path with tz worth preserving?", which prompted the run. **Signal: "affirmed is not closed" covers self-authored *prose*, not only code, and a plausible cross-subsystem cross-reference (`to_datetime` to the cftime bridge) is reasoning until the boundary input is run. Provenance: I did not self-trigger the verification, the *user's* question did. A self-authored design does not reliably run its own claims even when the skill says to, so an external prompt (a reviewer who is not the author) stays the likeliest trigger.**

  **Diff-review §16 turned on a test's assertion-scope: a guard that cannot catch what it guards.** The regression test asserted "no tz warning leaks" by filtering on the *exact numpy message string* the production code suppresses. If numpy ever rewords that message, the production filter stops matching (the warning leaks again) and the test's filter stops matching too (the leaked warning is not escalated to an error, so the test stays green). The guard shared its predicate with the thing it guards, so it was blind to precisely its own failure mode. Fix: assert on *any* `UserWarning`, keeping the production filter narrow. **Signal: §16 applies to a test's own assumption, not only the input under review; a test whose predicate is copied from the code it guards cannot detect that predicate going stale. (It later went moot when the fix moved to fold-before-parse and emits no warning at all, but the structural point stands.)**

  **A dependency-floor viability question, answered by running the whole version line, and closed by the user spotting the gap (§7 traded against a dimension it does not own; the uv-minimum-versions oracle).** The user asked for a thread-safe alternative to the process-global `warnings.catch_warnings()`. Two shapes: fold the offset to naive-UTC before numpy sees it (self-contained, chosen as Option F), or route the standard parse through pandas' vectorized parser (faster on an all-offset axis, but its out-of-ns support is version-gated). Pinning the pandas floor for the pandas route meant *running a version matrix*: 2.1, 2.2, and 2.3 all raise `OutOfBoundsDatetime` on an out-of-ns date, only 3.0 widens to `datetime64[us]`, so that route would force `pandas>=3.0` versus the current `>=2.0`. I first tested 2.1/2.2/2.3.0 and concluded "floor is 3.0"; the user then asked "any 2.x with minor > 3?", which drove testing the *final* 2.x release (2.3.3, published after 3.0.0, the likeliest home for a backport): it still raises. **Signal, echoing #109's "viability lives in a dependency version, run the floor": a "the floor is X" claim is unearned until the *entire* version line below the boundary is run, including the last patch of the last pre-boundary minor. And again the author under-ran (stopped at 2.3.0), the user closed the version-space gap.**

  **Process + recurring.** Guide reshaped the fix against the issue's own framing (ADR-0015 updated, not superseded), with the offset semantics and the deferred pandas floor logged as decisions in the ADR. ponytail merged two near-identical pandas tests into one parametrize (the repo's stated preference). xhigh code-review's conventions angle again caught a comment narrating past behavior plus an issue ref (the same user-memory convention #109 tripped), and then the user challenged a `# pragma: no cover` on `maybe_datetime`'s malformed-fallback: running a malformed value proved the branch reachable, so the pragma became a test. **Signal: a `# pragma: no cover` is a claim ("this cannot or should not be tested") that rots as the surrounding code changes, so treat it like any other unearned verdict and run the branch before trusting it.**

- **2026-07-20, second A1 landing off the ledger (not a review run).** A scoped harvest-and-land pass, prompted by a "how are things looking" status check after the log had raced 9 entries (07-17 titiler #65 to 07-20 #153) ahead of the ledger and SKILL.md. Read the 9 unharvested entries, confirmed A1/§16 was the runaway theme (it fired in all 9, in new directions the first landing's one-sentence Move did not cover), and landed only that, one focused edit, per the workflow's "isolate the behavior-changing edit" rule. **Landed into SKILL.md:** sounding 16's Move gained "the run target is wider than the input under review" (run the excluded case to test its stated reason, the downstream consumer to rank leverage pre-code, and the check itself: delete a case arm to see the type-checker go red, run the boundary on the oldest supported environment; resolve a default to the value it produces, not its description); the "Affirmed is not closed" Working note gained "the claim need not be code" (a docstring, a narrative .md nothing executes, a test predicate copied from the code it guards, a `# pragma: no cover`), "the verification hunts un-swept ground," and the provenance rule (the author under-runs even when the skill says to, so an external prompt is the likeliest trigger). **Ledger:** §A1 sub-rules (h) through (m) recorded with cites (#65/#137/#138/#139/#109/#147/#153), marked landed; §F item 1 flipped to done. **Deliberately deferred:** (f) citation-is-a-claim and (g) decode-the-bytes (pre-07-17, route through sounding 12 / already ledgered); the full re-harvest of 07-18 to 07-20 (ranking unchanged, so make-work now); and A2/A3/A5/A6/A7 plus the two new sub-themes (prose-drift-after-reversal; run-the-sibling-to-find-the-shape), each to its own isolated window. **Validation:** same as the first pass, dogfooding not a test, watch whether runs where 16 fires now reach for the excluded case / consumer / verification-code by default.

- **2026-07-20: generated TS/React user dashboard** (a sample authored fast, then reviewed; plumb review mode; the **first adversarial-batch pilot run**, and the first entry outside the self-plumbed corpus by design).
  Corpus: generated · poor · typescript · frontend-ui · greenfield
  Unhomed: primitive-obsession / domain-typing (`role`/`status` as `string`; caught in pieces by 1+3+4, no single "model the value as a type" probe); immutability / mutable-data (in-place `push` and field mutation; not cleanly any current sounding).

  **1/2 (headline): a four-field remote state made illegal states representable.** `users`, `isLoading`, `isError`, `errorMessage` as four independent `useState`s permit `isLoading && isError` and `isError` over stale non-empty `users`; the legal states are exactly three (loading / error(message) / ok(users)). Failure scenario: a refetch sets `isLoading=true` without clearing `isError`, so the render's `if (isError)` shows a stale error over a fresh load. The naive fix (a `useEffect` syncing the flags) adds illegal states; the move is one `RemoteData` discriminated union, which dissolves the cluster and the interleave at once.
  **1+3+4 (primitive obsession): `role`/`status` as `string`.** Closed sets ("admin"|"member"|"guest", ...) typed `string`, so `label`/`badge` are non-exhaustive `if` chains with a fall-through: a new role renders as "Guest" (a privileged role silently mislabeled), a new status renders raw. The `string` is the root that hides the non-exhaustiveness from the checker; the move is domain types + an exhaustive switch (`assert_never`).
  **immutability: `addUser` does `users.push(u); setUsers(users)` and `suspend` does `u.status = "suspended"`.** Model the data immutable and update by copy. The specific same-reference `setUsers(users)` (React bails on the re-render) routes to code-review by name; the structural mutable-data model is the plumb-level shape.
  **Tail:** 6 (fetch+parse+setState inline in the effect, extract `useUsers()`, which also removes the mock-global-`fetch` need); 5 (date format duplicated in `header()` and the row); 2 (`selectedId=""` in-band sentinel).

  **New signals for the tightening pass:**
  (1) **Both Tier-1 coverage-audit candidates fired, from the receiving end, on generated code.** primitive-obsession (across 1/3/4) and immutability (Fowler mutable-data, unhomed) both surfaced, the first empirical corroboration of the deductive nominations. Per CORPUS.md's validity check they are NOT promoted to §A yet: a candidate hot on `generated` but cold on real repos is an LLM artifact, so hold until a real-repo run fires them too.
  (2) **The `Unhomed:` line did its job the moment the corpus left the self-plumbed cell.** On ~40 self-plumbed entries it would read "none"; here it named two real gaps immediately, direct confirmation that the silence was selection bias, not completeness.
  (3) **testability stayed homed under 6, not unhomed.** Inject `fetch` and the load logic is testable without mocking a global, so on frontend code testability is a *consequence* of 6, not a distinct probe. Whether it needs its own sounding is the mock-heavy Java run's job to answer.
  (4) **The plumb / code-review partition held on frontend code** (a first): the mutable-data *model* is plumb; the same-reference *no-re-render* is code-review. First non-Python, non-self, non-library run in the log.
  (5) **Caveat (self-review bias):** I authored the sample and reviewed it, a mild author-bias; it was written as realistic "fast" React, not a plumb checklist, but a real-repo run removes the confound. Pilot verdict: format works, candidates fire, proceed to complete the 5+5 batch.

- **2026-07-20: earthaccess `auth.py` (real repo, first non-self review run)** (external-authored, plumb review mode on one module of a messy brownfield NASA-Earthdata library; real-batch run 1).
  Corpus: external-reviewed · mixed · python · library · brownfield
  Unhomed: primitive-obsession / domain-typing (`strategy: str`, a closed set of 3 dispatched by if/elif); sound-typing (`login -> Any` really returns `Auth`; `token: Mapping[str,str] | None` under-specifies two shapes). immutability did NOT fire standalone: it fused into the sounding-1 state-machine.

  **Headline (2/3 + primitive-obsession + sound-typing): a silent login no-op.** `login(strategy: str)` dispatches `interactive`/`netrc`/`environment` by a non-exhaustive `if/elif` with no `else`; `login` is typed `-> Any` and returns `self` unconditionally. `login(strategy="netrcc")` (a typo) matches no arm and returns an `Auth` with `authenticated=False` and no error; the user believes they authenticated and every later call quietly returns empty (`get_s3_credentials` -> `{}`). Root is `strategy: str`: make it `Literal[...]` / enum so the checker rejects the typo and a `match` is exhaustive, and give `login` a signaled outcome. Four probes (2, 3, primitive-obsession, sound-typing) converge on one load-bearing, security-adjacent flaw.
  **1 (park-leaning): `Auth` is a mutable bag of four public fields with implicit invariants.** `authenticated` is decoupled from `token`; `token: Mapping[str,str] | None` holds two shapes (a bare `{access_token}` from the env strategy vs the full token record from password auth). Sole-mutator discipline (`_get_credentials`) mostly upholds it, so park, but the two-shape `token` is a latent faithfulness/1 issue; the ideal is a sum type (`Unauthenticated | TokenAuth | PasswordAuth`).
  **Tail:** 6 (credential resolution welded to input/env/file/HTTP across the `_*` methods, separate resolve-from-source from exchange-for-token); 9/4 (`_get_credentials` is a query-named command that mutates `self` and does HTTP); 2 (`get_s3_credentials` collapses three failure reasons into `{}`); 5 (the twice-copied "URLs should be in constants.py" TODO, self-flagged). Routed to code-review: `login -> Any`, and `logger.exception` on a falsy non-raising response.

  **New signals for the tightening pass:**
  (1) **Two of the three coverage-audit candidates fired on REAL code, on the headline: primitive-obsession and sound-typing.** The validity check the generated run could not provide: they are not LLM artifacts. primitive-obsession has now fired on both generated (TS) and real (Python); one more real corroboration earns it promotion from a LANDSCAPE Tier-1 nomination to a §A candidate.
  (2) **immutability manifested differently across the corpus split.** Standalone in-place mutation on generated; here it *fused* into the sounding-1 mutable-state-machine (a mutable object with implicit cross-field invariants), with no standalone Fowler "mutable data" instance. So immutability's value as a *standalone* probe is corpus-dependent (clear on a fresh data structure, fused with 1 on an OO-ish stateful object). Watch whether the mutation-heavy Java run gives it a standalone instance or also fuses it.
  (3) **The candidate gaps co-fire with totality/outcomes on stringly-typed dispatch.** primitive-obsession + 3 (totality) + 2 (outcomes) + sound-typing converged on the one `strategy: str` flaw: a primitive standing in for a closed set turns an exhaustiveness gap into a silent-fallthrough bug. A candidate co-fire cluster for the combine.
  (4) **Plumb earned its keep on external code:** the headline is a real, security-adjacent silent-auth-failure, found by structure (the str-dispatch shape), not by running. First external-provenance review-run headline in the log that is a live defect rather than an affirmation.

- **2026-07-20: generated Java order-lifecycle service** (a sample authored fast, then reviewed; plumb review mode; adversarial-batch **gen-2**, the mutation-heavy-OO / mock cell, chosen to probe immutability-standalone and testability-without-mocks, the two candidates the self-plumbed corpus structurally cannot see).
  Corpus: generated · poor · java · service · greenfield
  Unhomed: none new (immutability and testability both found homes, see signals (1) and (2); primitive-obsession recurs but is already a tracked §A candidate).

  **1 (headline): the order lifecycle is a `String` status plus four independent nullable timestamps, and the transition methods don't guard the current state.** `Order` carries `status` ("NEW"|"PAID"|"SHIPPED"|"CANCELLED") and `paidAt` / `shippedAt` / `cancelledAt` / `trackingNumber`, every one a public setter mutated independently. Representable = 4 status × 2⁴ nullable fields = **64 combinations; ~5 are legal**:

  | state | status | paidAt | shippedAt | tracking | cancelledAt |
  | --- | --- | --- | --- | --- | --- |
  | new | NEW | null | null | null | null |
  | paid | PAID | set | null | null | null |
  | shipped | SHIPPED | set | set | set | null |
  | cancelled | CANCELLED | any | null | null | set |

  Failure scenario, realized by the missing guards: `cancelOrder(id)` sets CANCELLED, then `shipOrder(id, "1Z...")` (no status check at all) overwrites to SHIPPED, sets `shippedAt`, and emails the customer that their cancelled order shipped. Symmetrically `payOrder` guards only against CANCELLED, so `payOrder` on a SHIPPED order reverts status to PAID while `shippedAt`+`trackingNumber` stay set: the illegal row `PAID · shippedAt set` is now live. The naive fix (add an `if (status.equals("SHIPPED")) return false` to each method) scatters the state machine across the call sites and still leaves the 64 combinations representable. The move is one sealed type: `sealed interface OrderState permits New, Paid, Shipped, Cancelled` with records carrying exactly their own timestamps, transitions as methods returning the next state (`New.pay(clock) -> Paid`), so an illegal transition doesn't compile and the illegal rows can't be constructed.

  **6 + testability (the target probe): the pure pricing is welded to Postgres, SMTP, and the clock, with no seam to inject a test double.** `new OrderService()` (no-arg) opens `DriverManager.getConnection("jdbc:postgresql://…")` into a concrete `JdbcOrderRepository` and news up a `SmtpEmailClient`, and every method reads `LocalDateTime.now()` inline. The discount/tax computation in `placeOrder` is a pure function of `(items, tier)` but is reachable only after standing up a database and an SMTP server. To unit-test that the GOLD tier takes 10% you must mock the repo and the mailer, and there is no constructor seam to pass a mock through. Move: constructor-inject `OrderRepository`, `EmailClient`, and a `Clock`, and extract `price(items, tier) -> Pricing` as a pure function; the pricing then tests with zero mocks. **testability-without-mocks here is fully a consequence of 6**: the only reason a mock is needed is that the effects aren't injected, and 6's fix (inject the seams) dissolves the need entirely. This is the same verdict the frontend pilot reached; the mock-heavy Java run was supposed to be where testability might earn a standalone identity, and it did not.

  **immutability: fires BOTH fused and standalone on this run.** Fused into 1: the mutable status+timestamps state machine above. Standalone, and *not* reducible to the lifecycle invariant: `getItems()` returns the live internal `List<OrderItem>` (a caller mutates the order's items bypassing the service and its recomputed totals), `setItems(list)` stores the caller's list by reference (aliasing), and `OrderItem` is a fully mutable value (`setSku`/`setQuantity`/`setUnitPrice`) so an item's unit price can change under an order whose `subtotal` was already computed and persisted. These are Fowler "mutable data" / leaked-representation instances, co-firing with encapsulation (10), independent of the state machine. So the mutation-heavy Java run answers the CORPUS's open question: it *does* give immutability a standalone instance, and that instance is the leaked-mutable-collection / mutable-value-object face, distinct from the lifecycle face that fuses into 1.

  **Tail:** 2 (`placeOrder` returns `Long`/`null`, losing "empty items" as a reason; `pay`/`ship`/`cancel` return bare `boolean` collapsing not-found vs illegal-transition into one `false`); 3 (`describeStatus` is an if/elif with a bare `return "Cancelled"` default, so any unknown or future status silently reads "Cancelled"); primitive-obsession (`customerTier`/`status` are `String` closed sets dispatched by `.equals()`, so a typo `"Gold"` silently yields 0% discount, no error); 17 (`describeStatus` reads only `Order`'s fields and none of the service's: feature envy, belongs on `Order`/`OrderState`); 9 (`OrderService` = place+pay+ship+cancel+describe, a god-service). Routed to code-review: `tier.equals(...)` NPEs on a null tier; `getUnitPrice()` NPE.

  **New signals for the tightening pass:**
  (1) **testability-without-mocks fired on the mock-heavy cell and was fully a consequence of 6, not a standalone probe.** Two runs now agree (frontend pilot, this Java service): the untestability *is* the un-injected effect, and 6's inject-the-seams move erases it. This confirms the earlier §C "fold testability" verdict on the mechanism, and corrects the CORPUS worry that it might be a bias-suppressed standalone: it is present on mock-heavy code (not suppressed to zero), but its fix is identical to 6's, so it folds into 6 as a testability *lens*, not a separate §A sounding.
  (2) **immutability got a standalone instance here (leaked mutable `List` from `getItems`, mutable `OrderItem` value) distinct from the lifecycle instance that fused into 1.** So its two faces are now legible: the *lifecycle-invariant* face fuses into 1, the *leaked-representation / mutable-value-object* face co-fires with 10. Candidate combine verdict forming: immutability may be fully covered by 1 + 10 (a lens over both) rather than a new §A sounding. Hold for the batch analysis; pydantic (real-3) gives a third data point below.
  (3) **primitive-obsession fired again, but this is a second *generated* positive (Java), not a real one**, so it does not meet the "one more real corroboration" §A-promotion bar; it adds a generated data point in the same co-fire cluster (primitive-obsession + 3 + 2) as earthaccess.
  (4) **The sounding-1 headline is a live defect on generated code** (ship-a-cancelled-order), found from the state-shape, not by running. **Caveat (self-review bias):** I authored the sample, so the flaws are ones I could have planted; the structural findings are real regardless of authorship, but the author-bias is exactly why real-3 (pydantic, external, below) is the load-bearing run of this pair.

- **2026-07-20: pydantic `color.py` @ v2.5.3 (real repo, well-typed: the primitive-obsession acid test)** (external-authored, plumb review mode on one self-contained module; adversarial-batch **real-3**, user-named target; the point is to hold language constant, Python, while quality goes from earthaccess-`mixed` to pydantic-`clean`, and ask whether primitive-obsession false-positives on genuinely well-typed code).
  Corpus: external-reviewed · clean · python · library · active
  Unhomed: flag-argument that switches return/effect semantics (`as_named(fallback: bool)` toggles raise-vs-return): homed loosely under 2/4, but the *smell* itself (Fowler "Flag Argument") has no probe.
  *Seed note (2026-07-20 rescope): this single-module review is a **seed** of the pydantic whole-repo audit (real-3), not a standalone real entry. The `clean` repo tag is an a-priori prior the audit will confirm or refute; `color.py` is one deprecated module, so tallies here are provisional and module-scoped, not repo-level claims.*

  **Acid-test result (the reason this run exists): primitive-obsession correctly did NOT fire, despite a surface-pattern match identical to earthaccess.** `parse_hsl(h_units: str)` takes a closed set {`deg`, `rad`, `turn`} and dispatches by `if h_units in {None,'deg'} / elif == 'rad' / else`, which is structurally the earthaccess `strategy: str` finding to the letter. But the leverage trace closes it: `h_units` is a transient regex capture group (`(deg|rad|turn)?`) consumed two lines down in the same function, never stored, never a public parameter, with no downstream consumer that trusts it as a domain value. Same shape, opposite verdict, and the *leverage discipline* (trace to the consumer) is precisely what separates the false positive from the real one. So the sounding has specificity: it fires on closed-set-as-public-value and stays silent on closed-set-as-transient-token. This is the control the CORPUS wanted, and it means real-3 supplies not a promotion-corroboration but something arguably better, evidence primitive-obsession does not fire on well-typed code merely because a string-typed closed set exists.

  **2/4 (highest-leverage live finding): `as_named(fallback: bool)` is a flag argument that switches the method between raising and returning.** The outcome "this color has no CSS name" is modeled three ways: `as_named()` raises `ValueError`, `as_named(fallback=True)` returns a hex string, and `__str__` quietly hard-codes `fallback=True`. The return annotation `str` hides that the no-flag call can raise. Failure scenario: `Color((1, 2, 3)).as_named()` on an un-named color raises `ValueError` where a caller reading the signature expected a string. Move: `as_named() -> str | None` (None = no name found), letting the caller write `color.as_named() or color.as_hex()`; the `fallback` bool that toggles raise-vs-return goes away. Modest leverage (every external caller can hit it), but it is the one genuinely live API-shape finding in the module.

  **5 + 1 (note-and-park, expanded): `RGBA` hand-rolls a class that is a `NamedTuple` in disguise, storing the same four values twice.** Concretely, `RGBA.__init__` sets `r, g, b, alpha` and then a fifth slot `self._tuple = (r, g, b, alpha)` duplicating them, with `__getitem__` delegating to `_tuple` so the object can be indexed like the tuple it secretly is. The two stores can desync: mutating `rgba.r` leaves `_tuple[0]` stale. Why parked, not fixed: `RGBA` is documented "internal use only" and `Color` never mutates it after construction, so no consumer path reaches the stale state; the flaw is real but has no live trace. Move (cheap, and it deletes code): `class RGBA(NamedTuple): r: float; g: float; b: float; alpha: Optional[float]`, which gives attribute *and* index access from one immutable storage and removes `__init__`, `__getitem__`, and the `_tuple` duplication outright. immutability and one-source-of-truth converge on the same rewrite.

  **Tail:** 2/16 (`parse_color_value` wraps `float(value)` in `try/except ValueError` only; a tuple element that fails `float()` with `TypeError`, e.g. `Color((None, 0, 0))`, leaks a raw `TypeError` instead of the module's `PydanticCustomError`, **run-confirmed** against v2.5.3); faithfulness (7) is **satisfied** (`original()` stores the raw input verbatim, and `as_hex`/`as_rgb`/`as_hsl` are opt-in lossy projections over the canonical `RGBA`; integer channels 0..255 round-trip losslessly through `/255` then `int(round(c*255))`, **run-confirmed**), a textbook sounding-7-correct split of faithful-store from lossy-view; 5 is **satisfied** (`COLORS_BY_VALUE` is *derived* from `COLORS_BY_NAME` by comprehension, not hand-maintained; the aqua/cyan value collision resolves deterministically and is documented).

  **New signals for the tightening pass:**
  (1) **The acid test passed: primitive-obsession did not false-positive on well-typed code.** `h_units: str` is the earthaccess `strategy: str` shape, closed by the leverage trace (transient token, no downstream trust). Running tally for the sounding: **2 generated positives (TS, Java) + 1 real positive (earthaccess) + 1 real correct-negative (pydantic).** The §A-promotion bar (one more *real positive*) is still unmet, but specificity is now demonstrated, which the CORPUS explicitly wanted before promotion: a probe that fired on everything would be worthless as a value signal.
  (2) **immutability again did not fire standalone-Fowler on real Python; it fused with one-source-of-truth into "this should be an immutable value type".** Three OO/real data points now: earthaccess `Auth` (fused into 1), pydantic `RGBA` (fused with 5), vs the Java run's leaked-collection standalone. Consistent reading: immutability is a lens over 1 (lifecycle invariants), 5 (duplicated derived state), and 10 (leaked representation), and only the leaked-collection/mutable-value face reads as standalone. Strengthens the combine case: it is probably not its own §A sounding.
  (3) **On this one `clean`-tagged module plumb is correctly quiet: the headline is an API-shape finding, not a bug, and two soundings (7, 5) come back affirmed.** The calibration reads right at the *module* level (loud on the `strategy: str` / ship-a-cancelled-order shapes, quiet on well-built modeling). But `clean` is an **a-priori prior on the repo, not a verified property**: `color.py` is one deprecated module, so this is a module-level specificity data point, not a claim that pydantic-the-repo is clean. The whole-repo audit (real-3) tests that prior; until it lands, the earthaccess-`mixed`-loud vs this-module-quiet contrast is suggestive, not established.
  (4) **Unhomed candidate: "flag argument that switches return/effect semantics" (Fowler Flag Argument).** `as_named(fallback: bool)`. The *fix* is homed under 2 (model the outcome as a value), but the *smell* has no probe. One instance is not a nomination; watch for recurrence across the remaining batch runs.

- **2026-07-21: earthaccess WHOLE-REPO audit @ `bbbced0b` (real-batch run 1; supersedes the auth.py seed)** (external-authored, plumb review mode, breadth-first leverage-ranked top-N across the whole package; `earthaccess-dev/earthaccess` main @ `bbbced0b`, 2026-07-13, clean tree. Note: `nsidc/earthaccess` is deprecated per the maintainer; audit the `earthaccess-dev` fork. First whole-repo audit run after the 2nd canon pass + CxC sweep completed the candidate set, so the run also probes CQS, temporal-coupling, and recoverable/unrecoverable.)
  Corpus: external-reviewed · mixed · python · library · brownfield
  Unhomed: **none new** (a saturation signal, see signal (7)). Every fire lands on a tracked sounding or an already-nominated LANDSCAPE candidate (CQS, temporal-coupling, primitive-obsession, sound-typing, recoverable/unrecoverable).

  **Headline (highest leverage: 10 + primitive-obsession + sound-typing + 7 + CQS): the domain model is a `dict` subclass with `Any`-typed accessors, and its raw-CMR representation leaks into 6 modules.** `DataGranule`/`DataCollection` extend `CustomDict(dict)`, so the returned domain object *is* the raw CMR UMM JSON; the accessors are `Any`-typed (`get_umm -> str | dict[str, Any]`) and callers reach into storage directly (`granule["umm"]["SpatialExtent"]…`). The leak is not local: `["umm"]`/`["meta"]` indexing appears in **store, daac, search, virtual/core, virtual/_credentials** on top of results.py (grep-confirmed, 6 modules). Two sharp latent bugs fall out of the design: (a) **`DataGranule.__repr__` mutates the record** — `self["umm"]["SpatialExtent"] = None` when the key is absent (results.py:368) — a query that *commands* (CQS) and a *faithfulness* break (7): after `repr(g)`, a previously-absent `SpatialExtent` reads as an explicit `None`, so the "faithful" CMR record no longer round-trips; (b) `__init__` injects `self["size"] = self.size()` into that same record. **Failure scenario:** a consumer that treats "key absent" and "key is None" differently (a validator, a serializer re-emitting UMM) sees the record change under a mere `repr()`. **Why the obvious fix is wrong / the cost:** the ideal is to parse the CMR UMM into a *typed* model at the boundary — and this is squarely the **recoverable** case (the CMR record is *received*, the authority; validity is grammar, checkable from the value → a validating constructor, not construction-control). But that rewrites the public return type mid-deprecation (they are already migrating accessors method→attribute via `FutureWarning`, a one-way door, sounding 15), so **split the finding**: plan the typed model deliberately (one-way door); the two-way-door fixes — make `__repr__` pure, stop injecting `size`/`SpatialExtent` into the record — are cheap and land now.

  **#2 (2/3 + primitive-obsession + sound-typing: the seed headline, CONFIRMED at this SHA, fix now cheaper): a silent login no-op.** `login(strategy: str = "netrc")` still dispatches `interactive`/`netrc`/`environment` by a non-exhaustive `if/elif` with **no `else`** (auth.py:147-153); `login -> Any` returns `self` unconditionally. `login(strategy="netrcc")` (a typo) matches no arm, returns an `Auth` with `authenticated=False` and no error; the user believes they authenticated and every later authed call quietly returns empty. **What changed since the seed:** the individual strategies (`_netrc`, `_environment`) now *do* raise the new `LoginStrategyUnavailable`/`LoginAttemptFailure`, so the exceptions exist — only the *dispatch* silently falls through. So the fix is now nearly free: `strategy: Literal["interactive","netrc","environment"]`, an exhaustive `match` with `assert_never`/`else: raise LoginStrategyUnavailable`. Root is still `strategy: str` standing in for a closed set.

  **#3 (6 + temporal-coupling: global-singleton core): the whole free-function API welds to module globals.** `earthaccess/__init__.py` holds `_auth = Auth()`, `_store: Store | None`, a module `_lock`, exposed via `__getattr__` as `earthaccess.__auth__`/`__store__`; **38 reaches** for those globals across the package (grep-confirmed). Every `api.py` entry point, `results.DataCollection.services()`, and `virtual/_credentials.build_obstore_registry` read the global rather than receive an injected auth/store — no seam for a test double or a second concurrent session. **Temporal-coupling rides here:** `login()`-before-use is a required call order enforced only by runtime branches (`if earthaccess.__auth__.authenticated`, api.py:178) and runtime raises (`"…Call earthaccess.login() first."`, virtual/_credentials.py:133), never by the types. Move: keep the free functions as the thin convenience shell (14) but delegate to an injectable core (pass `auth`/`store`), so the login→use ordering and the effect seam are both explicit.

  **#4 (1 + sound-typing + 7, park-leaning): `token: Mapping[str, str] | None` holds two shapes.** `_get_credentials` sets `self.token = {"access_token": user_token}` (bare, one key) on the token/env path vs `self.token = token_resp.json()` (the full record, incl. `expiration_date`) on the password path (auth.py:313-330). Consumers hand-check the shape (`get_session` reads `self.token['access_token']`; `build_obstore_registry` guards `"access_token" not in edl_token`). Ideal: a sum type (`Unauthenticated | TokenAuth | PasswordAuth`) or at least a typed record; `Mapping[str,str]` also lies (the full record's values aren't all `str`). Park-leaning because a sole-mutator mostly upholds it, but it is the same latent two-shape issue the seed flagged.

  **Tail:** 5 (`virtual/_parser.py` spells the canonical parser names in **four** places — the `Literal` in `_types.py`, the `SUPPORTED_PARSERS` frozenset, the `_ALIASES` values, the `_parser_map` keys; add a parser → four edits, drift risk); sound-typing (`ParserType = Literal[...] | Any`, `_types.py:10` — the `| Any` collapses the union to `Any`, defeating the Literal's whole point; move to `Literal[...] | <ParserProtocol>`); 2 (failure-collapse: `return {}`/`return []` swallow distinct reasons in auth ×3 (not-authed / no-https-url / bad-response), store ×2, api ×2 (invalid params / …) — a typo'd search kwarg returns `[]`, read as "no data"); primitive-obsession (`**kwargs: Any` on **12** public signatures — a misspelled search parameter is silently ignored, no checker catch; `(endpoint, region)` positional tuple in `_credentials`; `daac`/`provider: str`); 15/13 (every `DataCollection` accessor is mid-migration method→attribute via `FutureWarning` — a one-way public-API door navigated with warnings). Routed to code-review: `size()` double bare-`except Exception` swallow (results.py:419-430); `_derive_s3_link` fragile URL munging `f"s3://{links[0].split('nasa.gov/')[1]}"` (results.py:441); `logger.exception` called outside an `except` on a falsy response (auth.py:215-219, seed-flagged).

  **Contrast (why `mixed`, not `poor`): the `virtual/` subpackage is materially better-modeled.** `_types.py` uses real `Literal` domain types (`AccessType`, `ParallelType`, `ReferenceFormatType`); `_parser.py` is an explicitly **sans-IO** module ("intentionally free of I/O side-effects") with a `frozenset` single-source parser set and a validating `resolve_parser` (the recoverable/grammar case done right: parse-or-`ValueError`); `exceptions.py` is a documented hierarchy with a crisp `LoginStrategyUnavailable` vs `LoginAttemptFailure` (skipped-vs-failed) distinction. So the repo has a clear **quality gradient** — the legacy dict-model core is loud, the new `virtual/` subpackage is quiet except where it *inherits* the two systemic issues (the dict-model, the global auth) and where it *introduces* the `Literal | Any`.

  **New signals for the tightening pass:**
  (1) **CQS fired repeatedly on real code, its strongest showing yet.** `auth._get_credentials` (a `get_`-named query that mutates four `self` fields and returns `bool`) + `DataGranule.__repr__` (a repr/query that mutates the record). Nominated *deductively* in the 2nd canon pass + one seed fire; a whole-repo audit now gives it **multiple independent real fires in one repo**, on the run designed to test it. CQS is the strongest §A-promotion candidate from this session's canon work; the `[bound against 6/9]` marker held (both fires are per-method command/query mixing, not architecture or generic cohesion).
  (2) **temporal-coupling fired as predicted, unenforced by types.** login→use ordering lives in runtime branches/raises across api.py and virtual/_credentials, never in the type. First real fire on the candidate broadened this session (from illegal-transitions). Corroborates keeping it; still reads as a rider on 1 (make the illegal *sequence* unrepresentable — an `Authenticated` capability the authed calls require) rather than standalone.
  (3) **recoverable-vs-unrecoverable applied cleanly as a diagnostic, not a violation-catcher.** It correctly *classified* the headline: the CMR record is received (authority) → recoverable/grammar → the right move is a boundary parser (validating constructor), NOT construction-control. First real application since the CxC sweep nominated it; note its *nature* is to route to the correct existing sounding, so it "fires" by classifying, which is what a meta-probe does. Watch that it stays a router and doesn't just become "parse at the boundary" (sounding 1).
  (4) **primitive-obsession clears the §A promotion bar.** Real positives now: earthaccess seed (`strategy: str`), this whole-repo audit (`strategy: str` confirmed + `**kwargs: Any` ×12 + `parser: str` + `(endpoint,region)` tuple), plus 2 generated (TS, Java) and the pydantic correct-negative. Multiple *real* positives + demonstrated specificity (the pydantic `h_units` non-fire) → **recommend promotion review** from LANDSCAPE Tier-1 nomination to a §A candidate.
  (5) **sound-typing fired with a second distinct mechanism.** `Literal[...] | Any` (union-collapse) is a different lie-to-the-checker than auth's `login -> Any` (return-Any). Two real mechanisms now (return-Any, union-Any) plus the `Mapping[str,str]` two-shape under-spec → the "no `Any`/no-lies-to-the-checker" kernel is confirmed distinct from 3/16 and worth a promotion review alongside primitive-obsession.
  (6) **immutability fused again (into 1), no standalone instance on real Python.** `Auth` (mutable bag) and `DataGranule` (mutable dict) both fuse into the sounding-1 lifecycle/leaked-representation face; no Fowler "mutable data" standalone (that only appeared on the Java leaked-collection). Fourth data point consistent with **fold immutability into 1 + 10** rather than a standalone §A sounding.
  (7) **Zero new unhomed candidates — the first whole-repo real audit to nominate nothing.** A full messy brownfield repo produced no leftover smell without a probe; every fire homed on a tracked sounding or nominated candidate. This is the **saturation signal** the "complete the instrument before measuring" gating was built to detect: the candidate set (2nd canon pass + CxC sweep) now absorbs a real repo with no residue. Supports that deductive nomination is near-complete; the remaining batch runs (titiler-cmr mock cell, the two non-Python picks) test *ranking/promotion*, not further *nomination*.
  (8) **The a-priori `mixed` prior is confirmed, not refuted.** The quality gradient (loud legacy core, quiet-ish new `virtual/`) is exactly what `mixed` predicted; the role is an *output* — earthaccess earns "fire-source on the legacy core, near-control on the new subpackage," a single repo supplying both readings.

- **2026-07-21: titiler-cmr WHOLE-REPO audit @ `5101ef06` (real-batch run 2; the decisive mock cell)** (external-authored, plumb review mode, breadth-first leverage-ranked top-N across the `titiler/cmr/` package — ~5.3k LOC, 18 modules; `developmentseed/titiler-cmr` main @ `5101ef06`, 2026-07-02, clean tree. The testability-without-mocks cell the self-corpus suppresses to ~zero: `test_compatibility` carries **135** mock/patch refs, `test_xarray_backend` 18, `conftest` 17, `test_timeseries` 14, `test_query` 13, plus VCR cassettes. Fresh read per the anchoring-hygiene note — explicitly NOT carrying earthaccess's dict-model lens. Probes the full candidate set: CQS, temporal-coupling, recoverable/unrecoverable, primitive-obsession, sound-typing, and the cell's target testability-without-mocks. Two load-bearing claims were **constructed and run** against the real code, not read.)
  Corpus: external-reviewed · mixed · python · service · brownfield
  Unhomed: **none new** (second consecutive whole-repo real audit to nominate nothing — saturation holds across a model-quality flip). Every fire lands on a tracked sounding or an already-nominated candidate (CQS, temporal-coupling, recoverable/unrecoverable, primitive-obsession, sound-typing, testability-without-mocks).

  **Contrast up front (the anchoring-hygiene payoff): the domain model is exemplary — the inverse of earthaccess.** `models.py` parses raw CMR UMM JSON into a *typed pydantic tree* at the boundary (`Granule._extract_from_umm_item`, `@model_validator(mode="before")`; every UMM container a typed `BaseModel` with aliases). recoverable/unrecoverable classifies it "received authority → validity is grammar → a validating boundary constructor, done RIGHT" — the *same router* earthaccess's `CustomDict(dict)` tripped, opposite verdict. So the findings are NOT in the model layer; they cluster at the two seams where typed modeling was skipped (a stringly-typed temporal, a sentinel-typed size) plus the reached-for effects the mock cell exists to surface.

  **Headline (highest leverage: 2/4 + primitive-obsession — `temporal: str` is an unparsed sum threaded through the whole temporal spine, and one consumer forgets a case and 500s).** `parse_datetime(str) -> tuple[datetime|None, datetime|None, datetime|None]` = `(instant, start, end)` encodes an `Instant | Interval` sum as *which of three optionals are set* (utils.py:76). **The concrete instance / failure scenario (RAN):** `parse_datetime("/2018-03-18T12:31:12Z")` — the `open-interval-to` case, a *documented openapi example* (models.py:49) — returns `(None, None, end)`; the consumer `interpolated_xarray_ds_params` does `dt = datetime_ if datetime_ else start` → `None`, then `dt.isoformat()` (dependencies.py:307,312) → **AttributeError, 500**, on a legal input. The *other* consumer, `timeseries_cmr_query` (timeseries.py:384), destructures the same tuple with a four-arm `if/elif/elif/else` and catches the open-start case with `else: raise 400` — so one weak return, two consumers, one handles the case and one crashes. **Why the obvious fix is wrong:** don't guard the crash site — the tuple's third slot (`end`) is *also* silently dropped by that same consumer on the happy `start/end` path (RAN: closed interval → dep uses only `start`). Parse `temporal` into a real sum (`Temporal = Instant(datetime) | Interval(start, end?)`) at the boundary; that one root removes the crash, the dropped-`end`, the `# noqa: C901` branching in `timeseries_cmr_query`, and the re-`split("/")`/`split(",")`/`normalize_temporal` scattered across the spine. This is the primitive-obsession root (`temporal: str`) and the sum-as-tuple root seen from two angles.

  **#2 (2 — a resource guard silently defeated by a `0`-as-unknown sentinel).** `calculate_time_series_request_size` returns `0` when `Collection.resolution_degrees` is `(None, None)` (utils.py:210-214). **The failure scenario (RAN):** a Collection with no `HorizontalDataResolution` in its UMM → `resolution_degrees` `(None, None)` → size `0`; the two guards `image_size = request_size/len(query)` and `request_size > time_series_*_max_total_size` (timeseries.py:590-603, 790-803) both evaluate **False**, so a timeseries/statistics or timeseries/bbox request against a resolution-less collection sails past the *exact* size limit written to stop it. **Silent** — only a `logger.warning`, no rejection. `resolution_degrees` itself squashes three outcomes into a type that can't tell them apart: `(None, None)` for ~6 distinct "metadata absent" reasons, a real `(x, y)`, and a *raised* `ValueError` for unsupported units. **The move:** model "size unknown" as its own outcome (raise/`None`/a `Sizing` sum), so the guard treats "can't determine size" as fail-closed, not as "size zero."

  **#3 (6 + testability-without-mocks — the cell's designated probe fires, and resolves as fully derivative of 6).** The codebase *injects heavily* and well: `CMRBackend.client`, `XarrayGranuleReader.opener` (defaulting to `open_dataset`), `get_s3_credentials`, `ctx=rasterio.Env`, `EarthdataTokenProvider` are all real DI seams — genuine sans-IO discipline. The 135/18/14 mock counts trace to **four specific reached-for effects**, each a sounding-6 instance the DI didn't reach: (a) `open_dataset` reaches for module-global `cache_client` + `_dataset_cache_lock` (reader.py:77-78), and `compatibility.py` calls it directly, so those tests can't dodge the global cache; (b) `credentials.py` constructs `Client()` inline inside both `_fetch` and reaches `datetime.now(UTC)` for expiry (must freeze the clock + patch httpx to test refresh); (c) `timeseries.py` constructs `AsyncClient()` inline in three endpoints (vs the injected sync `client` — asymmetry, 13) and reaches `datetime.now(tz=utc)` in query-building; (d) `compatibility.extract_xarray_metadata` reaches `np.random.choice` (compatibility.py:125) — a global RNG that makes the reported min/max/percentiles non-deterministic, so a stats test must seed the global RNG. **Every mock maps 1:1 to a reached-for effect that injection would remove** — and the codebase's own heavy DI elsewhere is the proof (same house, some seams cut, some not). testability-without-mocks is the *test-visible symptom* of 6, not an independent sounding.

  **#4 (1/16 — `Asset` is stricter than its assembly can guarantee; a legal granule 500s).** `Asset(direct_href: str, external_href: str, ext: str)` requires all three (models.py:181), but `Granule.get_assets` builds them incrementally from two independent `RelatedUrl` types — `ext`+`direct_href` come only from `GET DATA VIA DIRECT ACCESS`, `external_href` only from `GET DATA` (models.py:450-458). An HTTPS-only granule (no S3 direct link — a legal CMR shape) yields `data` missing `direct_href`+`ext` → `Asset(**data)` `ValidationError`, 500 on the `/granules` and tile paths. The model makes the illegal state (a one-href asset) unrepresentable *at construction* — correct instinct — but the assembly can't uphold it, so the invariant is enforced one tier too late (11). Park-leaning (depends on external-only granules occurring); route the exact traceback to code-review, but the shape is a real sounding-1.

  **Tail:** 2/16 (`Granule.bbox = shape(self.geometry).bounds` is partial — a no-spatial-extent granule → `geometry` None → `shape(None)` raises; `reader.py:335` and `backend.py:66` call it unguarded while `to_feature` guards it, so a geometry-less granule 500s the reader init); 5 (`_translate_legacy_expr` + `CMRAssetsExprParams.__post_init__` half-duplicate the legacy-identifier detection — two expression translators, one factored and one inline, running the same `re.findall` twice); 4 (`Granule.geometry -> dict[str, Any]` computed then `to_feature` does `cast(Geometry|None, self.geometry)` — a typed Polygon/MultiPolygon union built as an untyped dict and recovered by a cast); 8/10 (`XarrayGroupParam = cast(Any, XarrayIOParams.__annotations__["group"])`, compatibility.py:614 — reaching into another module's `__annotations__` rather than a public re-export); dead-in-package (`RetrySettings`, `StackSettings`, `GeoJSONSchema` unused within `titiler/cmr/` → ponytail-audit). Routed to **code-review**: four bare `except Exception: pass` swallows in compatibility.py (153,170,236,321); `pickle.dumps/loads` of an xarray `Dataset` as the cache payload (reader.py:198,243); `generate_datetime_ranges` point-mode double-append edge (timeseries.py:224,241); `get_variables`' domain check as a bare `assert` (reader.py:175, stripped under `-O`). Routed to **ponytail**: the function-local `from rio_tiler.errors import NoAssetFoundError` inside `_combine_bbox_and_geometry` (query.py:31).

  **Contrast (why `mixed`, not `clean` or `poor`): a real gradient, reverse polarity from earthaccess.** The well-modeled region is large and load-bearing — `models.py` (typed boundary parse), `expression.py` (an explicit AST-sandbox sans-IO module that documents *why* not numexpr), `query.py` (pure param-builders + one injected-client generator), `credentials.py` (a typed `S3Credential` TypedDict parsed at the boundary). The rough edges are localized to the temporal seam (stringly sum), the size seam (sentinel), the `Asset` assembly, and the effect-reaching concentrated in the two orchestration modules (`timeseries`, `compatibility`). Where earthaccess was **loud-legacy-core + quiet-new-subpackage**, titiler-cmr is **quiet-typed-core + loud-orchestration-rim** — the same `mixed` verdict with the polarity flipped.

  **New signals for the tightening pass:**
  (1) **The candidate set read as a clean CONTRAST against earthaccess — exactly the specificity evidence the CORPUS wanted before promotion.** Language held constant (Python), model quality flipped: **CQS** fired STRONG on earthaccess, near-silent here (only `backend.bounds`, a property that performs a network fetch — a query with an I/O side effect, not self-mutation); **temporal-coupling** fired on earthaccess (login-before-use ordering), silent here (auth is injected, no unenforced call order); **recoverable/unrecoverable** classified BOTH domain models with *opposite* verdicts (dict-subclass-wrong vs pydantic-boundary-right), earning its meta-probe "router" role a second time. A probe set that fired identically on both repos would be worthless as a value signal; this divergence is the signal.
  (2) **primitive-obsession fired a third real positive, on a NEW shape.** `temporal: str` is a *structured value* smuggled as a string (an `Instant | Interval | list-of-those`, parsed at ≥3 sites), distinct from earthaccess's `strategy: str` (a *closed enum* as a string). Two real mechanisms now (closed-set-as-string; structured-value-as-string) + the pydantic `h_units` correct-negative → the §A-promotion already recommended from real-1 is corroborated, and specificity broadens (it fires on two different obsession shapes, not one pattern).
  (3) **testability-without-mocks fired as designed and resolved as fully derivative of 6 — the mock cell delivered its verdict.** The 135/18/14 mock counts are real, but every mock maps to a reached-for effect (global cache, inline sync/async `Client`, `datetime.now`, `np.random`) that DI would remove, and the repo's own heavy injection proves it. **Recommendation: do NOT promote testability-without-mocks to its own §A sounding; fold it as the test-visible symptom of sounding 6.** This is the datum the whole "sample the mock cell" plan was built to get, and it agrees with the Java pilot's "consequence of 6."
  (4) **sound-typing fired MILD, and the mildness is itself the signal.** The `Any` escapes here (`cache_client: Any`, `extract_xarray_metadata -> dict[str, Any]`, `reader_options`) sit at genuine dynamic boundaries (xarray/cache), NOT the union-collapse `Literal[...] | Any` lie earthaccess had. The sounding correctly separates "Any at a real dynamic edge" (parked) from "Any that defeats a Literal" (fired) — a specificity data point that keeps the promotion honest.
  (5) **Two whole-repo real audits, zero new unhomed each, across a model-quality flip — saturation is holding.** real-1 (loud dict model) and real-2 (clean typed model) both nominate nothing; the candidate set absorbs opposite-polarity brownfield Python with no residue. The remaining runs (the two non-Python picks) now test whether saturation survives a *language* flip, not whether nomination is incomplete.
  (6) **The `mixed` prior confirmed with reversed polarity — evidence the tag predicts a gradient's *existence*, not its *location*.** The user reported "messy"; the audit found messy *seams* inside a well-modeled core — the mirror image of earthaccess's clean-subpackage-inside-messy-core. `mixed` earned; the role is again an *output* (quiet-core / loud-rim), never a pre-assignment. Two `mixed` repos, two opposite internal geographies, same tag — the tag is doing honest work.

- **2026-07-21: generated Go `spend` expense-tracker CLI** (a two-file CLI authored fast, then reviewed; plumb review mode; adversarial-batch **gen-3**, the non-Python / error-values cell, chosen to stress **sounding 2 (outcomes-as-values)** and its **fail-fast Boundary** in the one language whose whole idiom is `(T, error)` and `if err != nil`. Fixture built naively, then built with `go1.26.4` and every headline **constructed and run** against the binary. *(Prose without the em-dash double-hyphen, per standing feedback.)*)
  Corpus: generated · poor · go · cli · greenfield
  Unhomed: **none new** (saturation survives the *language* flip: the first non-Python run, on the sounding most likely to have a language-shaped gap, and it homed clean). The one candidate to watch, the `_`-blank-identifier **error discard** (Go's "must-consume" gap: a modeled outcome silently dropped, which a sum-type language forbids via `#[must_use]`), homes on **1** (as the *designer*: making an ignored outcome unrepresentable is exactly "make the illegal state unrepresentable") **and 3** (as the *consumer*: dropping the error is failing to handle a case). No new *actionable move* beyond those two, so it folds; but it drives new signal (2) below, a refinement to sounding 3.

  **Headline (2's Boundary + 6): the fail/return seam is misplaced at *both* ends of the same call chain.** The store layer **over-commits** (kills the process where it should return a value) and the edge **under-commits** (drops the values the store does return). Concretely: `Load`/`Save` call `log.Fatal` three times (store.go:37,41,50), so a corrupt or unwritable data file terminates the process from inside a library-level helper; meanwhile `main` already owns five `os.Exit(1)` sites (main.go:12,20,29,38,62), the *correct* edge for the value-becomes-a-raise seam. **The concrete instance / failure scenario (RAN):** a `~/.spend.json` containing `{ this is not valid json` → `spend list` prints `2026/07/21 ... corrupt data file: invalid character 't' ...` and exits 1 **from `store.go:41`**, before `main` ever sees the error; the store stole the decision. No test can exercise the corrupt-file path (it `os.Exit`s the test process), and no non-CLI consumer (a TUI, an HTTP handler) can recover or fall back to an empty budget. **Why the obvious fix is wrong:** do not "catch" the `log.Fatal` (you cannot; it is `os.Exit`). The Boundary note is doing its job here precisely: this is *not* a deliberate fail-fast house style (an accidental `log.Fatal` buried in a helper is not a chosen `os.Exit`-at-`main`-only discipline), so the move is to *name and relocate the seam*: `Load() (Budget, error)` / `Save(b) error` return values, and `main` (the real edge) raises them via its already-present `os.Exit`. That is the same one seam, drawn once, at the edge.

  **#2 (1 + 2: `(T, error)` used as a product where a sum was meant; `Find` returns `(nil, nil)`).** `Find(id int) (*Expense, error)` (store.go:87) has three representable outcomes, `(ptr, nil)` / `(nil, nil)` / `(nil, err)`, but produces only the first two, encoding "not found" as *both-slots-empty*. Go's `(T, error)` is a **product** type (both slots always exist), so the illegal combinations `(nil, nil)` and `(ptr, err)` are representable at every call site; a real sum (`Found(*Expense) | NotFound`) makes them unrepresentable. **The failure scenario (RAN):** `spend clear 99` on a one-expense store prints `no expense with id 99` and exits 1, and it works *only because* the sole caller `Clear` re-derives the not-found signal itself (`e, _ := b.Find(id); if e == nil`, store.go:93), discarding `Find`'s (always-nil) error with `_`. So the error slot is dead weight today, and a latent trap tomorrow: the day `Find` grows a real error (an index lookup, a DB), every `_`-discarding caller swallows it silently. Move: return `(*Expense, bool)` (Go's honest two-state, comma-ok) if lookup cannot fail, or a real found/not-found sum; either way the `(nil, nil)` ambiguity and the dead error slot both go.

  **#3 (2 + primitive-obsession, the live silent-success: a `_`-discard compounded by a `0`-in-band sentinel).** `main`'s `budget` case does `amt, _ := parseAmount(os.Args[2])` (main.go:56), discarding the error. **The failure scenario (RAN):** `spend budget notanumber` prints `monthly budget set to $0.00` and **exits 0 (success)**; the user typo'd their budget and was told it worked. It is then swallowed a second time downstream: `CheckBudget` treats `Monthly == 0` as `"no budget set"` (store.go:118), so `Monthly` conflates three distinct states, never-set, explicitly-zero, and parse-failed, into one, and the mis-set budget produces no over-budget warnings ever. This is the live defect of the run (cf. earthaccess's silent-login, the Java ship-a-cancelled-order), and its two roots are both tracked: the `_`-discard (signal (2)) and the `0`-as-unknown sentinel (signal (3)). Move: handle the parse error at the edge (`if err != nil { ... os.Exit(1) }`, like every other command), and model "unset" as its own state (`*float64`, or a `Budget = Unset | Monthly(amount)` sum) so `0` cannot stand in for absence.

  **Tail:** 2 (every error is an opaque `fmt.Errorf`/`log.Fatal` *string*, never a typed sentinel or `errors.Is`/`As` target, so the *reason* is unrecoverable except by string-matching, Go's idiomatic errors-as-values done stringly, the receiving dual of #2); primitive-obsession (`Status` "pending"/"cleared", `Category`, and `CheckBudget() string` returning "over"/"warning"/"ok"/"no budget set" are all closed sets typed `string`; the `CheckBudget` outcome is a 4-way *value* modeled as a bare string that also drops the *amount over*, a sounding-2 sum smuggled as a display string); 6 (`var dataFile = os.Getenv("HOME") + "/.spend.json"`, store.go:27, an env read at package-init welded into the store, no seam to point it elsewhere for a test); 16 (`ID: len(b.Expenses) + 1`, store.go:70, id-by-length, fragile the moment a delete lands, latent only because no delete exists). Routed to **code-review**: the `os.Args[2]` index with no length guard in `clear` and `budget` (main.go:34,56) **panics** (RAN: `spend clear` → `panic: runtime error: index out of range [2] with length 2`, main.go:34, an *uncontrolled* raise, the opposite failure from the headline's over-controlled one); and `id, _ := strconv.Atoi(os.Args[2])` (main.go:34) silently coerces a non-numeric id to `0` (RAN: `spend clear abc` → `no expense with id 0`, the *reason* "abc is not a number" lost). Routed to **ponytail**: the `Limits map[string]float64` field (store.go:25) is initialized and never read or written by any command, dead speculative state (YAGNI).

  **New signals for the tightening pass:**
  (1) **Sounding 2 fit Go natively, and its *Boundary* note drove the headline for the first time.** 2 was authored errors-as-values-first and carries an explicit fail-fast Boundary ("name the seam where value becomes raise; don't relitigate the philosophy"). Go is the language whose entire convention *is* errors-as-values, so it is the natural fit-test, and the fit was clean: the Boundary note told me not to argue whether `log.Fatal` is "banned" but to *locate the seam* (value→raise belongs at `main`, not the store), and the misplaced seam *was* the highest-leverage finding. Prior runs exercised 2's *body*; this is the first where the *Boundary clause* itself was the load-bearing tool. It also sharpened a distinction the note implies but did not spell out: an *accidental* `log.Fatal` in a helper is a misplaced seam (a finding), whereas a *deliberate* `os.Exit`-at-`main` house style is not; the tell is whether the raise sits at the chosen edge.
  (2) **NEW SIGNAL for sounding 3: its enforcement premise is language-dependent, and Go breaks it.** 3 promises "adding a case *forces* the update (compiler-checked exhaustiveness)." Go's error-values have no such check: `amt, _ :=` and a bare `f()` both compile clean, and **`go vet` is silent** on all four discards here (confirmed: clean vet). So error-handling totality in Go degrades to a third-party linter (`errcheck`/`staticcheck`) or a runtime silent-drop, never the type-checker. The "must-consume / `#[must_use]`" discipline (the receiving-side dual of sounding 2) therefore has *no new actionable move*: as the API *designer* it is sounding 1 (make an ignored outcome unrepresentable, which is exactly what `#[must_use]` does), and as the *consumer* it is sounding 3 (handle the error case). It folds. But **sounding 3 should carry a note**: its "compiler-checked exhaustiveness" guarantee assumes a checker the language may not provide, and for error-values specifically (Go, C return codes, unchecked exceptions) the guarantee is absent and the discipline is opt-in tooling. This is the one genuine language-flip refinement the run produced.
  (3) **The `0`-as-unknown sentinel RECURRED across cells.** titiler-cmr (real-2, external Python service) had `resolution_degrees (None,None) → size 0` silently defeating a resource guard; here `Monthly == 0` conflates unset/zero/parse-failed and swallows a mis-set budget. Same already-homed shape (in-band sentinel, 2/1), now seen on external-Python-service *and* generated-Go-CLI, different provenance and language. A cross-cell recurrence of a *tracked* smell: it strengthens the smell's reality without needing a new home, and it is a candidate exemplar-pair for the eventual §C write-up of the in-band-sentinel face of 2.
  (4) **primitive-obsession fired a third *generated* positive (Go), on the closed-set-as-string shape.** `Status`/`Category`/`CheckBudget`-string join the TS (gen-1) and Java (gen-2) generated positives. This does **not** move the §A-promotion bar (that needs *real* positives, already met by earthaccess + titiler-cmr and already recommended); it extends the *language* coverage of the specificity story (the sounding now has generated positives in three languages and a real correct-negative in pydantic).
  (5) **`go vet` clean is itself the tooling-level face of the fail-fast Boundary.** The default toolchain enforces *none* of the structural soundings here (not the discards, not the `(nil,nil)`, not the stringly enums). The discipline is opt-in linter territory, which is exactly why the seam placement is a *design* choice and not a compiler guarantee: the language will not stop you, so where the raise lives is on the author. This is the concrete, reproducible datum behind signal (1).
  (6) **Saturation held across the first language flip (Python → Go), on the run designed to break it.** Zero new unhomed on a fresh-language generated repo deliberately built to stress the sounding (2) most likely to carry a language-shaped gap. Combined with the two zero-new real audits, the candidate set now absorbs loud-Python, clean-Python, and error-values-Go with no residue. **real-4** (an external Rust or TS app: ownership + exhaustive `match`, or frontend-ui state) is the remaining language-flip test, and it is the load-bearing one, because (7).
  (7) **Caveat (self-authorship bias), same as gen-1/gen-2.** I wrote the fixture, so the smells are ones I could plant, and the structural findings + the RUN confirmations are real regardless of authorship, but a generated run can only do the *fit/nomination* job (does sounding 2 have a Go-shaped gap? answered: no, it homes and refines 3), not the *external-corpus* job. The load-bearing language-flip evidence will come from real-4 (external Rust/TS), exactly as real-1/real-2 were the load-bearing runs for Python after the generated pilots.

- **2026-07-21: rust-simple-httpd WHOLE-REPO audit @ `a3dc5244` (real-batch run 4; the EXTERNAL language-flip test)** (external-authored, plumb review mode, breadth-first leverage-ranked across the whole crate: `CompileNix/rust-simple-httpd` main @ `a3dc5244`, 2025-06-02, ~2045 Rust LOC / 9 files, an educational from-scratch HTTP/1.1 server with a multi-threaded worker pool. **Sourcing note:** the first Rust pick (`developmentseed/obstore`) was rejected at selection time for a *clean* prior (a low-power saturation test, the pydantic-defer logic); this target was chosen by *measuring* roughness empirically (45 `unwrap`/`expect` + 14 `panic!`-family in 2k LOC, a real `mixed`/`poor` prior), not by reputation. Built on cargo 1.90 and both leading headlines **constructed and RAN** against the binary; the panic-cascade escalation is reasoned from Rust poisoning semantics and marked as such. Probes the full candidate set with the error-values / sounding-2 axis foregrounded, as the enforced-exhaustiveness contrast to gen-3.)
  Corpus: external-raw · mixed · rust · service · active
  Unhomed: **none new** (saturation holds across a *language* flip on EXTERNAL code, the load-bearing test gen-3's generated fixture could not give). The must-consume / `#[must_use]` candidate got its **Rust enforced-but-opted-out** data point (`let _ = stream.write(...)` to silence the warning, `.unwrap()` to consume-by-panic, a macro `default:`/`Default` fallback), the exact counterpart to gen-3's "Go can't enforce"; it still folds into **1** (designer: make an ignored outcome unrepresentable) **+ 3** (consumer: handle the case), no new actionable move.

  **Headline (2's Boundary + 6: fail-fast panics buried in the worker/tcp core, and Rust escalates the smell into a CASCADE via mutex poisoning).** The raise lives deep in the core, not at the edge: `receiver.lock().unwrap().recv().unwrap()` (worker.rs:104, tcp.rs:40), `stream.peer_addr().expect("Failed to get peer address")` (http.rs:254,479), `panic!("Can't bind to {}")` (tcp.rs:69), plus `.unwrap()` on every thread `join`/`spawn`/`send` (worker.rs:75,81,117). **The concrete instance / failure scenario:** one worker hits the `peer_addr` `.expect` on a client that resets between `accept` and `handle` (a legal, routine race), the worker thread panics *while holding* the shared `Arc<Mutex<Receiver>>`, which **poisons the mutex**, so every sibling worker's next `receiver.lock().unwrap()` returns `Err(PoisonError)` and unwraps into a panic: one bad connection takes down the whole pool. **Why this is the Rust-specific sharpening:** gen-3's Go analog (`log.Fatal` in the store) kills the one process *locally*; Rust's buried panic corrupts *shared invariants*, so the blast radius is the sibling threads, not just the caller. So "the raise belongs at the edge" (sounding 2's Boundary) matters MORE here, and the fix is the same one gen-3 pointed to: return the error to the seam. **The contrast that proves it is a seam-placement choice, not a language necessity (RAN):** the config path draws the identical seam correctly, `default_from_env() -> Result<Config, ConfigError>` returns a typed sum and the raise happens at `main` via `.expect()` (RAN: `RUST_LOG=bogus_level` -> `panicked at main.rs:39: Failed to get default config from env: Enum(ParseEnumError)`, exit 101). Same repo, raise-at-edge in config, panic-in-core in http/tcp/worker.

  **#2 (1 + primitive-obsession + 7: HTTP's entire domain is unmodeled, so the server parses a request and then throws it away).** There is **no `Request`, `Response`, `Method`, or `Status` type anywhere** (grep-confirmed): the request line (method/path/version) is *never parsed at all*, headers live in an ad-hoc `HashMap<String,String>`, status is an uncoupled `(status_code: u16, status_message: &str)` pair passed to `compose_http_response`, and the response is a `formatdoc!` `String`. **The concrete illegal state:** `compose_http_response(200, "Not Found", ...)` is representable, the code and message are two independent primitives that should be one `enum Status`. **The failure scenario (RAN):** `DELETE /nonexistent/does/not/exist` and a raw `ZZTOP /wat HTTP/9.9` both return **200 OK** with a hardcoded 171-byte "Hi from Rust" body, the method/path are read and discarded, so routing, method rejection, and the file-serving in the commented-out block (http.rs:429-465) cannot exist. **The compiler itself flags the discard:** `warning: unused variable: request_body` (http.rs:366), Rust points at the parsed-then-dropped request. Move: parse the request line + headers into a typed `Request` at the boundary (parse-don't-validate, sounding 1/7), model the reply as `enum Status` + `Response`; the God-function and the illegal `(code,message)` pairs both dissolve.

  **#3 (16 + the "defeated resource guard" family, third corpus recurrence): the 413 payload guard is dead because it reads a variable that is never written.** `let bytes_body_read: usize = 0;` (http.rs:257) is never reassigned, and the guard `if bytes_body_read >= 50_000_000` (http.rs:418) therefore always evaluates false (grep-confirmed: one write, at init). Meanwhile the actual body-read loop `while body.len() < http_request_content_length` (http.rs:381) has **no size cap**, so `Content-Length: 999999999` grows `body` unbounded in memory with the 413 guard never firing. This is the **third** appearance of the defeated-resource-guard family across the corpus, each with a different mechanism: titiler-cmr's `0`-as-unknown size and gen-3's `Monthly == 0` were *sentinel values*; this is an *unwired variable*. Same shape (a written-down limit that does not limit), homed on 16 + 2, no new sounding. Route the dead variable to code-review; the structural note is that the cap belongs *inside* the read loop's model, not as a bolt-on after it.

  **Tail:** ponytail (`enum_with_helpers!`, util.rs:15-76, is a 60-line "generic" macro invoked **exactly once**, for `Level`, and it is not even general: its `from_str` hardcodes `-> Result<Level, _>` and its error `Display` is hardcoded to `"Invalid log level"` (util.rs:49,41), so a second use-site would not compile and would lie, an over-abstraction that is also structurally monomorphic; `struct_with_colorized_display_impl!` is likewise single-use; `iter`/`colorize` are dead per the compiler warnings); 9 + 6 (`handle_connection` is a ~230-line God-function welding header-read loop + EOH scan + limit checks + header parse + body read + response build + socket I/O + logging, so the pure parse cannot be tested without a live `TcpStream`, no sans-IO seam); 16 (the `bytes_read < buffer_client_receive_size` end-of-request heuristic, http.rs:320, misreads a normal short TCP read as "client done", a slow legal client that sends headers in small segments gets a false 400, the assumption "a short read means EOF" is never tested; default `buffer_client_receive_size` is 32, so it triggers easily); 16 (`checked_add(...).expect("Overflow when adding duration parts")`, config.rs:69, a legal-looking `BUFFER_READ_CLIENT_TIMEOUT` sum overflows u64 and panics at startup, the one blemish in the otherwise-clean config module); 3 (the `Some('s') | _` catch-all in `parse_duration`, config.rs:65, folds "seconds" and "unknown unit" into one arm). Routed to **code-review**: the `peer_addr().expect()` disconnection race and the mutex-poisoning cascade (both a live availability defect); the panics-in-`Drop` (worker.rs:75,81). Routed to **ponytail**: the two single-use macros and the dead `iter`/`colorize`.

  **Contrast (why `mixed`, not `poor`: a genuine quiet-core / loud-rim gradient, the third such repo).** The quiet core is real and load-bearing: `config.rs` models `ConfigError` as a proper sum (`Int | Enum | Bool`) with a `Display`, injects the parser as a closure into `discover_from_env_or`, and composes with `?` (textbook sounding 2 + 6 + 14, the raise reaching `main`, RAN); the two concurrency messages (`ConnectionHandlerMessage`, `worker::Message`) are proper sum types dispatched by **exhaustive `match`** (sounding 2/3 done right). So the author demonstrably *can* model sums and *can* thread `Result` to an edge, they simply did not for HTTP or for the panic paths. The loud rim is `http.rs` (no domain model, God-function, dead guard) and `tcp`/`worker` (the panic cascade). Where earthaccess was loud-legacy-core + quiet-new-subpackage and titiler-cmr was quiet-typed-core + loud-orchestration-rim, this is **quiet-config/messages + loud-http/concurrency**, the same `mixed` verdict, a third distinct internal geography.

  **New signals for the tightening pass:**
  (1) **Sounding 2's Boundary fired again, and Rust supplied a NEW blast-radius mechanism: mutex poisoning turns one buried panic into a cascade.** gen-3 (Go) showed the fail-fast-in-core smell killing the one process locally; Rust shows the *same* smell corrupting shared invariants so sibling threads die too. Same sounding (2 Boundary / 6), new mechanism, and it *sharpens* the sounding: "the raise belongs at the edge" carries more weight in a shared-state concurrency model, because a buried panic is not contained. Homed; a note for the Boundary clause that its cost is language- and concurrency-model-dependent.
  (2) **The must-consume / `#[must_use]` story got its enforced-but-opted-out data point, completing the gen-3 pair.** gen-3's refinement: totality/must-consume enforcement is *absent* for Go error-values (`_` compiles, `go vet` silent). Rust is the contrast: `Result` is `#[must_use]`, so ignoring it warns. This repo shows the three idiomatic escape hatches a codebase uses to opt out anyway: `let _ = stream.write(...)` (explicit discard to silence the warning, http.rs:219,480, which also drops the short-write byte count), `.unwrap()` (consume-by-panic, pervasive), and the `enum_with_helpers!` `default:` + `Default` impl (a parse-fail can silently become the default variant). So the law generalizes to two sides: **enforcement is language-dependent, and where the language enforces, codebases have idiomatic opt-outs**, neither side a new sounding (both home on 1 + 3), the Go/Rust pair is the evidence.
  (3) **The "defeated resource guard" recurred a THIRD time, third mechanism.** titiler-cmr (`0`-as-unknown), gen-3 (`Monthly == 0`), now this (`bytes_body_read` unwired). Sentinel, sentinel, dead-variable, one family (a written-down limit that does not limit), across Python-service / Go-CLI / Rust-service and external / generated / external. Robust cross-language cross-provenance pattern; a strong candidate exemplar cluster for the §C write-up of the in-band-sentinel / dead-guard face of sounding 2 + 16. Still homed, still no new sounding.
  (4) **Rust's compiler was NOT silent where `go vet` was, but its signal is a spectrum, not a wall.** 6 warnings, including one that flags the no-domain-model directly (`unused variable: request_body`). So "does the toolchain enforce the sounding" grades: go-vet-silent < Rust-warn-but-non-fatal (unused vars, dead code, shipped anyway) < Rust-error (`#[must_use]`, actively silenced with `let _ =`). This refines gen-3 signal (5): the enforcement gradient is real and the codebase sits at the permissive end of whatever the language offers.
  (5) **Saturation held across a language flip on EXTERNAL, messy code, the load-bearing test gen-3 could not provide.** Four external/real audits now (earthaccess loud-Python, titiler clean-typed-Python, gen-3 generated-Go, this messy-external-Rust) each nominate nothing; the candidate set absorbs a new language *family* (ownership + exhaustive match + panic-based concurrency) with no residue. Saturation now spans both the quality axis and the language axis. The remaining gen-4/gen-5 runs test ranking on cheap cells, not nomination.
  (6) **primitive-obsession fired a real positive in a new language (Rust).** The `(u16, &str)` status pair, `HashMap<String,String>` headers, and stringly method handling are the closed-set / structured-value-as-primitive shapes, now a *real* positive on Rust alongside earthaccess (`strategy: str`) and titiler (`temporal: str`). Corroborates the already-recommended §A promotion and extends its language coverage to three.
  (7) **Specificity WIN, shown intra-repo on external code: plumb stayed quiet on the genuinely well-modeled parts and loud on the rim.** The `ConfigError` sum, the two `Message` sums with exhaustive matches, the injected parsers, and the edge-raise in `main` are all *affirmed correct*, not flagged, while the no-model http core and panic concurrency fired. A probe set that lit up everything would be worthless as a value signal; this one discriminates *within one repo*, which is the specificity evidence the CORPUS wanted, now on external Rust rather than the pydantic module.
  (8) **The `mixed` prior confirmed, third quiet-core/loud-rim geography.** Empirically-measured roughness (the `unwrap`/`panic` density) picked a genuinely `mixed` repo, and the audit found the gradient the tag predicts, a different internal map each time (earthaccess, titiler, this). The role stays an *output* (fire-source on the rim, near-control on the core), never a pre-assignment; measuring roughness at *selection* time is the upstream analog of letting the audit assign the role.

- **2026-07-22: batch analysis output + three promotions landed (not a review run).** The adversarial batch ([CORPUS.md](CORPUS.md)) hit its stopping rule: four external/real audits (earthaccess, titiler-cmr, gen-3 Go, real-4 Rust) each nominating **zero** new `Unhomed:` across the quality AND language axes. This session did the **analysis output**, not more runs (gen-4/gen-5 skipped as volume in filled cells). *(Prose without the em-dash double-hyphen, per standing feedback.)*

  **Stratified signal read** (into [TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md) §C-batch): sounding × provenance, directional, money-comparison (cold-self / hot-elsewhere = bias-suppressed keep). **Unfroze §C** (the corpus is now representative): **no clean cut** (no sounding ever failed to fire; even 17 earned an off-self fire on gen-2 feature envy).

  **Promotions landed into SKILL.md** (three isolated edits, per the refinement discipline of one behavior-changing edit per theme): **18 primitive-obsession** (model the domain with types, not primitives, the bias-invisible headline: cold on self, hot on TS/Java/Go/earthaccess/titiler/Rust, correct-negative on pydantic `h_units`); **19 sound-typing** (no lies to the checker, earthaccess ×3 mechanisms + titiler parked-`Any` specificity; folds A10 TypeGuard/TypeIs as its narrowing facet); **20 CQS** (ask-or-do, earthaccess strong `_get_credentials`/`__repr__`, titiler near-silent contrast, `[bound against 6/9]` held). **Sounding 3 gained a note**: its compiler-checked-exhaustiveness premise is language-dependent (absent for Go error-values, opt-out-able in Rust), the gen-3+real-4 pair the evidence.

  **Folds recorded (§C-batch), NOT landed as soundings, each with its reason:** testability-without-mocks → 6 (the mock cell delivered its verdict: every mock maps 1:1 to a reached-for effect DI removes); immutability → 1 + 10 (leaked-mutable-collection is its only standalone face, gen-2 Java; elsewhere it fuses); must-consume / `#[must_use]` → 1 + 3 (the Go can't-enforce / Rust enforce-but-opt-out pair); temporal-coupling → rider on 1; recoverable-vs-unrecoverable → kept as a meta-router (classified both real models to opposite verdicts).

  **Method sharpening (the one thing that could turn):** the money comparison answers "**bias artifact?**" (cold/hot), *not* "**distinct sounding?**" (is the Move new?). testability is hot off-self yet folds because its fix *is* sounding 6's. Two axes, not one. This is necessary-but-not-sufficient sharpening of CORPUS's money-comparison rule (which as written implies hot-elsewhere ⇒ keep); immutability and must-consume fold on the same second axis. Recorded as a signal, not a JOURNEY beat: the individual fold verdicts were already in the log (Java/titiler entries), this session only *named the second axis*, a synthesis sharpening rather than a live turn or user-catch.

  **Deferred (recorded, not omitted):** the 17 → ~10–12 **combine execution** (the merge/keep *calls* are now decidable from representative data and recorded in §C-batch; landing the merges + reconciling the ~19/17/20 count per §E3 is its own pass); the OCP Boundary line on sounding 3 and A1 (f)/(g), still queued; gen-4/gen-5 optional ranking runs. **Net count:** 17 → 20 soundings pre-combine; the batch **swapped the sanctioned-additions membership** (immutability + testability folded OUT, primitive-obsession + CQS promoted IN, sound-typing landed as already planned).

- **2026-07-22: covjson-msgspec coverage-to-100 diff** (`self-plumbed · clean ·
  python · library`; a **test/doc-heavy diff**, a shape the corpus is thin on).
  Ran the pre-combine 20-sounding version (the 20 → 10 combine landed after this
  fired); sounding numbers below map to the current grouped set.

  Fired: **10 Hunt the breaking edge**, but as a *verification*, not a find. The
  three `# pragma: no cover` "unreachable exhaustiveness guard" claims and the
  `_ISSUE_SAMPLES` completeness guard were un-run assertions I had authored.
  Discharged by running the known-red input: deleted a `case` arm and confirmed
  `ty` goes red (`assert_never` receives `CoverageCollection & ~Coverage`), and
  dropped a sample and confirmed the completeness test fails. Both held. **6 / 8 /
  1 (match-strictness / right-tier / correct-by-construction)** co-fired on a
  note-and-park: a `category_encoding` key naming no category is representable and
  unflagged by `validate()` (the `if values:` empty-flags guard in the xarray
  bridge was the *symptom*). **Net: "Plumb is true" on the diff's own shape** (95%
  tests + doctests + 3 source lines); the leverage was all in the verification and
  the downstream trace.

  Leverage / co-fire: the note-and-park traced downstream (phantom key →
  `validate()` false-negative in `range.invalid-category-code` → silent flag-drop
  in `to_xarray`) and became filed bug **#162** (silent corruption). Same shape as
  the 2026-07-07 entry: the *park* verdict's expansion block prompted "what's the
  gap?", which drove it to a filed bug. **Second confirming instance of the
  "expand the park block" Output rule and the "a park verdict is the likeliest
  'explain that' trigger" provenance note:** both earned their keep again.

  Signals for the tightening pass:
  (1) **The self-authored-verification Working note is load-bearing even when the
  claims hold.** Both verifications confirmed the code was fine, yet running them was
  still correct: the alternative was shipping "Plumb is true" unverified.
  Discharge produces value by converting "I believe X" into "I confirmed X," not
  only by catching a wrong X. Worth sanctioning explicitly.
  (2) **On a near-pure-test diff, plumb's value came entirely from two Working
  notes (verification + downstream-trace), not the structural soundings** (which
  mostly do not apply to new test code). A corpus data point that the Working
  notes carry the skill outside its production-code-modeling habitat; the corpus
  is thin on test/doc diffs and this is one.
  (3) **(Boundary / candidate refinement.)** Plumb-on-a-diff surfaced the one
  latent bug a doctest structurally touched (#162, via the empty-flags branch) but
  missed three `from_xarray` faithfulness / illegal-state bugs (#163 bounds-vertex
  leak, which yields a coverage that fails its own `validate()`; #164 / #165
  auxiliary-coordinate drop). Those were caught by *code-review*'s "bugs in touched
  functions the PR re-exposes" angle. The diff only added tests exercising
  unchanged `from_xarray`, so the latent bugs sat outside plumb-on-a-diff's frame.
  Two of my new tests were tripwires that pin buggy output as expected; plumb could
  have flagged "this test asserts a shape that fails `validate()`." Candidate
  refinement: a new test that pins or asserts the current output of unchanged code
  is itself a plumb-relevant smell (check whether the assertion cements an illegal
  state, sounding 1, or a faithfulness violation, sounding 5), extending "hunt the
  breaking edge / run the excluded case" from pragma'd code to test assertions.

- **2026-07-23: worked-examples pass landed as [EXAMPLES.md](EXAMPLES.md) (not a review
  run).** Stage 3 of the refinement: one concrete example per facet (a real trigger +
  its move) for all 10 grouped soundings / 19 facets. Mined from this log via
  [TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md) §F (the old→new facet Rosetta stone) and
  §A–§D (which entry fired which sounding), opening the raw log only for the ~8 entries
  carrying the concrete trigger. **Result: zero facets needed inventing** — every one had a
  real fire, a late vindication of the corpus/saturation work: the three latest promotions
  (1b primitive-obsession, 1e sound-typing, 3e CQS) all illustrate from the *external*
  audits (earthaccess, titiler-cmr), not the self-corpus that first suppressed them.
  Provenance-tagged per example (self / external / generated); specificity non-fires kept
  beside 1b (pydantic `h_units`), 1e (titiler `Any`-at-edge), 3e (titiler `bounds`). Wired
  in: a SKILL.md pointer from the soundings intro; REFINEMENT.md Files list; JOURNEY.md
  beat 15. Per-facet source map: 1a gen-2 Java + 07-07 `Moment`; 1b earthaccess `login`;
  1c titiler-cmr `parse_datetime`; 1d Java `describeStatus` + gen-3 Go language note; 1e
  earthaccess `Literal|Any` + #138 `TypeGuard`; 2 #14 `_ROOT_TYPES`; 3a zarr metadata-DTO;
  3b earthaccess `CustomDict`; 3c/3d Java `OrderService`/`describeStatus`; 3e earthaccess
  `__repr__`; 4 titiler-cmr mock cell; 5a #44 `(bands,1)`; 5b zarr `must_understand`; 6 PR
  #130 §6.1.1 MUST-vs-MAY; 7 #37 `CoverageRedundantDomainType`; 8 titiler-cmr `Asset` +
  #113 inverse; 9 zarr RLE + earthaccess split-door; 10 07-07 year-0000 + #41.
