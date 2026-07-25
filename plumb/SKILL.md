---
name: plumb
description: >-
  Structural design review that ranks findings by leverage: the single most
  load-bearing change first, measured by tracing a flaw to what consumes it
  downstream, and judges a diff, plan, or described design against the principle
  itself rather than the surrounding code, so conforming to a bad established
  pattern is itself a finding. Asks whether the code has the right SHAPE (not
  whether it works, which is code-review, nor whether it is minimal, which is
  ponytail-review). Probes against principled "soundings", grouped into ten: correct by
  construction (make illegal states unrepresentable, model the domain with types
  not primitives / primitive obsession, model outcomes as typed values /
  discriminated unions / Result, totality, sound typing); one source of truth
  (DRY); focused parts with clean seams (low coupling, cohesion, encapsulation,
  keep behavior near its data / feature envy, command-query separation); a
  functional core with effects injected at the edges (sans-IO / ports-and-adapters
  / hexagonal architecture / dependency injection); faithful round-trips
  (faithfulness, symmetry); match strictness to the requirement (proportional
  response grounded in the source, RFC 2119); names that encode shape; put each
  check in the right tier; reversibility (one-way vs two-way doors); and hunting
  the breaking edge. Works on a
  greenfield repo (nothing to conform to) and a brownfield one (where the
  established pattern may itself be the fault to push against). Use when reviewing
  structure/modeling, or when designing a new type, module, API, or check and you
  want the shape right before building. Triggers: "plumb", "is this modeled
  right", "design review", "structural review", "review the shape", "review my
  plan/design", "how should I model this", "should this be a sum type / Result",
  "is this sans-IO", "functional core imperative shell", "ports and adapters",
  "hexagonal architecture", "make illegal states unrepresentable",
  "command-query separation", "is this out of plumb".
---

# Plumb

A plumb line measures against *true vertical* (an external ideal) and does not
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

- **Review** (default): given a diff, plan, or described design, report findings
  ranked by *leverage* (most load-bearing first).
- **Guide** (say "guide" / "before I build"): the soundings as questions to
  answer for the design at hand before writing code.

*Each principle below is a **sounding** (a depth-probe you drop on the design).*

## What this is NOT

Plumb owns *modeling and structure*. It defers, by name, rather than duplicating:

- pure over-engineering / "does this need to exist" → **ponytail-review**
- line-level bugs, cleanup, style → **code-review**

Plumb's altitude is above both: *is the design the right shape?*

## The soundings (grouped, ranked by leverage)

> The soundings are organized into **clusters** whose facets reinforce each
> other, interleaved with standalone soundings, ordered by *leverage* (the ones
> that most often carry the load-bearing finding come first). Cite a facet by its
> id (`1b`, `3e`) in a finding. A cluster is one review station with several
> questions, not one blurred principle: each facet keeps its own Smell and Move.
> How the clusters reinforce each other is mapped at the end. A worked example for
> every facet (a real trigger and its move, drawn from the dogfood log) lives in
> [EXAMPLES.md](EXAMPLES.md); the verified primary source behind each named concept
> (DRY, information hiding, CQS, …) lives in [REFERENCES.md](REFERENCES.md).

### 1. Correct by construction

Push correctness into the types themselves, so the static type checker rejects bad
states before the code runs, instead of tests chasing them at runtime.

*One family: make the type carry the truth so the checker enforces it. The facets
chain, lift the primitive into a real type (1b), make its illegal states
unrepresentable (1a), model the outcomes as typed cases (1c), force every case to
be handled (1d), and keep the checker able to see all of it (1e). Each fires on
its own; together they are the highest-leverage cluster, because a flaw here is
the kind no downstream test can catch.*

*The extended **why** for this cluster (brands vs value objects, smart
constructors, where invariants come from, the leak surface) is the companion
guide [Correct by
Construction](https://github.com/chuckwondo/digital-garden/blob/main/content/correct-by-construction.md).
Plumb is the operational review; that guide is the worked-in-depth rationale.*

**1a. Make illegal states unrepresentable.** Shape the type so a bad value can't
be built in the first place: invariants hold by construction, not by remembering to
check them. The same discipline pointed at other axes: an *immutable* value (no later
setter can break the invariant); an illegal *sequence* made unrepresentable (the
*typestate* pattern: a capability the next call requires, so "log in before use"
cannot compile wrong); an ignored *outcome* made unrepresentable (the
designer half of must-consume, exactly what Rust's `#[must_use]` encodes).
**Smell:** the same thing validated again and again downstream; a struct whose
fields permit combinations that are never valid; "remember to check X first"; a
shared dict/map written by several producers with no proof the keys are disjoint
(a collision resolves last-writer-wins, silently binding one key to the wrong
value). **Move:** push the invariant into the constructor/type;
parse-don't-validate at the edge. When the language closes the type-level rung (the
invariant can't be made a compile error), drop to an *enforcing test* that fails on the
regression, never settle at a comment, which only informs.

**1b. Model the domain with types, not primitives.** Give a closed-set or structured
value its own named type instead of a general-purpose primitive (a plain string,
number, or positional tuple), so misuse is a type error and the meaning is legible.
A field-group that always travels together becomes one object. First split
**brand** (a role with *no* invariant to check: a `NewType`/tag) from **value
object** (a real invariant: a smart constructor); the gate is "is there anything
to check?" **Smell (primitive obsession):** a `str` standing in for a closed enum (`strategy`, `status`,
`role`) dispatched by `if/elif`; a structured value smuggled as a string (a
`"start/end"` interval re-`split` at three call sites); a recurring positional
tuple (`(lat, lon)`, `(endpoint, region)`) where a named record belongs;
`**kwargs: Any` on a public signature that a misspelled key passes through
silently. **Move:** lift the primitive into the domain type: a `Literal`/enum for
a closed set (which also makes the dispatch compiler-exhaustive, reinforcing 1d), a
parsed sum for a structured value (reinforcing 1c), a small record for a
data-clump. **Boundary:** distinct from 1a (illegal *combinations* of fields, not
the primitive-vs-type choice) and 7 (a name can be exact while the *type* stays
primitive). It fires only on a closed-set / structured value a *downstream consumer
trusts as a domain value*, not a transient token consumed on the next line (a regex
capture used once, never stored).

**1c. Model outcomes as typed values.** Return each meaningful outcome as its
own typed case with its payload, so no caller can ignore a case and nothing is lost
to a bare null or boolean. The shape is a closed sum type (a *discriminated union*;
for outcomes specifically, *Result* / *Either* / *Option*); errors are values, with
an opt-in raise confined to the edge. **Smell:** `X |
None`, a bare bool, or an exception where the *reason* matters; two distinct
situations collapsed into one `None`. **Move:** name the outcomes as typed cases;
keep the rich result as truth, add a thin convenience for the common path.
**Boundary:** this takes the *errors-as-values* side; a fail-fast/throw house style
is a different tradition, not a violation: plumb's position is that the raise
belongs at the *edge* over a typed core, not that exceptions are banned. Where a
codebase is deliberately fail-fast, name the seam (where the value becomes a
raise), don't relitigate the philosophy.

**1d. Totality: handle every case.** Handle every variant, and make adding a new one
a type error until it's handled too, so the unforeseen case can't slip through a
silent default. **Smell:** a non-exhaustive match with a silent default; a
fall-through that swallows the unforeseen; a new variant that quietly breaks old
callers. **Move:** make the match exhaustive (`assert_never`); prefer closed sets
the checker can enforce. **Note (the guarantee is language-dependent):** "adding a
case forces the update" assumes a checker that enforces exhaustiveness. That holds
for a closed sum matched with `assert_never`, but *not* for error-values: Go's
`(T, error)` lets `_ :=` and a bare call compile clean with `go vet` silent, and
Rust's `#[must_use] Result` *warns* yet is routinely opted out of (`let _ =`,
`.unwrap()`, a `Default` fallback). So for error-values (Go, C return codes,
unchecked exceptions) totality degrades to opt-in tooling (`errcheck`/
`staticcheck`) or a runtime silent-drop; name it as a discipline, not a compiler
guarantee, where the language doesn't provide the check.

**1e. Sound typing: no lies to the checker.** Keep the declared types honest, with no
catch-all "any" or unchecked cast to launder past them, so the static type checker
sees the real shape and can enforce the rest. **Smell:** a
`Literal[...] | Any` that collapses the whole union back to `Any` (defeating the
Literal's point); a public function annotated `-> Any` that in fact returns one
known type; a function that always raises but is annotated with its nominal
return type (`__bool__ -> bool` instead of `NoReturn`), so the checker cannot see
it never returns and cannot flag `if x:` / `bool(x)` as unreachable; a
`Mapping[str, str]` under-specifying two distinct record shapes; a
`cast(...)` (a *named* escape) or a bare annotated assignment (a *silent* one)
vouching for what wasn't checked; a `TypeIs` predicate *stricter* than the type it
narrows, whose false-branch narrowing is then unsound (only a positive-only
`TypeGuard` is correct). **Move:** annotate the real type; replace the `Any`/`cast`
with a parse or a guard that earns the type; where a predicate is stricter than its
input, use `TypeGuard`, not `TypeIs`. **Boundary:** bound tightly against 1d
(totality is *handling* every case; this is *not blinding the checker* so it *can*
force the cases) and 10 (10 exercises the checker by feeding a known-red input; this
keeps the checker able to see red at all). An `Any` at a genuine dynamic edge (an
untyped blob, a cache) is parked, not a violation; the fire is an `Any` that
*defeats a declared type*.

### 2. One source of truth

Keep each piece of knowledge in one authoritative home and derive the rest, so
nothing drifts out of sync and a change lands in exactly one place. This is the *DRY*
principle (a *single source of truth*): one authoritative representation of every
piece of knowledge, with behavior built by composing small, single-purpose pure
functions. **Smell:** the
same decision derived in three places; a rule, formula, or constant with several
homes that can drift apart; the "check" and "use" paths duplicating logic. **Move:**
extract the decision once and call it everywhere; compose the whole from named
parts rather than restating it. **Boundary:** repetition of a *shape* is not
automatically a violation (Sandi Metz: "duplication is far cheaper than the wrong
abstraction"). Before extracting, ask whether the repeated sites encode
the *same* decision or *different* ones: two idioms can look alike yet decide
oppositely on an edge (one collapses empty→absent, another preserves it), so a
shared helper would *flatten* that load-bearing distinction. Dedup "the same
knowledge in N places"; leave "similar-looking idioms encoding different semantics"
alone, and pin each with a test. The tell: could one helper serve every site
*without* a parameter that re-encodes the very difference? If not, it is not one
source of truth: it is N sources wearing the same coat, and merging them hides a
decision. **Rider (trivial common path over a complete core):** the 90% case should
be a one-liner (a thin convenience) layered *over* the one authoritative core, and
the 10% case not locked out (the rich form stays reachable). A rich API forced on
every caller, or a convenient API with no escape hatch to the full thing, is the
smell; layer the convenience over the complete core and export both. (This rides
here rather than standing alone: it prescribes the *shape* of the single source's
public face, and in practice it only ever affirmed a thin convenience shell, never
driving a finding of its own.)

### 3. Focused parts, clean seams

Carve the system so each part has one job and connects through narrow, honest
interfaces, so you can change one part without breaking the others.

*The shape of modules and of the methods inside them. Facets: imports flow one
direction (3a) and callers depend on meaning not representation (3b) at the module
boundary; each unit does one thing (3c), behavior lives with its data (3d), and a
method either asks or does but not both (3e) inside it. Low coupling (3a) and high
cohesion (3c) are the classic pair; encapsulation (3b) is what lets you decouple;
locality (3d) and CQS (3e) are the per-method discipline that keeps a unit honest.*

**3a. Low coupling, clean boundaries.** Let dependencies flow one direction through
public surfaces only, so a change in one module doesn't ripple through the rest.
Modules are leaves or near-leaves; a module names another's *public* surface, never
its internals; the core knows nothing of its optional bridges. **Smell:** import cycles; a
low-level module importing a high-level one; reaching past a public API into a
private helper; a "utility" that drags a heavy/optional dependency in at import.
**Move:** invert the dependency (*dependency inversion*: inject, don't import);
rehome shared helpers neutrally; import optional deps lazily.

**3b. Encapsulation: expose intent, hide representation.** Let callers depend on what
a thing *means*, not how it's stored, so you can change the representation without
breaking them. This is *information hiding* (Parnas): the representation stays private
behind an intent-named surface. **Smell:** callers reaching into fields/internals; an
abstraction that leaks its storage (a *leaky abstraction*); invariants a caller must
maintain by hand. **Move:** expose
intent-named operations; make the representation private; keep invariants inside.

**3c. Cohesion: one concern per unit.** Give each unit a single job you can name
without an "and," so it's easy to find, understand, and change. This is the *Single
Responsibility Principle*: a module/type/function does one thing. **Smell:** a grab-bag module; a function whose doc
lists three unrelated jobs. **Move:** split by concern.

**3d. Keep behavior near the data it uses most.** Put a behavior where the data it
leans on lives, so logic doesn't reach across a boundary to reassemble what the owner
should compute itself. **Smell (feature envy):** a method calling many getters on
one collaborator and few on `self`; logic that reaches across a boundary to assemble
what the other side should compute and expose. **Move:** move the behavior to the
data (tell-don't-ask); or, if the data is a plain value, compose a function over it
beside its definition. **Boundary:** the method-*placement* face of the same pull as
cohesion (3c, *one* concern per unit) and encapsulation (3b, hide representation),
distinct in being about *where a method lives* (GRASP *Information Expert* / *Tell,
Don't Ask*).

**3e. Command-Query Separation: ask or do, not both.** Let a method either return a
value (a query, with no observable mutation) or cause a change (a command), never
both, so a query is safe to call and a command's effect is visible at the call site. **Smell:** a `get_`/`is_`/`__repr__`-named query
that mutates `self` or its argument and returns a status; a command that also returns
a value callers start to depend on. **Move:** split the query from the command; if a
caller needs both, let it call both, so the mutation is visible at the call site.
**Boundary:** distinct from 4 (4 is *where* effects live: a CQS-violating method can
sit wholly in the imperative shell and still mix asking with doing) and from 3c
(generic cohesion: CQS is the narrower, per-method, mechanically-checkable split,
does this one method both return *and* mutate?). Its blast radius is a query a caller
trusts as pure: a `repr()` that silently rewrites the record it prints breaks any
consumer that re-reads that record after inspecting it.

### 4. Functional core, effects at the edges

Keep decisions in a pure core and inject I/O, the clock, and randomness through seams
at the rim, so a test supplies its own stand-in at the seam (a fixed clock, an
in-memory store) rather than a mocking library, and one core runs the same whether
sync or async. A pure core of functions over immutable data pushes every effect and
impure dependency (I/O, the clock, randomness, the environment, mutable global state,
the framework) to a thin shell, injected at the edge as a seam (a fetcher, a clock,
an RNG, a parser, a store). Same shape, three names: *functional core /
imperative shell* states it generally (a pure decision core, a thin effectful rim);
*sans-IO* is that idea specialized to I/O (logic defined only over in-memory
values, the caller owning every read and write, so one implementation serves sync,
asyncio, threads, or Trio unchanged); *ports and adapters* (a.k.a. *hexagonal
architecture*) is its architectural face (the pure core is the hexagon, effects live
in boundary adapters).
Purity-by-default forces the split: impurity has to announce itself, so it gets
pushed to the rim. **Smell:** a core that *reaches for* an effect instead of
receiving it: `datetime.now()` or `random()` buried mid-logic, an env/config read
deep in the core, a hard-coded logger or global singleton, a framework imported by
a domain module, with the vivid special case being a library that bakes in one
transport (`requests` / `httpx` / `aiohttp`) or concurrency model, forcing that
dependency on every consumer (redundant when they already ship a different one) and
welding the logic to sync XOR async. This is where *testability without mocks* shows
up as a symptom: a core that receives its effects is tested by passing values, so a
wall of mocks is the tell that an effect was reached for, not injected. **Move:**
make the core *compute, never perform*: pass the effect in as a value or a
capability (this is *dependency injection*: the caller supplies the effect rather
than the core reaching for it; the fetched bytes, an injected `now` / `Fetch` /
store) so callers supply their own and one core serves every context, sync and async
included.

*Lineage & sources: see [REFERENCES.md](REFERENCES.md#4-functional-core-effects-at-the-edges)
(sans-IO, Bernhardt's functional-core/imperative-shell, Cockburn's hexagonal
architecture, Seemann, Fowler on DI).*

### 5. Faithful round-trips

Preserve what you took in and mirror the operations that carry data in and out, so a
value survives a round-trip unchanged.

*A stored form that reproduces its input (5a) and a complete set of mirrored
operations (5b) are the two halves of a real round-trip: a faithful store with no
encoder can't prove it round-trips, and a symmetric encode/decode pair over a lossy
store round-trips to the wrong value.*

**5a. Faithfulness: preserve the input.** Store the input so it reproduces exactly,
and keep any lossy interpretation as an opt-in view, so you never silently discard
what you read. **Smell:** a decode that normalizes, rounds, or
drops precision; a model that cannot reproduce what it read. **Move:** store
faithfully; offer lossy views as separate, opt-in operations.

**5b. Symmetry: complete the pair.** For every operation with a natural inverse
(encode/decode, to/from, set/get), provide and align its partner, so the pair
actually round-trips. **Smell:** a lone
half (a decoder with no encoder); asymmetric signatures for symmetric ideas; a
round-trip that doesn't round-trip. **Move:** complete the pair or justify its
absence; align the mirrored shapes.

### 6. Match strictness to the requirement

Enforce each rule as strongly as its source demands, and verify that strength at the
source rather than guess it, so you land neither over- nor under-strict. Grade the
response to the requirement's level (the *RFC 2119* keywords: mandatory/MUST→error,
recommended/SHOULD→warning, optional/MAY→permitted). Claims about an authority (spec, RFC, API contract, docs, a
ticket) are verified against it and cited, never asserted from memory. With **no**
external authority, the same discipline applies to the project's own stated
requirements: separate a real requirement from a preference and enforce each
proportionally. **Smell:** severity or hard-vs-soft chosen by vibes; "the spec says
MUST" without opening it; a preference enforced as a requirement (over-strict) or a
requirement left unenforced (under-strict); a constraint invented from nothing; a
*quantitative* claim ("~3x faster") taken from memory or a diffstat rather than a
measurement; a field's *type* shaped by the ticket's paraphrase rather than the
source; a contract reworded to match a known bug.
**Move:** find the governing source (or the stated requirement); confirm the claim
*and its strength*; let it pick the response. Absent a governing rule, don't
manufacture one: the absence of a requirement is information. Verifying the source is
wider than grading severity: **pin the exact revision** under review (a finding is
incomplete without the SHA it is against); check the source's **shape**, not only its
strength, since a ticket's one-line paraphrase can drop permitted *alternatives* and
encode a type that false-positives a conformant input; open the source the diff
**implements** (the issue, ADR, or header it was written from), not only the authority
it cites, because a faithful diff over a false source puts the fix upstream; and ground
a contract in its **intended** behavior, rewording it only if the intent itself is
wrong, never to match a tracked, fixable bug (which enshrines the defect and drifts
when the fix lands). Verifying can *close* a suspected finding as readily as sharpen a
real one.

### 7. Names encode shape

Let a name tell you the kind of thing it is (a union, a value, a result), so the
shape is legible at the call site and a lying name can't mislead. A verb pairs with
its noun; a suffix means one thing everywhere. **Smell:**
a `*Result` that's really a value+failures record; a success-implying name on a
mixed union; a domain word reused for the wrong shape. **Move:** rename for
legibility; if a suffix is overloaded, split it and apply the split everywhere.

### 8. Put each check where it belongs

Place cheap local invariants (O(1), single-object) at construction and cross-cutting
or data-scanning checks in an opt-in pass, so loading stays permissive and each check
runs where its scope and cost fit.
**Smell:** a cross-object or O(n) rule jammed into a constructor (a slightly-off
document won't even load); a genuinely-local invariant left unchecked. **Move:**
match the check's placement to its scope and cost.

### 9. Reversibility: one-way vs two-way doors

Tell hard-to-undo decisions (a public API, a wire format, stored data) from easily
reversible ones and spend care in proportion, so a wrong guess stays cheap to walk
back.
**Smell:** a hard-to-reverse choice made lightly; an experiment wired through a
one-way door; a wrong guess whose blast radius is the whole codebase. **Move:**
spend care in proportion to reversibility; keep two-way doors cheap; isolate the
risky bet behind a seam.

### 10. Hunt the breaking edge

Find the legal input that breaks the design's assumption and actually run it, so
"that can't happen" is tested, not hoped for. Probe with the input that violates the
assumption: out-of-range, non-ASCII, empty/null, reduced-precision, adversarial. **Smell:** an assumption
("a 4-digit ASCII year", "it fits in a datetime") with no case testing its
boundary. **Move:** name the assumption *as a precise invariant*, then find the *legal*
input that *violates* it, then **construct and run** it (for a decoder or wire type,
build the case by *decoding bytes*, not a hand-typed literal: a literal can carry
runtime types the wire never produces, e.g. a decoded `tuple[Any, ...]` with `list`
interiors, and miss the very edge it cannot reach): a "bounded/negligible"
verdict is un-earned until that input has actually run; add the case. A legal
input the design handles *correctly* is not the breaking edge, however untested;
the breaking edge is the one that violates the invariant (e.g. two producers
writing one shared key). The run target is wider than the input under
review: run the *excluded* case (a green exclusion proves the filter fires, not that
its stated *reason* holds), the downstream *consumer* (its crash-vs-silent-repair-vs-reject
profile ranks the rules you plan *before* you write code), a *sibling* implementation of
the same operation (run the other paths of an N-path design on the same input *before*
adopting the buggy path's own proposed fix; a sibling that already handles it *names the
shape* the issue and the ADR missed, and in guide mode this runs before any code, sharper
than running a neighbor merely to settle a detail), and the *check itself*:
delete a `case` arm to confirm the type-checker goes red, and run the boundary on the
*oldest supported environment*; a green check never fed a known-red input is unearned.
Resolve a default to the value it *produces* and run that, not "the default" as an
abstraction.

## How the clusters reinforce each other

The soundings are not independent; the load-bearing finding usually lives where two
of them meet. The map (from the observed co-fires):

- **1 (correct by construction) × 2 (one source of truth):** a missing sum member
  is silently omitted downstream, and the drift's *leverage* is that one source of
  truth was lost, not the local omission. Model the outcome as a case *and* give it
  one home.
- **1 × 10 (hunt the edge):** 10 is *how you verify* a totality or illegal-state
  claim, run the maximizing input; and 1e (sound typing) is what keeps the checker
  able to *see* the red edge 10 feeds it.
- **5 (faithfulness) × 1a:** an unfaithful shape forces an invented axis, then guards,
  then a defensive comment. Fix the representation and the guards dissolve.
- **4 (functional core) × 6 (match strictness):** a SHOULD conditional on an
  unfetchable remote is the signal to push the effect to the edge, not to weaken the
  rule.
- **7 (names) × 10:** a name that lies about a shape is most often surfaced by the
  breaking input that the true shape would have handled.
- **6 × 2, 6 × 3a:** an over-claimed severity and a coupling both trace back to a
  single authority read wrong; verify the source once and both rank correctly.
- **1a × 1e:** a guard that raises to make an operation unrepresentable (1a) is
  enforced *statically* only if the raising method is annotated `-> NoReturn` (1e);
  the nominal return type leaves the guard runtime-only, and the checker passes
  `if x:` / `bool(x)` green.

## Output

**Review mode**: a list ranked most-leverage-first. When there are findings, lead
the list with the line `Soundings violated (most-leverage first):`, then one line
per finding:

```
<id>: <name> · <file:line or component> · <what's off> → <the move>
```

`<id>` is the sounding or facet id and `<name>` its short label from the legend
below. The id is the key (it cross-references EXAMPLES, TIGHTENING, and the cluster
map); the name gives the reader context, so a finding never renders as a bare
number. Example: `1a: Make illegal states unrepresentable · store.py:88 · two
producers write one key with no coordination → make the pairing a single owned
type`. Lead with the single highest-leverage change if there is one. End with
`net: <the one change that matters most>`, or `Plumb is true.` when nothing
structural is off. Route correctness bugs to code-review and over-engineering to
ponytail-review *by name*, not here.

**Sounding labels** (the canonical `<name>` per id, and the one source of truth for
the output line):

- **1a** Make illegal states unrepresentable
- **1b** Model with types, not primitives
- **1c** Model outcomes as typed values
- **1d** Handle every case (totality)
- **1e** Keep declared types honest
- **2** Keep one source of truth
- **3a** Keep coupling low (one-way dependencies)
- **3b** Expose intent, hide representation
- **3c** Keep one concern per unit (cohesion)
- **3d** Keep behavior near its data
- **3e** Separate commands from queries
- **4** Push effects to edges
- **5a** Preserve input faithfully
- **5b** Complete inverse pairs (symmetry)
- **6** Match strictness to requirement
- **7** Make names encode shape
- **8** Put checks in correct tier
- **9** Weigh walk-back cost before committing
- **10** Prove claims by running breaking cases, not reasoning

**Expand the load-bearing findings.** The one-liner is the scannable spine, not
the whole report. For the highest-leverage finding, and for *every* note-and-park
verdict (a "leave it" with no reasoning is the surest trigger for "wait, what's
actually wrong?"), write a short block beneath the line that pre-empts the
follow-up question, in three beats:

- **The concrete instance**: the exact illegal value, state, or call, spelled
  out (`Moment(naive, SECOND)`), never "an invalid combination." When the smell
  is an illegal state left representable, count the states and show the legal
  slice: a three-row table beats a paragraph.
- **The failure scenario**: the specific input and consumer that turn the flaw
  into a wrong outcome. This is the same downstream trace that set the finding's
  rank (the caller that trusts the lie, the check it defeats), so you write it
  once and it serves twice.
- **Why the obvious fix is wrong, or what the real fix costs**, so the reader
  neither reaches for the naive fix nor, on a park, wonders why you didn't act.

Leave the tail as one-liners; expanding a nit is noise. The test: if a reader
would reasonably reply "explain that one," it needed the block up front.

**Guide mode**: walk the soundings as questions for the design at hand, answer
each for the specific case (not in the abstract), and finish with the one or two
that most shape this solution.

**When a user says plumb missed or misfired**: offer to build a structured
report, not a free-text complaint, and hand back a ready-to-file report.
Run the triage at the edge: the *lane check* (only a structural/modeling miss is
plumb's; a missed correctness bug routes to code-review and missed
over-engineering to ponytail-review, both correct deferrals, not misses), and
*coverage vs wording* (does no sounding cover the shape, or did a covering
sounding fail to fire?). Fill the report from the run just done: the design or a
*redacted/minimal* example, plumb's verdict, the true shape, and how far the miss
got before it was caught. Never upload anything: the skill stays pure, and the
model hands back a prefilled New Issue link for the repo
(`github.com/chuckwondo/claude-skills/issues/new?title=...&body=...`, the report as a
URL-encoded markdown body) that opens ready to review and submit. The signal returns
at the edge, a human filing an issue, not the skill phoning home.

## Working notes

- Rank by *leverage*, not count. One "this should be a sum type" beats ten nits.
- Measure that leverage by tracing the flaw to what *consumes* it. A mislabeled
  case or a lying name is a nit until you follow it downstream to the thing it
  breaks: a check it defeats, a caller it silently misleads; the blast radius
  sets the rank, not the size of the local wrongness. Trace against a second target
  too: the work's own *charter* (the issue's stated motivation), since a diff can be
  flawless in *what it does* and still under-deliver the issue it claims to close, and
  a half-delivered charter is itself a leverage finding. The same trace splits *fix*
  from *note-and-park*, and a park has two reasons. *Unreachable*: the bad state
  has no path to a consumer (a lone trusted constructor already upholds it), so
  name it and give the cost-vs-risk in a line. *Out-of-scope*: the defect is
  reachable and load-bearing, but the fix lives outside the change's agreed
  boundary (a sibling module's crash on the same input the new rule flags); park
  it to a *filed follow-up issue*, a routed action, not a note that rots.
- Prefer the change that makes an illegal state *unrepresentable* over the one that
  adds a guard.
- Judge against the ideal, not the incumbent. A widespread bad pattern is a bigger
  finding, not an excuse.
- A name is part of the design: a misleading name is a defect, not a preference.
- Be concrete: name the exact case, the exact rename, the exact seam. "Consider
  decoupling" is not a finding; "`_bridging` imports `validation`, inverting the
  layering: inject the check instead" is.
- When a sounding doesn't apply, say so briefly; don't manufacture a finding to
  fill it.
- Run plumb at all three altitudes: as *guide* questions before code exists, on the
  *plan* once there is one, and on the *diff* after. They are complementary, not
  redundant: each catches flaws the others cannot. The plan judges the *stated
  shape*, so some errors are only legible once code exists; the diff, run *after*
  code-review and its fixes, catches structural debt a correctness fix introduced.
  Read a clean diff-pass as a *positive* signal the plan was thorough, not a wasted
  run. Two diff-specific failure modes: it can surface a *higher* sounding the plan's
  fix produced without claiming it (re-rank the landed fix against all soundings, not
  just the one it targeted), and it can *miss* fresh debt the implementation added
  (affirming the plan's fix landed is not sweeping the new code, see the "Affirmed"
  note). And the load-bearing move often lands in *none* of the three passes but the
  *design dialogue between them*: a reviewer's pushback after the guide walk, where
  the real reshaping happens. (On #14 the plan-review's headline was a host-app naming
  collision; the diff-review's was a one-source-of-truth drift that only existed once
  code was written: two passes, two different load-bearing findings.)
- "Affirmed" is not "closed"; verifying a claim is an action, not an argument. "The fix
  landed", "the edge is bounded", "it's negligible" are *claims*; verify them by
  doing: sweep the new code for a fresh instance of the same sounding (affirming one
  landed is the cue to hunt its *other* instances, not to close it out), or
  *construct and run* the breaking input. When you authored what you're reviewing,
  this is mandatory: a self-authored design rationalizes its own soundings, and only
  a run survives confirmation bias (a careful code-read, even a subagent's, is still
  reasoning until run). The claim need not be code: a docstring, a narrative `.md` no
  build executes, a test's own predicate (copied from the code it guards, so blind to
  that predicate going stale), a `# pragma: no cover`, each is an un-run assertion,
  and after a decision *reverses*, stale prose is the top risk because nothing compiles
  it. The verification must hunt the ground the last sweep *skipped*: re-running the cases
  already green is confirmation bias in a lab coat. Provenance to plan around: a
  self-authored design does not reliably run its own claims even when this note says to,
  so the likeliest real trigger is an external prompt, a reviewer, or the user, who is
  not the author. A specific shape to catch yourself in: a sounding firing *positive*
  on a site (2/DRY: "one clean assembly point") masks a different sounding firing
  *negative* on the *same* site (1a: "and the exact place a collision hides"), because
  the flattering read arrives first and you stop; before leaving a site you affirmed,
  ask which sounding could *indict* it.
- A decision that *reverses* is a distinct trigger: it turns every artifact that
  described the now-impossible path into a lie, and prose is the least-checked of them,
  nothing compiles a stale `.md`. After any reversal, sweep by what no build executes:
  narrative `.md` (top risk) > doctested docstrings (`pytest --doctest-modules`) >
  typechecked-and-tested code. Grep the prose deliberately, the checker will not flag it.
  And the stale artifact need not be *your* doc: a reversal can invalidate a *sibling
  ticket* whose premises leaned on the old behavior (an issue's own Constraints citing a
  case a same-day merge just made unreachable), so check a ticket against HEAD, not only
  against when it was written.
