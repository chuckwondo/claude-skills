# Plumb: refinement status & how to continue

*A design-review / design-guide skill, drafted collaboratively. This note captures
where the refinement stands and how to finish it: deliberately outside the
covjson-msgspec repo, since plumb is general engineering judgment, not
covjson-specific.*

## Locked decisions

- **Name:** `plumb`, measure against *true*, not against the incumbent codebase.
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
  (ponytail, code-review, and external neighbors). **Some overlap is acceptable**:
  if avoiding it would weaken a sounding or plumb's overall impact, keep it and
  *name* it (a `[combine?]` marker, or a **Boundary:** line in the sounding). Cut the
  accidental overlap; keep the load-bearing kind. Prior art & neighbor analysis lives
  in [LANDSCAPE.md](LANDSCAPE.md), a living snapshot kept fresh as plumb evolves.

## Candidate superset (superseded by the ledger)

The pre-dogfood candidate was ~19 soundings, hand-grouped into clusters
(correct-by-construction; purity & composition; seams / dependency injection;
structure & boundaries; interface shape; judgment & process) as the armchair seams for
merging. That grouping is superseded: the **empirical** combine evidence now lives in
[TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md), §B the observed co-fire dossier, §C
cut/keep by fire-frequency, §F the landing order. The armchair `[combine?]` markers
*disagree* with the observed co-fires, so run the combine from the ledger, not the
clusters.

**Settled additions decisions** (the original eight-proposals round): FC/IS split out
standalone (DONE 2026-07-08, now sounding 6); simplicity deferred to `ponytail-review`;
clarity reframed as plumb's *goal*, not a sounding. **Resolved on evidence (2026-07-22, the
adversarial batch):** of the three sanctioned additions, **sound typing landed** (sounding 19),
**immutability folded** into 1+10, and **testability-without-mocks folded** into 6; the canon audit
added **primitive-obsession** (18) and **CQS** (20). SKILL.md now has **20** soundings, and the count
question §E3 tracked is closed (see TIGHTENING-SIGNALS.md §C-batch + §E3).

## Open questions (the tightening pass)

1. **Tighten the 20 soundings → a tight ~10–12.** The correct-by-construction and purity
   clusters double up in places (illegal-states / sound-typing / outcomes-as-values
   all lean on the same idea); decide the merges.
2. **Clarity:** overarching goal, or a narrowed "reads as its intent" sounding?
3. **Completeness:** keep as an umbrella, or drop (totality + symmetry cover it)?
4. **Presentation:** grouped-by-cluster vs one flat leverage-ranked list.
5. **Definition dose:** crisp definition + one-line payoff per sounding + a compact
   cluster reinforcement map: deep collaboration narrative to the CxC companion.
6. **Sounding 1: the *layer* of "parse-don't-validate" (from #113).** The sounding
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
one-line "what it buys you," a Smell, and a Move: plus a short "how the clusters
reinforce each other" map, and pointers to the Correct-by-Construction guide for
the why.

## How to continue (recommended)

1. **Move plumb out of its origin repo. [DONE]** Plumb lives here in
   `chuckwondo/claude-skills`, the versioned source of truth; `~/.claude/skills/plumb`
   symlinks to it, so `/plumb` runs live from this repo in any project. Refinement
   without dogfooding was guesswork, and now it dogfoods live.
2. **Dogfood, then tighten. [dogfooding done and ongoing]** Review mode has run on
   many real diffs and guide mode on real designs. Which soundings *fire*, which
   *never* do (cut candidates), and which *co-fire* (merge candidates) is tracked in
   [DOGFOOD-LOG.md](DOGFOOD-LOG.md) and harvested into
   [TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md). Usage drives the final list, not
   armchair debate. The **tighten** half is the live next step (item 3).
3. **Do the combine pass** to land ~10–12, then write the definitions, payoffs, and
   reinforcement map.
4. **Cross-link with Correct by Construction.** Shared DNA (illegal-states, sum
   types, immutability, sound typing). Division of labor: CxC = the deep "why";
   plumb = the operational review/guide. Each references the other.
5. **Optional, once stable:** split into `plumb-review` / `plumb-guide` entry points
   (mirroring the ponytail family) if the two modes want separate triggers.

## Files in this skill

- [SKILL.md](SKILL.md): the live skill (20 soundings + Working notes).
- [DOGFOOD-LOG.md](DOGFOOD-LOG.md): append-only log of real runs and refinement
  actions, kept separate from this rewrite-in-place status doc so it can grow
  without churning it.
- [CORPUS.md](CORPUS.md): the corpus-representativeness protocol, the `Corpus:` /
  `Unhomed:` entry tags and the plan for a broader (adversarial) dogfood corpus.
- [TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md): the consolidated, ranked harvest of
  the log's signals; the decision-ready input to the tightening/combine pass.
- [LANDSCAPE.md](LANDSCAPE.md): prior-art and neighbor-skill analysis, kept fresh.
- [case-studies/](case-studies/): the worked examples plumb was distilled from
  (`temporal-conversion`, `resolve-the-repair`).
