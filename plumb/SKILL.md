---
name: plumb
description: >-
  Structural design review that ranks findings by leverage — the single most
  load-bearing change first, measured by tracing a flaw to what consumes it
  downstream — and judges a diff, plan, or described design against the principle
  itself rather than the surrounding code, so conforming to a bad established
  pattern is itself a finding. Asks whether the code has the right SHAPE (not
  whether it works, which is code-review, nor whether it is minimal, which is
  ponytail-review). Probes against principled "soundings": make illegal states
  unrepresentable; model outcomes as typed values; handle every case; names that
  encode a type's shape; one source of truth; a functional core with effects
  injected at the edges (sans-IO / ports-and-adapters); faithful lossless
  round-tripping data; low
  coupling; cohesion; encapsulation; checks in the right tier; proportional
  response grounded in the real source; symmetry; a trivial common path over a
  complete core; reversibility (one-way vs two-way doors); and hunting the
  breaking edge. Works on a
  greenfield repo (nothing to conform to) and a brownfield one (where the
  established pattern may itself be the fault to push against). Use when reviewing
  structure/modeling, or when designing a new type, module, API, or check and you
  want the shape right before building. Triggers: "plumb", "is this modeled
  right", "design review", "structural review", "review the shape", "review my
  plan/design", "how should I model this", "should this be a sum type / Result",
  "is this sans-IO", "functional core imperative shell", "ports and adapters",
  "is this out of plumb".
---

# Plumb

A plumb line measures against *true vertical* — an external ideal — and does not
care how crooked the existing wall is. That is the stance: **is this
structurally true?**, judged against the principle, not against what happens to
be there. Plumb works on an empty repo (nothing to conform to) and on an old one
(where the established habit may be the fault). When the incumbent pattern *is*
the fallacy, name it and recommend departing from it: **conforming to bad
precedent is itself a finding.**

The largest wins rarely come from a typo. They come from noticing that an outcome
should have been a *value* not an exception, that a *name* lies about a type's
shape, or that an invalid state was left *representable*. Plumb hunts those.

Two modes:

- **Review** (default) — given a diff, plan, or described design, report findings
  ranked by *leverage* (most load-bearing first).
- **Guide** (say "guide" / "before I build") — the soundings as questions to
  answer for the design at hand before writing code.

*Each principle below is a **sounding** (a depth-probe you drop on the design).*

## What this is NOT

Plumb owns *modeling and structure*. It defers, by name, rather than duplicating:

- pure over-engineering / "does this need to exist" → **ponytail-review**
- line-level bugs, cleanup, style → **code-review**

Plumb's altitude is above both: *is the design the right shape?*

## The soundings (ranked by leverage)

> Draft ordering. `[combine?]` marks principles that overlap and are candidates
> to merge or fold in our tightening pass.

### 1. Make illegal states unrepresentable  `[combine? with 2, 7]`
Encode invariants in the type so a bad value cannot be constructed; parse
untrusted input into a trusted shape once, at the boundary, then trust it inward.
**Smell:** the same thing validated again and again downstream; a struct whose
fields permit combinations that are never valid; "remember to check X first."
**Move:** push the invariant into the constructor/type; parse-don't-validate at
the edge.

### 2. Model outcomes as values; lose no information  `[combine? with 1, 3]`
An operation with several meaningful outcomes returns a closed sum type, each case
carrying its own payload; errors are values, with an opt-in raise confined to the
edge. **Smell:** `X | None`, a bare bool, or an exception where the *reason*
matters; two distinct situations collapsed into one `None`. **Move:** name the
outcomes as typed cases; keep the rich result as truth, add a thin convenience
for the common path. **Boundary:** this takes the *errors-as-values* side; a
fail-fast/throw house style is a different tradition, not a violation — plumb's
position is that the raise belongs at the *edge* over a typed core, not that
exceptions are banned. Where a codebase is deliberately fail-fast, name the seam
(where the value becomes a raise), don't relitigate the philosophy.

### 3. Totality: handle every case  `[combine? with 2]`
Every input and every variant is handled; adding a case *forces* the update
(compiler-checked exhaustiveness), not a hoped-for edit. **Smell:** a
non-exhaustive match with a silent default; a fall-through that swallows the
unforeseen; a new variant that quietly breaks old callers. **Move:** make the
match exhaustive (assert-never); prefer closed sets the checker can enforce.

### 4. Names encode shape
A name tells you the *kind* — a one-of union vs a value+failures record vs a single
value; a verb pairs with its noun; a suffix means one thing everywhere. **Smell:**
a `*Result` that's really a value+failures record; a success-implying name on a
mixed union; a domain word reused for the wrong shape. **Move:** rename for
legibility; if a suffix is overloaded, split it and apply the split everywhere.

### 5. One source of truth; compose  `[combine? with 6, 14]`
One authoritative home for each piece of knowledge, reused by many consumers;
behavior built by composing small, single-purpose pure functions. **Smell:** the
same decision derived in three places; a rule, formula, or constant with several
homes that can drift apart; the "check" and "use" paths duplicating logic. **Move:**
extract the decision once and call it everywhere; compose the whole from named
parts rather than restating it. **Boundary:** repetition of a *shape* is not
automatically a violation. Before extracting, ask whether the repeated sites encode
the *same* decision or *different* ones — two idioms can look alike yet decide
oppositely on an edge (one collapses empty→absent, another preserves it), so a
shared helper would *flatten* that load-bearing distinction. Dedup "the same
knowledge in N places"; leave "similar-looking idioms encoding different semantics"
alone, and pin each with a test. The tell: could one helper serve every site
*without* a parameter that re-encodes the very difference? If not, it is not one
source of truth — it is N sources wearing the same coat, and merging them hides a
decision.

### 6. Functional core; effects at the edges  `[combine? with 5, 8]`
A pure core of functions over immutable data, with every effect and impure
dependency — I/O, the clock, randomness, the environment, mutable global state, the
framework — pushed to a thin shell and injected at the edge as a seam (a fetcher, a
clock, an RNG, a parser, a store). Same shape, three names: *functional core /
imperative shell* states it generally (a pure decision core, a thin effectful rim);
*sans-IO* is that idea specialized to I/O (logic defined only over in-memory
values, the caller owning every read and write, so one implementation serves sync,
asyncio, threads, or Trio unchanged); *ports and adapters* is its architectural
face (the pure core is the hexagon, effects live in boundary adapters).
Purity-by-default forces the split: impurity has to announce itself, so it gets
pushed to the rim. **Smell:** a core that *reaches for* an effect instead of
receiving it — `datetime.now()` or `random()` buried mid-logic, an env/config read
deep in the core, a hard-coded logger or global singleton, a framework imported by
a domain module — with the vivid special case being a library that bakes in one
transport (`requests` / `httpx` / `aiohttp`) or concurrency model, forcing that
dependency on every consumer (redundant when they already ship a different one) and
welding the logic to sync XOR async. **Move:** make the core *compute, never
perform* — pass the effect in as a value or a capability (the fetched bytes, an
injected `now` / `Fetch` / store) so callers supply their own and one core serves
every context, sync and async included.

*Lineage & sources:*
- sans-IO — sans-io.readthedocs.io/how-to-sans-io.html; firezone.dev/blog/sans-io
  (a Rust application of it)
- functional core / imperative shell — Bernhardt, "Boundaries" and the
  functional-core/imperative-shell screencast (destroyallsoftware.com); Google
  Testing Blog, 2025-10
- ports & adapters from FP — Seemann,
  blog.ploeh.dk/2016/03/18/functional-architecture-is-ports-and-adapters

### 7. Faithfulness: preserve the input  `[combine? with 1]`
The stored/decoded form reproduces the input exactly (it round-trips); any lossy
interpretation is an opt-in projection, never the stored representation. **Smell:**
a decode that normalizes, rounds, or drops precision; a model that cannot
reproduce what it read. **Move:** store faithfully; offer lossy views as separate,
opt-in operations.

### 8. Low coupling, clean boundaries  `[combine? with 9, 10]`
Modules are leaves or near-leaves; imports flow one direction; a module names
another's *public* surface, never its internals; the core knows nothing of its
optional bridges. **Smell:** import cycles; a low-level module importing a
high-level one; reaching past a public API into a private helper; a "utility" that
drags a heavy/optional dependency in at import. **Move:** invert the dependency
(inject, don't import); rehome shared helpers neutrally; import optional deps
lazily.

### 9. Cohesion: one concern per unit  `[combine? with 8]`
A module/type/function does one thing; you can name it without an "and."
**Smell:** a grab-bag module; a function whose doc lists three unrelated jobs.
**Move:** split by concern.

### 10. Encapsulation: expose intent, hide representation  `[combine? with 8]`
Callers depend on what a thing *means*, not how it's built; the representation can
change without breaking them. **Smell:** callers reaching into fields/internals; an
abstraction that leaks its storage; invariants a caller must maintain by hand.
**Move:** expose intent-named operations; make the representation private; keep
invariants inside.

### 11. Put the check in the right tier
Local, O(1), single-object invariants at construction; cross-cutting or
data-scanning checks in an opt-in pass, so loading stays permissive and faithful.
**Smell:** a cross-object or O(n) rule jammed into a constructor (a slightly-off
document won't even load); a genuinely-local invariant left unchecked. **Move:**
match the check's placement to its scope and cost.

### 12. Proportional response, grounded in the real source
A requirement graded mandatory drives an *error*; recommended drives a *warning*;
optional is permitted. Claims about an authority (spec, RFC, API contract, docs, a
ticket) are verified against it and cited — never asserted from memory. With **no**
external authority, the same discipline applies to the project's own stated
requirements: separate a real requirement from a preference and enforce each
proportionally. **Smell:** severity or hard-vs-soft chosen by vibes; "the spec says
MUST" without opening it; a preference enforced as a requirement (over-strict) or a
requirement left unenforced (under-strict); a constraint invented from nothing.
**Move:** find the governing source (or the stated requirement); confirm the claim
*and its strength*; let it pick the response. Absent a governing rule, don't
manufacture one — the absence of a requirement is information.

### 13. Symmetry
Paired operations exist and mirror each other (encode/decode, to/from, set/get,
sync/async); shapes that should match, match. **Smell:** a lone half (a decoder
with no encoder); asymmetric signatures for symmetric ideas; a round-trip that
doesn't round-trip. **Move:** complete the pair or justify its absence; align the
mirrored shapes.

### 14. Trivial common path over a complete core  `[combine? with 5]`
The 90% case is a one-liner (a thin convenience); the 10% case is not locked out
(the rich form remains reachable). **Smell:** a rich API forced on every caller; or
a convenient API with no escape hatch to the full thing. **Move:** layer a thin
convenience over a complete core; export both.

### 15. Reversibility: know the door
Distinguish one-way doors (costly to undo: a public API, a wire format, stored
data) from two-way; keep the blast radius of a possibly-wrong decision contained.
**Smell:** a hard-to-reverse choice made lightly; an experiment wired through a
one-way door; a wrong guess whose blast radius is the whole codebase. **Move:**
spend care in proportion to reversibility; keep two-way doors cheap; isolate the
risky bet behind a seam.

### 16. Hunt the breaking edge
The design is probed with the input that violates its assumption — out-of-range,
non-ASCII, empty/`None`, reduced-precision, adversarial. **Smell:** an assumption
("a 4-digit ASCII year", "it fits in a datetime") with no case testing its
boundary. **Move:** name the assumption; find the *legal* input that breaks it, then
**construct and run** it — a "bounded/negligible" verdict is un-earned until that
input has actually run; add the case. The run target is wider than the input under
review: run the *excluded* case (a green exclusion proves the filter fires, not that
its stated *reason* holds), the downstream *consumer* (its crash-vs-silent-repair-vs-reject
profile ranks the rules you plan *before* you write code), and the *check itself* —
delete a `case` arm to confirm the type-checker goes red, and run the boundary on the
*oldest supported environment*; a green check never fed a known-red input is unearned.
Resolve a default to the value it *produces* and run that, not "the default" as an
abstraction.

### 17. Locality of behavior: keep behavior with its data  `[combine? with 9, 10]`
Behavior lives with the data it operates on; a method that reads another object's
fields more than its own belongs on *that* object (feature envy). **Smell:** a
method calling many getters on one collaborator and few on `self`; logic that
reaches across a boundary to assemble what the other side should compute and expose.
**Move:** move the behavior to the data (tell-don't-ask); or, if the data is a plain
value, compose a function over it beside its definition. **Boundary:** adjacent to
cohesion (9, *one* concern per unit) and encapsulation (10, hide representation) but
distinct — this is the method-*placement* face of the same pull (GRASP *Information
Expert* / *Tell, Don't Ask*). Harvested from the clean-code rubric; the
`[combine?]` marker defers merge-or-keep to the tightening pass.

## Output

**Review mode** — a list ranked most-leverage-first, one line per finding:

```
<sounding> · <file:line or component> · <what's off> → <the move>
```

Lead with the single highest-leverage change if there is one. End with
`net: <the one change that matters most>`, or `Plumb is true.` when nothing
structural is off. Route correctness bugs to code-review and over-engineering to
ponytail-review *by name*, not here.

**Expand the load-bearing findings.** The one-liner is the scannable spine, not
the whole report. For the highest-leverage finding, and for *every* note-and-park
verdict — a "leave it" with no reasoning is the surest trigger for "wait, what's
actually wrong?" — write a short block beneath the line that pre-empts the
follow-up question, in three beats:

- **The concrete instance** — the exact illegal value, state, or call, spelled
  out (`Moment(naive, SECOND)`), never "an invalid combination." When the smell
  is an illegal state left representable, count the states and show the legal
  slice: a three-row table beats a paragraph.
- **The failure scenario** — the specific input and consumer that turn the flaw
  into a wrong outcome. This is the same downstream trace that set the finding's
  rank (the caller that trusts the lie, the check it defeats), so you write it
  once and it serves twice.
- **Why the obvious fix is wrong, or what the real fix costs** — so the reader
  neither reaches for the naive fix nor, on a park, wonders why you didn't act.

Leave the tail as one-liners; expanding a nit is noise. The test: if a reader
would reasonably reply "explain that one," it needed the block up front.

**Guide mode** — walk the soundings as questions for the design at hand, answer
each for the specific case (not in the abstract), and finish with the one or two
that most shape this solution.

## Working notes

- Rank by *leverage*, not count. One "this should be a sum type" beats ten nits.
- Measure that leverage by tracing the flaw to what *consumes* it. A mislabeled
  case or a lying name is a nit until you follow it downstream to the thing it
  breaks — a check it defeats, a caller it silently misleads; the blast radius
  sets the rank, not the size of the local wrongness. The same trace splits *fix*
  from *note-and-park*: a defect the normal entry point can reach is load-bearing;
  one whose bad state has no path to a consumer — a lone trusted constructor
  already upholds it — is real but parkable, so name it, give the cost-vs-risk in
  a line, and move on.
- Prefer the change that makes an illegal state *unrepresentable* over the one that
  adds a guard.
- Judge against the ideal, not the incumbent. A widespread bad pattern is a bigger
  finding, not an excuse.
- A name is part of the design: a misleading name is a defect, not a preference.
- Be concrete: name the exact case, the exact rename, the exact seam. "Consider
  decoupling" is not a finding; "`_bridging` imports `validation`, inverting the
  layering — inject the check instead" is.
- When a sounding doesn't apply, say so briefly; don't manufacture a finding to
  fill it.
- Run plumb at both altitudes — on the *plan* before code, and again on the *diff*
  after. They are complementary, not redundant: the two passes catch different
  flaws. (On #14 the plan-review's headline was a host-app naming collision; the
  diff-review's was a one-source-of-truth drift that only existed once code was
  written.) Each pass earns its keep.
- "Affirmed" is not "closed"; a discharge is an action, not an argument. "The fix
  landed", "the edge is bounded", "it's negligible" are *claims* — discharge them by
  doing: sweep the new code for a fresh instance of the same sounding (affirming one
  landed is the cue to hunt its *other* instances, not to close it out), or
  *construct and run* the breaking input. When you authored what you're reviewing,
  this is mandatory — a self-authored design rationalizes its own soundings, and only
  a run survives confirmation bias (a careful code-read, even a subagent's, is still
  reasoning until run). The claim need not be code: a docstring, a narrative `.md` no
  build executes, a test's own predicate (copied from the code it guards, so blind to
  that predicate going stale), a `# pragma: no cover` — each is an un-run assertion,
  and after a decision *reverses*, stale prose is the top risk because nothing compiles
  it. The discharge must hunt the ground the last sweep *skipped*: re-running the cases
  already green is confirmation bias in a lab coat. Provenance to plan around: a
  self-authored design does not reliably run its own claims even when this note says to,
  so the likeliest real trigger is an external prompt — a reviewer, or the user, who is
  not the author.
