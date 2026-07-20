# Plumb: corpus design and dogfood-entry protocol

*Why this exists: the dogfood log is drawn almost entirely from two Python libraries
written **by the plumb author while applying plumb**. That is a self-selecting sample.
A sounding fires rarely not because it is unimportant but because this corpus
pre-avoids the practice it would catch (testability-without-mocks fires ~never because
we never write a mock to begin with). Fire-frequency therefore measures*
`importance × how often THIS corpus commits the sin`*, and the second factor is near
zero for the bad-practice soundings. To read fire-frequency as a value signal we must
stratify it by corpus; to find missing soundings we must run plumb on code we did not
write. This file defines the tags that make stratification possible and the plan for a
broader corpus.*

## What the current corpus is

Almost one cell: `self-plumbed · clean · python`, shape `library` (covjson-msgspec) or
`service` (titiler-covjson). Every fire-frequency number in
[TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md) §C is conditional on that cell. **Do
not cut a sounding on that data** (§C cut/keep is frozen until the corpus is
representative): a sounding cold here may be the hottest one on a mock-heavy or
brownfield repo. Retro-tagging the bulk is unnecessary busywork, but **two review runs
are the exceptions, and the only existing non-`self` data**, so name them: the
**zarr-python audit** (`external-reviewed · mixed · python · library · brownfield`, a
whole-repo audit) and **PR #130** (`external-raw · mixed · python · library · active`,
an outside contributor's diff, which is *why* it fired differently). Those two are the
seeds of the stratified comparison; everything else is the one cell. New entries are
tagged from the start.

## The `Corpus:` tag (one line per new entry)

Five dimensions, `·`-separated, controlled vocabulary so it greps cleanly:

`Corpus: <provenance> · <quality> · <language> · <shape> · <maturity>`

- **provenance** (the bias axis, the one that matters most): `self-plumbed` (authored
  by us with plumb applied) · `self-legacy` (our own pre-plumb code) ·
  `external-reviewed` (someone else's, merged or maintained) · `external-raw` (someone
  else's, no design review: a contributor PR, an abandoned repo) · `generated`
  (LLM-written, no review).
- **quality** (coarse, a-priori): `clean · mixed · poor`.
- **language**: `python · typescript · go · rust · java · csharp · ...`.
- **shape**: `library · application · service · cli · frontend-ui · data-pipeline · infra`.
- **maturity**: `greenfield · active · brownfield` (brownfield = years of drift, where
  "conforming to bad precedent is itself a finding" actually gets exercised).

Example: `Corpus: generated · poor · typescript · frontend-ui · greenfield`.

## The `Unhomed:` line (the gap instrument)

The inductive gap-finder. On each entry, record any finding that had **no clean
sounding home**, got shoehorned, or was a structural concern that code-review or
ponytail caught only because plumb has no probe for it:

`Unhomed: <one line per candidate gap, or "none">`

A pattern that recurs in `Unhomed:` across the broader corpus is a candidate **new
sounding**. On the current clean corpus this line is almost always "none": that
silence is the selection bias, not evidence of completeness.

## Corpus-design axes: sample the empty cells

Sample for the axes that generate *different* structural smells, not for convenience.
The current corpus fills one cell, so nearly any non-self, non-clean, non-Python,
non-library run adds information. Priority cells, each exercising soundings the current
corpus cannot:

- **`poor` quality, any provenance**: the point of the whole exercise: the target
  user's code.
- **`java` / `csharp`, oo, mutation-heavy**: exercises immutability and
  testability-without-mocks, the two candidates we structurally cannot observe now.
- **`go`**: error-values, no exceptions: stresses sounding 2 and the fail-fast Boundary.
- **`rust`**: ownership + exhaustive match: stresses 1 (illegal states) and 3 (totality).
- **`frontend-ui`**: state management is a smell family plumb has never seen.
- **`brownfield`**: exercises the judge-against-the-ideal stance head-on.
- **`generated`**: an endless, reproducible source of plumb's target smells.
- **`poor` or `generated` Python (same-language control)**: not for language diversity
  (Python is our saturated cell) but to hold language *constant* while provenance and
  quality vary, so the `self-plumbed · clean` vs `external-raw · poor` comparison is not
  confounded by a language switch. One such cell keeps the stratified table honest.

## Sourcing recipes (cheap, un-pre-corrected code)

- **generated**: ask an LLM to build a small app "fast, no review" → instant
  `generated · poor`. Reproducible; you pick the domain and language.
- **external-raw**: contributor PRs to our own repos (already seen: #130 fired
  differently on an outside diff); abandoned or low-activity repos; course / homework /
  tutorial-starter code.
- **refactoring before/after**: the "before" is *labeled* bad code with named smells
  (Fowler, refactoring.guru), ground truth for whether plumb catches what a human named.
- **self-legacy**: our own pre-plumb commits.
- **other-language messy**: small, known-rough repos in Go / Rust / Java / TS.

## The first adversarial batch (concrete plan)

One focused batch, not forty entries. Goal: populate the empty cells enough to see
which soundings are bias-suppressed and to make the `Unhomed:` line trigger.

- **Size**: 6 to 10 real `/plumb` runs, review mode.
- **Target spread** (deliberately hit empty cells, and *mix generated with real*): at
  least 4 languages; at least 3 shapes including one `frontend-ui`; at least 5 `poor`; a
  **balanced provenance mix**, roughly half `generated` and half real
  (`external-raw` / `external-reviewed`), so neither the self-plumbed bias nor the
  LLM-smell bias dominates; at least 2 `brownfield`; at least 1 whole-repo audit on a
  messy *real* repo (audits exercise the brownfield stance, cf. the zarr entry).
- **Generated vs real is itself a signal**, not just volume: generated code carries its
  *own* smell profile (verbose, stringly-typed, God-functions, defensive over-checking)
  distinct from human bad code (drift, copy-paste divergence, framework anti-patterns,
  premature abstraction). A coverage-audit candidate that fires hot on `generated` but
  cold on real repos is suspect as an LLM artifact; one that fires on both is a real
  gap. Read the `generated` vs `external-raw` columns against each other.
- **Scope guardrail**: keep most runs to a diff or a small module (whole-repo audits
  are expensive); time-box each.
- **Log**: the normal entry plus the `Corpus:` and `Unhomed:` lines. Mark the batch so
  it can be analyzed as a group.

## The analysis output

After the batch, produce a **stratified** fire-frequency table: sounding × provenance
(and × quality). The money comparison is `self-plumbed` vs `external-raw` / `generated`:

- cold in `self-plumbed`, hot elsewhere → **bias-suppressed**; keep it, it is
  high-value on the target user's code (this is the correction that retracts the
  "testability fires ×1, fold it" verdict).
- cold in **both** → a genuine cut candidate.

Feed the stratified table back into TIGHTENING-SIGNALS.md §C, and any recurring
`Unhomed:` into a candidate new sounding for §A.

## Entry template

```text
- **YYYY-MM-DD: <repo> <what>** (mode; how sourced).
  Corpus: <provenance> · <quality> · <language> · <shape> · <maturity>
  Fired: <soundings + headlines>.
  Unhomed: <candidate gaps, or none>.
  <the usual narrative + "New signals for the tightening pass">.
```
