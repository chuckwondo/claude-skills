# Name the repair, then resolve it

*A [plumb](../SKILL.md) case study: how one design test placed the same check in
two different tiers, and why resolving the value (not counting the repairs) is
what decided it. From covjson-msgspec #147, whose ADR reversed a sub-decision of
an earlier one.*

## Setting the scene

[covjson-msgspec](https://github.com/chuckwondo/covjson-msgspec) reads and writes
[CoverageJSON](https://covjson.org/), a JSON format for spatiotemporal data. A
*coverage* has a *domain* whose *axes* carry the coordinates: longitude `x`,
latitude `y`, time `t`, and so on. Most axes are `primitive` (one value per
step). Some are *composite*: a `tuple` axis packs several coordinates into each
value (a trajectory's `(t, x, y)`), and a `polygon` axis packs GeoJSON rings. A
composite axis names its components in a `coordinates` member, for example
`["t", "x", "y"]`.

The library validates in tiers ([ADR-0002]). A local, O(1) invariant whose
violation leaves an object *uninterpretable in isolation* is rejected at
**construction**, so the document fails to load. A violation that leaves *a
meaningful object whose parts merely disagree* is deferred to an opt-in
**`validate()`** pass, so the document loads and the issue is reported.
Permissive decode is the default: a repairable document should still load.

The question this case study turns on is narrow. **A composite axis that omits
`coordinates` entirely: which tier catches it?**

## The same test, applied twice, two answers

[ADR-0018] gave the tier line an operative test:

> **Name the repair.** Exactly one repair means the object is interpretable, so
> the check belongs in `validate()`. Zero or ambiguous repairs mean it is not,
> so the check belongs at construction.

It applied that test to the omitted-`coordinates` case and concluded the code
was wrong:

> A composite axis without `coordinates` was rejected at construction, yet the
> criterion says such an axis should load.

The reasoning: §6.1.1 says an omitted `coordinates` "defaults to a one-element
array of the axis identifier." That default is a *single* repair, so, by the
test, the axis stays interpretable and belongs below construction. [ADR-0018]
removed the construction guard (via [#131]); a composite axis could now omit
`coordinates` and load.

[ADR-0019], written for #147, applied the identical test and reached the
opposite tier. The difference is one step: it **resolved** the repair instead of
counting it. For a composite axis, keyed literally `"composite"` in the Common
Domain Types that use one, the one-element default resolves to `("composite",)`:
a lone coordinate identifier named `"composite"`. But `"composite"` is the
*kind* of the axis, not one of its coordinates. The repair produces a value
that names nothing. One repair, and it is unusable. So the object is
uninterpretable after all, and the check belongs at construction.

## What the earlier ADR got right

This is not a story about a careless decision. [ADR-0018] made a real catch. The
guard it removed checked only that `coordinates` was *present*, never that it
*fit*: an axis with `coordinates=("composite",)` and three-component values
satisfied the guard while being malformed, and the bridges silently dropped the
surplus two components. A guard that rejects conformant documents while the
malformation it was mistaken for walks past is worth removing. [ADR-0018] even
named where the real rule belongs: over the *resolved* identifiers, in
`validate`'s arity scan ([#127]).

So the miss was not the direction of its skepticism. It was one unfinished step.

## The miss

The same ADR that insisted the arity rule must work over *resolved* identifiers
did not resolve the identifier default when it decided the *tier*. It counted
the repairs (one), read "one repair" as "interpretable," and stopped. Had it
carried its own resolved-identifier discipline one step further, into the tier
question, it would have computed `("composite",)` and seen that a single repair
can still produce a nonsensical value.

That is the whole lesson, and it refines the test [ADR-0018] itself wrote:

> **"Name the repair" is necessary but not sufficient. Counting the repairs
> (zero, one, many) tells you about the value's *shape*. Whether the object is
> usable depends on the value the repair *produces*, which you learn only by
> resolving it. A single, unambiguous repair can still be unusable.**

Counting is reasoning about the value. Resolving is computing it. It is the
design-time version of plumb's rule that only a run survives confirmation bias:
resolve the value, do not reason about its description.

## Why the scanning tier could not save it

[ADR-0018] pointed the real rule at `validate`'s arity scan, over the resolved
identifiers. But that scan structurally cannot hold this case, and one breaking
input shows why. Consider a self-consistent one-dimensional polygon: its
positions have one element each, and it declares one identifier, `("x",)`. The
arity scan compares each position's length to the identifier count, finds
`1 == 1`, and passes it, while [RFC 7946] requires a position to have two or
more numbers. The scan can catch a position that *disagrees* with the count; it
cannot catch a count that is *itself too low* when the positions agree with it.
Only a check on the identifier count, at construction, catches that. The tier
[ADR-0018] pointed to could not have held the rule even if the omitted case had
never come up.

## What the reversal cost, and what caught it

Removing the guard did not merely relabel a tier. It let the nonsensical default
reach the value-scan: a composite axis that omitted `coordinates` now loaded,
resolved to a count of one, and drew a *flood* of arity errors, one per value or
position, against that bogus count. That flood is exactly what #147's review
surfaced. The symptom of the missed resolution was sitting downstream the whole
time; it took following the default back to `("composite",)` to name the cause.

The fix is not the old guard reborn. [ADR-0019]'s construction check tests that
`coordinates` *fits*, a floor of at least one identifier for `tuple` and at
least two for `polygon`, the very "does it fit" the old present-only guard
lacked. It lives at construction because the resolved default is unusable, and
it makes the illegal state unrepresentable, which deletes both the flood and any
guard that would have suppressed it.

## Groundwork

- **composite axis**: a `tuple` or `polygon` axis whose every value bundles
  several named coordinates; keyed `"composite"` in the Common Domain Types.
- **`coordinates`**: the axis member naming those components; optional, with a
  spec default of "a one-element array of the axis identifier."
- **tier (construction vs validate)**: where a rule runs, at load (rejecting the
  document) or in an opt-in pass (reporting an issue on a loaded document).
- **name the repair**: [ADR-0018]'s test, one repair means interpretable
  (validate), zero or ambiguous means not (construction). This case refines it:
  resolve the repair, then judge.
- **ADR**: an [Architecture Decision Record](https://adr.github.io/), a durable
  note of a design decision and why it was made.

## Sources

- Decisions: [ADR-0002] (the tier line), [ADR-0018] (name the repair; the
  sub-decision this reverses), [ADR-0019] (composite `coordinates` at
  construction)
- Issues: covjson-msgspec #147, [#131] (removed the guard), [#127] (the arity
  scan)
- Spec: [CoverageJSON §6.1.1](https://github.com/covjson/specification/blob/master/spec.md#611-axis-objects);
  [RFC 7946 §3.1.1](https://www.rfc-editor.org/rfc/rfc7946#section-3.1.1) (a
  position has two or more numbers)
- The [plumb](../SKILL.md) skill and its [dogfood log](../DOGFOOD-LOG.md)

[ADR-0002]: https://github.com/chuckwondo/covjson-msgspec/blob/main/docs/adr/0002-opt-in-tiered-validation.md
[ADR-0018]: https://github.com/chuckwondo/covjson-msgspec/blob/main/docs/adr/0018-typed-projection-scope.md
[ADR-0019]: https://github.com/chuckwondo/covjson-msgspec/blob/main/docs/adr/0019-composite-coordinates-required.md
[#127]: https://github.com/chuckwondo/covjson-msgspec/issues/127
[#131]: https://github.com/chuckwondo/covjson-msgspec/issues/131
[RFC 7946]: https://www.rfc-editor.org/rfc/rfc7946#section-3.1.1
