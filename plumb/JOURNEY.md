# Plumb: the build journey

*The narrative of how plumb was built and refined, kept **separately** from the working
artifacts because those lose it. [DOGFOOD-LOG.md](DOGFOOD-LOG.md) is an append-only ledger of
runs (granular, not a story); [LANDSCAPE.md](LANDSCAPE.md) is overwritten to stay current (it
erases how the thinking changed); [CORPUS.md](CORPUS.md), [TIGHTENING-SIGNALS.md](TIGHTENING-SIGNALS.md),
and [REFINEMENT.md](REFINEMENT.md) hold the current state, not the beliefs they replaced. This
file preserves the **reversals**: the wrong turns, who caught them, and the lesson each one
bought. The goal is a story worth telling others about building a skill that encodes
**judgment**, not a mechanical check.*

*Status: living draft, appended at each real turning point. Framing and voice are still open.*

---

## The spine (the one idea)

Plumb judges structural design against an *ideal*. Building it well required applying plumb's
**own** discipline to plumb's **own** construction, recursively:

- *Judge against the ideal, not the incumbent* → the soundings list can't just be "what was in
  one head"; it has to be judged against the canon.
- *Hunt the breaking edge* → we had to hunt the breaking edge of our own validation method, and
  found it (a corpus that pre-avoids the sins plumb hunts).
- *Don't trust a claim you haven't run* → "this repo is clean," asserted from reputation, was
  exactly the unearned claim plumb forbids.
- *Model outcomes; treat a label as a hypothesis* → a quality tag (`clean`/`poor`) is a prior to
  be tested, not a fact to reason from.

Each beat below is the same shape: we trusted something convenient, found it was **biased**,
**blind**, or **unearned**, and the fix was a principle plumb already preaches, turned back on
plumb itself. A judgment tool has to be built by the method it embodies. That self-similarity
is the story, and it is the transferable part: it is a method for building any non-mechanical
skill.

## How this file is kept

Append a beat at each turning point. A beat is: **Believed** (what we trusted) · **Broke** (what
exposed it) · **Corrected** (what changed) · **Lesson** (the transferable principle), plus *who
caught it*. Much of the value is that several turns were **the user catching the model**, not the
model self-correcting: the honest story shows the reversals and their source, not a triumphal
march.

---

## Sources and dating (primary-source recon, 2026-07-21)

The beats are reconstructable from local Claude Code transcripts, which capture the actual
dialogue, so *who voiced what* is visible (the same way beats 5 and 7 are legible in the
session that produced them). Where each beat's source lives:

- **Beats 0-1 (origins):** `covjson-msgspec` transcripts, 215 sessions, done exclusively on
  this machine (a complete record). Repo work starts **2026-06-22**; the word **"plumb" first
  appears 2026-06-24** (about two days in, so plumb shaped the library from near day-one,
  which is itself the root of the fire-frequency bias); the **"sounding" vocabulary appears
  ~2026-07-02**, so the *concept* predates the *metaphor* by roughly eight days.
- **Beats 2-4 (bias, blindness, gap-finders):** `claude-skills` transcripts, 5 sessions from
  **2026-07-08**; the signals (`corpus`, `selection bias`, `coverage audit`, `unhomed`,
  `bias-suppress`) are present.
- **Beats 5-7:** the **2026-07-20/21 session** that first created this file, in the conversation
  itself.
- **Beats 8-9 (+ the earthaccess real-1 whole-repo audit):** the **2026-07-21 session**, a
  **separate, later transcript** from the 5-7 one. Beat 8 = the second canon pass; beat 9 = the
  CxC proxy-source catch (and its same-session `nsidc`-vs-`earthaccess-dev` echo). The
  "(this session)" tags on beats 5-9 therefore point at **two different transcripts** — a
  boundary the origins-mining pass must respect, since attribution is per-transcript. (The
  earthaccess audit itself is *not* a beat: it is a confirmation, and DOGFOOD-LOG already holds
  it; the journey records only what the working docs erase.)
- **Beats 10-11:** a **later same-day (2026-07-21) session**, a **third distinct transcript** from
  beats 5-7 and 8-9, running gen-3 (the generated Go `spend` CLI) and real-4 (the `rust-simple-httpd`
  audit). Beat 11 (the `obstore` clean-prior catch) is a **verbatim user question** in this
  transcript, so its attribution is firm; beat 10 (the sounding-3 / must-consume refinement) is
  **model-proposed and user-directed**, flagged for the author's confirmation. The per-transcript
  attribution boundary from beats 5-9 applies here too. (The gen-3 and real-4 *saturation-held*
  results are confirmations in DOGFOOD-LOG, not beats; only the wording refinement and the
  selection catch turned.)

**The bias, quantified from the recon:** `faithful` and `round-trip` appear in ~102 of the 215
covjson-msgspec sessions (~half), because covjson-msgspec *is* a faithful-serialization
library. Sounding 7 looks universally load-bearing from this corpus precisely because the
corpus is a faithfulness library: beat 1 with a number attached.

**Deep narrative + attribution: a focused mining pass (pending).** The dates above are
recon-level (grep, not read). The real conception narrative and the per-beat "who caught it"
come from reading the genesis sessions. Attribution *is* reconstructable from the dialogue,
but two things need the author's verification **after** drafting, not before: (a) transcripts
show the *exchange*, and a reversal is often collaborative (model raises tentatively, user
sharpens, or vice versa), so labeling a single catcher is a judgment call; (b) transcripts
cannot see *off-transcript* thinking, an insight formed between sessions and typed as a
conclusion looks like "user stated it" but its texture is known only to the author. This is
the same plumb discipline the journey is about: do not assert what you can verify, and let the
party who can confirm (the user) verify the claim the model cannot cleanly self-confirm.

---

## The beats

### 0. The bootstrap: a soundings list from one head
- **Believed:** a first list of soundings, drawn from what the author already knew about
  structural design, was a fine place to start.
- **Broke:** nothing yet, but it was a convenience sample of one person's knowledge, suspect by
  construction. You must start somewhere; the error would be trusting the start as the truth.
- **Corrected:** held the list provisional from the outset, every sounding carries a `[combine?]`
  marker, nothing frozen.
- **Lesson:** a judgment tool's seed is a hypothesis, not a spec. Name it provisional or you will
  defend it later out of habit.

### 1. Dogfooding, and the fire-frequency trap
- **Believed:** how often a sounding *fires* when we run plumb on our own code measures how
  *important* it is; a sounding that never fires can be cut.
- **Broke:** the corpus was almost entirely two Python libraries written *by the author while
  applying plumb*. Fire-frequency there measures importance × how often *this* corpus commits the
  sin, and the second factor is near zero for precisely the sins we were careful to avoid. A cold
  sounding looked unimportant when it was actually **pre-avoided**.
- **Corrected:** stopped reading raw fire-frequency as a value signal (leads into beat 2).
- **Lesson:** a metric measured on a sample shaped by the very thing you are measuring is
  circular. Fire-frequency is confounded by the corpus's provenance.

### 2. Naming the bias: corpus representativeness
- **Believed (briefly):** we could still use fire-frequency to cut soundings if we were careful.
- **Broke:** the confound is not fixable by care; it is structural. A sounding cold on
  self-plumbed code may be the hottest one on mock-heavy or brownfield code we never sampled.
- **Corrected:** wrote [CORPUS.md](CORPUS.md); **froze** the §C cut/keep decisions until the
  corpus is representative; defined a five-axis `Corpus:` tag (provenance, quality, language,
  shape, maturity) so fire-frequency can be **stratified** instead of pooled; planned an
  adversarial batch that deliberately samples the empty cells (generated + real, non-Python,
  brownfield, mock-heavy).
- **Lesson:** when a metric is confounded, do not average it away; **stratify** by the confounder
  and refuse to act on the pooled number. Name the bias in writing so the freeze has teeth.

### 3. The blindness: what fire-frequency can never see
- **Believed:** a good-enough corpus would eventually tell us which soundings matter.
- **Broke:** even a perfect corpus only reports on soundings we *have*. It is silent about
  soundings we are *missing*. The sharpest example: **primitive-obsession**. Because we already
  model with types, we never commit the smell, so it never fires, so by fire-frequency it looks
  unimportant, when it is simply **invisible** to the method.
- **Corrected:** added a **deductive** gap-finder, the canon coverage audit in
  [LANDSCAPE.md](LANDSCAPE.md), walking external catalogs (Fowler, the type-driven / CxC canon,
  Ousterhout, NTCoding) to ask "does plumb have a probe for each principle?", independent of our
  code, so immune to the corpus bias. It nominated primitive-obsession, corroborated immutability
  and sound-typing, and surfaced illegal-transitions.
- **Lesson:** an inductive method (learn from runs) is blind to what your sample never contains.
  Pair it with a **deductive** sweep of the field's canon, which does not depend on your data at
  all.

### 4. Two gap-finders, complementary
- **Believed:** one good gap-finding mechanism should suffice.
- **Broke:** the inductive `Unhomed:` line (findings from real runs with no sounding home) and the
  deductive canon walk catch *different* misses: one finds what real code does that we did not
  model; the other finds what the canon knows that we forgot.
- **Corrected:** kept both, and made them feed the same candidate list (deductive **nominates**;
  adversarial dogfooding **confirms and ranks** by real leverage).
- **Lesson:** blind spots have more than one source; you need a finder aimed at each. Induction
  and deduction are not rivals here, they are two lamps pointed at different corners.

### 5. (this session) The single-module mirage
- **Believed:** reviewing one well-chosen module of pydantic (`color.py`) let me call the repo
  `clean` and treat it as a specificity control.
- **Broke:** the user asked, "if you haven't fully audited pydantic, how can you claim it to be
  clean?" `color.py` is one deprecated module, ~3% of the package. I had reasoned *from* a quality
  prior as if the audit had already confirmed it. **Caught by the user.**
- **Corrected:** quality tags are **a-priori priors the audit tests**, never verified properties;
  a repo's role (control vs fire-source) is an **output** of the audit, not a pre-assignment;
  relabeled the `color.py` review a *seed*, not a repo claim.
- **Lesson:** do not reason downstream from a convenient label as if it were established. The same
  "run it, don't assert it" discipline plumb applies to code applies to your claims about the code.

### 6. (this session) Measurement humility: not everything wants to be statistical
- **Believed (question raised):** should we push the batch toward statistical significance?
- **Broke:** two things. Reaching a real fire-rate would need tens of repos per cell (hundreds of
  audits, infeasible by hand). And more fundamentally, it is a **single-rater judgment
  instrument**: I both design the soundings and score whether they fire, so a significance number
  would be false precision, correlated subjective judgments dressed as measurement.
- **Corrected:** the analysis is a **saturation-based signal read**, not a frequency table:
  existence ("does it ever fire off-self?", one counterexample settles it), contrast
  (hot-on-poor vs quiet-on-clean), and stopping by saturation (add diverse cells until no new
  `Unhomed:` candidate appears), never a p-value. If real rates are ever wanted, that is an
  automation project, not hand-dogfooding.
- **Lesson:** match the rigor claim to the instrument. A judgment tool yields *directional* signal;
  pretending it yields statistics is the same false-precision sin as reading module counts as
  rates.

### 7. (this session) Complete the instrument before you measure
- **Believed (default plan):** run the repo audits, and let the deductive canon pass happen later.
- **Broke:** the user pointed out the order was backwards: the soundings are the measuring
  instrument; if the later canon pass adds or changes a candidate, every audit already run was
  blind to it, re-work, or a confounded taxonomy. **Caught / proposed by the user.**
- **Corrected:** gated the repo audits behind a **second canon pass** over the un-walked canon
  (connascence, CQS, full GRASP/SOLID, temporal coupling, design-by-contract), scoped by the same
  saturation rule. This completes **nomination** only; promotion (§A) and combines (§C) still gate
  on batch data, so canon-first does not jump either downstream gate.
- **Lesson:** finish the instrument's candidate set before you measure with it. Changing the ruler
  after taking readings invalidates the readings.

### 8. (this session) The OO canon mostly folds: plumb is type-first
- **Believed:** the un-walked canon still to sweep — connascence, CQS, the rest of SOLID/GRASP,
  temporal coupling, design-by-contract — was a large body of famous principles, so it might
  nominate several new soundings.
- **Broke:** it nominated **one** (CQS). Almost everything else *folds*, and for a common
  reason: plumb's **type-first stance already absorbs the OO canon**. LSP dissolves into the
  preference for a closed sum over a subtype hierarchy; OCP is the mirror image of totality (a
  closed exhaustive sum is *deliberately* closed to extension); design-by-contract's
  postconditions lift into the type (`NonEmpty<T>` over an asserted "returns non-empty").
  Plumb steers *away from* the shapes — inheritance hierarchies — where half those warnings
  even apply. **Caught by the model** (the deductive walk itself); no user catch this beat.
- **Corrected:** recorded the folds *with their reasons* rather than as omissions (a reasoned
  non-gap is a result, not a blank), broadened the Tier-2 illegal-transitions candidate to
  cover temporal coupling generally, and promoted **CQS** to a Tier-1 candidate — it was both a
  deductive miss and a real earthaccess unhomed fire, the same deductive+inductive convergence
  that earned primitive-obsession its slot in beat 3.
- **Lesson:** a deductive canon sweep pays off even when it mostly folds — the folds *locate the
  skill* (they told us plumb is a type-driven lens, not an OO one), and the lone escape (CQS,
  like primitive-obsession before it) re-earns the method's keep. Saturation is a finding, not a
  failure to find.

### 9. (this session) The proxy canon: a sweep is only as good as the source you read
- **Believed:** "CxC" was a canon I could sweep plumb against — the first pass cited it four
  times (immutability, sound-typing, primitive-obsession, typestate), and I'd offered to do a
  systematic second sweep "against the public type-driven canon (Wlaschin / King / Hickey)."
- **Broke:** the user asked, "where *specifically* are you reading CxC from?" I had no artifact
  — only the plumb docs' own secondary citations plus general training knowledge wearing a
  citation's coat. Worse, the *first pass had done the same thing weeks earlier*: its "CxC"
  citations are all textbook type-driven canon, and they miss the real guide's **load-bearing**
  idea entirely — *recoverable vs unrecoverable invariants*, which is original to the guide, not
  in any textbook. A proxy sweep is structurally blind to exactly the source's own contribution.
  **Caught by the user**, with one question.
- **Corrected:** the user pointed me at the real file
  (`digital-garden/content/correct-by-construction.md`); read in full, the faithful sweep
  nominated the recoverable/unrecoverable candidate (Tier-2), corroborated immutability and
  sound-typing from a genuine second source, and yielded six named riders — materially more than
  the proxy, and *different* in kind. Flagged the first-pass citations as proxy-sourced in
  LANDSCAPE.
- **Lesson:** a deductive canon walk inherits the authority of the canon it *actually opens* —
  not the canon it *names*. Citing a source you reconstructed from memory is the same unrun-claim
  sin as calling a repo clean from its reputation (beat 5), one level up: it launders priors as
  authority and goes blind to precisely what's new. Open the source, or label the proxy as a
  proxy — never let a remembered catalog impersonate the real one.
- **Echo, same session (the pattern, not a one-off):** the identical slip recurred within the
  hour. Starting the earthaccess audit I reached for `nsidc/earthaccess` — the *apparent*
  canonical upstream — and the user corrected it again: "that's old/deprecated, use
  `earthaccess-dev`." **Two source-provenance catches by the user in one session**, same shape
  each time: a solo model reaches for the *plausibly-authoritative* source (the famous canon, the
  official upstream) over the *actually-current* one, and the person who knows the real provenance
  is the one who catches it. The recurrence is the real datum — this is a **systematic** failure
  mode of solo model work, not a stray miss, which is exactly why the human-in-the-loop is
  load-bearing and why the transferable method must name "verify the source is the live one" as a
  step, not a footnote.

### 10. (this session: gen-3 Go + real-4 Rust) The soundings smuggle language assumptions; a language flip audits their wording
- **Believed:** sounding 3 states its guarantee as "adding a case *forces* the update
  (compiler-checked exhaustiveness)," and sounding 2's Boundary states "the raise belongs at the
  edge" as a uniform rule. Both were phrased as language-independent design properties, the way a
  plumb line is meant to measure against a language-neutral ideal.
- **Broke:** running plumb across a language-*family* boundary (Python, then Go, then Rust) showed
  both are language-*dependent* premises. Go (gen-3): the compiler-checked-exhaustiveness guarantee
  is *absent* for error-values, `amt, _ :=` and a bare call both compile clean and `go vet` is
  silent (RAN), so totality degrades to a linter. Rust (real-4): the guarantee is *present*
  (`Result` is `#[must_use]`), but a codebase opts out idiomatically: `let _ = stream.write(...)` to
  silence the warning, `.unwrap()` to consume-by-panic, a macro `Default` fallback to swallow a
  parse-fail (RAN). And Rust exposed a fact neither Python nor Go did: a buried panic does not just
  fail locally the way Go's `log.Fatal` does, it *poisons shared state* (`Arc<Mutex>` cascade), so
  sounding 2's Boundary carries a strictly higher cost in a shared-state concurrency model.
- **Corrected:** the must-consume / `#[must_use]` discipline (the receiving-side dual of sounding 2)
  does *not* become a new sounding; it folds into **1** (as the API designer, make an ignored
  outcome unrepresentable) **+ 3** (as the consumer, handle the error case). But the fold came with a
  wording fix: sounding 3 must separate the *ideal* (every case is consumed) from the *enforcement*
  (which the type system may or may not provide, and which a codebase can escape), and sounding 2's
  Boundary gains that its blast-radius is concurrency-model-dependent. Attribution: **model-proposed**
  (the must-consume gap was called at gen-3's start and the Go/Rust enforced-contrast pair was
  designed to test it) and **user-directed** (the user set the batch and chose Rust for real-4);
  *to be confirmed by the user.*
- **Lesson:** a sounding phrased as a *compiler guarantee* ("forces the update") has a language
  assumption baked into its words, and a tool that claims to measure against a language-neutral ideal
  must state the ideal separately from its enforcement. The instrument that exposes the smuggled
  premise is the **language flip** itself: sampling a new language family (the CORPUS empty-cell rule)
  does more than test saturation, it *audits the soundings' own wording* for hidden assumptions.
  Saturation *held* (zero new unhomed across four external audits), and that is a DOGFOOD
  confirmation; the beat is the wording refinement the flip forced out.

### 11. (this session, sourcing real-4) The clean-prior trap: match the sample to the question, and measure, don't trust reputation
- **Believed:** for real-4 (the external-Rust language-flip test) I proposed `developmentseed/obstore`,
  chosen on the axis under test (Rust) plus convenience (already local, same org as real-2), and I
  pre-framed its pyo3 FFI seam as a bonus.
- **Broke:** the user caught it: "i'm relatively familiar with obstore, and believe it is probably
  quite clean, so I'm wondering if this is a good candidate." A *clean* repo is a low-power
  saturation test: few smells means "zero new unhomed" cannot distinguish "the set absorbed
  everything" from "there was nothing to absorb," so the result is nearly uninformative. I had matched
  the repo to the *language* but not to the *question*: a saturation test wants a repo you *expect to
  be messy*, so that zero-new is a surprising, high-information outcome. **Caught by the user.**
- **Corrected:** reframed the clean repo as the pydantic-role (a specificity control, deferred), not
  the saturation test, and sourced a `mixed`/`poor` target by *measuring* roughness (unwrap/panic
  density: 45 + 14 in rust-simple-httpd) instead of trusting reputation, rejecting obstore for its
  clean prior.
- **Lesson:** the measurement *sample* must fit the question, not just the axis under test: a
  saturation test wants high smell-density, a specificity control wants a clean one, and the two are
  not interchangeable. And the prior is *measurable at selection time* (grep the panic/unwrap
  density), which is beat 5's "quality is an output the audit assigns, not a prior" pushed one stage
  earlier: do not even *select* on reputation, measure. This is the **third** time in this journey's
  lineage the user caught the model trusting a reputation over a measurement, after beat 5 (pydantic's
  clean *reputation*) and beat 9 (CxC's remembered *citation*, plus the `nsidc` deprecated-upstream
  echo). The recurrence is the datum: a solo model reaches for the *plausibly-representative* choice
  (the famous canon, the official upstream, the well-regarded repo) and the person who knows the
  ground truth is the one who catches it, which is why "verify or measure the thing, don't trust its
  reputation" has to be a named step in the transferable method, not a footnote.

### 12. (this session) The combine: group, don't fold — the count was the wrong axis
- **Believed:** with the corpus saturated and §C-batch's calls recorded, I framed the deferred 20 →
  ~10–12 combine as a *count-aggressiveness* dial and offered three options (aggressive ~10, moderate
  ~12, conservative ~15), each a different amount of *folding* soundings into one another. The frame
  smuggled in an assumption: that combining means folding, and the choice is how much.
- **Broke:** the user rejected the axis: "I'm less concerned with reaching a specific count than
  getting the right soundings properly delineated (but not a laundry list of weak ones either) — if
  conservative is actually a better delineation, don't avoid it for the arbitrary 10–12 range. What's
  your take?" That reframed the question from *how many* to *what is genuinely distinct*, and exposed
  that my options traded delineation against count as if they were the same lever. **Caught by the
  user.**
- **Corrected:** separated the two operations "combine" had been conflating — **fold** (a probe loses
  its Move into a parent) vs **group** (distinct probes get organized under one headline, each keeping
  its Move). The batch's own distinctness axis (`is the Move new?`), originally a *promotion* test,
  reused as a *fold-vs-group* test, decides it: a distinct-Move probe may only be grouped, never
  folded. That dissolved the dilemma — grouping buys the low headline count (~10) *for free* off the
  reinforcement structure while preserving all 19 distinct Moves as facets. Landed SKILL.md as 10
  grouped headlines; only genuine demotion was 14 (affirm-only, never drove a finding → rider).
- **Lesson:** when the model offers a menu of options, the *axis the menu is built on* is itself a
  claim that can be wrong — and a menu is a comfortable place to hide an unexamined frame, because it
  looks like deference. Here the count axis (a number named early and then treated as the thing being
  traded) was the artifact; the real axis was distinctness, and it took the domain owner's priorities
  to name it. This is beat 5/9/11's pattern turned inward one more notch: not "measure the sample, don't
  trust its reputation," but "check the *frame* of the choice you're presenting, don't trust that the
  dial you reached for is the dial that matters." The `~10–12` target from REFINEMENT.md was the
  reputation this time: a number set early, load-bearing by habit, until the user asked whether it
  should be.

### 13. (this session) Sharpening the labels: a term is a reference, not a label
- **Set out to:** with the combine's 10 grouped soundings landed, refine every headline and facet
  *label* so it lands instantly for a first-time reader, the scaffold for a planned reader-facing
  writeup (its own companion doc, so SKILL.md stays lean) plus a one-line description and one real
  example per sounding. Rule: canonical name plus a plain gloss, parallel in form, mutually distinct,
  every term-of-art glossed. Most labels already cleared the bar; about eight needed a touch, several
  only a word. A low-drama step, logged anyway because the reasoning transfers.
- **Broke, and the user pushed each catch a level deeper than the model first took it:**
  - **Object-less head nouns.** "Proportional response" reads blank because "response" carries no
    object (response to *what?*); the fix is never a clarifying suffix but a noun that bakes its object
    in. The user then pushed it twice more: "proportional" is *itself* object-less (proportional to
    what?), and the model's next try, "enforce", was not just opaque but *inaccurate*, covering only
    the mandatory end and silently dropping the recommended/optional levels the sounding grades. Landed
    on **"Match strictness to the requirement"**, where "strictness" spans the whole range and is the
    sounding's *own* word (its body already says over-/under-strict). "Structure & boundaries" failed
    the same test (structure of what?) and became **"Focused parts, clean seams"**.
  - **A label that hid its own distinction.** 3d, "keep behavior with its data", read as plain OOP
    encapsulation, and the user asked what the distinction even was. The real answer is feature-envy /
    GRASP Information-Expert: a method leaning on *another* object's data is misplaced, a defect that
    fires straight *through* clean encapsulation and applies in FP too (co-locate a function with the
    type). Then two more user catches: "feature envy" literally describes *data* envy (Fowler's own
    note is that the envied thing is the data), so the canonical term *misdirects* as a label; and
    "with" is the OOP-bundling word ("a class bundles data *with* behavior"), pulling back toward the
    very conflation being removed. Landed on **"Keep behavior near the data it uses most"**: jargon-free,
    "near" is co-location not containment, "uses most" is Fowler's actual test.
- **Lesson:** the reusable rule is **a canonical term is a reference, not a label**. "Feature envy",
  "locality of behavior", "proportional response" are the right words to *cite* in the body
  (searchable, precise) and the wrong words to *lead with* when they misdirect or hide their object. A
  label must be transparent to someone reading it cold; the term lives in the body where a gloss can
  catch it. Corollary: the object-less-noun smell recurs at every level (response, then proportional,
  then enforce), so apply the test until the label names both what it acts on and what it matches to.
  Provenance, and it is beat 1 and beat 12's gap once more: the model's first-pass labels kept
  smuggling the author's own knowledge of the object, and the reader meeting them cold is the one who
  sees the blank, which is why the pass had to be run *with* the domain owner reading each label, not
  by the author alone.

### 14. (this session) Descriptions, familiar names, and eating our own cooking
- **Set out to:** turn the settled labels into reader-facing content, a crisp one-line
  *description* per sounding/facet (what it is, and what it buys), then surface the *familiar
  names* a reader might already know, both feeding a planned companion writeup. Both moves are
  beat 13's reference-vs-label rule run forward: descriptions and canonical names live in the
  body, the label stays clean.
- **Broke and sharpened, most of it user-caught:**
  - **A reader-facing description must not smuggle the author's home language.** The first drafts
    leaned Python (`str`/`int`/`tuple`, `Any`, `cast`, `None`) and said "compiler" (false for
    interpreted languages) and "checker" (vague). The fix: language-neutral terms ("a
    general-purpose primitive", "the static type checker", "a type error", "a bare null or
    boolean"), no backticks. Caught by the user.
  - **An imprecise payoff invites the wrong reading.** "logic tests without mocks" was ambiguous,
    because an injected stand-in *is* a test double, so a reader would rightly object. The precise
    claim: because the effect arrives *through a seam*, a test hands in its own stand-in as an
    ordinary argument, so the *mocking library that patches internal calls* is what becomes
    unnecessary. Caught by the user; the fix names the distinction (injected stand-in vs
    library-patching).
  - **Surface familiar names as references, but only where they map exactly.** A sweep of all ten
    soundings for canonical terms a reader might know but that went unnamed added primitive
    obsession, DRY, SRP, information hiding, RFC 2119, typestate, discriminated union /
    Result-Either-Option, hexagonal architecture, and dependency inversion to the bodies. The bar
    the user reaffirmed: a *loose* cite is worse than none, because a reader who knows the term
    trusts the mapping and is misled, so the tempting-but-inexact ones (LSP/OCP/ISP, Law of
    Demeter, CQRS, intention-revealing names, boundary-value analysis, Postel's law) were dropped
    with reasons.
  - **A technique is a Move, not a sounding.** The user asked whether dependency injection is
    captured. It is, as the *Move* of soundings 4 and 3a, not a standalone sounding: DI is a
    *technique that achieves properties* (a pure core, low coupling), not a property itself, and
    run through the combine's distinctness test ("is the Move new?") it folds, exactly as
    testability-without-mocks did. Promoting a technique alongside properties is a category error.
    It still gets *named* in the body, which it previously wasn't.
- **Lesson, the sharpest and reflexive:** the references that let an unfamiliar reader learn a
  named concept must be **verified, not recalled**. A document *about* grounding claims in their
  real source, whose own citations were pasted from memory, fails its own sounding 12 on the very
  page that defines it. The journey's recurring datum (beats 5, 9, 11: the model reaches for the
  plausible-from-reputation answer, the human catches it) sets the rule: assume recalled URLs and
  attributions are wrong until checked, so the bibliography is a dedicated verified step, never
  improvised into the prose. The through-line of the whole pass: everything a reader will read
  (label, description, name, citation) is a claim, and the author's own fluency is exactly what
  hides the claim from the author.

### 15. (this session) Stage 3: every facet already had a real fire

The plan was "draft one example per facet, from the dogfood log where one exists, *invented only where
the log has none*." The result: across all 19 facets, **zero needed inventing**. The escape hatch went
unused. That is itself the finding, and a late vindication of the corpus work (beats 1–2, 7): a corpus
built and stratified until it saturated turns out to hold a concrete, runnable instance of *every*
probe the skill carries, including the three latest promotions (primitive-obsession, sound-typing, CQS)
whose real fires all come from the external audits, not the self-corpus that first suppressed them.

- **The ledger was the Rosetta stone, not the 257KB log.** TIGHTENING-SIGNALS.md §F already mapped every
  old sounding number to its post-combine facet id, and §A–§D already indexed which entry fired which
  sounding. Mining ran off that index and only opened the raw log for the ~8 entries that carried the
  concrete trigger, never a linear read of all 53 entries. The lesson for a future maintainer: the
  harvested ledger *is* the query surface; re-reading the append-only log end-to-end is the slow path.
- **Provenance is a property of the example, not just the fire.** Each example is tagged self /
  external / generated, and the spread is deliberate: the correct-by-construction and faithfulness
  clusters illustrate best from the *self* covjson work (`_ROOT_TYPES`, the phantom `(bands,1)` axis,
  the year-0000 mislabel), while the newly-promoted structural soundings illustrate best from the
  *external* audits (earthaccess's dict-model leak, titiler-cmr's `parse_datetime` tuple-sum, zarr's
  cross-sibling `must_understand` gap). An example inherits the authority of its source: an external
  fire proves the probe catches real code, not a self-plumbed artifact.
- **The specificity contrasts earn their place beside the fires.** For three facets the *non*-fire is
  as instructive as the fire: 1b did not fire on pydantic's transient `h_units` regex capture, 1e
  parked titiler's `Any` at a genuine xarray edge, 3e went near-silent on titiler's `bounds`. Keeping
  the contrast next to the example is what stops the example from reading as "any string-typed closed
  set fires."
- **The first cut described code in prose; the user caught that it was indecipherable.** The review
  table and the first EXAMPLES.md draft narrated each trigger and move ("a `str` standing in for a
  closed set, dispatched by if/elif..."). The user's correction: an examples doc must show real
  **before/after code blocks** with enough surrounding context to see both the smell and the repair, not
  a prose paraphrase of code. The rewrite pairs a **Problem** and a **Fix** fence per facet, in the
  facet's native language (Python / Java / Go), keeping the same signatures and call sites across the
  pair so the Fix is a true round-trip of the Problem (the skill's own faithfulness sounding, 5a,
  applied to its own docs). Lesson for any future example doc: code shows shape, prose only claims it.
- **Adding commit-pinned links forced verification, and verification caught drift, exactly beat 14's
  lesson turned on the examples themselves.** The user asked for links to the exact file and line at each
  audited commit so a reader can open the original. Constructing them meant fetching the real files at
  their SHAs rather than trusting the audit notes, and the notes had drifted: earthaccess `login` is at
  L111 not the recalled L147 (147 is the dispatch inside it), titiler-cmr imports `Client` from `httpx2`
  not `httpx`, the zarr coupling lives in `validate_codecs`'s lazy import (not an `ArrayV3Metadata`
  method), and `GroupMetadata.from_dict` filters unknown keys for v2 but not v3 (subtler than "the
  sibling has no handling"). Every example is now faithful to code a reader can click through to. This is
  sounding 6 / the "verify the source, do not recite from memory" rule applied to the skill's own
  companion doc: a citation is a claim, and opening it is the verification.
- **A source's own status is part of verifying it: the pydantic non-fire was dropped as deprecated.** The
  crisp specificity control for primitive-obsession (pydantic's `parse_hsl(h_units: str)`, a closed-set
  string that correctly does *not* fire) came from `color.py`, which the user flagged as deprecated code.
  A deprecated module is a weak thing to hold up as an exemplar, so the code block was cut and 1b's
  specificity kept as a short prose note (fires on a value a consumer trusts, not a token used and
  discarded). Verifying a citation is not only "is the line right" but "is this source one worth
  standing on."

### 16. (this session) Stage 4: the references verify the skill's own claims

Stage 4's job was the last reader-facing gap: the named concepts a sounding invokes (information
hiding, CQS, railway oriented programming) had no followable pointer, only name-drops. The
decision was *not* to write a third narrative doc. The deep *why* already lives in the
Correct-by-Construction guide, the build story in this file, the worked examples in EXAMPLES.md; a
new "why" companion would only restate SKILL.md's already-deep bodies. So Stage 4 is a verified
REFERENCES.md (one entry per sounding) plus a bidirectional cross-link to the CxC guide. The scope
call was the model's; the user delegated it ("help me decide") and set two constraints: redundancy
with CxC is acceptable, and links point to the GitHub repo.

- **Verification changed content, not just confidence, exactly as beat 14 predicted.** The ~20
  citations were fanned out to four subagents, each told to fetch or confirm every URL and flag
  anything that did not map. The returns were not rubber stamps: sounding 5 *upgraded* from a
  proposed park to a clean cite (Wlaschin's "there and back again" is precisely the round-trip
  property); sounding 10 *stayed* parked (QuickCheck founds random property testing, not the
  minimal-failing-case shrinking that "hunt the breaking edge" is about); a citation flagged as
  suspect from memory (a "Google Testing Blog, 2025-10" post) turned out to be real, so verification
  *kept* a true source a hunch would have cut; and DIP's original objectmentor.com host is dead, so
  the entry cites the book reprint rather than ship a URL that 404s. A dead link is itself a lie a
  citation tells. This is sounding 6 turned on the skill's own bibliography.
- **The user's late paper was a beat-14 catch in miniature.** Mid-assembly the user surfaced
  Hughes's "Why Functional Programming Matters" and asked whether it added anything. The honest
  answer required opening it, not recalling it. Fetched and read, the paper turns out *not* to
  support the cite it most invites: sounding 4 is about pushing effects to the edge, but Hughes
  explicitly dismisses "no side-effects" as the uninteresting property and argues FP's power is
  compositional glue. So it was filed as a *foundational* entry (the composition-as-modularity
  thesis behind soundings 2, 3c, and the pure-core half of 4) with an explicit note that it is not a
  source for effect-placement, in both REFERENCES.md and the CxC canon. The tempting attribution was
  subtly wrong, and only reading the source caught it. The user found the paper; the model caught
  the misfit; the user chose to file it in both homes.
- **One home for references is the skill's own sounding 2.** SKILL.md's sounding-4 block was the
  only inline citation set; it was folded out into REFERENCES.md and replaced with a pointer.
  Consolidating the references into a single authoritative file is DRY applied to the docs.
- **The em-dash convention caught a fresh-file drift before it landed.** The first REFERENCES.md
  draft carried 40 em-dashes against a corpus that is deliberately em-dash-free (SKILL.md and
  EXAMPLES.md have zero). A house-style grep before commit caught it; the file was rewritten with
  colons, commas, and parentheses. A new file does not inherit the house style automatically; it has
  to be checked against it.
- **Lesson:** the references apparatus is where the skill is most exposed to its own sounding 6,
  because an author's fluency hides a wrong citation better than a wrong claim. The only safe
  reference is a fetched one, and the delegation to verify each was not ceremony: it moved four real
  entries and corrected the one the user contributed.

### 17. (this session) A miss, not a fire: the first refinement the clean corpus surfaced by *missing*

- **The reversal.** Self-plumbed a covjson-msgspec `from_xarray` coordinate-classification fix
  (guide soundings on the root-cause map, then `/plumb review` on the diff). Both passes earned
  their keep: guide mode surfaced a lost invariant and an over-permissive fallback; review mode
  caught a 10 (an untested reframe invariant) and a 1b/1e (a two-`str` positional tuple, promoted
  to a NamedTuple). But on the `add()` closure that assembles the axes I fired 2/DRY *positive*
  ("one clean assembly point, both branches covered") and stopped. An external `/code-review` then
  constructed two *legal* datasets that collide on the shared keyed dicts and found silent
  corruption (a range bound to the wrong axis; longitude values lost). I reproduced both and fixed
  with a collision-checked composer that raises. Third confirming instance of the provenance rule:
  the author under-runs, the external reviewer is the real trigger.
- **The mechanism is sharper than "didn't look hard enough."** The DRY-positive did not merely
  coexist with the 1a-negative, it *masked* it: same site, opposite verdicts, and the flattering
  read arrived first, so the review stopped before reaching the indicting one. Landed as a
  counter-move in the provenance Working note: on your own diff, when a sounding fires positive on
  a site, ask which sounding could *indict* the same site before leaving it.
- **Sounding 10 fired, but on a legal-and-correct edge.** I had "verified" 10 by constructing and
  running a `lon(i)`/`lat(j)` case, which the design handles correctly, not the invariant-violating
  input (two role coords on one dimension, colliding on one key). Hunting "an untested input"
  satisfied 10 superficially while missing "the input that violates the invariant." Landed as a
  10-Move sharpening: name the assumption as a precise invariant, then find the *legal* input that
  *violates* it; a legal edge, however untested, is not the breaking edge.
- **Why a miss outranks a fire, and what it proves.** This is the first refinement driven by a
  false negative instead of fire-frequency, a different signal channel that meets the corpus-bias
  problem head-on (beats 1 to 4). A clean, author-pre-corrected self-corpus cannot surface a gap by
  *firing* (it never commits the sin), yet it just surfaced one by *missing*: a sounding that
  covers the shape failed to fire. The gap was in 1a's *wording*, not its *coverage* (1a owns
  "illegal states unrepresentable," but its Smell did not name a shared accumulator written by N
  producers with no uniqueness guarantee). Landed as a Smell clause. A false negative is a
  legitimate, and here a load-bearing, refinement input.

### 18. (this session) The landings tail: transcription, not discovery, and where dogfooding re-enters

- **The resume-token was ambiguous, and the model misread it.** The prior session wrote "re-invoke
  `/plumb` to continue" into memory. A bare `/plumb` is *also* the skill's own review invocation, so
  the model first read it as "the review tool needs a target" and asked the user for a diff. The
  disambiguator was never in the command, it was in memory's `IMMEDIATE NEXT`. A small process note
  for any cross-session resume convention: a token that means two things is resolved only by
  out-of-band context, and the model will reach for the wrong meaning first.
- **The pacing question, and the discovery-vs-transcription split.** Starting the queued §A landings,
  the user asked whether to weave more repo audits between them. Answer: no, and the reason is the
  same two-axis distinction from the batch analysis (beat 6, beats 10 to 11). The batch was
  *discovery* ("is there an unhomed sounding? does the ranking hold across languages?") and it
  *saturated*, four external audits, zero-new-unhomed; more repos would re-run a closed question. The
  §A landings are *transcription*: each moves an already-corroborated, already-logged signal into
  SKILL.md wording. No fresh run gates a transcription, because the data that would answer it is
  already in the log.
- **Where dogfooding re-enters: once, at the end, external.** A wording landing is itself a claim
  ("this note helps a real review"), and the provenance rule (beats 5, 17) says the author re-reading
  it does not verify it. So the batch's honest close is one fresh dogfood run on a *new external
  target* after the landings, checking the reworded notes actually fire and help, validation of the
  wording, not more nomination. Over-auditing (a repo between each edit) and under-verifying (land
  seven author-re-read notes) are the two failure modes this avoids. The user's question forced the
  distinction into the plan.
- **First landing: A2, three altitudes.** Expanded the "both altitudes" Working note to *guide /
  plan / diff*, plus the observation the load-bearing move often lands in the *design dialogue
  between* the passes, not the passes themselves (×16 corroboration, the most-developed ledger
  theme). Ponytail stance on the tail: land the ×3+ items as notes, fold the ×1 items as one-clause
  riders, and drop A1(f) entirely (sounding 6 already carries it, a cross-link would be a note
  defending a note).
- **A8 was a 2/DRY check on plumb's own prose.** The "Affirmed" note already said "after a decision
  reverses, stale prose is the top risk," so landing A8 meant asking the sounding-2 Boundary question
  *of the skill itself*: does an A8 note duplicate that clause, or encode a different decision? It
  encodes a different one: the "Affirmed" clause says *prose is an un-run claim, verify it*; A8 says *a
  reversal is a distinct trigger, here is how to rank and hunt the stale artifacts, sibling tickets
  included*, so a separate note is right, not a fold. Trimming one into the other would have flattened
  the distinction, the exact anti-pattern sounding 2's Boundary warns against. The tail pass keeps
  turning the soundings back on the edits that land them.

### 19. (this session) The validation run: saturation held, but the model anchored to the incumbent twice, and the user caught both

- **The batch's close ran, and it landed clean.** The validation target was the user's
  `developmentseed/virtualizarr-data-pipelines` CDK template (external, unseen: an Icechunk/Virtualizarr
  ingestion starter someone forks). Every finding homed to an existing sounding, no unhomed candidate
  surfaced, so the infra-as-code cell added zero categories and saturation strengthened across a new
  corpus cell. The predicted process notes all bore weight: A7-charter (measure against "does this shape
  hurt the person who forks it," not "is it production-complete"), A6-park (routed correctness to
  code-review and over-engineering to ponytail by name), 9-reversibility (the template's contract is a
  one-way door inherited by every fork, which set the ranking), and A1g (verify the synthesized artifact,
  not the Python: I ran the pydantic settings model to confirm it *accepts* the deploy-breaking
  GC-without-VPC state and that the shipped `.env.sample` fails to load at all, rather than eyeballing the
  constructs). Per the provenance rule (beats 5/17/18) this is how the self-authored §A wordings earn
  "verified": an external target, author-under-runs.

- **But the load-bearing work was the design dialogue after the review, not the review.** The headline
  review finding (a `process_file` returning a `bool` the caller ignores, so a conformant fork silently
  commits and deletes failed files) was real, but the user redirected: "your findings fix broken things,
  not the soundness of the design." Everything that followed (is the `Protocol` even needed, what is the
  true contract, how to make illegal call-orders uncompilable, where the config knobs live) landed in the
  back-and-forth, not in any single pass. A live ×17 corroboration of the A2 three-altitudes note that the
  load-bearing move often lands in the dialogue between the passes, and here it happened in a *validation*
  run, not a refinement pass.

- **Tooth 1, the incumbent-anchor self-catch.** I recommended a two-method ABC partly because it "matches
  how the sample already thinks." The user caught it: "you are letting the incumbent influence you away
  from the ideal." That is the exact anti-pattern the "judge against the ideal, not the incumbent" note
  guards against, and I had quoted the incumbent as a point *in favor*. A plumb-on-plumb miss while running
  the anti-anchoring tool.

- **Tooth 2, positive-masks-negative, again.** My per-function-`Protocol` redesign felt clean (2/DRY, 3c:
  each function does one thing), so I stopped. The user pointed out it left the *call sequence*
  unconstrained: a maintainer of the skeleton can commit an empty session or open a session on an unseeded
  repo, exactly the 1a illegal-transition (typestate) hazard from EXAMPLES.md Example A. The flattering
  "who implements what" reading masked the higher-leverage "in what order" one on the same design. Same
  shape as the covjson MISS-TRIAGE (beat 17), and I failed to apply the very note that names it.

- **Tooth 3, a hand-wave that was hiding the most important knob.** I wrote `_config()` and `_is_empty()`
  as if they existed (sounding 6, asserting instead of verifying). Pressed on configuration, `_config()`
  turned out to be where the *virtual chunk container* lives, the single most deploy-specific piece in the
  system, buried next to a hardcoded `in_memory_storage()` that is *why the sample is a no-op*. Injecting
  it as a `Backend` (sounding 4) is what unlocks mock-free testing: the existing tests' wall of `MagicMock`
  and `@patch(Processor)` was the sounding-4 tell that effects were reached-for, not injected. The config
  probe converted a hand-wave into the design's testability seam.

- **The meta-observation worth a future decision.** Two of the three teeth (anchor, masking) are
  *application lapses of existing notes*, not coverage gaps: the skill already carries "judge against the
  ideal" and "positive-masks-negative," and the model failed to fire either proactively at *guide/design
  altitude*, where the incumbent is a sample you consciously depart from yet still anchor to. Both notes
  are phrased for review-mode (judging an artifact that exists); neither fired in guide-mode (designing
  from scratch). Candidate refinement, NOT landed here: a guide-mode-specific instance of
  judge-against-the-ideal. Per the MISS-TRIAGE protocol this is the "application lapse" branch (recurrence
  means the wording is not salient enough), and one session is a watch, not yet a landing. The full
  existing-vs-redesign analysis and the plan are target-repo deliverables (brief-and-handoff), not skill
  knowledge, and do not live here.

### 20. (this session) The payoff-line sweep: the polish already landed, so the sweep was a verification, not an edit

- **The last open skill-repo item resolved to "nothing to do," and that is the correct outcome.** The
  remaining §A-adjacent task was a light consistency sweep of the per-sounding and per-facet "what it buys
  you" lead lines (landed in Stage 2, beats 13 to 14, as each entry's "what it is, so what it buys"
  opener). Read fresh, all 22 lead lines (10 group headers + 12 facets) hold the same shape: an imperative
  directive followed by a benefit-focused `so [payoff]` clause, and every payoff names a concrete win
  ("so a change in one module doesn't ripple," "so a wrong guess stays cheap to walk back," "so 'that
  can't happen' is tested, not hoped for"), not a restatement of the mechanism. A sweep whose honest
  verdict is "consistent" is a real result, not a skipped step: manufacturing edits into an already-polished
  doc is the churn the sweep exists to avoid.
- **The two closest calls, both left as-is with reasons.** *1a* is the one structural outlier: its payoff
  sits inline ("Shape the type so a bad value can't be built in the first place: invariants hold by
  construction...") rather than as the trailing `, so [payoff]` clause 1b through 1e use. Rewriting it to
  the trailing form forces a double "so"; the inline form reads cleanly and 1a is the flagship facet, so
  the variance is stylistic, not out of step. *3c* has the thinnest payoff ("so it's easy to find,
  understand, and change"), a generic triad next to concrete neighbors, but it is the canonical SRP benefit
  statement and any sharpening drifts into sounding 2's territory ("in one place"). Both are within range;
  neither warranted reopening. The lazy call and the right call were the same call.

### 21. (this session) Wiring the feedback loop: the crux of continuous improvement, and where "reference, don't restate" breaks

- **Believed:** with the sounding set converged and publishing next, the remaining intake work read as
  mechanical: build the two pieces issue #5 specifies (a `.github` issue form and a self-capture line in
  `SKILL.md`), and follow the issue's instruction to *reference* the committed MISS-TRIAGE doctrine in
  `REFINEMENT.md` rather than restate it, on both pieces.
- **Broke (a design-time catch, not a shipped reversal), triggered by the user's prior question "should we
  spin plumb off to its own repo?":** verifying the plugin mechanics (via `claude-code-guide`, against the
  docs, not recalled) surfaced that a Claude Code plugin has *no manifest file-exclusion*: the whole plugin
  directory is copied into every installer's cache. So the ship-vs-internal split must be structural, and
  `REFINEMENT.md` is dev scaffolding that *does not ship*. That breaks the instruction on one side: the
  shipped `SKILL.md` line cannot "reference" a doctrine the downstream user will never receive. Single
  source of truth is satisfiable across files in one repo, not across the *ship boundary*.
- **Corrected:** split the two pieces by altitude. The issue *template* lives in the repo (viewed on
  GitHub, where `REFINEMENT.md` also lives), so it links the doctrine. The shipped `SKILL.md` line is
  *self-contained*: it states the minimal edge-triage (the lane check + coverage-vs-wording) by leaning on
  the routing `SKILL.md` already carries, and leaves `REFINEMENT.md`'s full maintainer-side protocol
  unshipped and unreferenced. Two altitudes, not duplication.
- **Lesson (the crux, and why this is a beat, not a checkbox):** a skill that encodes *judgment* improves
  almost entirely from its *misses*, and a miss is a false negative the user usually cannot see either (it
  is what plumb did not say). A local skill has, and should have, *no telemetry*. So the only way step 13's
  miss-channel stays open once strangers use the skill is to wire the loop *into the skill itself*: the
  distribution unit is a prompt, so the feedback mechanism is a prompt too, a self-capture line that turns
  every user's model into a first-pass triage agent emitting a well-formed report. This is sounding 4 (pure
  core, effect at the edge) turned on plumb's own distribution: the skill stays pure, the human filing the
  issue is the edge. The second, reusable lesson is the boundary itself: **"reference, don't restate" stops
  at the ship line**, a shipped artifact must be self-contained, so single-sourcing ends there and the
  shipped side re-states the minimum or splits the content by altitude.

### 22. (this session) Half a loop is a suggestion box: the consumption side the intake beat skipped

- **Believed:** beat 21 "wired the feedback loop." With the issue form and the self-capture line built and
  merged (PR #6), #5 was done and the loop was closed.
- **Broke:** the user asked two questions the build had never answered, "how do we actually make use of
  reported feedback to refine plumb?" and then, sharper, "once I see an issue filed, what do I
  *specifically* do?" Beat 21 had built the *intake* and never described the *consumption*: how a report
  becomes a refinement, and how the reporter learns it mattered. An intake with no consumption is a
  suggestion box no one empties, not a loop.
- **Corrected:** the consumption half was mostly already doctrine, the MISS-TRIAGE protocol committed in
  `f2a65f5`, but nothing connected "an issue arrived" to "run that protocol." Landed a maintainer-facing
  *Processing an incoming report* runbook in REFINEMENT.md (open with `gh issue view`, triage, verify by
  reconstructing and running the case, land as a branch + PR editing SKILL.md / DOGFOOD-LOG / JOURNEY,
  close the loop with a reply plus a version bump), and added transferable-method step 17 (close the loop)
  beside step 16 (open it). The form pre-answers the two cheap triage steps (lane, coverage) but never the
  expensive one: reconstruct the reporter's case and run it, because the report is a claim, not proof.
- **Lesson:** "wire the loop" is only half a loop. A feedback mechanism is not closed until the consumption
  path is described, including its least glamorous step, telling the reporter what changed, because people
  report again only if the first report visibly mattered. And the division of labor is the build's recurring
  datum once more: the model drafts the triage, but "plumb missed X" is itself a reputation-plausible claim,
  so the human who holds ground truth verifies and merges. This beat exists because the user caught the
  missing half by asking how they would actually operate it.

### 23. (this session) The loop's first live run: a self-dogfooded candidate, verified by a non-author, and a channel it could never reach

- **Believed:** with the loop wired (beats 21, 22) and the consumption runbook committed, a candidate the
  discovery session was confident about (it proposed that "A12 should land in SKILL.md") was ready to land,
  and the intake form was the channel a refinement signal travels.
- **Broke, two ways, both caught by the machinery just built:** (1) the discovery session proposed editing
  SKILL.md itself. The author-does-not-land-own-claims rule stopped it: the session HELD A12 and captured
  only, and the consumption runbook then ran for the first time with a *non-author* verifying A12 by
  re-running `mypy --warn-unreachable`, not trusting the session's report (`-> bool` reports "Success";
  `-> NoReturn` flags the guard's `if x:` body unreachable). (2) Testing whether A12 could travel through the
  *intake form* showed it could not: A12 is a wording sharpening from a run where plumb *worked* (its
  diff-pass caught the `1e` hole by running mypy). An external user would have had no misfire to file.
- **Corrected:** A12 landed as a 1e wording gap (the Smell did not name the always-raises / `-> NoReturn`
  shape) via the runbook, verified independently. And the channel model gained a boundary: the form catches
  misfires and misses ("plumb was wrong"); own-dogfooding catches wording-sharpenings from *successful* runs,
  which are invisible to the form by construction.
- **Lesson:** the loop is not only for external complaints. Its highest-fidelity input is the maintainer's
  own successful runs, where the signal is "the principle covered this but the wording did not *name* it", a
  class that never reaches a "plumb was wrong" form. And a confident self-proposed candidate is not a landing
  until a non-author re-runs it: the author-does-not-land rule plus an independent run is what turned A12 from
  a claim into a verified change. Caught by the user, who insisted the discovery session capture-only and land
  nothing, and whose broad-design/form question surfaced the channel boundary.

### 24. (this session) The barrier-reducer had a barrier: dogfooding the intake through its own delivery surface

- **Believed:** beat 21 shipped the intake as a rich issue *form* (six fields, dropdowns) plus a
  self-capture line that hands back a *prefilled New Issue URL*, and that this was the low-friction path a
  downstream user would take.
- **Broke, on the first real use:** running the self-capture in another repo's session showed the prefilled
  URL is unusable, the report overflows GitHub's URL limit and truncates in a terminal, and the rendered
  issue body was styled markdown, not copy-paste-ready raw text. The first fix (a code block *per field*)
  reintroduced the barrier from the other side: more than two paste targets is itself tedious. And a step
  back exposed a DRY smell in plumb's own repo: the report schema lived in *two* homes (the YAML form and
  the self-capture line), a sounding-2 finding on the skill's own infrastructure.
- **Corrected:** the self-capture now hands back *exactly two* copy-pasteable values, a title and a body,
  each in its own code block, with lane / coverage / how-surfaced as labeled lines in the body (the form's
  dropdowns render as body text anyway, so nothing is lost). The YAML form was dropped to a `config.yml`
  chooser pointer, collapsing the schema to one home. Folded in the same pass: a steelman guardrail, a
  model reporting a verdict *it* gave must advocate for the user's objection, not soften the report toward
  agreeing with itself.
- **Lesson:** a barrier-reducer must be dogfooded through its *actual delivery surface* (a terminal, a URL
  length limit, a markdown renderer), not just designed on paper; and "more structured" can be *more*
  friction: six fields and a long URL lose to two copyable values once the model, not the user, is filling
  them. Caught entirely by the user: the truncation-and-not-copyable observation, the "why not just two
  values" simplification, and the "that means dropping the template" insight that turned it into a DRY fix.

---

## The transferable method

*The checklist for building any skill that encodes **judgment** rather than a mechanical check,
distilled from the beats above. Finalized 2026-07-24 at beat 20; the *sustain* phase then grew from the
feedback-loop work, beat 21 adding step 16 (open the loop) and beat 22 step 17 (close it), without
disturbing the twenty-beat distillation. The guide-mode watch-candidate (beat 19) remains open as a
possible later beat.*

Two through-lines run under every step. The first is **the spine** (stated at the top of this file):
a judgment tool has to be built by the method it embodies, so each phase below is one of plumb's own
soundings turned back on plumb's construction. The second is the single most-repeated datum in the
log, and it is quieter: **a solo model reaches for the choice that is plausible from reputation** (the
famous canon, the official upstream, the well-regarded repo, the remembered citation, the number named
early) **and the person who knows the ground truth is the one who catches it.** Beats 5, 7, 9, 11, 12,
13, 14 were user-caught, most of them this exact shape; the recurrence, not any single catch, is why
the human-in-the-loop is load-bearing and why "verify or measure the thing, do not trust its
reputation" is a step here, not a footnote.

1. *Seed.* **Start from a named-provisional seed, not a spec** (beat 0). A first list drawn from one head is a
   convenience sample of one, suspect by construction. Mark it provisional in writing (every item a
   `[combine?]`) or you will defend it later out of habit.
2. *Validate, and distrust the instrument that validates.* **Dogfood, but never read a metric the corpus can bias** (beats 1, 2). Fire-frequency on a corpus
   you wrote *while applying the skill* measures importance times how-often-this-corpus-sins, and the
   second factor is near zero for the sins you avoid: a cold probe looks unimportant when it is
   *pre-avoided*. Do not average the confound away; **stratify** by it, and **freeze** every cut
   decision in writing until the corpus is representative.
3. **Add a deductive sweep for what runs can never show** (beats 3, 4). An inductive method is silent
   about the probes you *do not have*. Walk the field's canon to ask "is there a probe for each known
   principle?", independent of your code and so immune to its bias. Keep both finders: the inductive
   unhomed-finding (what real code does that you did not model) and the deductive canon walk (what the
   canon knows that you forgot) catch different misses.
4. *Measure honestly.* **Treat every label and quality tag as a prior the audit tests, never a fact to reason from**
   (beat 5). "This repo is clean," asserted from reputation, is the exact unrun claim the skill
   forbids, one level up. A subject's role (control vs fire-source) is an *output* of the audit, not a
   pre-assignment.
5. **Match the rigor claim to the instrument** (beat 6). A single-rater judgment tool (you design the
   probes *and* score whether they fire) yields *directional* signal: existence, contrast, and
   stopping-by-saturation, never a p-value. A significance number would be false precision, the same
   sin as reading module counts as rates.
6. **Complete the instrument's candidate set before you measure with it** (beat 7). If a later canon
   pass adds a probe, every audit already run was blind to it. Finish nomination first; changing the
   ruler after taking readings invalidates the readings.
7. **Fit the sample to the question, and measure the sample rather than trust its reputation**
   (beat 11). A saturation test wants a subject you *expect to be messy* (so "zero new" is a
   surprising, high-information outcome); a specificity control wants a clean one; they are not
   interchangeable. The prior is measurable at selection time (grep the panic/unwrap density), so do
   not even *select* on reputation.
8. *Let the folds and the flips teach you.* **A canon sweep pays off even when it mostly folds** (beats 8, 9). The folds *locate the skill*: the
   OO canon folding into plumb's type-first stance is what revealed plumb is a type-driven lens, not an
   OO one, and a reasoned non-gap is a result, not a blank. But a sweep inherits only the authority of
   the source it *actually opens*: a proxy reconstructed from memory is blind to exactly the real
   source's own contribution (the CxC guide's recoverable/unrecoverable idea, in no textbook), so open
   the file or label the proxy a proxy.
9. **Flip the context to audit the wording, not just the coverage** (beat 10). Sampling a new language
   family or domain does more than test saturation: a probe phrased as a *compiler guarantee* ("adding
   a case forces the update") has a language assumption baked into its words, and the flip is what
   exposes the smuggled premise. State the ideal separately from its enforcement.
10. *Organize and present.* **Check the frame of the choice you present, not just the options** (beat 12). When you offer a
    menu, the *axis the menu is built on* is itself a claim that can be wrong, and a menu is a
    comfortable place to hide an unexamined frame because it looks like deference. (The count dial was
    the artifact; the real axis was distinctness. Group distinct probes under one headline; fold only a
    probe with no new Move of its own.)
11. **A canonical term is a reference, not a label; and verify every citation, do not recall it**
    (beats 13, 14, 16). Lead with a transparent name the reader meets cold; cite the term-of-art in the
    body where a gloss can catch it, because a loose cite is worse than none (a reader who knows the
    term trusts the mapping). Then verify the references by *fetching* them: a document about grounding
    claims in their source fails its own principle if its citations were pasted from memory, and
    fetching moves real content (a park becomes a cite, a dead host becomes a book reprint), it is not
    ceremony. Show code, not prose about code (beat 15): an examples doc needs before/after blocks, and
    building commit-pinned links forces the same verification that catches drift.
12. *Vindicate, then maintain.* **Saturation is a finding, and a saturated corpus proves its own worth** (beats 8, 15): built and
    stratified until it saturated, the corpus held a concrete runnable instance of *every* probe, zero
    invented. Read a clean pass as a positive signal that the earlier work was thorough, not a wasted
    run, and that includes a late consistency sweep whose honest verdict is "no change" (beat 20): that
    is a result, not a skipped step.
13. **A miss is a distinct, high-value signal channel** (beat 17). A false negative (a real flaw no
    probe caught) is orthogonal to fire-frequency, so it bypasses corpus bias entirely: a clean corpus
    that can never surface a gap by *firing* can still surface one by *missing*. Triage it before
    landing: a missed bug or over-engineering is a correct deferral to a neighbor tool, not a miss; a
    shape no probe covers is a coverage gap that reopens nomination; a shape a probe covers but did not
    *name* is a wording gap.
14. **Know whether you are discovering or transcribing, and do not re-run a closed question** (beat 18).
    Discovery (is there an unhomed probe? does the ranking hold across languages?) gates on fresh runs
    and *saturates*; transcription (moving a corroborated signal into the wording) needs no new run.
    Once discovery saturates, more audits re-run a closed question.
15. **The load-bearing move often lands between the passes, and a self-authored claim needs an external
    trigger to be verified** (beat 19). The reshaping happens in the design dialogue *after* a review,
    not in the review; and a self-authored design rationalizes its own probes, so the likeliest real
    trigger is a reviewer or user who is not the author. A specific trap to name: a probe firing
    *positive* on a site can *mask* a different probe firing *negative* on the same site, because the
    flattering read arrives first and you stop, so before leaving a site you affirmed, ask which probe
    could *indict* it.
16. *Sustain.* **Publishing hands you a corpus you could never build by hand, but only if the signal can
    travel back, so wire the loop before you ship** (beat 21). Step 13's miss-channel goes silent the moment
    strangers use the skill: a miss is invisible to telemetry (a review skill that uploads a user's work is a
    trust non-starter, and violates the local-first stance the skill teaches) and usually invisible to the
    user too. The distribution unit is a prompt, so make the feedback mechanism one: a self-capture line that
    offers to build a triage-shaped report turns every user's model into a first-pass triage agent, and a
    structured issue form makes the well-formed report the easy path, not a free-text blob. Keep the skill
    pure and put the effect (the signal returning) at the edge, a human filing an issue, not the skill
    phoning home. And note the boundary this exposes: single-sourcing (step 11's "reference, don't restate")
    stops at the *ship line*, a shipped artifact must be self-contained, so the shipped side re-states the
    minimum or splits the content by altitude.
17. **Opening the loop is half of it; closing it is the other half** (beat 22). An intake with no
    consumption path is a suggestion box no one empties. Describe how a report becomes a refinement:
    triage it by the skill's *own* method (a report is a claim, so verify the miss by reconstructing and
    running the case, do not trust the report), then land it or decline it, and either way tell the
    reporter what changed, because people report again only if the first report visibly mattered. Keep the
    human who holds ground truth on the merge gate: "the tool missed X" is a reputation-plausible claim
    like any other.

**The single rule beneath all of them:** everything a reader will read, and every claim you make about
your own corpus, label, source, or frame, is a *claim to be run*, not a fact to reason from. Apply the
skill's own discipline to its own construction, recursively, and staff the seat the author cannot fill:
the reader meeting a label cold, the domain owner who knows the live source, and the run that survives
confirmation bias.
