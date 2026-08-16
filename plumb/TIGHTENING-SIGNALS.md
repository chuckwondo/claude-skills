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

> **Count-changing promotions live in §C-batch, not here** (§A is behavior/notes only). Landed
> 2026-07-22 from the batch: **primitive-obsession** (SKILL sounding 18), **sound-typing** (19), **CQS**
> (20), plus the **sounding-3 language-dependence note**. Folds recorded there too (testability→6,
> immutability→1+10, must-consume→1+3, temporal-coupling→rider on 1, recoverable/unrecoverable→router).

### A1. "Affirmed" is not "closed": verifying is an action, not an argument *(×15+, the sharpest; landed in two passes)*
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
  opening it is the verification. Distinct from (a)–(e) in that nothing here was a *verdict* or a
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
  (i) the verification hunts the ground the **last sweep skipped**, not the cases already green: a re-run
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
  **Provenance across (h)–(m):** the author under-ran in every one; the verification's real trigger was an
  *external* prompt (the user's question, the reviewee's principle), corroborating (d): a self-authored
  design does not reliably run its own claims even when the skill says to (`#65`, `#109`, `#153`).
- **Landed (two passes).** First pass (2026-07-14, `e6b540f`): 16's Move sharpened to *construct-and-run*
  and the "Affirmed is not closed" Working note added (sub-rules a–d + e's both-directions framing).
  Second pass (2026-07-20): (h)–(m) folded into 16's Move and the same note, the run target is wider
  than the input (excluded case / consumer / check-itself / oldest environment), the verification hunts
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
  different breaking case each time; a clean pass is weak evidence when the reviewer is the author):
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

### A6. A park's reason can be *scope*, not unreachability; its resolution is a filed follow-up *(×3)*
`#129`: the highest-leverage finding was `subset.py`'s bare `IndexError` on the exact input the new
`validate()` rule flags. It was **reachable** (confirmed by running the *public* `isel()`, not the
private helper first probed) and load-bearing, yet correctly **parked**: the path to a consumer
exists, so the current fix-vs-park reason (SKILL.md:281–284) does not apply. It parked because the fix
lives outside the change's agreed **scope** (`#129` scoped the work to the `validate()` rule; subset's
repair, drop vs. diagnostic-raise, is a separate decision that may want an ADR). The resolution was a
**routed, traceable issue (#142)**: an *action* (cf. A1's "verifying is an action, not an
argument"), not a note that rots. Distinct from `#44`-commit-1's park, which flagged a better-shape
contrast on the incumbent sibling; here the subject is a reachable crash and the boundary is scope.
- **Corroborated (×3):** `#138` (the diff-review's whole value was one run-surfaced park routed to new
  issue #147) and `#139` (spun off docs follow-up #151); park-to-filed-issue is now the log's standard
  park resolution.
- **Proposed target:** the fix-vs-park Working note (SKILL.md:280–284): add "out-of-scope, routed to a
  follow-up" as a third park class beside "unreachable / sole trusted constructor," and state its
  resolution is a *filed issue* (links A1's verifying-is-an-action rule).

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

### A11. Judge-against-the-ideal and positive-masks-negative must fire in *guide* mode, not only review *(judge-against-ideal ×1; positive-masks-negative ×2 as of 2026-07-26; WATCH: application lapse of existing notes, not a coverage gap)*
2026-07-24 virtualizarr-data-pipelines validation run (external CDK template): on an EXTERNAL target the
model twice anchored to the incumbent at *design* altitude, and the user caught both. (1) It recommended a
redesign partly because it "matches how the sample already thinks", the exact thing "judge against the
ideal, not the incumbent" forbids, quoted as a point *in favor*. (2) A per-function-`Protocol` redesign
that fired 2/DRY + 3c *positive* masked a 1a illegal-*sequence* (typestate) it left representable, the same
positive-masks-negative shape #163/#165 landed the review-mode counter-move for. Both notes already exist
(the judge-against-ideal Working note; the positive-masks-negative counter-move landed 2026-07-23), but
both are phrased for *review-mode* (an artifact that exists) and did not fire in *guide-mode* (designing
from scratch), where the incumbent is a sample you consciously depart from yet still anchor to. Provenance
twist: an external target removed the author-under-runs bias, yet the anchor still fired, so the risk is
*incumbent*- and *flattering-read*-specific, not author-specific.
- **Proposed target (HELD, watch):** a guide-mode rider on the judge-against-ideal and
  positive-masks-negative notes: in guide mode, name the *ideal* before the incumbent sample, and when a
  redesign flatters one sounding, ask which sounding it leaves representable. **Not land-ready on ×1:** per
  the MISS-TRIAGE application-lapse branch, a single lapse of an existing note is a salience *watch*, not a
  landing; a second guide-mode lapse confirms the wording is not salient enough at design altitude.
  Corroboration cite: DOGFOOD-LOG 2026-07-24, JOURNEY beat 19. Not in the §F active queue until corroborated.
- **Corroboration (2026-07-26, non-author triage of the virtualizarr PLAN.md run):** a second guide-mode
  instance of the *positive-masks-negative* half (not the judge-against-ideal half): a "two-way door" (9)
  reading masked a 1a/2 illegal-state / DRY flaw on the same additive field and was pulled back only on the
  *refute* pass, never caught proactively. That run's own 2-vs-9 adjudication-cue candidate was DECLINED as a
  standalone landing (first-instance per the recurrence audit; already covered by the SKILL.md:579–583 PMN
  note, so a dedicated cluster-map row would triple-source it) and folded here instead. A11's PMN half now
  stands at ×2 in guide mode; whether that tips it from watch to land-ready is a maintainer call, and its
  landing is a distinct guide-mode rider, not this run's boundary edit (§A13). Cite: DOGFOOD-LOG 2026-07-25
  (virtualizarr PLAN.md) RESOLVED 2026-07-26, JOURNEY beat 25.

### A12. Sound typing fires on an always-raising function annotated with its nominal return type, not `NoReturn` *(×1, LANDED 2026-07-25)*
`#157` `ValidationReport`: a `__bool__` that only raises (a 1a guard making ambiguous truthiness
unrepresentable) was annotated `-> bool`, which lies to the checker: it never returns a bool, so `if report:`
and `bool(report)` stayed green under all four strict checkers and the guard fired only at runtime. The honest
type is `NoReturn`. A 1e *wording* gap, not a coverage gap: 1e's principle ("no lies to the checker") already
covers it, but the Smell list did not name the shape, which is the dual of the existing "`-> Any` that returns
a known type" smell (an annotation that under-claims what it returns rather than over-claiming). Verified
NON-AUTHOR by re-running `mypy --warn-unreachable`: `-> bool` reports "Success: no issues found", `-> NoReturn`
flags the `if report:` body "Statement is unreachable".
- **Landed 2026-07-25:** 1e Smell gains the always-raises / `-> NoReturn` shape; the cluster map gains a
  `1a × 1e` co-fire (a 1a raising-guard is enforced statically only if annotated `NoReturn`). Ecosystem
  precedent (pandas `DataFrame.__bool__ -> NoReturn`) noted but not cited in-skill: the #157 run found its own
  pandas citation wrong twice, so it is left unverified rather than repeated. Corroboration: DOGFOOD-LOG
  2026-07-25 (#157), JOURNEY beat 23.

### A13. Typestate holds only within one process; a compile-time token cannot cross a process or serialization boundary *(×1, LANDED 2026-07-26)*
2026-07-25 virtualizarr-data-pipelines redesign PLAN.md (guide/plan mode): the proposed typestate stages
(`open_store → Store → WriteSession`) make an illegal call order uncompilable *within a process*, but the
pipeline runs as separate AWS entrypoints. A cron-triggered garbage-collection job never receives the
in-memory `Store` token, so it re-derives one through the only constructor available, which opens with
`Repository.open_or_create`; on an absent store that *creates* an empty repository instead of raising
(run-verified against real icechunk), silently re-seeding the exact empty store the typestate was meant to
forbid. A 1a *wording* enrichment, not a coverage gap: 1a fired and 8 co-fired (the two facts that make the
state illegal sit on opposite sides of the process boundary, so no tier sees both), so saturation held; the
principle covered it but neither 1a nor Example A named the process-boundary limit of a compile-time token.
- **Landed 2026-07-26 (non-author triage):** a new EXAMPLES.md Example C (real Python before/after from this
  run's own icechunk fire: `open_or_create` re-seeds vs `open` raise-on-absent), plus a minimal SKILL.md 1a
  qualifier naming *only* the boundary limit (an in-memory token cannot cross a process/serialization
  boundary), NOT the remedy (which would restate 1a's parse-at-the-edge Move and bloat the densest sounding).
  The two novel points: a typestate token dies at the boundary, and non-creators must open fail-closed
  (raise-on-absent), never create-if-absent. The author's proposed delivery (a caveat on the *Java* Example A
  plus a remedy-restating rider) was reshaped by the refute pass. Corroboration: DOGFOOD-LOG 2026-07-25
  (virtualizarr PLAN.md) + its 2026-07-26 RESOLVED line, JOURNEY beat 25.

### A14. MISS-TRIAGE has no disposition for a *confirmed misfire* (a sounding that fired where it should not) *(×0 observed; DECLINED as framed 2026-08-16; WATCH on the narrow form)*
2026-08-16 covjson-msgspec #110 plan run: the render surfaced a 1e *scope* item (a lookup table is a type
lie only when its values are a union of `type[...]` consumed as a type argument, and is sound when the
values are homogeneous and the key type is annotated), observed that it fits neither branch of MISS-TRIAGE
step 2 (not a coverage gap, not a wording gap, because 1e fired and was right), and proposed a third branch
for *misfire-prevention* candidates arriving from a run where plumb was right.
- **DECLINED as framed**, on four checks run against the repo's own history:
  1. **Not novel on the successful-run axis.** §A12 was harvested from a run where plumb *worked* and homed
     cleanly as a wording gap; JOURNEY beat 23 states the case outright (there was no misfire to file). So
     "arrives from a correct run" selects nothing the existing branches cannot already take.
  2. **The specificity apparatus already exists, in three homes.** A per-sounding **Boundary** clause (1e's
     own: an `Any` at a genuine dynamic edge "is parked, not a violation; the fire is an `Any` that
     *defeats a declared type*"); a per-facet **"Specificity: where it correctly stays quiet"** subsection
     in EXAMPLES.md (1e already has one, EXAMPLES.md:585); and corpus-level **specificity controls** in
     CORPUS.md (the pydantic `h_units` correct-negative, DOGFOOD-LOG:1644). A fourth home for the same
     knowledge is the sounding-2 violation §A11's decline turned on.
  3. **The runbook already disposes of the case:** "*out of lane, or plumb was right* is no change at all"
     (REFINEMENT.md, Processing an incoming report, step 3).
  4. **×0 observed instances.** No misfire is recorded anywhere in the log's history (the only hits are
     this run's own "no sounding misfired" and the candidate itself), and the skill is unpublished (issue
     #1 open), so the external misfire channel has by construction delivered nothing. The protocol's own
     rule is that one instance is a watch; zero is not even that.
- **What survives, narrowed (WATCH, not land-ready):** step 2 splits on *did not fire*, so a **confirmed**
  misfire (a fire the reporter disputes and is right about) has no disposition, while Signal intake
  explicitly courts that class as the loudest external channel ("it catches the loud *misfires* (a fire the
  user disputes) far better than the silent *misses*"). The runbook therefore advertises an input its
  triage cannot classify. Draft clause, held until a first real instance or until publication makes the
  channel live: *a sounding that fired where it should not is a **specificity gap**: narrow the Smell or
  sharpen the Boundary, and record the correct-negative in that facet's EXAMPLES.md specificity subsection.*
- **Byproduct, home identified, content edit pending:** the covjson 1e scope item is a *specificity* item,
  and its home is EXAMPLES.md 1e's existing specificity subsection, as a real Python contrast pair from
  merged code (`_PROJECTION` rejected in `to_numpy` versus the annotated `_CONVERTERS` accepted in
  `from_numpy`, one file, with the comment saying why the former cannot share the latter: `range.py:328-330`
  and `range.py:1059-1061`). Not landed here: this triage's author also authored the candidate (beat 26), so
  the gate that reshaped §A13 has not yet been applied to the content edit.
- Cite: DOGFOOD-LOG 2026-08-16 (#110 plan) + its TRIAGED line, JOURNEY beats 26 and 27.

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
| **5 × 16** | 16 is *how you verify* a 5-divergence (run the maximizing input) | `#41` | not marked |
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

> **UNFROZEN (2026-07-22): the corpus is now representative.** The adversarial batch
> reached its stopping rule (theoretical saturation: four external/real audits, earthaccess
> loud-Python, titiler clean-typed-Python, gen-3 error-values-Go, real-4 messy-external-Rust,
> each nominating **zero** new `Unhomed:` candidates, across both the quality and the language
> axis). Fire-frequency can now be read *stratified by provenance* (the money comparison), so the
> cut/keep freeze lifts. **Result: still no clean cut** (no sounding ever failed to fire; even 17
> earned an off-self fire on gen-2). What the stratification delivers is the bias correction the
> freeze protected: three soundings that read "cold" on the self-corpus are **hot off-self**
> (bias-suppressed keeps → promoted), and two candidates that read "keep" **fold** on a distinctness
> axis the money comparison alone cannot see. Full stratified read and every disposition are in
> **§C-batch** below; the historical one-cell caveat that follows is retained for context.

> **FROZEN (2026-07-20, LIFTED 2026-07-22 by §C-batch): do not cut a sounding on this data.** The
> corpus is one cell (`self-plumbed · clean · python · library`), which is author-pre-corrected, so
> fire-frequency measures `importance × how often THIS corpus commits the sin`, and the
> second factor is near zero for the bad-practice soundings (testability-without-mocks
> fires ~never because we never write mocks). A low count here is as likely to be
> selection bias as low value. Cut/keep unfreezes once the corpus is representative and
> fire-frequency can be *stratified* by provenance/quality; see [CORPUS.md](CORPUS.md).
> Merges (co-fire, §B) are less bias-sensitive but still under-sample the cold region.

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
  - **17** (locality of behavior): fired `zarr` (8/9/17 co-fire), **then again off-self** on gen-2
    Java (`describeStatus` feature envy, a real finding). No longer "exactly once"; its
    keep-vs-merge-into-9/10 stays the open combine call (see §C-batch).
  - **2** (outcomes-as-values): a few *self* findings (`#74` Raw-reject, `#18` explicit `Skipped`)
    plus its Boundary line, rarely a standalone *self* headline. **The batch reversed that reading:**
    2 is the dominant headline the moment the corpus is an error-values language (gen-3 Go, real-4
    Rust) or external code (titiler `temporal`, earthaccess collapse) — bias-suppressed as a headline,
    see §C-batch.

### §C-batch: stratified signal read (2026-07-22) — the adversarial-batch analysis output

*Per [CORPUS.md](CORPUS.md) "The analysis output": sounding × provenance, **directional** (fired /
did-not-fire / fired-but-parked / affirm-only), never a rate. Saturation-based, not statistical
(single-rater instrument). Provenance buckets: **self** = the ~40-entry `self-plumbed·clean·python`
cell; **gen** = `generated·poor` (gen-1 TS, gen-2 Java, gen-3 Go); **real** = `external·mixed`
(earthaccess py-lib, titiler py-service, real-4 Rust-service) + the pydantic `clean` seed. Money
comparison: cold-in-self / hot-elsewhere = **bias-suppressed → keep**; cold-in-both = **cut candidate**.*

| sounding / candidate | self | gen | real / external | disposition |
|---|---|---|---|---|
| **2** outcomes-as-values | fired, ~never *headline* | fired (sentinel, bare returns) | **HEADLINE ×4** (gen-3 Go & real-4 Rust Boundary; titiler `temporal`; earthaccess collapse×7) | **keep; bias-suppressed *as a headline*** — cold-headline in self, hot-headline on error-values langs + external. Re-rank up at the combine. |
| **17** locality | fired ×1 (`zarr`) | **fired** (gen-2 feature envy) | — | off-self fire → no longer "×1"; `[combine? 9/10]` call still open |
| **14** trivial-path | affirm-only | did-not-drive | affirm-only (earthaccess shell) | cold-*driving* in both → **merge candidate** (fold into 5 / rider), **not a cut** |
| primitive-obsession | **cold (bias-invisible)** | HOT (TS, Java, Go) | HOT (earthaccess `strategy:str`, titiler `temporal:str`, real-4 no-`Request` type) + correct-negative (pydantic `h_units`) | **bias-suppressed → PROMOTE** (new sounding 18) |
| sound-typing | cold | — | fired ×3 mech (earthaccess return-`Any` / `Literal\|Any` / two-shape); parked-correctly (titiler `Any`-at-edge) | **bias-suppressed → PROMOTE** (new sounding 19), bound vs 3/16 |
| CQS | cold | — | STRONG (earthaccess `_get_credentials`, `__repr__`); near-silent-*contrast* (titiler `bounds`) | **bias-suppressed → PROMOTE** (new sounding 20), bound vs 6/9 |
| immutability | cold-standalone (fuses 1) | standalone (gen-2 leaked `List` / mutable value) + fused | fused (earthaccess→1, pydantic→5) | **FOLD into 1 + 10** — leaked-mutable-collection is its *only* standalone face |
| testability-without-mocks | ~never | consequence-of-6 | **derivative-of-6** (titiler mock cell: 135 mocks → 4 reached-for effects DI removes) | **FOLD into 6** — the mock cell was built to give it a standalone identity and it did not |
| must-consume / `#[must_use]` | n/a | Go **can't-enforce** (gen-3, `go vet` silent) | Rust **enforce-but-opt-out** (real-4 `let _=` / `.unwrap()` / `Default`) | **FOLD into 1** (designer) **+ 3** (consumer); drives the **sounding-3 language note** |
| recoverable vs unrecoverable | n/a | — | classified BOTH models, opposite verdicts (earthaccess dict = wrong; titiler pydantic = right) | **KEEP as a meta-router** (routes to 1 vs 2/11; "fires" by classifying) |
| temporal-coupling | cold | — | fired (earthaccess login-before-use, unenforced by types); silent (titiler, injected) | **KEEP as a rider on 1** (make the illegal *sequence* unrepresentable) |

**Money-comparison verdicts.**

- **Bias-suppressed keeps** (the freeze's whole purpose). primitive-obsession, sound-typing, and CQS
  read cold on the self-corpus *only* because we already model with types / don't lie to the checker /
  don't mix command-and-query; each fires real off-self. All three **promote** (§18–20 in SKILL.md).
  The same pattern re-valued an *existing* sounding: **2's headline-value is bias-suppressed** — we
  write errors-as-values by habit, so 2 seldom headlines self runs, yet it is the dominant headline
  the instant the corpus is an error-values language (Go, Rust) or external code. A method built to
  vet candidates also re-ranks a shipped sounding.
- **No clean cut.** Cold-in-both would be a cut target; nothing is. 14 is the closest (affirm/prescribe-
  only in *both* self and off-self, never drove a finding), so it stays a **combine** (merge-into-5 /
  rider) question, not a cut.
- **The distinctness axis the money comparison cannot see.** Hot-off-self proves a candidate is *real*
  (not an LLM / self-plumbed artifact); it does **not** prove it is a *distinct sounding*. testability
  fired hot on the mock cell (real, not suppressed to zero) yet **folds**, because its *Move is
  identical to 6's* (inject the seams). Two axes, not one: `bias artifact?` (cold/hot) and `distinct
  probe?` (is the Move new?). immutability and must-consume fold on the same second axis (their Moves
  are 1/10 and 1/3). This sharpens CORPUS's money-comparison rule, which as written implies
  hot-elsewhere ⇒ keep; the batch shows hot-elsewhere ⇒ *real*, and distinctness is a separate test.

**§A promotion reviews (the corpus now earns them; each reviewed on specificity, none declined).**

- **primitive-obsession → PROMOTE (sounding 18).** Real positives across two distinct shapes
  (earthaccess `strategy:str` = closed-set-as-string; titiler `temporal:str` = structured-value-as-string;
  real-4 no-`Request`/`Response`/`Method`/`Status` type) + three generated (TS, Java, Go) + the pydantic
  `h_units` **correct-negative** (closed by the leverage trace: a transient regex capture, not a trusted
  domain value). Specificity demonstrated — it does *not* fire on every string-typed closed set, only on
  one a downstream consumer trusts. Distinct from 1 (field *combinations*) and 4 (a name can be exact
  while the *type* stays primitive). Standalone, not a rider on 1.
- **sound-typing → PROMOTE (sounding 19), bound tightly vs 3/16.** Three real mechanisms on earthaccess
  (`login -> Any` return-Any; `Literal[...] | Any` union-collapse; `Mapping[str,str]` two-shape under-spec)
  + titiler's **parked** `Any`-at-a-real-dynamic-edge (specificity: the fire is an `Any` that *defeats* a
  declared type, not one at a genuine xarray/cache boundary). Absorbs A10 (a `TypeIs` predicate stricter
  than its input is unsound; use `TypeGuard`) as its narrowing facet.
- **CQS → PROMOTE (sounding 20), honoring `[bound against 6/9]`.** Strongest real showing on the run
  designed to test it: earthaccess `_get_credentials` (a `get_`-named query mutating four `self` fields
  and returning `bool`) and `DataGranule.__repr__` (a repr that mutates the record). The bound held —
  both are per-method command/query mixing, not architecture (6) or generic cohesion (9). titiler's
  near-silence (only `backend.bounds`, a query with an I/O side effect) is the specificity contrast a
  worthless probe would not show.

**Fold decisions (recorded per step 4, with reasons — not omissions).**

- **testability-without-mocks → 6.** gen-1 (homed under 6), gen-2 (consequence of 6), titiler real-2
  (the decisive mock cell: 135/18/14 mock counts → four reached-for effects — global cache, inline
  sync/async `Client`, `datetime.now`, `np.random` — each removed by the DI the repo already practices
  elsewhere). Present but not independent; fold as 6's test-visible symptom.
- **immutability → 1 + 10.** gen-1 standalone push/mutation; gen-2 **both** (lifecycle fused into 1
  *and* a standalone leaked `List` / mutable `OrderItem`); earthaccess fused into 1; pydantic fused with
  5. The **only standalone face** is the leaked-mutable-collection / mutable-value (gen-2); elsewhere it
  fuses (lifecycle→1, derived-state→5, leaked-rep→10). A lens over 1/10, not a standalone probe.
- **must-consume / `#[must_use]` → 1 + 3.** The gen-3 (Go: no enforcement, `go vet` silent) + real-4
  (Rust: `#[must_use]` warns but is opted out with `let _=` / `.unwrap()` / `Default`) pair: enforcement
  is *language-dependent*, and where the language enforces there are idiomatic opt-outs. Designer-side
  Move is 1 (make an ignored outcome unrepresentable — exactly what `#[must_use]` does); consumer-side is
  3 (handle the case). No new Move → fold; the one residue that IS landed is the sounding-3 note.
- **temporal-coupling → rider on 1.** One real fire (earthaccess login-before-use, enforced only by
  runtime branches/raises, never the type); silent where auth is injected (titiler). The Move is 1's
  pointed at *sequences* (make the illegal *order* unrepresentable — a capability the authed calls
  require). Rider, not a standalone sounding.
- **recoverable vs unrecoverable → keep as a meta-router.** It catches no violation; it *routes*:
  received-authority-with-checkable-grammar (**recoverable**) → a boundary parser / validating
  constructor (1 at the edge, or 2/11); a fact about history/intent/provenance the bytes don't record
  (**unrecoverable**) → construction-control is the only mechanism (1). It classified earthaccess's dict
  model and titiler's pydantic tree to *opposite* verdicts — the router working. Watch it stays a router
  and doesn't collapse into "parse at the boundary" (1).

**Merge/keep calls (§B markers vs observed co-fire, now unfrozen; execution stays the deferred combine).**

- **5 is confirmed the empirical hub**, and the batch adds co-fires that again disagree with its armchair
  `[combine? with 6, 14]` marker: titiler's `temporal:str` root co-fires 2/4/primitive-obsession;
  earthaccess's dict model co-fires 10/7/CQS/primitive-obsession/sound-typing. **Call:** at the combine,
  drive 5's merges from its real neighbors (1, 3, 16, 15, 10, 13, + primitive-obsession); drop the 6/14
  armchair marker as unsupported.
- **primitive-obsession co-fires with 1/2/3/4** on stringly-typed dispatch (earthaccess, gen-1/2/3) — the
  promoted sounding wants tight boundaries against all four at the combine.
- **14 ↔ 5:** the mutual marker is armchair; 14 never co-fired with 5 (14 only affirms the thin-convenience
  shell). **Call:** 14 is a lightly-used keep whose 5-merge is not co-fire-earned; revisit as fold-14-into-
  a-rider on its low *drive*-rate, not on a 5 coupling.
- The full 17 → ~10–12 **combine execution stays deferred** (REFINEMENT item 3): these are the now-decidable
  *calls*; landing the merges (and reconciling the count, §E3) is its own pass. This session deliberately
  *grows* the pre-combine set (three promotions) so the combine runs from the complete evidence-backed set
  rather than pre-suppressing earned probes. Count moved 17 → 20, and the batch **swapped the
  sanctioned-additions membership**: immutability + testability folded OUT, primitive-obsession + CQS in
  (sound-typing landed as already planned) — the §E3 "~19" reconciliation now resolves on evidence, not count.

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
  plumb signal is *depth-of-verification*, not a missing sounding.
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
3. **✔ Resolved (2026-07-22): the count reconciled on evidence.** SKILL.md now defines **20** numbered
   soundings. The original "~19" was 17 + three sanctioned-but-unlanded additions (immutability,
   testability-without-mocks, sound typing); the batch resolved all three on evidence: **immutability
   folded** into 1+10, **testability folded** into 6, **sound typing promoted** (19). The canon audit added
   two more, both promoted: **primitive-obsession** (18) and **CQS** (20). So the combine starts from **20**,
   not a to-be-reconciled count: 17 → 20 pre-combine, then 20 → ~10–12 at the combine (see §C-batch).

---

## F. Recommended landing order

**✔ Landed:** A1 (two passes, 2026-07-14 a–e + 2026-07-20 h–m; (f) citation and (g) decode-bytes still
queued) · A3 (sounding-12 verify-the-source riders: pin-revision, shape, upstream, doc-grounding,
verify-can-close, 2026-07-20) · A4 (sounding-5 Boundary line, 2026-07-14) · E1 + E2 (the two doc fixes,
2026-07-14).

**✔ Landed (2026-07-22, the batch analysis output, count-changing — recorded in §C-batch):** three
promotions into SKILL.md (**18** primitive-obsession, **19** sound-typing, **20** CQS) + the **sounding-3
language-dependence note**. §C cut/keep unfrozen (no cut); folds recorded (testability→6, immutability→1+10,
must-consume→1+3, temporal-coupling→rider-on-1, recoverable/unrecoverable→router).

**✔ Landed (2026-07-22, THE COMBINE — the deferred 20 → ~10–12 execution ran):** SKILL.md restructured to
**10 grouped headlines / 19 facet-Moves**. Method = **group, don't fold**: the batch's distinctness axis
(`is the Move new?`) reused as a *fold-vs-group* test, so a distinct-Move probe may only be *grouped* under a
shared cluster headline (each facet keeps its own Smell/Move), never folded away. Clusters: **1 correct by
construction** (1a illegal-states / 1b domain-types(old 18) / 1c outcomes(old 2) / 1d totality(old 3) / 1e
sound-typing(old 19)); **3 structure & boundaries** (3a coupling(old 8) / 3b encapsulation(old 10) / 3c
cohesion(old 9) / 3d locality(old 17) / 3e CQS(old 20)); **5 faithfulness & round-trip** (5a faithfulness(old
7) / 5b symmetry(old 13)). Standalones: **2** one-source-of-truth(old 5, with old 14 demoted to a rider),
**4** functional-core(old 6), **6** proportional-response(old 12), **7** names(old 4), **8** right-tier(old
11), **9** reversibility(old 15), **10** hunt-the-edge(old 16). The §C-batch merge/keep calls executed as
recorded: 5's armchair `[6,14]` marker dropped, 14 demoted on low *drive*-rate (never a rider on a 5 coupling),
8×9×17 clustered, all `[combine?]` markers retired. Only *fold* beyond the batch's four was none; only
*demotion* was 14. A cross-cluster **reinforcement map** was written (the target-end-state's "how the clusters
reinforce" layer). Count reconciled 20 → **10** as a consequence of grouping, not by targeting a number.

**✔ Landed (2026-07-23, the §A tail begins, JOURNEY beat 18):** **A2** (three altitudes): the
SKILL.md "both altitudes" Working note expanded to *guide / plan / diff*, plus the point that the
load-bearing move often lands in the *design dialogue between* the passes, not the passes
themselves. Also confirmed **A10 already-landed in the combine** (1e carries the TypeGuard-vs-TypeIs
narrowing facet, SKILL.md 1e Smell + Move), marked done with no separate landing.

**Pass stance (ponytail, decided 2026-07-23):** land the ×3+ items as real Working notes; **fold the
×1 items as one-clause riders**, not new bullets, on an already-dense section; **A1(f) dropped** —
sounding 6 already carries "verified, never asserted from memory," so a cross-link would be a note
defending a note. Validation is one external dogfood run *after* the tail lands, not between edits
(saturation closed nomination; these are transcription, see beat 18).

**✔ Landed (2026-07-23, folded into JOURNEY beat 18):** **A8** (reversal-triggered stale-artifact
sweep): a new final Working note, distinct from the "Affirmed" note (which already had the
*top-risk prose* half) by a 2/DRY check, adding the executability ranking (narrative `.md` > doctested
docstrings > typechecked/tested code) and the *sibling-ticket-vs-HEAD* facet.

**✔ Landed (2026-07-23):** **A9** (run a sibling to find the shape): folded into sounding 10's "the
run target is wider" enumeration as a third run-target (a *sibling* implementation run on the same
input *before* adopting the buggy path's own fix; names the shape the issue/ADR missed; strongest in
guide mode), homed with its family rather than a standalone note.

**✔ Landed (2026-07-23):** **A6** (a park's reason can be scope): the fix-vs-park Working note now
names *two* park reasons, *unreachable* (name it, cost-vs-risk in a line) and *out-of-scope*
(reachable and load-bearing, but outside the change's boundary; resolve to a *filed follow-up issue*,
a routed action, not a rotting note, linking A1's verifying-is-an-action rule).

**✔ Landed (2026-07-23, the ×1 rider batch, one commit):** **A5** (unreachable type-ideal → an
*enforcing test*, never a comment; rider on 1a's Move), **A7** (trace leverage against the work's
*charter*, not only what consumes it; a half-delivered charter is a finding; clause in the leverage
Working note), **A1(g)** (build the breaking input by *decoding bytes*, not a convenient literal that
carries runtime types the wire never produces; parenthetical in sounding 10's Move).

**Queue empty — the §A tail is fully landed.** Remaining before the batch closes:

1. **Validation run** (not a landing): one external dogfood pass on a *new* target, honoring the
   provenance rule, to confirm the reworded notes fire and help rather than merely read well. This is
   how a self-authored wording change earns "verified" (beats 5, 17, 18).
2. **Payoff-line polish** (light sweep, likely already done): the per-sounding "what it buys you"
   lead lines landed in Stage 2; a consistency pass only if a facet reads thin.

*Done/dropped from the queue: **A2 · A5 · A6 · A7 · A8 · A9 · A1(g)** ✔ landed · **A10** ✔
already-landed (1e) · **A1(f)** dropped (covered by sounding 6).*

*The combine pass (Section B/C) is now **ready to run** (2026-07-22): the corpus reached saturation, §C
unfroze, the merge/keep calls are recorded in §C-batch, and the count reconciled to **20** (§E3). Per
REFINEMENT.md's "let usage drive, not armchair debate," this ledger is its input; the input is now in.*
