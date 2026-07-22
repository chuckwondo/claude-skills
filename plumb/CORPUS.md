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

- **Size**: ~10 runs, balanced **5 `generated` + 5 real**, review mode. The generated
  half is small-module/small-diff reviews; the **real half is whole-repo audits** (four
  planned: 2 Python + 2 non-Python, pydantic deferred; see the 2026-07-20 scope decision
  under Batch progress). Run incrementally: a 2 to 3
  run *pilot* first, to validate the entry format and see whether the coverage-audit
  candidates fire at all, then complete the batch.
- **Target spread** (deliberately hit empty cells, and *mix generated with real*): at
  least 4 languages; at least 3 shapes including one `frontend-ui`; at least 5 `poor`; a
  **balanced provenance mix**, roughly half `generated` and half real
  (`external-raw` / `external-reviewed`), so neither the self-plumbed bias nor the
  LLM-smell bias dominates; at least 2 `brownfield`; the real runs are whole-repo
  audits (superseding the earlier "at least 1"; see Batch progress), which exercise the
  brownfield stance, cf. the zarr entry.
- **Generated vs real is itself a signal**, not just volume: generated code carries its
  *own* smell profile (verbose, stringly-typed, God-functions, defensive over-checking)
  distinct from human bad code (drift, copy-paste divergence, framework anti-patterns,
  premature abstraction). A coverage-audit candidate that fires hot on `generated` but
  cold on real repos is suspect as an LLM artifact; one that fires on both is a real
  gap. Read the `generated` vs `external-raw` columns against each other.
- **Scope guardrail**: generated runs stay a diff or a small module; the real runs
  are whole-repo audits (expensive, one per turn). Time-box each.
- **Log**: the normal entry plus the `Corpus:` and `Unhomed:` lines. Mark the batch so
  it can be analyzed as a group.

### Batch progress (pilot done 2026-07-20; real half rescoped to whole-repo audits 2026-07-20)

**Scope decision (2026-07-20).** The *real* half of the batch is **whole-repo audits**, not
single-module reviews: **2 Python** (earthaccess, seeded; and developmentseed/titiler-cmr, a
**mock-heavy** repo picked to hit the testability-without-mocks cell the self-corpus
suppresses to ~zero) + **2 non-Python** (my picks). **pydantic is deferred** (clean-*prior*
specificity control, 23k LOC, low marginal info now; its `color.py` seed stays as a module
data point, and a full audit runs only if saturation is not reached) and **rasterio is
dropped** (a second Python-library fire-source is volume in an already-filled cell). Capping
Python at 2 follows the saturation logic: the three candidate Python repos all live in the
saturated `python · library` cell, so diversity (non-Python, plus the mock axis) outvalues a
third Python library. The *generated* half stays small-module/small-diff (the cost
guardrail). This supersedes the earlier "at least 1 whole-repo audit" floor. Audits are
breadth-first and leverage-ranked (zarr-style top-N across the repo), one repo per turn
(expensive).

**Quality tags are a-priori priors, not audit results.** Per this file's own definition,
quality is assigned *coarse and a-priori*, so `clean`/`mixed`/`poor` on a repo is a
*hypothesis the audit tests*, never a verified property. Do not pre-assign a repo a role
("specificity control" vs "fire-source") from its prior: quiet-vs-loud is an **output** of
the audit. A `clean`-tagged repo whose audit stays quiet *earns* the control reading; one
that lights up *refutes its own prior*, itself a result. (Caught 2026-07-20: an earlier draft
called pydantic a clean control from reputation + one deprecated module, reasoning from the
prior as if the audit had run. It had not.)

**The two module runs already done are seeds, not standalone real entries.** earthaccess
`auth.py` and pydantic `color.py` are the first ranked findings of their repo's audit; their
per-module tallies are **provisional** until the whole-repo audit lands.

| # | Slot | Status |
| --- | --- | --- |
| gen 1 | TS/React dashboard (small module) | done (pilot) |
| gen 2 | Java service (small module) | done |
| gen 3 | Go CLI (small module) | **DONE 2026-07-21** (`spend` expense-tracker CLI, generated, built + RAN on go1.26.4). Zero new unhomed: **saturation survives the language flip**. Headline = 2's fail-fast Boundary (misplaced fail/return seam, `log.Fatal` in store vs `os.Exit` in main). The `_`-discard "must-consume" candidate folds into 1 (designer) + 3 (consumer); it drives one refinement: **sounding 3's compiler-checked-exhaustiveness premise is language-dependent and absent for Go error-values** (`go vet` clean on all discards). `0`-as-unknown sentinel recurred (echoes titiler-cmr real-2). |
| gen 4 | Rust or C# module (small module) | todo |
| gen 5 | Node/JS backend (small module) | todo |
| real 1 | earthaccess whole-repo audit (Python, mixed/brownfield) | **DONE 2026-07-21** @ `bbbced0b` (audit the `earthaccess-dev` fork; `nsidc/earthaccess` is deprecated per the maintainer). `mixed` prior confirmed; CQS + temporal-coupling + primitive-obsession + sound-typing all fired real; **zero new unhomed** (saturation) |
| real 2 | developmentseed/titiler-cmr whole-repo audit (Python, **mock-heavy**, external) | **DONE 2026-07-21** @ `5101ef06`. `mixed` prior confirmed (reverse polarity: quiet-typed-core + loud-orchestration-rim, mirror of earthaccess). testability-without-mocks fired **and resolved as fully derivative of 6** (135 mocks → 4 reached-for effects: global cache, inline sync/async Client, `datetime.now`, `np.random`); recommend fold-not-promote. Headline `temporal: str` unparsed sum (primitive-obsession 3rd real positive, new shape) + `0`-as-unknown size-guard bypass (both **run**-confirmed). Candidate set read as clean CONTRAST vs earthaccess (CQS/temporal-coupling strong there, quiet here; recoverable/unrecoverable classified both models, opposite verdicts). **Zero new unhomed** (saturation holds across a model-quality flip) |
| real 4 | non-Python: **Rust app** (ownership + exhaustive match / sounding 1+3) | **DONE 2026-07-21**: `CompileNix/rust-simple-httpd` @ `a3dc5244` (~2045 Rust LOC / 9 files, educational from-scratch HTTP/1.1 server), built + RAN on cargo 1.90. Chose it by *measuring* roughness (45 unwrap/expect + 14 panic-family = `mixed`/`poor` prior) after rejecting `obstore` for a clean prior (low-power saturation test). **Zero new unhomed: saturation holds across a language flip on EXTERNAL messy code** (the load-bearing test gen-3 couldn't give). Headline = 2's Boundary (panics buried in worker/tcp; Rust escalates via mutex poisoning into a cascade, a new blast-radius mechanism); config draws the same seam right (Result to a raise at main, RAN). #2 = no `Request`/`Response`/`Method`/`Status` type, server discards the request and always returns 200 (RAN; compiler warns `unused request_body`). #3 = dead 413 guard (`bytes_body_read` never written) = defeated-resource-guard family, 3rd corpus recurrence. must-consume got its Rust **enforced-but-opted-out** datum (`let _ =`/`.unwrap()`/`Default`), completes the gen-3 pair; still folds into 1+3. |
| ~~real 3~~ deferred | non-Python: external **Go service** (error-values / sounding 2) | **deferred/dropped 2026-07-21**: gen-3 (generated Go) already covered the Go / error-values / sounding-2 cell and hit saturation, so an external Go audit is now volume in a touched cell (same call as rasterio). Revisit only if a later run raises a Go-relevant question. |
| backup | `fromscratchcode/cairo` (Axum-inspired Rust framework, ~1735 LOC / 17 files) | **held for a future real Rust repo**: richer *architectural* surface (routing/extractors, soundings 8/10/6), the coupling/framework flavor vs rust-simple-httpd's error-values flavor. `obstore` (clean prior) also remains available as a specificity control if wanted. |
| deferred | pydantic (clean-prior control, 23k LOC) | `color.py` seed retained; full audit only if saturation not reached |
| dropped | rasterio | 2nd Python-library fire-source, a filled cell |

**Recommended next order:** ~~Gate: complete the LANDSCAPE second canon pass first~~
**DONE 2026-07-21** (see LANDSCAPE "Second pass: un-walked canon"): candidate set now also
carries **CQS** (Tier-1, deductive + earthaccess unhomed fire) and a broadened Tier-2
**temporal coupling / illegal transitions**; the rest of the un-walked canon folded or went
off-axis with reasons (near-saturation, CQS the single escape). A follow-on **faithful CxC
sweep** (against the real companion guide, not the first pass's proxy citations) nominated
**recoverable-vs-unrecoverable invariants** (Tier-2) and corroborated immutability + sound-typing.
Nomination is complete; promotion §A and combines §C still gate on batch data. **The audits
should now also probe for CQS, temporal coupling, and recoverable-vs-unrecoverable.**
**earthaccess (real-1) is DONE @ `bbbced0b` (2026-07-21): all three new candidates fired real,
CQS strongest (multiple in-repo fires), and it produced zero new unhomed candidates — a
saturation signal that nomination is near-complete, so the remaining runs test ranking/promotion,
not nomination.**
**titiler-cmr (real-2) is DONE @ `5101ef06` (2026-07-21): the mock cell delivered its verdict —
testability-without-mocks fires but is fully derivative of sounding 6 (fold, don't promote); the
candidate set read as a clean CONTRAST against earthaccess (specificity, not repetition); still
zero new unhomed (saturation holds across a model-quality flip).**
**gen-3 (generated Go CLI) is DONE 2026-07-21: the first non-Python run, and saturation survived the
*language* flip: zero new unhomed, sounding 2 homed Go's error-values natively (its fail-fast Boundary
drove the headline), and the one Go-specific candidate (the `_`-discard "must-consume" gap) folded into
1 + 3 while refining 3 (its compiler-checked-exhaustiveness premise is absent for Go error-values).**
**real-4 (rust-simple-httpd) is DONE 2026-07-21: saturation held across a language flip on EXTERNAL messy
Rust, zero new unhomed.** The must-consume candidate got its Rust enforced-but-opted-out datum, completing
the gen-3 Go/Rust pair (Go can't enforce; Rust enforces but has idiomatic opt-outs `let _ =`/`.unwrap()`/`Default`),
and Rust supplied a new blast-radius mechanism for 2's Boundary (mutex poisoning cascades a buried panic). The
defeated-resource-guard family recurred a 3rd time (unwired variable, vs titiler/gen-3 sentinels).
Next, the batch is near its stopping rule: four external/real audits (earthaccess, titiler, gen-3-generated-Go,
real-4-Rust) all zero-new across quality AND language. Remaining optional cheap runs: **gen-4** (Rust or C#
small module) and **gen-5** (Node/JS backend), which test *ranking* on filled/cheap cells, not further
nomination. A future real Rust repo could use the held `cairo` backup (framework/coupling flavor) or `obstore`
(clean specificity control). Each repo's `clean`/`mixed`/`poor` prior is confirmed or refuted by its own audit
(real-4 confirmed `mixed` by measuring roughness at *selection* time, the upstream analog of role-as-output).
**Stopping rule:** theoretical saturation across diverse cells (see The analysis output), not
a target count and not statistical significance.
**Pilot/seed conclusions (provisional).** primitive-obsession fired on generated (TS, Java) +
real (earthaccess `auth.py`); on pydantic `color.py` (one deprecated module) it correctly did
NOT fire (`h_units: str` closed by the leverage trace), a specificity data point at the *module*
level, not yet a repo-level claim. sound-typing fired on real. immutability is corpus-dependent:
standalone (leaked collection / mutable value) on generated, fused into 1 (lifecycle) or 5
(duplicated derived state) on real OO code. testability-without-mocks fired on mock-heavy Java,
fully a consequence of 6. All held out of §A pending the five audits.

## The analysis output

**DONE 2026-07-22.** The batch hit its stopping rule (four external/real audits, zero new
`Unhomed:` each, across quality and language) and the stratified read is written into
[TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md) **§C-batch**: sounding × provenance,
directional. Outcome: three bias-suppressed promotions (primitive-obsession, sound-typing,
CQS → SKILL soundings 18/19/20), two folds-on-the-distinctness-axis (testability→6,
immutability→1+10), the must-consume Go/Rust pair folded into 1+3 with a sounding-3 note,
temporal-coupling kept as a rider on 1, recoverable/unrecoverable kept as a meta-router,
and no cut. gen-4/gen-5 skipped as volume in filled cells. The spec below is retained as
the method of record.

After the batch, produce a **stratified signal read**, not a statistical frequency
table: sounding × provenance (and × quality), reported as *directional* (fired / did not
fire / fired-but-parked), never as a rate with an implied denominator.

**Why not statistical (decided 2026-07-20).** The questions this batch asks are existence
and contrast, not estimation: "does sounding X *ever* fire off the self-plumbed corpus?"
(one counterexample settles it), "is X hot on `poor` and quiet on `clean`?" (a few per
side show the pattern), "does a smell recur in `Unhomed:` with no home?" (saturation, not
frequency). A real fire-*rate* with confidence would need tens of repos *per cell* (dozens
of cells, so hundreds to thousands of audits), and even then it is one rater (me) scoring
soundings I also designed: correlated subjective judgments, not independent measurements,
so a significance number would be false precision, the same sin as reading module-counts
as frequencies. **We do not chase statistical.** The stopping rule is **theoretical
saturation across diverse cells**: keep adding *different* cells (empty-cell-first, per the
sourcing recipe) until a new audit stops producing new `Unhomed:` candidates and each
sounding has at least one clear off-self fire-or-not. Stop per-region when discovery dries
up, not at a target N; diversity (a new language/shape) outvalues volume (another repo in
a filled cell). If genuine frequencies are ever wanted, the only honest path is
**automation** (plumb as a mechanical pass over hundreds of repos, machine-counted), a
separate project with a different cost structure, out of scope for hand-run dogfooding.

The money comparison stays `self-plumbed` vs `external-raw` / `generated`:

- cold in `self-plumbed`, hot elsewhere → **bias-suppressed**; keep it, it is
  high-value on the target user's code (this is the correction that retracts the
  "testability fires ×1, fold it" verdict).
- cold in **both** → a genuine cut candidate.

Feed the stratified read back into TIGHTENING-SIGNALS.md §C, and any recurring
`Unhomed:` into a candidate new sounding for §A.

## Entry template

```text
- **YYYY-MM-DD: <repo> <what>** (mode; how sourced).
  Corpus: <provenance> · <quality> · <language> · <shape> · <maturity>
  Fired: <soundings + headlines>.
  Unhomed: <candidate gaps, or none>.
  <the usual narrative + "New signals for the tightening pass">.
```
