# Plumb — tightening-pass signal ledger

*A consolidated, deduplicated harvest of the "New signals for the tightening pass" scattered
across [DOGFOOD-LOG.md](DOGFOOD-LOG.md) (33 entries, 2026-07-07 → 07-17). The log is the empirical
record; this is the decision-ready index into it. **This file lands nothing** — no soundings
merged, no SKILL.md edits. It exists so the next pass (and the eventual combine) can act from one
ranked view instead of re-reading 1200 lines.*

*Citations use the log's own shorthand (`#14`, `#37`, `zarr`, `07-07`, …). Sounding numbers are the
**current** post-2026-07-08 scheme; the one exception is 07-07's headline, logged as "15" pre-split =
today's **16**. Corroboration count = distinct entries that produced the signal.*

---

## A. Land-ready operating rules (ranked by leverage)

Well-corroborated signals that change *behavior/notes*, not the sounding count — safe to land into
SKILL.md whenever green-lit, independent of the combine. Each names a concrete target.

### A1. "Affirmed" is not "closed" — discharge is an action, not an argument *(×6, the sharpest)*
The only two logged **misses** were soundings *named but not run*: `#90` (diff pass affirmed the 5
fix landed, never swept the new code for a *fresh* 5 → code-review caught it) and `#41` (both passes
*named* the clamp-divergence under 5×16 and argued it "bounded/negligible" → never built the
maximizing input → code-review caught a false-reject on ordinary equatorial reads). `#99` and `#62`
are the positive inverse: the same 16 findings **constructed and run**, catching a fractional-second
rounding divergence (`#99`) and falsifying a subagent's code-read (`#62`) that reasoning had missed.
- **Corroboration:** `#90`, `#41`, `#99`, `#62` (all 2026-07-13/14), `#130` (07-16, the positive
  inverse again and the widest surface yet: four unverified claims in one run, three of them the
  project's own), `#131` (07-17, under **maximal** pressure: a self-authored plan re-probed three
  times, every pass falsifying the author's own clean read).
- **Sub-rules it carries:** (a) affirming a sounding *landed* is the cue to hunt that sounding's
  **other** instances in the diff, not to close it out (`#90`); (b) a "bounded/negligible" park on a
  co-fire is **un-earned** until the maximizing input has been run (`#41`); (c) 16 can find *an* edge
  and still miss the **load-bearing** one — prefer the edge that breaks the assumption the design
  *rests on* (a claim written into a comment is a standing 16 target) (`#41`); (d) only a run
  survives confirmation bias when the reviewer is the author/champion — extended by `#62` to a
  **subagent's** authoritative-sounding code-trace (a code-read is still reasoning until run);
  (e) the un-earned verdict runs in **both directions**, and the thing that lies can be a **proxy**
  rather than an argument — (a)–(d) all argue a concern *away* ("bounded", "the fix landed"), but a
  stand-in artifact can equally argue one *in*: a hand-built struct substituted for the real
  `NdArray` overstated a perf payoff by ~5x (1.34x vs the real member's 1.07x) and made a
  dead idea look worth pursuing, and it was caught by a glaring arithmetic anomaly rather than by
  method (`07-16`, **not a review run**, author's own miss). The defect is neither optimism nor
  pessimism about the verdict: it is substituting an argument *or a proxy* for a run of the real
  thing, whichever way the verdict points.
  (f) the un-earned claim is often a **citation**, and the document that lies is as likely to be the
  project's own as the diff's — `#130` ran four to ground in one review: a PR's "§6.1.1 MUST" (the
  spec says **MAY**, and the wording originated in the project's *own issue*, faithfully transcribed
  by the contributor), a corpus manifest header asserting it covered "every code" (three short, and
  unenforced, so it had rotted silently), an ADR README's own "append-only" rule (not the rule the
  repo actually follows), and the *reviewer's* "44 references" (really 22 insertions/22 deletions,
  taken from a diffstat skim and caught only by checking before publishing — into the very document
  about treating the record honestly). Sounding 12 already forbids asserting an authority from
  memory, so (f) is less a new rule than the **surface** A1 applies to: a citation is a claim, and
  opening it is the discharge. Distinct from (a)–(e) in that nothing here was a *verdict* or a
  *measurement*; the lie was a quoted source, and the tests were green throughout because none of it
  is test-catchable.
  (g) construct the breaking input the way it **arrives**, not the way that is convenient: for a
  decoder or wire type, build the case by *decoding bytes*, since a hand-typed literal can carry
  runtime types the wire never produces (a decoded `tuple[Any, ...]` with `list` interiors) and hide
  an edge the literal cannot reach (`#131` pass 3: a "tuple all the way down" polygon check that fired
  on every legal wire-decoded polygon yet passed an all-tuples literal fixture).
- **Proposed target:** sharpen sounding 16's **Move** (SKILL.md:209) to require *construct-and-run*,
  and add one Working note (SKILL.md:265–290): *"'Affirmed'/'bounded'/'the fix landed'/'the
  benchmark says' is a claim, not a discharge; the discharge is an action — sweep the new code,
  build and run the breaking input, or measure the real artifact rather than a stand-in — and it is
  mandatory when you authored what you're reviewing. A claim can flatter as readily as it
  dismisses."* Note the wording must cover **both** directions per sub-rule (e); the narrow
  "argued it away" framing would not have caught `07-16`. Fold sub-rule (g) into 16's Move as well:
  for a decoder, build the breaking input by *decoding bytes*, not a hand-typed literal (`#131`).

### A2. Both-altitudes, sharpened into its sub-cases *(×11, most-developed theme)*
The existing "run plumb at both altitudes" note (SKILL.md:286–290) is corroborated but under-specified.
The log has fractured it into distinct, nameable sub-cases:
- **Different flaws** (plan vs diff catch genuinely different defects): `#14`, `#37`, `#77`.
- **Confirmatory diff = a *positive* signal about plan thoroughness**, not a wasted pass — don't read
  a clean diff-pass as "plumb found nothing, skip it": `#69`, `#44` commit 1, `#94`.
- **Diff can find a *higher* bonus sounding** the plan fix produced without claiming it (re-rank the
  landed fix against *all* soundings): `#92` (plan headline 5/10 → diff headline 1).
- **Diff can *miss* fresh debt the implementation introduced**, the inverse of the above: `#90`.
- **Same-altitude re-probe finds more** (re-running the *same* pass, not switching altitude, hunts a
  different breaking edge each time; a clean pass is weak evidence when the reviewer is the author):
  `#131`, a self-authored plan reviewed three times, surfaced three disjoint failure classes (a
  spec-depth misread, then `str` duck-typing the arity check, then a wire-vs-literal decode-type), all
  of which literal-built unit tests would have passed.
- **Emerging shape:** a *subtractive* plan fix ("build less") → confirmatory diff; an *additive* plan
  fix (new representation) → diff may find a dividend: `#94` vs `#92`.
- **Sequencing:** run the diff pass *after* code-review and its fixes — a correctness fix can
  introduce structural debt plumb then catches (`#37`); and plan-review judges the plan's *stated
  shape*, so some errors are only legible once code exists (`#77`'s wrong `is not None` instruction).
- **Corroboration:** `#14`, `#37`, `#69`, `#44`, `#18`, `#77`, `#92`, `#90`, `#94`, `#41`, `#131`.
- **Proposed target:** expand the SKILL.md:286 note into these bullets, or a short "Two altitudes"
  subsection.

### A3. Sounding 12 = verify the *source*, and let it turn on your own claims *(×10)*
12 is doing far more work than "grade proportionally." Documented facets:
- **Dual role / forcing function:** "can't cite it" is *itself* the finding that forces the fetch
  (`#37`, `#69`, `#77`).
- **Turns on the wielder's own asserted claims** (assert-from-memory), with the user as enforcer
  (`#18`, `#69`, `#77`).
- **Can *invert* the ranking, not just confirm:** verifying a mechanism a design cantilevers off
  dissolved a false headline and surfaced the true one (`#21` `@import`).
- **Bind the review's own substrate — pin the exact source revision/SHA under review** (`zarr`; the
  log calls this "the strongest actionable skill gap this audit produced" — a finding is incomplete
  without the exact revision it is against).
- **Extends to a *quantitative* claim vs its measurement source:** `#99` ("~3-4x" → 1.5x), `#62`
  (287µs was an API-composition artifact, not a double-parse).
- **Verify can *close* a suspected finding, not only sharpen a real one:** `#62` (`_has_spec_timezone`
  is spec-correct, not over-lenient).
- **Open the source the diff *implements*, not only the authority it names — the over-claim is often
  UPSTREAM of the diff** (`#130`). 12's Smell list reads as though the reviewee over-claims ("'the
  spec says MUST' without opening it"), but `#130`'s docstring was *faithful to its source*: the
  fabricated "§6.1.1 MUST" came from the project's **own issue**, and the outside contributor
  transcribed it correctly. A diff can conform perfectly to a bad citation — the citation-shaped
  form of plumb's standing stance that conforming to bad precedent is itself a finding. First logged
  run whose correct fix-home was an **issue body**. Same run: the manifest header and the ADR
  README's own rule were likewise unverified project prose, so the rule generalizes past specs to
  *any* in-repo document a diff or a reviewer leans on.
- **Corroboration:** `#37`, `#69`, `#18`, `#77`, `#21`, `zarr`, `#74`, `#99`, `#62`, `#130`.
- **Proposed target:** sounding 12 (SKILL.md:175) — add the pin-the-revision rider and the
  "quantitative claim vs its measurement" + "verify can close a finding" facets to its Move, plus
  the upstream rider: *open the source the diff implements (the issue, the ADR, the header it was
  written from), not only the external authority it cites; a faithful diff over a false source puts
  the fix upstream.*

### A4. Sounding 5 has a resolution *taxonomy* — the reflexive "extract to one home" is one of five
Sounding 5 is the dominant headline and its fix is *not* always dedup. The log has enumerated five
distinct resolutions (kept in Section D below with cites). The single most land-ready piece is the
**Boundary line** already fully drafted in the log (`#77`, DOGFOOD-LOG.md:492–508): *similar-looking
idioms encoding **different** decisions are not a 5 violation — pin each with a test, don't merge.*
- **Proposed target:** add the drafted **Boundary** line to sounding 5 (SKILL.md:101), beside its
  existing `[combine? with 6, 14]` marker. (Verbatim text is in the log; no authoring needed.)

### A5. When sounding 1's ideal is *unreachable*, reach for the enforcing test, not a comment *(×1, clean)*
`#77`: the guard gradient is type-level (make `if not x` a type error) > **test** (fails on the
regression) > comment (only informs). When the top rung is closed by the language, drop to a test that
*enforces*, never settle at a comment.
- **Proposed target:** Working note, or a rider on sounding 1 (SKILL.md:67).

### A6. A park's reason can be *scope*, not unreachability; its discharge is a filed follow-up *(×1, clean)*
`#129`: the highest-leverage finding was `subset.py`'s bare `IndexError` on the exact input the new
`validate()` rule flags. It was **reachable** (confirmed by running the *public* `isel()`, not the
private helper first probed) and load-bearing, yet correctly **parked**: the path to a consumer
exists, so the current fix-vs-park reason (SKILL.md:281–284) does not apply. It parked because the fix
lives outside the change's agreed **scope** (`#129` scoped the work to the `validate()` rule; subset's
repair, drop vs. diagnostic-raise, is a separate decision that may want an ADR). The discharge was a
**routed, traceable issue (#142)**: an *action* (cf. A1's "a discharge is an action, not an
argument"), not a note that rots. Distinct from `#44`-commit-1's park, which flagged a better-shape
contrast on the incumbent sibling; here the subject is a reachable crash and the boundary is scope.
- **Proposed target:** the fix-vs-park Working note (SKILL.md:280–284): add "out-of-scope, routed to a
  follow-up" as a third park class beside "unreachable / sole trusted constructor," and state its
  discharge is a *filed issue* (links A1's discharge-is-an-action rule).

### A7. Measure leverage against the work's *charter*, not only a downstream consumer *(×1, clean)*
`#129`: every prior headline traced a flaw to what *consumes* it downstream; this one traced the diff
against the stated goal of the work it closes. `#129`'s own motivation named the `subset` `IndexError`
as "a poor diagnosis of a malformed document," and the feature shipped only the *detection* half (the
`validate()` rule), leaving the crash. The leverage question became "does the change deliver its
charter, or only part of it?" A diff can be structurally *true in what it does* and still
under-deliver the issue it claims to close, and the half-delivered charter is the finding. Adjacent to
A3/`#130` but inverted: there the issue the diff *implemented* was the source of a false citation;
here the issue is the yardstick for *completeness*, not a lie.
- **Proposed target:** the leverage Working note (SKILL.md:277): add a second trace target beside "what
  *consumes* it," the work's **charter** (the issue's own motivation). A half-delivered charter is a
  leverage finding even when the delivered half is flawless.

---

## B. Combine dossier — merge candidates (assembled, NOT executed)

The concrete co-fire couplings the log observed, as the evidence base for the eventual 19→~10–12
combine. **Nothing here is acted on.** The striking result: sounding **5 is the empirical hub**, and
its *real* co-fire neighbors (1, 3, 16, 15, 10, 13) are **not** the ones its current
`[combine? with 6, 14]` marker names.

| Co-fire | What it means | Cites | vs current SKILL.md marker |
|---|---|---|---|
| **4 × 16** | a name/type that lies, surfaced by a breaking edge | 07-07 | — |
| **1 × 5** | add a union member → silently omitted; the drift's leverage is one-source | `#14`, `#92` | 5 marks `[6,14]`, not 1 |
| **3 × 5** | "add a case → silently skipped" totality smell whose leverage is a one-source drift; log says "watch whether 3 and 5 should be cross-flagged" | `#69` | neither marks the other |
| **7 × 1** | unfaithful shape forces an invented axis + guards + defensive comment | `#44` | matches 7`[1]`, 1`[…,7]` |
| **5 × 16** | 16 is *how you discharge* a 5-divergence (run the maximizing input) | `#41` | not marked |
| **5 × 1** | in-band sentinel for empty/root fails 5 *and* 1 at once; one representation (`()`) fixes both | `#92` | not marked |
| **8 × 9 × 17** | coupling cycle papered by a lazy import + feature-envy | `zarr` | matches 8`[9,10]`, 17`[9,10]` |
| **12 × 13** | diff two independently-written sibling types against a shared external authority (asymmetry invisible per-class) | `zarr` G1 | not marked; log proposes a 12↔13 cross-flag |
| **6 × 12** | sans-IO: a SHOULD conditional on an unfetchable remote domain → drop | `#37` | 6 marks `[5,8]` |
| **15 × 9** | a one-way-door signature resolved by the cohesion argument | `#69` | not marked |
| **12 × 8** | one artifact, two audiences (human vs agent) pulling opposite on the same bytes | `#21` | not marked |
| **5 × 15** | subtractive 5 (build less) co-fires with reversibility: defer the unproven half | `#94` | 14`[5]` only |
| **5 × 10** | root-representation choice centralizes the format *and* narrows the type | `#92` | not marked |

**Headline for the combine pass:** the `[combine? with N]` markers in SKILL.md were assigned by
*armchair* similarity; the dogfood co-fires are the *usage* evidence REFINEMENT.md asks for, and they
disagree with the markers most sharply around sounding 5. Reconcile marker ↔ observed-co-fire when
the combine runs.

---

## C. Cut / keep evidence (fire-frequency) — answers REFINEMENT.md's "which never fire → cut"

**Empirical answer: no sounding *never* fired.** So the naive "cut the dead ones" has no clean
targets — but activity is very uneven, which is the real input to the combine.

- **Heavily exercised, unambiguously earn keep** (headlined a real finding, repeatedly): **5**
  (dominant — headline in `#14`,`#37`,`#69`,`#44`,`#92`,`#94`,`#90`,`#99`,`#62`), **16**, **12**,
  **1**, **3**, **7**, **13**.
- **"First headline" markers the log tracks as distinctness/keep evidence:** 3 @ `#69`, 7 @ `#44`,
  8/9/17 @ `zarr` (prior-headline set was 4, 5, 12, 15, 16). Each first-headline is logged precisely
  as "this sounding earns its keep / is distinct."
- **Moderately exercised:** 4, 6, 8, 9, 10, 11, 15 (6 and 11 fire most often as *affirmations* — the
  design got them right — which the log counts as real output, not silence).
- **Lightly exercised — the genuine combine questions:**
  - **14** (trivial-common-path) — fired **only ever as an affirmation** (`#14`, `#69`), never drove a
    finding. The closest thing to a cut candidate, but "affirm-only" ≠ "never fires."
  - **17** (locality of behavior) — fired **exactly once** (`zarr`, as an 8/9/17 co-fire); the newest
    and least-exercised. Its keep-vs-merge-into-9/10 is the most open call.
  - **2** (outcomes-as-values) — a few findings (`#74` Raw-reject, `#18` explicit `Skipped`) plus its
    LANDSCAPE-driven Boundary line; load-bearing but rarely a standalone headline.

---

## D. Boundary-sharpening notes

**The sounding-5 resolution taxonomy** (the log's richest single thread; keep all five for the combine):
1. **Real dup → extract to one home.** `#14` (`_ROOT_TYPES = get_args`), `#69` (lift `coordinate_systems`).
2. **Real dup taxing a hot path → *deliberate* dup + an enforced differential test.** `#99`
   (single-sourcing would put a regex back on the path the change exists to remove).
3. **Not dup — different codomains → don't unify; make the design doc argue from the codomain root,
   not a cost tradeoff.** `#62` (the "inverted" 5: three parsers with different return types; the ADR
   argument was the headline, not the code).
4. **Subtractive — 5 fires on dup a plan is *about to add*; fix is "build less."** `#94` (take the one
   semantic discriminator, defer the workload-gated rest; co-fires 15).
5. **Boundary — similar-looking idioms encoding *different* decisions are not a 5 violation; pin with a
   test, don't merge.** `#77` (full Boundary text drafted at DOGFOOD-LOG.md:492–508).
   - New **smell shape** to add to 5's list: *a predicate/classifier re-implemented inline in a new
     helper instead of calling the existing total one* — the tell is a fresh `isinstance(...) and
     foo(...)` chain duplicating an existing classifier (`#90`).
   - Generated-artifact flavor: *a generator asserting conclusions about its own output* is a 5/
     circularity smell (`#74`, `#18`).

**Skill-partition with code-review / ponytail-review** (the standing self-check — mostly holds clean):
- **NaN routing rule of thumb:** NaN-in-*values* → code-review; NaN admitted by a *boundary that
  claims to produce trusted values* → plumb (`#44` vs `#69`).
- **Redundant coverage that paid off:** code-review's *reuse* angle caught a 5 (plumb's own turf)
  that plumb missed — twice, same day (`#90`, `#41`). The correctness bug itself is code-review's; the
  plumb signal is *depth-of-discharge*, not a missing sounding.
- **Reversibility (15) routes the "is this over-care?" question to ponytail-review by name** rather
  than manufacturing a plumb finding (`#21` three-rounds-of-IA).
- Clean deferrals logged where plumb correctly stayed out of ponytail/code-review's lane: `#90`
  (`_temporal_keys` single-caller wrapper), `#69`/`#44`/`#94` (various).
- **Both-directions handoff, corroborated:** the partition is not a one-way dump. plumb defers a
  correctness class → code-review finds the leak → the fix rises back to *shared infrastructure*, a
  structural/altitude win: `#131` (a `TypeError` leak in `coordinate_identifiers` plumb routed away by
  name, whose shared-`composite_columns` fix was itself the deeper structural improvement),
  corroborating the `07-15` partition entry on a self-authored diff where plumb found only shape.

**Scope beyond code** (each a distinct altitude plumb transferred to cleanly — for the combine's
"where does plumb apply" framing): plans before code (`#14`,`#69`,`#99`); a documentation/information
architecture (`#21` — illegal-state analog = "one fact, two canonical homes that can drift"); a
measurement/benchmark artifact where 12 *is* the correctness condition (`#18`,`#74`); an ADR's
*argument structure* (`#62`); brownfield third-party audit where "judge against the ideal" is
load-bearing in a way greenfield can't exercise, and a self-flagging TODO is corroboration, not a
reason to defer (`zarr`). Organic firing with no `/plumb` invocation, under a competing mode, on live
design decisions — candidate triggers "would X work / does this give us Y for free / better ergonomics
for Z" (`#74`/`#18`).

---

## E. Doc inconsistencies (noted, not fixed)

1. **Stale term-swap.** SKILL.md:51 offers *"One-word swap if you prefer `gauges`"* — but
   REFINEMENT.md:12 records *soundings* as a **locked decision** and lists "gauges" among the
   **rejected** names. Delete the swap offer.
2. **Changelog points at the wrong file.** LANDSCAPE.md:4 calls REFINEMENT.md an *"append-only history
   of internal changes"* and LANDSCAPE.md:183–184 says to log each rescan *"in REFINEMENT.md's
   changelog"* — but REFINEMENT.md is rewrite-in-place and has **no `## Changelog`** section; the
   append-only file is DOGFOOD-LOG.md, and it is **LANDSCAPE.md itself** that carries a `## Changelog`
   (line 186). Repoint the rescan-logging instruction.
3. **17 soundings vs a "~19" target with three unlanded additions.** SKILL.md defines exactly **17**
   numbered soundings. REFINEMENT.md's "eight-additions" verdict (lines 60–68) says *"Add standalone:
   … immutability; testability-without-mocks; sound typing"* — only the FC/IS split (sounding 6) was
   marked DONE. So three sanctioned standalone additions are **not reflected in SKILL.md**. Not a bug,
   but the combine pass starts from 17, not 19 — reconcile the target count first.

---

## F. Recommended landing order (if/when a follow-up pass is green-lit)

Ranked by leverage; the first two address the only two logged *misses*, so they buy the most:

1. **A1 — discharge-is-an-action** (sharpen sounding 16 + one Working note). Highest leverage: closes
   the miss class directly.
2. **A2 — both-altitudes sub-cases** (expand the SKILL.md:286 note). Cheap, high-corroboration.
3. **A4 — sounding-5 Boundary line** (paste the log's drafted text). Zero authoring cost.
4. **A3 — sounding-12 verify-the-source riders** (pin-the-revision + quantitative-claim + can-close).
5. **A5 — sounding-1 unreachable-ideal → test** (small rider or Working note).
6. **A6: park-can-be-scope, discharged as a filed follow-up** (third park class on the fix-vs-park Working note, SKILL.md:280–284). Fresh (×1).
7. **A7: leverage measured against the charter** (second trace target on the leverage Working note, SKILL.md:277). Fresh (×1).
8. **E1/E2 — the two trivial doc fixes** (gauges line; changelog pointer) — land alongside anything.

*The combine pass (Section B/C) stays deferred per REFINEMENT.md's "let usage drive, not armchair
debate" — this ledger is its input, not its trigger.*
