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

1. **✔ Resolved (2026-07-22): the combine ran → SKILL.md is now 10 grouped soundings.** The
   merge was executed as **group, don't fold**: distinct-Move probes are *grouped* under a
   shared cluster headline (each keeping its own Smell/Move as a numbered facet), never folded
   away. Rule used: the batch's distinctness axis (`is the Move new?`) is a *fold-vs-group* test:
   a distinct Move may only be grouped. So the correct-by-construction cluster (illegal-states
   1a, domain-types 1b, outcomes 1c, totality 1d, sound-typing 1e) keeps all five Moves; the
   structure cluster (coupling 3a, encapsulation 3b, cohesion 3c, locality 3d, CQS 3e) keeps
   five; faithfulness+symmetry (5a/5b) keeps two. The only *fold* (Move-death) beyond the batch's
   four was **none**; the only *demotion* was **14** (trivial-common-path, affirm-only, never
   drove a finding) → a rider on 2. Count: 20 → **10 headlines / 19 facet-Moves**. The ~10–12
   target was hit as a *consequence* of grouping, not by targeting a number (the user's steer:
   right delineation over count).
2. **Clarity:** overarching goal, or a narrowed "reads as its intent" sounding?
3. **Completeness:** keep as an umbrella, or drop (totality + symmetry cover it)?
4. **✔ Resolved (2026-07-22): grouped-by-cluster.** Chosen over the flat list because grouping
   preserves the same distinct Moves as a flat 15 *and* surfaces the reinforcement structure the
   target-end-state asks for. See the "How the clusters reinforce each other" map in SKILL.md.
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
3. **✔ Combine pass ran (2026-07-22): 20 → 10 grouped soundings, reinforcement map written.**
   Remaining polish (not blocking): a one-line "what it buys you" payoff per sounding (the
   Smell/Move bodies are in place); it can land alongside the queued §A items (A2 three
   altitudes, A5–A10) in TIGHTENING-SIGNALS.md §F.
4. **✔ Done (2026-07-23, Stage 4): cross-linked with Correct by Construction.** Shared DNA
   (illegal-states, sum types, immutability, sound typing). Division of labor: CxC = the deep "why";
   plumb = the operational review/guide. Bidirectional: SKILL.md's cluster-1 intro + REFERENCES.md
   point to the CxC guide (github.com/chuckwondo/digital-garden); the guide's canon paragraph points
   back to plumb/SKILL.md + REFERENCES.md. Hughes's "Why FP Matters" landed in both as a foundational
   composition cite (explicitly not an effect-placement source).
5. **Optional, once stable:** split into `plumb-review` / `plumb-guide` entry points
   (mirroring the ponytail family) if the two modes want separate triggers.

## Capturing a dogfood entry from another repo

Most real runs happen where the work is (covjson-msgspec, virtualizarr, and other local
repos), not here, but the log and its house style live in this repo. Two paths, chosen by
whether the run's context survives the trip back:

**Default (one step).** Carry the raw run back to a session with this repo as the working
directory and paste it: the log, the `Corpus:` tags, and the HELD/landable rule are all
loaded here, so the entry renders in house style directly. This is the right path whenever
the material still fits in a paste.

**When context will not survive** (a long session in the other repo, an imminent `/clear`, a
transcript too large to carry), have that session emit a compact *field note* first, while
its context is hot. The field note is the intake-form schema (subject, verdict, true shape,
lane, coverage, provenance) plus the four maintainer-only fields, captured raw so a later
session in this repo can render it:

> Emit a plumb dogfood field-note for this run. Capture, do not prose it up. Fill every
> field; write `unknown` rather than guess.
>
> - **Corpus:** self-plumbed/external, clean/mixed, lang, shape, greenfield/brownfield
> - **Subject:** what was reviewed (diff, plan, design), one line
> - **Fired:** which soundings by number, and any co-fires
> - **Breaking case + downstream trace:** the concrete instance and what consumes it
>   (non-negotiable: a fire without it is filler)
> - **Verdict vs true shape:** what plumb said / what was correct
> - **Provenance:** who caught each thing (me, the model, or /code-review)
> - **Drove:** into the work or into the skill (tag which); if the skill, coverage-gap or
>   wording-gap
> - **Authored by the model?** yes = HELD (the author cannot land their own claim); no =
>   landable

The four maintainer-only fields (corpus, fired-by-number, drove-work-vs-skill, HELD/landable)
are what lift the intake-form schema up one tier to a log entry; the shared six are exactly
the [issue form](../.github/ISSUE_TEMPLATE/plumb-report.yml)'s fields, so a downstream report
and a maintainer field-note are the same capture at two audience levels.

The one thing to hold across the handoff is the concrete breaking case, verbatim: it is what
every strong entry in the log is built on, and it is the first casualty of a session
summarizing itself.

## Triage protocol (for a flagged signal)

When a run surfaces a candidate refinement (a miss, an unhomed finding, a lapse), triage it before
landing. This is the **MISS-TRIAGE protocol**, referenced by name in JOURNEY beats 17 and 19 and
consolidated here so it is committed, not memory-only:

1. **Lane check.** A missed *bug* (→ `code-review`) or *over-engineering* (→ `ponytail-review`) is a
   correct deferral, a boundary note, not a plumb miss. Only a *structural/modeling* miss is in lane.
2. **Coverage vs execution.** *No sounding covers the shape* = a **coverage gap** = a new `Unhomed:`
   that BREAKS saturation and reopens nomination (a candidate new sounding). *A sounding covers it but
   did not fire* = a **wording gap** (add the instance to its Smell/Move, lands like a §A item), OR
   *ranked-low / parked when load-bearing* (sharpen the leverage-trace), OR an **application lapse**
   (recurrence means the wording is not salient enough; one instance is a watch, not a landing).
3. **Verify the miss is real before landing.** Construct the case and confirm plumb *should* have
   caught it. A confirmed coverage/wording miss OUTRANKS queued §A landings.

Why a miss is high-leverage: it is a *false-negative* channel, orthogonal to fire-frequency, so it
bypasses corpus bias (a clean corpus surfaces a gap by *missing*, not *firing*). A miss is a reversal
by construction (Believed / Broke / Corrected), so capture a JOURNEY beat with honest who-caught-it.

## Signal intake (post-publish): how a downstream signal reaches this repo

Publishing hands plumb the representative corpus it could never build by hand, but a corpus you cannot
*observe* is useless, and a local skill has **no telemetry and should have none** (a review skill that
uploads a user's diffs is a privacy/trust non-starter and violates the sans-IO / local-first stance
the skill itself teaches). So the intake is these channels, in fidelity order:

1. **Own dogfooding stays primary.** Highest fidelity: full repo access, you run the full triage
   yourself. External use *supplements*, never replaces. Keep logging to DOGFOOD-LOG.
2. **Voluntary user reports (issues on this repo).** The only free external channel, but lossy and
   self-selected: it catches the loud *misfires* (a fire the user disputes) far better than the silent
   *misses* (a miss is what plumb did not say, so the user usually cannot see it either). Lower the
   friction with an issue template shaped like a MISS-TRIAGE input: the design/diff, plumb's verdict,
   the true shape, who caught it.
3. **The skill prompts its own capture (the skill-native move).** The distribution unit is a *prompt*,
   so the feedback mechanism can be too: a line in SKILL.md's output contract so that when a user says
   plumb missed or misfired, the *downstream* model offers to build the structured report (running the
   lane-check + coverage-vs-wording at the edge) and hands back a ready-to-file issue body. Every
   user's Claude becomes a first-pass triage agent emitting a well-formed entry.

This is the skill's own soundings turned on its distribution: keep the skill **pure** (local, no I/O)
and push the effect (getting the signal back) to the **edge**, a human filing an issue prompted by the
model (sounding 4); and shape the intake so a well-formed report is the easy path, not a free-text blob
(sounding 1). Close the loop: triage → land in this repo → re-publish with a version bump → tell
reporters what changed (a CHANGELOG / release note), because people report again only if the first
report visibly mattered.

**Build items:** the `.github/ISSUE_TEMPLATE/plumb-report.yml` issue form and the SKILL.md self-capture
line landed in PR #6 (2026-07-25). The maintainer-side consumption procedure follows.

## Processing an incoming report

The intake channels above put a triage-ready report in the issue tracker; this section is how the loop
actually closes. Run it from a session with this repo as the working directory: the triage reads this
file, and a landing edits SKILL.md / DOGFOOD-LOG / JOURNEY, all here. The plumb skill loads from its
symlink; the model does the drafting and the human holds the merge gate.

1. **Open it.** `gh issue view <n>`. The form auto-labels the report `plumb`. Treat it as a *claim*, not
   ground truth: a well-filed report pre-answers the lane check and coverage-vs-wording (its two
   dropdowns), which moves you past the two cheap triage steps, not past verification.
2. **Triage it** by the Triage protocol above (lane check → coverage vs execution → verify the miss is
   real). The load-bearing step is the last: reconstruct the reporter's case and *run* it to confirm
   plumb should have caught it. A report you only reason about is un-verified.
3. **Land or decline**, per that protocol's coverage-vs-execution split: a *coverage gap* becomes a
   candidate new sounding (reopen nomination), a *wording gap* adds the instance to a sounding's
   Smell/Move, an *application lapse* is a watch (one instance is not a landing), and *out of lane, or
   plumb was right* is no change at all. A landing is a branch + PR editing SKILL.md, a DOGFOOD-LOG
   entry, and a JOURNEY beat with honest who-caught-it.
4. **Close the loop** (the last line of Signal intake above): merge, then *reply to the reporter* with
   what changed or why not, and on a landing bump the version and add a CHANGELOG line. Even a decline
   gets an explanation. (Versioning and CHANGELOG mechanics: the publishing runbook, #2.)

The report is a reputation-plausible claim like any other ("plumb missed X"), so the human who holds
ground truth verifies and merges while the model fetches, triages, constructs-and-runs, and drafts the
branch. This is the same human-in-the-loop that caught the model throughout the build.

## Files in this skill

- [SKILL.md](SKILL.md): the live skill (10 grouped soundings / 19 facets + reinforcement map + Working notes).
- [EXAMPLES.md](EXAMPLES.md): one worked example per facet (a real trigger + its move, sourced from the
  dogfood log; zero invented), the human-facing companion to SKILL.md's Smell/Move spine. Landed 2026-07-23.
- [REFERENCES.md](REFERENCES.md): the verified bibliography, one entry per sounding (primary source + why
  it maps), the Correct-by-Construction cross-link, and honest parks for soundings 7/8/10. Every citation
  fetched or confirmed, not recalled (the skill's own sounding 6 on its own docs). Landed 2026-07-23 (Stage 4).
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
