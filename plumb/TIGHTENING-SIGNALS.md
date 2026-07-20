# Plumb: tightening-pass signal ledger

*A consolidated, deduplicated harvest of the "New signals for the tightening pass" scattered
across [DOGFOOD-LOG.md](DOGFOOD-LOG.md) (fully harvested 07-07 → 07-20). The log is the empirical
record; this is the decision-ready index into it. **The
edits live in SKILL.md**: this file indexes signals and now tracks their landing status, it does not
perform them. It exists so the next pass (and the eventual combine) can act from one
ranked view instead of re-reading 1200 lines.*

*Citations use the log's own shorthand (`#14`, `#37`, `zarr`, `07-07`, …). Sounding numbers are the
**current** post-2026-07-08 scheme; the one exception is 07-07's headline, logged as "15" pre-split =
today's **16**. Corroboration count = distinct entries that produced the signal.*

---

## A. Land-ready operating rules (ranked by leverage)

Well-corroborated signals that change *behavior/notes*, not the sounding count: safe to land into
SKILL.md whenever green-lit, independent of the combine. Each names a concrete target.

### A1. "Affirmed" is not "closed": discharge is an action, not an argument *(×15+, the sharpest; landed in two passes)*
The only two logged **misses** were soundings *named but not run*: `#90` (diff pass affirmed the 5
fix landed, never swept the new code for a *fresh* 5 → code-review caught it) and `#41` (both passes
*named* the clamp-divergence under 5×16 and argued it "bounded/negligible" → never built the
maximizing input → code-review caught a false-reject on ordinary equatorial reads). `#99` and `#62`
are the positive inverse: the same 16 findings **constructed and run**, catching a fractional-second
rounding divergence (`#99`) and falsifying a subagent's code-read (`#62`) that reasoning had missed.
- **Corroboration:** `#90`, `#41`, `#99`, `#62` (all 2026-07-13/14), `#130` (07-16, the positive
  inverse again and the widest surface yet: four unverified claims in one run, three of them the
  project's own), `#131` (07-17, under **maximal** pressure: a self-authored plan re-probed three
  times, every pass falsifying the author's own clean read). **07-18 → 07-20, ×9 more, all
  self-authored guide/diff runs:** `#65` (over-reached the *resolution* of a correctly-run edge), `#137`
  and `#138` (run the *excluded* case, and the downstream *consumer* pre-code), `#139` (hunt the
  un-swept ground), `#109` and `#153` (the verification code and the dependency version-line are
  themselves un-run claims), `#147` (resolve the value, not its description).
- **Sub-rules it carries:** (a) affirming a sounding *landed* is the cue to hunt that sounding's
  **other** instances in the diff, not to close it out (`#90`); (b) a "bounded/negligible" park on a
  co-fire is **un-earned** until the maximizing input has been run (`#41`); (c) 16 can find *an* edge
  and still miss the **load-bearing** one: prefer the edge that breaks the assumption the design
  *rests on* (a claim written into a comment is a standing 16 target) (`#41`); (d) only a run
  survives confirmation bias when the reviewer is the author/champion, extended by `#62` to a
  **subagent's** authoritative-sounding code-trace (a code-read is still reasoning until run);
  (e) the un-earned verdict runs in **both directions**, and the thing that lies can be a **proxy**
  rather than an argument: (a)–(d) all argue a concern *away* ("bounded", "the fix landed"), but a
  stand-in artifact can equally argue one *in*: a hand-built struct substituted for the real
  `NdArray` overstated a perf payoff by ~5x (1.34x vs the real member's 1.07x) and made a
  dead idea look worth pursuing, and it was caught by a glaring arithmetic anomaly rather than by
  method (`07-16`, **not a review run**, author's own miss). The defect is neither optimism nor
  pessimism about the verdict: it is substituting an argument *or a proxy* for a run of the real
  thing, whichever way the verdict points.
  (f) the un-earned claim is often a **citation**, and the document that lies is as likely to be the
  project's own as the diff's: `#130` ran four to ground in one review: a PR's "§6.1.1 MUST" (the
  spec says **MAY**, and the wording originated in the project's *own issue*, faithfully transcribed
  by the contributor), a corpus manifest header asserting it covered "every code" (three short, and
  unenforced, so it had rotted silently), an ADR README's own "append-only" rule (not the rule the
  repo actually follows), and the *reviewer's* "44 references" (really 22 insertions/22 deletions,
  taken from a diffstat skim and caught only by checking before publishing: into the very document
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
  (h) the run target is **wider than the input under review**: run the *excluded* case (a green
  exclusion proves the filter fires, not that its stated *reason* holds: a correct filter can carry a
  false why, `#137`), and run the downstream *consumer*, which already exists and whose
  crash-vs-silent-repair-vs-reject profile ranks the planned rules by leverage *before* code is written
  (`#138`, shapely): this is what makes §16 runnable in guide mode.
  (i) the discharge hunts the ground the **last sweep skipped**, not the cases already green: a re-run
  of the affirmed set is confirmation bias in a lab coat (`#139`).
  (j) §16 turns on the **verification code itself**: in a known-trap domain (int64 datetime overflow,
  float epsilon, timezone math) the tool reached for to check the boundary is subject to the same trap
: the overflow-detector silently overflowed twice before it was right (`#109`).
  (k) a "better design" verdict is unearned until run on the **oldest supported environment / the whole
  version line** below a boundary, since a design's viability can live in a dependency version (`#109`,
  `#153`; ties §7 to the uv-minimum-versions skill as the oracle).
  (l) the claim run need not be **code**: a docstring, a narrative `.md` nothing executes, a test's
  predicate copied from the code it guards (blind to that predicate going stale), a `# pragma: no cover`
: each an un-run assertion, and stale `.md` prose is the top risk after a decision *reverses* because
  nothing compiles it (`#147`, `#147-impl`, `#153`).
  (m) **resolve the value, don't reason about its description**: ADR-0018 reasoned about "the default"
  as an abstraction and recorded a tier backwards; resolving that default to the concrete `("composite",)`
  it produces flipped the answer a year later (`#147`).
  **Provenance across (h)–(m):** the author under-ran in every one; the discharge's real trigger was an
  *external* prompt (the user's question, the reviewee's principle), corroborating (d): a self-authored
  design does not reliably run its own claims even when the skill says to (`#65`, `#109`, `#153`).
- **Landed (two passes).** First pass (2026-07-14, `e6b540f`): 16's Move sharpened to *construct-and-run*
  and the "Affirmed is not closed" Working note added (sub-rules a–d + e's both-directions framing).
  Second pass (2026-07-20): (h)–(m) folded into 16's Move and the same note, the run target is wider
  than the input (excluded case / consumer / check-itself / oldest environment), the discharge hunts
  un-swept ground, the claim need not be code, and resolve-the-value-not-its-description. **Still
  queued:** (f) a citation is a claim (routes through sounding 12) and (g) build the breaking input by
  *decoding bytes*, not a literal: both harvested pre-07-17, deferred to the next pass.

### A2. Both altitudes, now *three* (guide / dialogue / diff), sharpened into sub-cases *(×16, most-developed theme)*
The existing "run plumb at both altitudes" note (SKILL.md:286–290) is corroborated but under-specified.
The log has fractured it into distinct, nameable sub-cases:
- **Different flaws** (plan vs diff catch genuinely different defects): `#14`, `#37`, `#77`.
- **Confirmatory diff = a *positive* signal about plan thoroughness**, not a wasted pass: don't read
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
- **Sequencing:** run the diff pass *after* code-review and its fixes, a correctness fix can
  introduce structural debt plumb then catches (`#37`); and plan-review judges the plan's *stated
  shape*, so some errors are only legible once code exists (`#77`'s wrong `is not None` instruction).
- **A third altitude, guide mode, and the load-bearing move often lands in the *design dialogue*
  between the altitudes, not the guide questions themselves** (`#113` the guide→plan→diff sequence;
  `#147` the tier reversal that reversed ADR-0018 came from the reviewer's pushback *after* the guide
  pass, not from the guide walk).
- **Guide → build → diff, each earning its keep on a *different* finding** (`#138`, the first full pair
  in the log: guide headline = leverage ranked by *running the downstream consumer* pre-code; diff
  headline = a misdiagnosis only the built code's run exposed; `#139`/`#109`/`#153` the same arc on bug
  fixes, guide reshaping the ticket before code, the diff hunting the edges the earlier sweep skipped).
- **Corroboration:** `#14`, `#37`, `#69`, `#44`, `#18`, `#77`, `#92`, `#90`, `#94`, `#41`, `#131`,
  `#113`, `#65`, `#138`, `#147`, `#147-impl`, `#139`, `#109`, `#153`.
- **Proposed target:** expand the SKILL.md:286 note into these bullets, or a short "Three altitudes
  (guide / dialogue / diff)" subsection.

### A3. Sounding 12 = verify the *source*, and let it turn on your own claims *(×12+)*
12 is doing far more work than "grade proportionally." Documented facets:
- **Dual role / forcing function:** "can't cite it" is *itself* the finding that forces the fetch
  (`#37`, `#69`, `#77`).
- **Turns on the wielder's own asserted claims** (assert-from-memory), with the user as enforcer
  (`#18`, `#69`, `#77`).
- **Can *invert* the ranking, not just confirm:** verifying a mechanism a design cantilevers off
  dissolved a false headline and surfaced the true one (`#21` `@import`).
- **Bind the review's own substrate: pin the exact source revision/SHA under review** (`zarr`; the
  log calls this "the strongest actionable skill gap this audit produced": a finding is incomplete
  without the exact revision it is against).
- **Extends to a *quantitative* claim vs its measurement source:** `#99` ("~3-4x" → 1.5x), `#62`
  (287µs was an API-composition artifact, not a double-parse).
- **Verify can *close* a suspected finding, not only sharpen a real one:** `#62` (`_has_spec_timezone`
  is spec-correct, not over-lenient).
- **Open the source the diff *implements*, not only the authority it names: the over-claim is often
  UPSTREAM of the diff** (`#130`). 12's Smell list reads as though the reviewee over-claims ("'the
  spec says MUST' without opening it"), but `#130`'s docstring was *faithful to its source*: the
  fabricated "§6.1.1 MUST" came from the project's **own issue**, and the outside contributor
  transcribed it correctly. A diff can conform perfectly to a bad citation: the citation-shaped
  form of plumb's standing stance that conforming to bad precedent is itself a finding. First logged
  run whose correct fix-home was an **issue body**. Same run: the manifest header and the ADR
  README's own rule were likewise unverified project prose, so the rule generalizes past specs to
  *any* in-repo document a diff or a reviewer leans on.
- **The source governs the type's *shape*, not only the response's strength** (`#139`): fetching
  domain-types.md verbatim showed a composite type permits *alternatives* (`[t,x,y,z]` **or**
  `[t,x,y]`), which a single `tuple[str, ...]` cannot represent; the issue's one-line paraphrase was a
  keystroke from being encoded as that single-tuple field, which would have false-positived a
  conformant 4-D document. 12 is usually invoked for *severity*; here the spec governed the field's
  *type*. Verify the *shape* against the source, not the ticket's summary of it.
- **Ground a contract/doc in the *intended* behavior; reword only if the intent itself is wrong**
  (`#65`): a public description states intent, and a tracked, fixable bug that deviates belongs in the
  tracker + a pinning test + the implementation-level docstring, not in a reworded contract (rewording
  enshrines the defect and drifts when the fix lands). Discriminator vs `#37`, where the deviation was
  a permanent property the design does not intend to fix, so the doc *was* correctly reworded.
- **Corroboration:** `#37`, `#69`, `#18`, `#77`, `#21`, `zarr`, `#74`, `#99`, `#62`, `#130`, `#139`, `#65`.
- **✔ Landed (2026-07-20):** into sounding 12's Smell + Move (SKILL.md:183): the pin-the-revision rider; the
  "quantitative claim vs its measurement" and "verify can *close* a finding" facets; the upstream rider
  (*open the source the diff implements, the issue / ADR / header it was written from, not only the
  external authority it cites; a faithful diff over a false source puts the fix upstream*); the
  **shape** rider (the source governs the field's *type*, not only severity); and the doc-grounding
  rider (ground a contract in intended behavior, reword only if the intent is wrong).

### A4. Sounding 5 has a resolution *taxonomy*: the reflexive "extract to one home" is one of five
Sounding 5 is the dominant headline and its fix is *not* always dedup. The log has enumerated five
distinct resolutions (kept in Section D below with cites). The single most land-ready piece is the
**Boundary line** already fully drafted in the log (`#77`, DOGFOOD-LOG.md:492–508): *similar-looking
idioms encoding **different** decisions are not a 5 violation: pin each with a test, don't merge.*
- **✔ Landed** (2026-07-14, pass 1): the Boundary line is in sounding 5 (SKILL.md:106), beside its
  `[combine? with 6, 14]` marker.
- **New don't-dedup sub-cases (07-18 → 07-19), candidates for a *second* sounding-5 landing** (they
  join the five in Section D):
  - **un-driftable constant** (`#142`, `#137`): same decision in N places is dedup debt only if the
    knowledge can *drift*; a fixed spec constant (`len*2`, the default `(name,)`) written twice is one
    immutable fact, and a shared helper is a ponytail-1 wrapper, not one-source-of-truth.
  - **lossy-for-purpose** (`#137`): the tempting shared helper *flattens* a distinction the second
    consumer needs (`coordinate_identifiers` returns `(name,)` for *both* the violation and the
    conformant-omitted case, hiding the present-vs-absent distinction the detect exists to draw). A4's
    "N sources wearing one coat," inverted: the coat is *lossy* for the second reader.
  - **type-integrity / the sharing *mechanism* is in scope for 5** (`#142`): constructing a domain type
    to harvest one method, when that forces fabricating its other required fields (a *located* finding
    with no location), is a type-abuse the "reduce duplication" instinct hides; the duplication is the
    cheaper honesty. Can trip 4/10.
  - **false-symmetry lookup** (`#147-impl`): a `{"tuple": 1, "polygon": 2}[dt]` floor dict is one coat
    over two different sources (present-at-all vs an RFC magic number); split into one message per real
    requirement, caught at design-of-the-check time.

### A5. When sounding 1's ideal is *unreachable*, reach for the enforcing test, not a comment *(×1, clean)*
`#77`: the guard gradient is type-level (make `if not x` a type error) > **test** (fails on the
regression) > comment (only informs). When the top rung is closed by the language, drop to a test that
*enforces*, never settle at a comment.
- **Proposed target:** Working note, or a rider on sounding 1 (SKILL.md:67).

### A6. A park's reason can be *scope*, not unreachability; its discharge is a filed follow-up *(×3)*
`#129`: the highest-leverage finding was `subset.py`'s bare `IndexError` on the exact input the new
`validate()` rule flags. It was **reachable** (confirmed by running the *public* `isel()`, not the
private helper first probed) and load-bearing, yet correctly **parked**: the path to a consumer
exists, so the current fix-vs-park reason (SKILL.md:281–284) does not apply. It parked because the fix
lives outside the change's agreed **scope** (`#129` scoped the work to the `validate()` rule; subset's
repair, drop vs. diagnostic-raise, is a separate decision that may want an ADR). The discharge was a
**routed, traceable issue (#142)**: an *action* (cf. A1's "a discharge is an action, not an
argument"), not a note that rots. Distinct from `#44`-commit-1's park, which flagged a better-shape
contrast on the incumbent sibling; here the subject is a reachable crash and the boundary is scope.
- **Corroborated (×3):** `#138` (the diff-review's whole value was one run-surfaced park routed to new
  issue #147) and `#139` (spun off docs follow-up #151); park-to-filed-issue is now the log's standard
  park discharge.
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

### A8. A decision that reverses turns prose into lies; grep the prose, ranked by what no build executes *(×3)*
`#147`/`#147-impl`/`#139`: after a tier reversal (moving a check to construction made an
omitted-composite state unrepresentable), every doc that *described handling* the now-impossible path
became a stale contradiction (`concepts.md` asserted the removed guard was "over-strict, removed by
`#131`," the inverse of the ship). Nothing compiles a stale `.md`, so no checker flags it; a deliberate
grep of the prose was the only catch. Rank stale-artifact risk by what no build executes: narrative
`.md` (top) > docstrings (doctested by `pytest --doctest-modules`) > code (typechecked/tested). And a
reversal invalidates not only docs but *sibling issues* that leaned on the old behavior (`#139`: the
issue's own Constraints cited a case a same-day merge had just made unreachable), so check a ticket's
premises against HEAD.
- **Proposed target:** a Working note under faithfulness / one-source-of-truth, or a rider on sounding
  7. Adjacent to A3 (a stale doc is an unverified source) and A1(l) (prose is an un-run claim); the
  distinct core is *a reversal is the trigger, and prose is the least-checked artifact*.

### A9. Run a *sibling* implementation to find the true shape, not only to settle a detail *(×2)*
`#109`/`#153`: when one path of an N-path design is buggy, run its siblings on the same input *before*
adopting the buggy path's own proposed fix. `#109`: the issue proposed routing out-of-range dates to
cftime, but running the *pandas* bridge showed it widens the datetime64 unit instead, revealing Option
B (widen the unit), a shape neither the issue nor the ADR considered, and reframing the fix from a
*calendar* matter to a *resolution* one. `#153`: in *guide* mode, a three-line run of the three temporal
paths side by side falsified the ticket's premise ("the bridges already flatten to naive-UTC") before
any code. A sibling that already handles the input *names the shape*.
- **Proposed target:** a Working note, or fold into the guide-mode note (guide mode must *run* the
  siblings, not reason from the issue). Sharper than A3's "run a neighbor library to settle a detail"
  (`#139` msgspec): here the sibling reveals the whole design, not a detail.

### A10. Sound narrowing: a predicate stricter than the type it narrows is `TypeGuard`, never `TypeIs` *(×1, clean)*
`#138`: pushing `_is_polygon_array` from a cast to a type guard, `TypeIs` was *unsound* because the
predicate is stricter than the narrowed type (it returns False for an empty `()`, which IS a `tuple`),
so `TypeIs`'s negative-branch narrowing would wrongly strip `tuple` from the else branch; only the
positive-only `TypeGuard` is correct. A sounding-1 (sound typing) facet: when a predicate narrows a
type, ask whether it is *stricter* than that type; if so, only a positive-only guard is sound.
- **Proposed target:** a rider on sounding 1, or a Working note. Niche (×1) but a real soundness trap,
  not style.

---

## B. Combine dossier: merge candidates (assembled, NOT executed)

The concrete co-fire couplings the log observed, as the evidence base for the eventual 19→~10–12
combine. **Nothing here is acted on.** The striking result: sounding **5 is the empirical hub**, and
its *real* co-fire neighbors (1, 3, 16, 15, 10, 13) are **not** the ones its current
`[combine? with 6, 14]` marker names.

| Co-fire | What it means | Cites | vs current SKILL.md marker |
|---|---|---|---|
| **4 × 16** | a name/type that lies, surfaced by a breaking edge | 07-07 | n/a |
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

## C. Cut / keep evidence (fire-frequency): answers REFINEMENT.md's "which never fire → cut"

**Empirical answer: no sounding *never* fired.** So the naive "cut the dead ones" has no clean
targets, but activity is very uneven, which is the real input to the combine.

- **Heavily exercised, unambiguously earn keep** (headlined a real finding, repeatedly): **5**
  (dominant: headline in `#14`,`#37`,`#69`,`#44`,`#92`,`#94`,`#90`,`#99`,`#62`), **16**, **12**,
  **1**, **3**, **7**, **13**.
- **"First headline" markers the log tracks as distinctness/keep evidence:** 3 @ `#69`, 7 @ `#44`,
  8/9/17 @ `zarr` (prior-headline set was 4, 5, 12, 15, 16). Each first-headline is logged precisely
  as "this sounding earns its keep / is distinct."
- **Moderately exercised:** 4, 6, 8, 9, 10, 11, 15 (6 and 11 fire most often as *affirmations*, the
  design got them right, which the log counts as real output, not silence).
- **Lightly exercised: the genuine combine questions:**
  - **14** (trivial-common-path): fired **only ever as an affirmation** (`#14`, `#69`), never drove a
    finding. The closest thing to a cut candidate, but "affirm-only" ≠ "never fires."
  - **17** (locality of behavior): fired **exactly once** (`zarr`, as an 8/9/17 co-fire); the newest
    and least-exercised. Its keep-vs-merge-into-9/10 is the most open call.
  - **2** (outcomes-as-values): a few findings (`#74` Raw-reject, `#18` explicit `Skipped`) plus its
    LANDSCAPE-driven Boundary line; load-bearing but rarely a standalone headline.

---

## D. Boundary-sharpening notes

**The sounding-5 resolution taxonomy** (the log's richest single thread; keep all five for the combine):
1. **Real dup → extract to one home.** `#14` (`_ROOT_TYPES = get_args`), `#69` (lift `coordinate_systems`).
2. **Real dup taxing a hot path → *deliberate* dup + an enforced differential test.** `#99`
   (single-sourcing would put a regex back on the path the change exists to remove).
3. **Not dup: different codomains → don't unify; make the design doc argue from the codomain root,
   not a cost tradeoff.** `#62` (the "inverted" 5: three parsers with different return types; the ADR
   argument was the headline, not the code).
4. **Subtractive: 5 fires on dup a plan is *about to add*; fix is "build less."** `#94` (take the one
   semantic discriminator, defer the workload-gated rest; co-fires 15).
5. **Boundary: similar-looking idioms encoding *different* decisions are not a 5 violation; pin with a
   test, don't merge.** `#77` (full Boundary text drafted at DOGFOOD-LOG.md:492–508).
   - New **smell shape** to add to 5's list: *a predicate/classifier re-implemented inline in a new
     helper instead of calling the existing total one*: the tell is a fresh `isinstance(...) and
     foo(...)` chain duplicating an existing classifier (`#90`).
   - Generated-artifact flavor: *a generator asserting conclusions about its own output* is a 5/
     circularity smell (`#74`, `#18`).

**Skill-partition with code-review / ponytail-review** (the standing self-check: mostly holds clean):
- **NaN routing rule of thumb:** NaN-in-*values* → code-review; NaN admitted by a *boundary that
  claims to produce trusted values* → plumb (`#44` vs `#69`).
- **Redundant coverage that paid off:** code-review's *reuse* angle caught a 5 (plumb's own turf)
  that plumb missed: twice, same day (`#90`, `#41`). The correctness bug itself is code-review's; the
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

**Scope beyond code** (each a distinct altitude plumb transferred to cleanly: for the combine's
"where does plumb apply" framing): plans before code (`#14`,`#69`,`#99`); a documentation/information
architecture (`#21`: illegal-state analog = "one fact, two canonical homes that can drift"); a
measurement/benchmark artifact where 12 *is* the correctness condition (`#18`,`#74`); an ADR's
*argument structure* (`#62`); brownfield third-party audit where "judge against the ideal" is
load-bearing in a way greenfield can't exercise, and a self-flagging TODO is corroboration, not a
reason to defer (`zarr`). Organic firing with no `/plumb` invocation, under a competing mode, on live
design decisions: candidate triggers "would X work / does this give us Y for free / better ergonomics
for Z" (`#74`/`#18`).

---

## E. Doc inconsistencies

1. **✔ Fixed (2026-07-14): stale term-swap.** The "One-word swap if you prefer `gauges`" offer was
   deleted from SKILL.md; it contradicted REFINEMENT.md's locked *soundings* decision, which lists
   "gauges" among the rejected names.
2. **✔ Fixed: changelog pointer.** LANDSCAPE.md now correctly names DOGFOOD-LOG.md as the append-only
   history (it had called REFINEMENT.md that); REFINEMENT.md is rewrite-in-place with no changelog.
3. **Open: 17 soundings vs a "~19" target with three unlanded additions.** SKILL.md defines **17**
   numbered soundings. The original eight-additions round sanctioned three standalone additions not yet
   in SKILL.md, immutability, testability-without-mocks, and sound typing (now recorded in
   REFINEMENT.md's "Candidate superset (superseded by the ledger)" section). Not a bug, but the combine
   starts from 17, not 19: reconcile the target count first.

---

## F. Recommended landing order

**✔ Landed:** A1 (two passes, 2026-07-14 a–e + 2026-07-20 h–m; (f) citation and (g) decode-bytes still
queued) · A3 (sounding-12 verify-the-source riders: pin-revision, shape, upstream, doc-grounding,
verify-can-close, 2026-07-20) · A4 (sounding-5 Boundary line, 2026-07-14) · E1 + E2 (the two doc fixes,
2026-07-14).

**Queued, ranked by leverage:**

1. **A2: three altitudes (guide / dialogue / diff)** (expand the SKILL.md:286 note). Cheap,
   high-corroboration (×16).
2. **A8: prose-drift after a reversal** (Working note under faithfulness / one-source-of-truth). ×3.
3. **A9: run the sibling to find the shape** (Working note, or into the guide-mode note). ×2.
4. **A5: sounding-1 unreachable-ideal → test** (small rider or Working note). ×1.
5. **A6: park-can-be-scope, discharged as a filed follow-up** (third park class on the fix-vs-park
   note, SKILL.md:280–284). ×3.
6. **A7: leverage measured against the charter** (second trace target on the leverage note,
   SKILL.md:277). ×1.
7. **A10: sound narrowing, TypeGuard vs TypeIs** (rider on sounding 1). ×1, niche.
8. **A1 (f)/(g): citation-is-a-claim + decode-the-bytes** (still queued from the first harvest).

*The combine pass (Section B/C) stays deferred per REFINEMENT.md's "let usage drive, not armchair
debate": this ledger is its input, not its trigger. Reconcile the ~19→17 count (§E3) before combining.*
