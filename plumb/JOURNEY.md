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

---

## The transferable method (to finalize at the end)

*A stub for the closing: the checklist for building a non-mechanical, judgment-based skill, drawn
from the beats above. Provisional shape:*

1. Start from a named-provisional seed (beat 0).
2. Dogfood, but distrust any metric the dogfood corpus can bias (beats 1, 2).
3. Add a deductive canon sweep for what the corpus can never show you (beats 3, 4).
4. Treat every label and claim as a hypothesis to run, not a fact to reason from (beat 5).
5. Match your rigor claims to a single-rater instrument: signal, not statistics (beat 6).
6. Complete the instrument before you measure with it (beat 7).
7. Throughout: apply the skill's own discipline to the skill's own construction. If it judges
   against an ideal, so must its build; if it distrusts unrun claims, so must you.
