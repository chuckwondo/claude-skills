# Plumb — landscape & prior art

*A **living snapshot** of publicly available skills that neighbor or overlap plumb.
Unlike [REFINEMENT.md](REFINEMENT.md) (append-only history of internal changes),
this file is **overwritten to stay current** — rescan the ecosystem, then update it
in place. Keep it fresh, accurate, clear, informative.*

**Last scanned:** 2026-07-08 · **Next rescan:** when a sounding is added/merged, or
~quarterly, whichever first.

---

## Why this file exists

1. **Don't reinvent the wheel** — know what already ships before building.
2. **Sharpen boundaries** — of each *sounding* and of the *skill overall* — to avoid
   unnecessary overlap with the arena (ponytail, code-review, and the external
   neighbors below).

### The boundary-sharpening principle (standing lens)

> Sharpen individual sounding boundaries **and** the overall skill boundary to
> mindfully avoid *unnecessary* overlap with other skills in the arena. **Some
> overlap is acceptable** — if avoiding it would weaken a sounding or the overall
> impact of plumb, keep the overlap and *name* it. Overlap to be cut is the
> accidental kind; overlap that is load-bearing stays.

Mechanism, matching REFINEMENT.md's convention: when a finding overlaps an existing
sounding, don't silently fold (loses the insight) or silently mint (ignores the
overlap) — record it **with a `[combine? with N]` marker** so the tightening pass
decides on the merits.

---

## Current verdict

**Not reinventing the wheel.** As of the last scan, exactly one public *structural
review* skill exists in an adjacent tradition — **NTCoding's
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

## The arena — four buckets

| Bucket | What it is | Relation to plumb | Examples |
|---|---|---|---|
| **1. Type-modeling generators** | generation + fixed-threshold lint (no `any`, <10-line methods, Zod) | overlaps soundings 1–4 by *topic*; opposite *mode* (generate/enforce vs judge) | NTCoding `software-design-principles`; DDD (Hickey+Wlaschin) skills |
| **2. Macro-architecture review** | services, scalability, deployment, caching | same word "review", wrong altitude — explicitly *not* type/shape level | VoltAgent `architect-reviewer`; alirezarezvani Software Architect |
| **3. Reference catalogs** | prose / cross-language lookup, not runnable review | plumb's *sources & companions*, not competitors | aipatternbook.com; F# for Fun & Profit; **jpablo/vibe-types** |
| **4. The real neighbor** | evidence-based *structural review* skill | closest prior art — differs on method/stance/breadth | **NTCoding `lightweight-design-analysis`** |

---

## Neighboring skills (detail)

### NTCoding / claude-skillz (Nick Tune) — the real neighbor *suite*
A DDD/clean-code house-style pipeline. Multiple sub-skills, each adjacent to a slice
of plumb:

- **`lightweight-design-analysis`** — *review* skill. Understand-flow-first, file:line
  refs, severity levels, **8 dimensions**: Naming, Object Calisthenics, Coupling &
  Cohesion, Immutability, Domain Integrity, Type System, Simplicity, Performance.
  → Closest competitor. Dimension-by-dimension *completeness*, not leverage; OO/clean-
  code tradition; no plumb-line stance; missing plumb's fidelity/decision-cost half.
- **`software-design-principles`** — *generation/lint*. "Make illegal states
  unrepresentable", discriminated unions, no `any`/`as`, fail-fast (throw), inject
  deps, intention-revealing names, no comments, Zod, object calisthenics, feature-envy.
  → Bucket 1. Owns the Wlaschin phrasing plumb used to lead with (now de-led in the
  frontmatter to avoid the router collision).
- **`separation-of-concerns`** — prescriptive folder architecture
  (`features/`/`platform/`/`shell/`). → Off-axis: mandates *one* structure; plumb is
  architecture-neutral (touches the same coupling/cohesion ideas without prescribing a
  layout).
- **`architect-refine-critique`** (`/arc`) — 3-subagent chain for *new* system design.
  → Off-axis: greenfield design pipeline, not shape-review.
- **`tactical-ddd`** — DDD tactical patterns. → Bucket 1-ish, modeling guidance.

### jpablo / vibe-types
Cross-language type-feature **lookup catalog** (Python, Rust, Scala 3, Lean 4, TS):
~32–48 techniques/language mapped to the constraints they enforce. Covers plumb's
topics (illegal states, parse-don't-validate, functional core, totality) but **does
not review code** — a query-a-technique index. → **Companion/source, not competitor.**
Candidate to *cite* from soundings 1/3/6 rather than differentiate against.

### Off-axis, catalogued for completeness
- **VoltAgent `architect-reviewer`** — macro architecture; explicitly *not* type/shape.
- **alirezarezvani Software Architect** — Clean Arch / SOLID / ADRs; high-level.
- **tirth8205 Code Review Graph** — AST knowledge-graph *tooling*, different axis.
- **OneRedOak Claude Code Workflows** — a design-review *workflow template* (process
  scaffold, not a principle set).
- **NeoLabHQ Review Local Changes** — multi-agent *correctness* review → routes to
  plumb's `code-review` deferral, not plumb.

---

## Sounding-by-sounding overlap map

Nearest arena coverage per sounding, and **plumb's distinct kernel** — the thing that
would be lost if the sounding were dropped in favor of the neighbor. ✅ real overlap ·
◐ partial · ❌ arena gap (plumb-only).

| # | Sounding | Arena | Plumb's distinct kernel / boundary |
|---|---|---|---|
| 1 | Illegal states unrepresentable | ✅ NTCoding, vibe-types | shared topic; plumb's edge is *ranking* it by downstream blast radius, not the idea |
| 2 | Outcomes as values, lose no info | ⚠️ **tension** | plumb = errors-as-values, raise at the *edge*; NTCoding = fail-fast *throw*. Rival traditions — see Tensions |
| 3 | Totality / exhaustiveness | ◐ implied by "Type System" | plumb names compiler-forced exhaustiveness (assert-never) explicitly |
| 4 | Names encode a type's *shape* | ◐ "intention-revealing names" | plumb's claim is subtler: the name reveals *Result vs union vs value*, not just "not generic" |
| 5 | One source of truth; compose | ◐ Coupling & Cohesion | DRY-of-*knowledge* as its own probe |
| 6 | Functional core; effects at edges | ◐ they have DI seams | **plumb-owned** — sans-IO / ports-&-adapters; NTCoding is OO tell-don't-ask, not FC/IS |
| 7 | Faithfulness / round-trip | ❌ | **plumb-only** — no neighbor checks lossless round-tripping |
| 8 | Low coupling, clean boundaries | ✅ Coupling & Cohesion | genuine overlap; keep (load-bearing) and let the leverage-ranking differentiate |
| 9 | Cohesion, one concern | ✅ Coupling & Cohesion | genuine overlap; ditto |
| 10 | Encapsulation | ✅ (NTCoding *stronger*) | tell-don't-ask/no-getters is more prescriptive there; plumb states intent-over-representation, architecture-neutral |
| 11 | Check in the right tier | ❌ | **plumb-only** — O(1)-at-construction vs opt-in-pass placement |
| 12 | Proportional response, real source | ❌ | **plumb-only** — severity grounded in a cited authority |
| 13 | Symmetry | ❌ | **plumb-only** — paired-operation mirroring |
| 14 | Trivial common path over complete core | ❌ | **plumb-only** — their "Simplicity" is YAGNI, a different idea |
| 15 | Reversibility / one-way doors | ❌ | **plumb-only** — decision-cost by door type |
| 16 | Hunt the breaking edge | ❌ | **plumb-only** — the legal input that violates the assumption |
| 17 | Locality of behavior *(candidate)* | ✅ NTCoding "feature envy" | **harvested** from the arena; overlaps 9/10 — see Harvest |

**Reading of the map:** overlap concentrates in 1–4 and 8–10 (the type-modeling +
structure clusters every clean-code rubric shares). The **six ❌ gaps (7, 11–16)**
cluster into one theme — *data fidelity and decision-cost over time* — that the
OO/clean-code tradition doesn't reach because it optimizes the *class*, not the
*data's journey through the system*. **That cluster is plumb's moat.**

---

## Open tensions & harvest

### Tension — sounding 2: errors-as-values vs fail-fast-throw
NTCoding's rule is *"fail-fast, throw a clear error, never fallback."* Plumb's sounding
2 is *"errors are values, opt-in raise confined to the edge."* Not contradictory
(throw-**at-the-edge** over a typed core satisfies both) but they read as rival
philosophies. **Disposition:** sounding 2 now carries an explicit **Boundary** line
stating plumb takes the errors-as-values side and where the fail-fast seam sits — so a
reader from the OO tradition isn't left thinking plumb bans exceptions.

### Harvest — feature envy → candidate sounding 17 "Locality of behavior"
The one thing worth harvesting from the arena. NTCoding makes feature-envy a first-class
detector (*count external vs own references; more external → move the method*). Plumb had
no crisp home for method-level *placement*. **Disposition:** minted as **candidate
sounding 17** with a `[combine? with 9, 10]` marker — its kernel ("behavior lives with
the data it operates on"; GRASP *Information Expert* / *Tell, Don't Ask*) sits at the
intersection of cohesion and encapsulation. Whether it stays standalone or folds is a
tightening-pass call, deferred by the marker per convention.

---

## Sources (last scan)

- NTCoding claude-skillz — https://github.com/NTCoding/claude-skillz
  (`lightweight-design-analysis`, `software-design-principles`, `separation-of-concerns`,
  `architect-refine-critique`, `tactical-ddd`)
- jpablo/vibe-types — https://github.com/jpablo/vibe-types
- VoltAgent architect-reviewer — https://github.com/VoltAgent/awesome-claude-code-subagents
- aipatternbook.com · fsharpforfunandprofit.com (reference reading)
- Aggregators swept: awesome-skills.com · claudeskills.info/best

---

## How to keep this fresh

When rescanning (on a sounding change, or ~quarterly):
1. Re-sweep the aggregators + `github.com/NTCoding/claude-skillz` (moves fastest) for
   new or changed neighbors; refresh **Last scanned**.
2. Re-check each ❌ gap — if a neighbor closes one, plumb's moat shrank; note it and
   re-justify the sounding's distinctness.
3. Re-run the boundary-sharpening principle over any *new* sounding: nearest arena
   coverage + distinct kernel; add a row; mark `[combine?]` if it overlaps.
4. Overwrite this file in place. Log the *fact of the rescan* (one line) in
   REFINEMENT.md's changelog; keep the analysis here.

## Changelog
- **2026-07-08** — initial landscape scan. Established the four buckets, identified
  NTCoding `lightweight-design-analysis` as the closest prior art, mapped all
  soundings, recorded the sounding-2 tension and the feature-envy harvest.
