---
name: plumb
description: >-
  Structural design review and design-time checklist for whether code is modeled
  with the right SHAPE (not whether it works, which is code-review, nor whether
  it is minimal, which is ponytail-review). Judges a diff, a plan, or a described
  design against principled "soundings": make illegal states unrepresentable;
  model outcomes as typed values; handle every case; names that encode a type's
  shape; one source of truth and a pure core; faithful lossless data; low
  coupling; cohesion; encapsulation; checks in the right tier; proportional
  response grounded in the real source; symmetry; a trivial common path over a
  complete core; reversibility; and hunting the breaking edge. Works on a
  greenfield repo (nothing to conform to) and a brownfield one (where the
  established pattern may itself be the fault to push against). Use when reviewing
  structure/modeling, or when designing a new type, module, API, or check and you
  want the shape right before building. Triggers: "plumb", "is this modeled
  right", "design review", "structural review", "review the shape", "review my
  plan/design", "how should I model this", "should this be a sum type / Result",
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

*Each principle below is a **sounding** (a depth-probe you drop on the design).
One-word swap if you prefer `gauges`.*

## What this is NOT

Plumb owns *modeling and structure*. It defers, by name, rather than duplicating:

- pure over-engineering / "does this need to exist" → **ponytail-review**
- line-level bugs, cleanup, style → **code-review**

Plumb's altitude is above both: *is the design the right shape?*

## The soundings (ranked by leverage)

> Draft ordering. `[combine?]` marks principles that overlap and are candidates
> to merge or fold in our tightening pass.

### 1. Make illegal states unrepresentable  `[combine? with 2, 6]`
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
for the common path.

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

### 5. One source of truth; compose  `[combine? with 13]`
One pure function many consumers reuse; a functional core of pure functions over
immutable data, effects in a thin shell, seams (a fetcher, a parser) injected at
the edges. **Smell:** the same decision derived in three places; a core reaching
for I/O or a framework; the "check" and "use" paths duplicating logic. **Move:**
extract the decision once; call it everywhere; push effects out; inject what
varies.

### 6. Faithfulness: preserve the input  `[combine? with 1]`
The stored/decoded form reproduces the input exactly (it round-trips); any lossy
interpretation is an opt-in projection, never the stored representation. **Smell:**
a decode that normalizes, rounds, or drops precision; a model that cannot
reproduce what it read. **Move:** store faithfully; offer lossy views as separate,
opt-in operations.

### 7. Low coupling, clean boundaries  `[combine? with 8, 9]`
Modules are leaves or near-leaves; imports flow one direction; a module names
another's *public* surface, never its internals; the core knows nothing of its
optional bridges. **Smell:** import cycles; a low-level module importing a
high-level one; reaching past a public API into a private helper; a "utility" that
drags a heavy/optional dependency in at import. **Move:** invert the dependency
(inject, don't import); rehome shared helpers neutrally; import optional deps
lazily.

### 8. Cohesion: one concern per unit  `[combine? with 7]`
A module/type/function does one thing; you can name it without an "and."
**Smell:** a grab-bag module; a function whose doc lists three unrelated jobs.
**Move:** split by concern.

### 9. Encapsulation: expose intent, hide representation  `[combine? with 7]`
Callers depend on what a thing *means*, not how it's built; the representation can
change without breaking them. **Smell:** callers reaching into fields/internals; an
abstraction that leaks its storage; invariants a caller must maintain by hand.
**Move:** expose intent-named operations; make the representation private; keep
invariants inside.

### 10. Put the check in the right tier
Local, O(1), single-object invariants at construction; cross-cutting or
data-scanning checks in an opt-in pass, so loading stays permissive and faithful.
**Smell:** a cross-object or O(n) rule jammed into a constructor (a slightly-off
document won't even load); a genuinely-local invariant left unchecked. **Move:**
match the check's placement to its scope and cost.

### 11. Proportional response, grounded in the real source
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

### 12. Symmetry
Paired operations exist and mirror each other (encode/decode, to/from, set/get,
sync/async); shapes that should match, match. **Smell:** a lone half (a decoder
with no encoder); asymmetric signatures for symmetric ideas; a round-trip that
doesn't round-trip. **Move:** complete the pair or justify its absence; align the
mirrored shapes.

### 13. Trivial common path over a complete core  `[combine? with 5]`
The 90% case is a one-liner (a thin convenience); the 10% case is not locked out
(the rich form remains reachable). **Smell:** a rich API forced on every caller; or
a convenient API with no escape hatch to the full thing. **Move:** layer a thin
convenience over a complete core; export both.

### 14. Reversibility: know the door
Distinguish one-way doors (costly to undo: a public API, a wire format, stored
data) from two-way; keep the blast radius of a possibly-wrong decision contained.
**Smell:** a hard-to-reverse choice made lightly; an experiment wired through a
one-way door; a wrong guess whose blast radius is the whole codebase. **Move:**
spend care in proportion to reversibility; keep two-way doors cheap; isolate the
risky bet behind a seam.

### 15. Hunt the breaking edge
The design is probed with the input that violates its assumption — out-of-range,
non-ASCII, empty/`None`, reduced-precision, adversarial. **Smell:** an assumption
("a 4-digit ASCII year", "it fits in a datetime") with no case testing its
boundary. **Move:** name the assumption; find the *legal* input that breaks it; add
the case.

## Output

**Review mode** — a list ranked most-leverage-first, one line per finding:

```
<sounding> · <file:line or component> · <what's off> → <the move>
```

Lead with the single highest-leverage change if there is one. End with
`net: <the one change that matters most>`, or `Plumb is true.` when nothing
structural is off. Route correctness bugs to code-review and over-engineering to
ponytail-review *by name*, not here.

**Guide mode** — walk the soundings as questions for the design at hand, answer
each for the specific case (not in the abstract), and finish with the one or two
that most shape this solution.

## Working notes

- Rank by *leverage*, not count. One "this should be a sum type" beats ten nits.
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
