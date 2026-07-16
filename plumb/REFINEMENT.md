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
6. **Sounding 1 — the *layer* of "parse-don't-validate" (from #113).** The sounding
   assumes untrusted input is parsed into a trusted shape at *decode*. #113 is a
   counter-case: the faithful stored form is deliberately permissive (a grab-bag
   core, the structural face of permissive decode / ADR-0002), and illegal states
   are made unrepresentable at *first consumption* instead, via an opt-in `refine()`
   projection to clean variants. Decide whether 1 should name the edge as
   decode-*or*-first-use; doing so reconciles 1 with 7 (faithfulness) and 11
   (permissive load) where they appear to conflict. See the 2026-07-15 #113 dogfood
   entry, signal (2).

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

Real review-mode runs and what each drove into the skill live in
[DOGFOOD-LOG.md](DOGFOOD-LOG.md) — append-only, kept separate from this
rewrite-in-place status doc so the log can grow without churning it.

## Artifacts in scratchpad (ephemeral — relocate with the skill)

- `plumb-SKILL.md` — the working draft (15 soundings + folding notes).
- `plumb-refinement-status.md` — this note.
- `temporal-iteration-log.md` / `.html` — the case study plumb was distilled from.
