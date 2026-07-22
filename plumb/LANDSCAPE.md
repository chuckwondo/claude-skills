# Plumb: landscape & prior art

*A **living snapshot** of publicly available skills that neighbor or overlap plumb.
Unlike [DOGFOOD-LOG.md](DOGFOOD-LOG.md) (the append-only history of runs and changes),
this file is **overwritten to stay current**: rescan the ecosystem, then update it
in place. Keep it fresh, accurate, clear, informative.*

**Last scanned:** 2026-07-20 · **Next rescan:** when a sounding is added/merged, or
~quarterly, whichever first.

---

## Why this file exists

1. **Don't reinvent the wheel**: know what already ships before building.
2. **Sharpen boundaries**: of each *sounding* and of the *skill overall*, to avoid
   unnecessary overlap with the arena (ponytail, code-review, and the external
   neighbors below).

### The boundary-sharpening principle (standing lens)

> Sharpen individual sounding boundaries **and** the overall skill boundary to
> mindfully avoid *unnecessary* overlap with other skills in the arena. **Some
> overlap is acceptable**: if avoiding it would weaken a sounding or the overall
> impact of plumb, keep the overlap and *name* it. Overlap to be cut is the
> accidental kind; overlap that is load-bearing stays.

Mechanism, matching REFINEMENT.md's convention: when a finding overlaps an existing
sounding, don't silently fold (loses the insight) or silently mint (ignores the
overlap): record it **with a `[combine? with N]` marker** so the tightening pass
decides on the merits.

---

## Current verdict

**Not reinventing the wheel.** As of the last scan, exactly one public *structural
review* skill exists in an adjacent tradition: **NTCoding's
`lightweight-design-analysis`** (clean-code / OO / DDD). Plumb differs on three
axes, and that difference is the whole reason plumb earns its place:

| Axis | The arena neighbor | Plumb |
|---|---|---|
| **Method** | evaluates fixed dimensions for *completeness* (report all) | ranks by **leverage**, tracing a flaw to what consumes it downstream |
| **Stance** | no position on the incumbent; conforms to a house style | judges against the **ideal**; conforming to bad precedent is itself a finding |
| **Breadth** | clean-code/OO rubric | 6 soundings the OO tradition structurally can't reach (see map) |

Everything else in the ecosystem is off-axis: *generators/enforcers* (fixed-threshold
lint), *macro-architecture* reviewers (services/scaling/deploy), or *reference
catalogs* (prose, lookup tables).

---

## The arena: four buckets

| Bucket | What it is | Relation to plumb | Examples |
|---|---|---|---|
| **1. Type-modeling generators** | generation + fixed-threshold lint (no `any`, <10-line methods, Zod) | overlaps soundings 1–4 by *topic*; opposite *mode* (generate/enforce vs judge) | NTCoding `software-design-principles`; DDD (Hickey+Wlaschin) skills |
| **2. Macro-architecture review** | services, scalability, deployment, caching | same word "review", wrong altitude: explicitly *not* type/shape level | VoltAgent `architect-reviewer`; alirezarezvani Software Architect |
| **3. Reference catalogs** | prose / cross-language lookup, not runnable review | plumb's *sources & companions*, not competitors | aipatternbook.com; F# for Fun & Profit; **jpablo/vibe-types** |
| **4. The real neighbor** | evidence-based *structural review* skill | closest prior art: differs on method/stance/breadth | **NTCoding `lightweight-design-analysis`** |

---

## Neighboring skills (detail)

### NTCoding / claude-skillz (Nick Tune): the real neighbor *suite*
A DDD/clean-code house-style pipeline. Multiple sub-skills, each adjacent to a slice
of plumb:

- **`lightweight-design-analysis`**: *review* skill. Understand-flow-first, file:line
  refs, severity levels, **8 dimensions**: Naming, Object Calisthenics, Coupling &
  Cohesion, Immutability, Domain Integrity, Type System, Simplicity, Performance.
  → Closest competitor. Dimension-by-dimension *completeness*, not leverage; OO/clean-
  code tradition; no plumb-line stance; missing plumb's fidelity/decision-cost half.
- **`software-design-principles`**: *generation/lint*. "Make illegal states
  unrepresentable", discriminated unions, no `any`/`as`, fail-fast (throw), inject
  deps, intention-revealing names, no comments, Zod, object calisthenics, feature-envy.
  → Bucket 1. Owns the Wlaschin phrasing plumb used to lead with (now de-led in the
  frontmatter to avoid the router collision).
- **`separation-of-concerns`**: prescriptive folder architecture
  (`features/`/`platform/`/`shell/`). → Off-axis: mandates *one* structure; plumb is
  architecture-neutral (touches the same coupling/cohesion ideas without prescribing a
  layout).
- **`architect-refine-critique`** (`/arc`): 3-subagent chain for *new* system design.
  → Off-axis: greenfield design pipeline, not shape-review.
- **`tactical-ddd`**: DDD tactical patterns. → Bucket 1-ish, modeling guidance.

### jpablo / vibe-types
Cross-language type-feature **lookup catalog** (Python, Rust, Scala 3, Lean 4, TS):
~32–48 techniques/language mapped to the constraints they enforce. Covers plumb's
topics (illegal states, parse-don't-validate, functional core, totality) but **does
not review code**: a query-a-technique index. → **Companion/source, not competitor.**
Candidate to *cite* from soundings 1/3/6 rather than differentiate against.

### Off-axis, catalogued for completeness
- **VoltAgent `architect-reviewer`**: macro architecture; explicitly *not* type/shape.
- **alirezarezvani Software Architect**: Clean Arch / SOLID / ADRs; high-level.
- **tirth8205 Code Review Graph**: AST knowledge-graph *tooling*, different axis.
- **OneRedOak Claude Code Workflows**: a design-review *workflow template* (process
  scaffold, not a principle set).
- **NeoLabHQ Review Local Changes**: multi-agent *correctness* review → routes to
  plumb's `code-review` deferral, not plumb.

---

## Sounding-by-sounding overlap map

Nearest arena coverage per sounding, and **plumb's distinct kernel**: the thing that
would be lost if the sounding were dropped in favor of the neighbor. ✅ real overlap ·
◐ partial · ❌ arena gap (plumb-only).

| # | Sounding | Arena | Plumb's distinct kernel / boundary |
|---|---|---|---|
| 1 | Illegal states unrepresentable | ✅ NTCoding, vibe-types | shared topic; plumb's edge is *ranking* it by downstream blast radius, not the idea |
| 2 | Outcomes as values, lose no info | ⚠️ **tension** | plumb = errors-as-values, raise at the *edge*; NTCoding = fail-fast *throw*. Rival traditions: see Tensions |
| 3 | Totality / exhaustiveness | ◐ implied by "Type System" | plumb names compiler-forced exhaustiveness (assert-never) explicitly |
| 4 | Names encode a type's *shape* | ◐ "intention-revealing names" | plumb's claim is subtler: the name reveals *Result vs union vs value*, not just "not generic" |
| 5 | One source of truth; compose | ◐ Coupling & Cohesion | DRY-of-*knowledge* as its own probe |
| 6 | Functional core; effects at edges | ◐ they have DI seams | **plumb-owned**: sans-IO / ports-&-adapters; NTCoding is OO tell-don't-ask, not FC/IS |
| 7 | Faithfulness / round-trip | ❌ | **plumb-only**: no neighbor checks lossless round-tripping |
| 8 | Low coupling, clean boundaries | ✅ Coupling & Cohesion | genuine overlap; keep (load-bearing) and let the leverage-ranking differentiate |
| 9 | Cohesion, one concern | ✅ Coupling & Cohesion | genuine overlap; ditto |
| 10 | Encapsulation | ✅ (NTCoding *stronger*) | tell-don't-ask/no-getters is more prescriptive there; plumb states intent-over-representation, architecture-neutral |
| 11 | Check in the right tier | ❌ | **plumb-only**: O(1)-at-construction vs opt-in-pass placement |
| 12 | Proportional response, real source | ❌ | **plumb-only**: severity grounded in a cited authority |
| 13 | Symmetry | ❌ | **plumb-only**: paired-operation mirroring |
| 14 | Trivial common path over complete core | ❌ | **plumb-only**: their "Simplicity" is YAGNI, a different idea |
| 15 | Reversibility / one-way doors | ❌ | **plumb-only**: decision-cost by door type |
| 16 | Hunt the breaking edge | ❌ | **plumb-only**: the legal input that violates the assumption |
| 17 | Locality of behavior *(candidate)* | ✅ NTCoding "feature envy" | **harvested** from the arena; overlaps 9/10: see Harvest |

**Reading of the map:** overlap concentrates in 1–4 and 8–10 (the type-modeling +
structure clusters every clean-code rubric shares). The **six ❌ gaps (7, 11–16)**
cluster into one theme: *data fidelity and decision-cost over time*, that the
OO/clean-code tradition doesn't reach because it optimizes the *class*, not the
*data's journey through the system*. **That cluster is plumb's moat.**

---

## Canon coverage audit (deductive gap-finding)

*The inverse of the overlap map above. Instead of "what does each plumb sounding
overlap," ask "does plumb have a probe for each principle in the structural-design
canon?" This is **deductive** gap-finding (walk the catalog, check coverage), immune to
the dogfood corpus's selection bias (see [CORPUS.md](CORPUS.md)) because it does not
depend on our code. It **nominates** candidates; adversarial dogfooding **confirms and
ranks** them by real leverage. Sources: Fowler's code-smell catalog, the type-driven /
CxC canon (Wlaschin, Hickey, "parse don't validate"), Ousterhout (APOSD), NTCoding's 8
dimensions.*

**Tier 1: multi-source convergence (act on these first).**

- **Immutability / mutable-data** [Fowler "Mutable Data" · NTCoding "Immutability" · CxC
  · fires x6 in-log · already sanctioned]. Distinct from sounding 6 (functional core is
  about *effects*; immutability is about the *data* being unmodifiable after
  construction). The strongest confirmed gap. → land as a sounding.
- **Sound typing: no lies to the checker** [NTCoding "Type System" · CxC "the type
  carries the invariant" · A10 seed · fires x31 but mostly absorbed by 3/16]. Distinct
  kernel: no `Any` / `cast` / unsound narrow that lets the checker be bypassed. → land,
  bounded tightly against 3 (totality) and 16 (typechecker-as-validator).
- **Model the domain with types, not primitives** [Fowler "Primitive Obsession" + "Data
  Clumps" · Object Calisthenics "wrap primitives" · CxC newtype / smart-constructor]. A
  bare `str` / `int` / `tuple` where a domain type belongs; a field-group that recurs
  and wants to be one object. Adjacent to 1 (illegal states) and 4 (names) but a
  distinct *probe* plumb does not currently name. **The audit's headline finding: this
  is invisible to the fire-frequency method**, because we already model with types, so
  we never commit the smell and it never fires; only the deductive walk catches it. →
  candidate sounding, or a sharp rider on 1. *(Second pass sharpens this: connascence of
  meaning / boolean-blindness — a bare `bool` or magic `0`/`1` whose meaning is a shared
  convention across sites — is the same probe pointed at a value convention; and data-clumps
  / connascence of position — a positional `(lat, lon)` where a `Point` belongs — is its
  recurring-field-group face.)*
- **Command-Query Separation (CQS)** [Meyer · connascence-of-execution adjacent ·
  earthaccess `auth.py` real unhomed fire]. A single method both *returns* a value and
  *mutates* observable state: a query that commands, or a command that returns status.
  Distinct from 6 (architecture: *where* effects live; a CQS-violating method can sit
  wholly in the imperative shell and still mix asking with doing) and from 9 (generic
  cohesion): CQS is a per-method, mechanically-checkable split — does it return AND mutate?
  **The second pass's headline candidate: both a deductive miss AND a real inductive fire**
  (earthaccess `_get_credentials`, a query-named method that mutates `self`, homed only
  awkwardly under 9/4 in the seed run) — the same deductive+inductive convergence that
  earned immutability and sound-typing their Tier-1 slots. Bound tightly against 6 and 9.
  → candidate sounding; confirm/rank in the batch.

**Tier 2: single strong source, distinct kernel (watch, adversarial-confirm).**

- **Temporal coupling / illegal *transitions* unrepresentable** [CxC typestate ·
  connascence-of-execution · Meyer]. **Broadened by the second pass** from "state machines"
  to *any* hidden ordering requirement: call `.open()` before `.read()`; a
  must-set-before-read field; `configure()` then `run()`, not only an explicit state
  machine. Sounding 1 makes illegal *states* unrepresentable; this makes an illegal
  *sequence* unrepresentable — typestate (`.read()` exists only on an `OpenFile`) — or,
  where typestate is too heavy, names the ordering contract explicitly. Distinct from 6 (a
  temporally-coupled pair can be pure) and from 1 (states vs sequences). Clusters with CQS:
  a query that secretly commands *creates* temporal coupling downstream. → rider on 1, or a
  new sounding if it fires on stateful code.
- **Recoverable vs unrecoverable invariants** [CxC Point 3, "the load-bearing distinction of
  the whole guide"; faithful sweep 2026-07-21]. A *meta*-probe that routes to the right
  sounding: can validity be decided from the finished value alone (**recoverable** → a
  validating constructor / a downstream check suffices) or is it a fact about the value's
  *history / intent / provenance* the bytes don't record (**unrecoverable** → construction
  control is the *only* mechanism; no downstream validator can exist)? Plumb owns both
  *answers* (validate → 2/11; control construction → 1) but not the *question that chooses
  between them*. Ties to 7 (the guide's `/axes/x/y` forgotten-escape is an information-loss /
  non-round-trip case) and the provenance family (SafeHtml / taint / units / normalization).
  Single strong source, distinct kernel → Tier-2; `[combine? rider on 1]`. Detail in the CxC
  sweep below.

**Tier 3: partial coverage, likely fold (not new soundings).**

- **Message chains / Law of Demeter** [Fowler · Object Calisthenics] → a rider on 8
  (coupling) / 10, not a probe of its own.
- **Deep vs shallow modules** [Ousterhout] → folds into 14 (trivial common path over a
  complete core) + 10 (encapsulation).
- **Anemic domain model** [Fowler · NTCoding] → already covered by 17 (locality of
  behavior) + 10.

**Confirmed non-gaps (the arena has them; plumb correctly defers or omits).** Simplicity
/ Speculative Generality / Lazy Element / Long Function → ponytail. Performance →
off-axis (code-review). Naming, Coupling, Cohesion, Domain Integrity → already soundings
4 / 8 / 9 / 1.

**Net:** the audit corroborates the two known additions (immutability, sound typing)
from a second, bias-free direction, adds one genuinely new bias-invisible candidate
(primitive-obsession / domain-typing), and one distinct-kernel Tier-2 (illegal
transitions). None is a fire-frequency artifact, so all survive the §C freeze. Promote a
candidate into TIGHTENING-SIGNALS.md §A once it fires in the adversarial batch.

**Batch outcome (2026-07-22, the batch reached saturation; dispositions in
[TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md) §C-batch).** Of the candidates above:
**primitive-obsession** (Tier-1), **sound-typing** (Tier-1), and **CQS** (Tier-1)
**promoted** to SKILL.md soundings **18 / 19 / 20** — each fired real off-self with
demonstrated specificity (primitive-obsession's pydantic `h_units` correct-negative;
sound-typing's parked `Any`-at-a-dynamic-edge; CQS's near-silent titiler contrast).
**Immutability** (Tier-1) **folded into 1 + 10** — its only standalone face is the
leaked-mutable-collection (gen-2 Java); elsewhere it fuses into the lifecycle (1),
derived-state (5), or leaked-representation (10). **Temporal coupling** (Tier-2) stays a
**rider on 1** (make the illegal *sequence* unrepresentable). **Recoverable vs
unrecoverable** (Tier-2) is **kept as a meta-router**, not a numbered sounding: it
classified earthaccess's dict model and titiler's pydantic tree to opposite verdicts,
routing each to 1 vs 2/11. Separately, **testability-without-mocks** (an Open-tensions
harvest candidate) **folded into 6** — the titiler mock cell (135 mocks) proved every
mock maps 1:1 to a reached-for effect DI removes. The Tier-3 folds and confirmed
non-gaps held; no neighbor closed a moat gap.

### Second pass: un-walked canon (DONE 2026-07-21)

*Rationale (decided 2026-07-21): the soundings are the measuring instrument; the repo
audits measure with it, so complete the deductive **nomination** set before measuring. A
candidate nominated mid-batch leaves the already-run audits blind to it (incomplete
`Unhomed`/fire data, re-work). The canon walk is cheap and code-independent, so it has no
reason to wait behind the expensive audits. This completes **nomination only**: promotion
(§A) still requires an adversarial fire, and the combine decisions (§C) stay frozen pending
batch data, so canon-first adds candidates without touching either downstream gate.*

The first pass walked Fowler + CxC + Ousterhout + NTCoding. Second pass swept the five
un-walked bodies below with the same distinct-kernel-vs-fold test. **Result: one new
candidate (CQS, → Tier-1 above), one broadening (temporal coupling, → Tier-2 above), the
rest fold or go off-axis with reasons. Near-saturation: CQS is the single escape.** Per-body
disposition:

- **Connascence** (Page-Jones, connascence.io). The taxonomy's *forms* distribute across
  soundings we already have rather than nominating one of their own: connascence of value
  (fields must agree) → sounding 1; of meaning / boolean-blindness and of position /
  data-clumps → sharpen the **primitive-obsession** Tier-1 candidate (noted there); of
  algorithm (same encode both ends) → 5 + 13, with the sharp residue that when the algorithm
  is duplicated across an *un-shareable* boundary (JS client / Python server), one-source-of-
  truth becomes "one *spec* + a conformance test," not extraction; of execution → temporal
  coupling (below); of timing → off-axis (races → code-review); of identity → immutability +
  10. **The one additive idea:** connascence's *locality gradient* — the coupling strength you
  tolerate should degrade with the distance between the coupled elements (strong connascence
  is fine inside one function, a smell across a module boundary). Sounding 8 says "low
  coupling" flat; this grades it. → **rider on 8**, not a new sounding.
- **CQS / Command-Query Separation** (Meyer). → **promoted to Tier-1 above** (deductive miss +
  earthaccess real unhomed fire; the second pass's headline).
- **Full GRASP / SOLID** (un-checked forms). All fold or go off-axis, with reasons:
  - **LSP / behavioral subtyping** → mostly **off-axis**: it is a property of inheritance
    hierarchies, and plumb's totality (3) + illegal-states (1) soundings *prefer the closed
    sum type that has no LSP hazard*. Where a `Protocol` implementer breaks the interface's
    documented contract, that is design-by-contract + sounding 12, not a new probe.
  - **OCP (open/closed)** → **the other side of a tension plumb already resolved**: a closed,
    exhaustive sum (sounding 3) is deliberately *closed to extension* so the compiler forces
    every case — the expression-problem trade. Not a gap. → recommend a **Boundary line on
    sounding 3** (mirroring the errors-as-values Boundary on 2) so an OO reader sees plumb
    takes the closed-and-exhaustive side and where it costs. *(A landing, deferred to §A.)*
  - **ISP (interface segregation)** → **cohesion (9) at interface grain + coupling (8)**; the
    narrow-capability seam in 6 is ISP done right. Fold.
  - **Protected Variations / Indirection / Pure Fabrication** → design *devices*, not
    fault-probes: covered by 10/15/6/8 where legit, and their over-applied forms (protecting a
    variation that never varies, indirection for one implementation) are **ponytail's** turf,
    deferred by name. Non-gaps.
- **Temporal coupling** (must-call-A-before-B, no explicit state machine). Same probe as the
  Tier-2 illegal-transitions candidate (the smell; typestate is the move). → **merged into and
  broadened that Tier-2 entry above**, not a separate candidate.
- **Design by contract** (Meyer pre/post/invariant). Folds: **invariants** → 1 (+11 for where
  the runtime check goes); **preconditions** → 11 + 16 + 12 (a precondition is a requirement);
  **postconditions** → 1 with the sum-type move — a "returns non-empty" contract is best kept
  by returning a `NonEmpty<T>`, i.e. *lift the contract into the type* rather than assert it.
  The caller-vs-callee responsibility split is sounding 1's parse-at-the-edge-trust-inward.
  **Confirmed non-gap**, fully distributed across 1/11/12.

**The structural finding of the pass:** most of the OO/procedural canon folds because plumb's
**type-first stance already absorbs it** — LSP dissolves into the sum-type preference, OCP is
the mirror of totality, DbC lifts contracts into types. Plumb is a *type-driven* design lens,
not an OO one, and it steers *away from* the shapes (inheritance hierarchies) where half the
OO canon's warnings even apply. CQS is the one probe that escapes that absorption — and, like
primitive-obsession in the first pass, it re-earns the deductive method's keep.

#### CxC (Correct by Construction): faithful sweep (added 2026-07-21)

*Prompted mid-pass ("did you want CxC too?"). **Correction first:** the first pass's "CxC"
citations were a **proxy** — general type-driven canon (Wlaschin / King / Hickey) wearing a
"CxC" label — not the actual companion guide, which no one had read. The real source is
`~/src/chuckwondo/digital-garden/content/correct-by-construction.md` (stage **budding**: the
**Values** scale is complete; **States / Sequences / Relationships** are seedlings). Reading it
changed the yield, because its load-bearing idea is **original to the guide**, so the proxy
sweep was structurally blind to it. This is the deductive method's own breaking edge — a canon
walk is only as good as the canon actually read (JOURNEY beat 9).*

**One new candidate (→ Tier-2 above):** recoverable vs unrecoverable invariants — CxC's own
headline distinction, invisible to the proxy.

**Corroborations (deductive, bias-free — a second source strengthens existing candidates):**
- **Immutability** (Tier-1): CxC — "airtight = controlled construction **and** immutability;
  skip either and the invariant leaks — through the front door or the window."
- **Sound typing** (Tier-1): CxC Point 4 Hole 3 gives the mechanism — `Any`-laundering, with
  `cast(...)` a *named* hatch and an *annotated assignment* a *silent* one: the concrete kernel
  of "no lies to the checker."

**Riders (fold, but named — they sharpen an existing sounding/candidate):**
- **Primitive-obsession** candidate: split **brand** (a role, *no* invariant → `NewType`) from
  **value object** (a real invariant → smart constructor); CxC's Q1 "is there anything to
  check?" is the gate. The candidate as framed ("a bare str/int where a domain type belongs")
  misses this fork.
- **Sounding 1**: (a) **timeless value-facts vs world-facts** — "`UserId` must be a *real*
  user" is a fact about the DB *now* (a query, stale the instant it's checked), not a property
  of the value; a type carries only timeless facts, so don't type a world-fact. (b) the
  backbone under 1: **leak surface = what the public constructor accepts** (the guide's sharpest
  line).
- **Sounding 6 / 1**: **minting is a boundary-authority act** — the layer where raw data first
  becomes meaningful vouches; an *interior* `UserId(...)` vouches for what it cannot know (the
  bug wearing construction syntax). Concentrate the mints; grep them.
- **Sounding 11**: **seam / one-guard-per-seam** — a runtime guard belongs where guarantees
  change (wire / unchecked caller / every `Any` / brand erasure), and *once*; re-checking in
  every interior function silently re-invents correct-by-validation. Sharper than 11's
  cost/scope tiering for the boundary case.
- **Sounding 10**: **closure** — every operation on a refined type returns the refined type; a
  method that hands back the raw base "undoes the constructor one call at a time" (an
  encapsulation leak with an algebraic name).
- **Sounding 12 / 4**: **false confidence** — a guard that looks stronger than it is (a brand on
  a public surface whose door still accepts garbage) is worse than none: it moves the mistake
  from visible to invisible. A refined type with an open front door is a lying name (4) and
  disproportionate trust (12) at once.

**Both directions (feed back to the guide's author):** on the scales CxC has only *seeded*,
plumb is **ahead** — sounding 1 already operationalizes the **States** scale, and the broadened
Tier-2 candidate the **Sequences** scale. The **Relationships** scale (a value valid only
*relative to another* — an index tied to one collection; connascence of identity) is thin on
*both* sides; watch it, don't nominate yet.

Output complete: survivors folded into the Tier-1/2/3 lists above; candidate set is ready for
the repo audits.

---

## Open tensions & harvest

### Tension: sounding 2: errors-as-values vs fail-fast-throw
NTCoding's rule is *"fail-fast, throw a clear error, never fallback."* Plumb's sounding
2 is *"errors are values, opt-in raise confined to the edge."* Not contradictory
(throw-**at-the-edge** over a typed core satisfies both) but they read as rival
philosophies. **Disposition:** sounding 2 now carries an explicit **Boundary** line
stating plumb takes the errors-as-values side and where the fail-fast seam sits, so a
reader from the OO tradition isn't left thinking plumb bans exceptions.

### Harvest: feature envy → candidate sounding 17 "Locality of behavior"
The one thing worth harvesting from the arena. NTCoding makes feature-envy a first-class
detector (*count external vs own references; more external → move the method*). Plumb had
no crisp home for method-level *placement*. **Disposition:** minted as **candidate
sounding 17** with a `[combine? with 9, 10]` marker: its kernel ("behavior lives with
the data it operates on"; GRASP *Information Expert* / *Tell, Don't Ask*) sits at the
intersection of cohesion and encapsulation. Whether it stays standalone or folds is a
tightening-pass call, deferred by the marker per convention.

---

## Sources (last scan)

- NTCoding claude-skillz: https://github.com/NTCoding/claude-skillz
  (`lightweight-design-analysis`, `software-design-principles`, `separation-of-concerns`,
  `architect-refine-critique`, `tactical-ddd`)
- jpablo/vibe-types: https://github.com/jpablo/vibe-types
- VoltAgent architect-reviewer: https://github.com/VoltAgent/awesome-claude-code-subagents
- aipatternbook.com · fsharpforfunandprofit.com (reference reading)
- Aggregators swept: awesome-skills.com · claudeskills.info/best

---

## How to keep this fresh

When rescanning (on a sounding change, or ~quarterly):
1. Re-sweep the aggregators + `github.com/NTCoding/claude-skillz` (moves fastest) for
   new or changed neighbors; refresh **Last scanned**.
2. Re-check each ❌ gap: if a neighbor closes one, plumb's moat shrank; note it and
   re-justify the sounding's distinctness.
3. Re-run the boundary-sharpening principle over any *new* sounding: nearest arena
   coverage + distinct kernel; add a row; mark `[combine?]` if it overlaps.
4. Overwrite this file in place. Log the *fact of the rescan* (one line) in this
   file's **Changelog** below; keep the analysis above.

## Changelog
- **2026-07-08**: initial landscape scan. Established the four buckets, identified
  NTCoding `lightweight-design-analysis` as the closest prior art, mapped all
  soundings, recorded the sounding-2 tension and the feature-envy harvest.
- **2026-07-20**: rescan + first canon coverage audit. NTCoding neighbor unchanged
  (8 dimensions confirmed; it also flags Anemic Domain Model, which maps to sounding
  17). One new Bucket-1 entrant, a DDD modeling skill (mcpmarket, Hickey / Wlaschin
  lineage), which does not change the "one review neighbor" verdict. Added the Canon
  coverage audit section: Tier-1 candidates immutability, sound-typing, and (new,
  bias-invisible) primitive-obsession / domain-typing; Tier-2 illegal-transitions. The
  moat gaps (7, 11-16) still hold; no neighbor closed one.
