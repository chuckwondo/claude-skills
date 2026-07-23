# Plumb: references

*The verified sources behind the named concepts each sounding invokes. A reader
who meets a term in [SKILL.md](SKILL.md) (say "information hiding,"
"command-query separation," or "railway oriented programming") can follow it here
to the primary source and read the original argument.*

*Every citation was **verified, not recalled** (2026-07-23): each URL was fetched
or confirmed against its source, and each book was checked for author, title, and
year. This is the skill's own sounding 6 (verify the source; a citation is a
claim) turned on its own documentation. Where a concept has no source that maps
**exactly**, this file says so and cites nothing rather than reach for a loose
match: a loose citation is worse than none, because a reader who knows the term
trusts the mapping and is misled. Three soundings (7, 8, 10) are deliberate parks
for that reason.*

*Division of labor with [Correct by
Construction](https://github.com/chuckwondo/digital-garden/blob/main/content/correct-by-construction.md):
that companion guide is the extended **why** for the correct-by-construction
family (sounding 1), proportionality (sounding 6), and provenance; plumb is the
operational review and guide. Each references the other. The guide curates its own
verified canon (Alexis King, Yaron Minsky, the smart-constructor idiom); the
sounding-1 entries below are the operating anchors, and the guide is where the
reasoning is worked in depth.*

*Foundational (composition & modularity).* John Hughes, "Why Functional
Programming Matters" (in *Research Topics in Functional Programming*, ed. Turner,
Addison-Wesley, 1990; earlier in *The Computer Journal* 32(2), 1989) is the
manifesto for composition as the point of functional style: **modularity is the
key to good software**, and the two "glues" (higher-order functions and lazy
evaluation) are what let small, general parts be combined into whole programs. It
underlies the *compose-the-whole-from-named-parts* thread that runs through
sounding 2 (one source of truth), 3c (cohesion), and the pure-*core* half of
sounding 4. One caution, in the spirit of this file: it is **not** a source for
sounding 4's *effect placement*. Hughes explicitly dismisses "no assignment, no
side-effects" as the uninteresting property and argues FP's power is compositional
glue, not the absence of effects, so it is cited here for what it actually claims,
not for the effects-at-the-edges idea it is easy to misattribute to it.
<https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf>

---

## 1. Correct by construction

The deep rationale for this whole cluster (brands vs value objects, smart
constructors, where invariants come from, the leak surface) lives in the
[Correct by
Construction](https://github.com/chuckwondo/digital-garden/blob/main/content/correct-by-construction.md)
guide. The operating anchors:

- **Make illegal states unrepresentable (1a).** Yaron Minsky, "Effective ML
  Revisited," Jane Street Tech Blog: the canonical home of the slogan (it
  originates in his 2010 Effective ML talk, Harvard CS51).
  <https://blog.janestreet.com/effective-ml-revisited/>
- **Parse, don't validate (1a, the edge discipline).** Alexis King, "Parse,
  don't validate," 2019: the primary source of the phrase; parsing *produces a
  value in a better type* rather than answering yes/no.
  <https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/>
- **The ignored-outcome-made-unrepresentable case (1a).** Rust's `#[must_use]`
  attribute, The Rust Reference: the designer half of must-consume, encoded as a
  lint. <https://doc.rust-lang.org/reference/attributes/diagnostics.html#the-must_use-attribute>
- **Model the domain with types, not primitives (1b).** The *Primitive Obsession*
  code smell. Fowler & Beck, *Refactoring* (2nd ed., Addison-Wesley, 2018) is the
  origin; Refactoring has no per-smell page, so the stable web anchor is
  <https://refactoring.guru/smells/primitive-obsession>.
- **Model outcomes as typed values (1c).** Scott Wlaschin, "Railway Oriented
  Programming," F# for Fun and Profit: the canonical case for chaining
  Result/Either. <https://fsharpforfunandprofit.com/rop/>
- **Totality: handle every case (1d).** Python's `typing.assert_never` and the
  `Never`-based exhaustiveness pattern, official docs: the mechanism behind
  "adding a case forces the update" (where the language enforces it; see the
  sounding's language-dependence note). <https://docs.python.org/3/library/typing.html#typing.assert_never>
- **Sound typing: no lies to the checker (1e).** PEP 647 (*User-Defined Type
  Guards*) and PEP 742 (*Narrowing types with TypeIs*), both Final. The
  load-bearing difference the sounding rests on: `TypeGuard` narrows only the
  positive branch; `TypeIs` narrows **both** branches and so requires the narrowed
  type be consistent with the input, which is why a predicate *stricter* than the
  type it narrows must be a `TypeGuard`, never a `TypeIs`.
  <https://peps.python.org/pep-0647/> · <https://peps.python.org/pep-0742/>

## 2. One source of truth

- **DRY.** Andrew Hunt & David Thomas, *The Pragmatic Programmer* (Addison-Wesley;
  20th Anniversary ed., 2019). The origin, stated as: "Every piece of knowledge
  must have a single, unambiguous, authoritative representation within a system."
  <https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/>
- **The counter-weight (the Boundary).** Sandi Metz, "The Wrong Abstraction"
  (2016): "duplication is far cheaper than the wrong abstraction"; the line
  originates in her RailsConf 2014 talk "All the Little Things." This is the source
  for the sounding's warning against merging similar-looking idioms that encode
  different decisions. <https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction>

## 3. Focused parts, clean seams

- **Low coupling / high cohesion, the origin (3a, 3c).** Larry Constantine & Ed
  Yourdon, *Structured Design* (Yourdon Press, 1979): where coupling and cohesion
  were named as design measures.
- **Dependency inversion (3a, the Move).** Robert C. Martin, "The Dependency
  Inversion Principle," *C++ Report*, May 1996 (reprinted in *Agile Software
  Development, Principles, Patterns, and Practices*, Prentice Hall, 2002): inject,
  don't import. (The original objectmentor.com host is defunct; the book reprint is
  the durable anchor.)
- **Encapsulation / information hiding (3b).** David L. Parnas, "On the Criteria To
  Be Used in Decomposing Systems into Modules," *Communications of the ACM* 15(12),
  1972: the foundational paper. Stable citation:
  <https://dl.acm.org/doi/10.1145/361598.361623>; readable mirror:
  <http://sunnyday.mit.edu/16.355/parnas-criteria.html>.
- **Cohesion / one concern per unit (3c).** Robert C. Martin, "The Single
  Responsibility Principle": "one, and only one, reason to change."
  <https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html>
  (the misspelled slug is correct as-is).
- **Keep behavior near its data (3d).** The *Feature Envy* smell. Fowler & Beck,
  *Refactoring* (2nd ed., 2018) is the origin (no per-smell page exists on
  refactoring.com, so the book chapter is the anchor). The *Tell, Don't Ask*
  framing: Martin Fowler, "TellDontAsk" (bliki, 2013)
  <https://martinfowler.com/bliki/TellDontAsk.html>. The GRASP *Information Expert*
  pattern ("assign responsibility to the class with the information needed"): Craig
  Larman, *Applying UML and Patterns* (3rd ed., Prentice Hall, 2004).
- **Command-Query Separation (3e).** Bertrand Meyer, *Object-Oriented Software
  Construction* (Prentice Hall, 1988/1997) coined it; Martin Fowler's bliki page is
  the accessible canonical explainer and credits Meyer.
  <https://martinfowler.com/bliki/CommandQuerySeparation.html>

## 4. Functional core, effects at the edges

*(These are the sources formerly inlined in SKILL.md's "Lineage & sources" block,
verified and rehomed here: one home for references, the sounding's own DRY.)*

- **sans-IO**: pure protocol logic, no I/O in the core. "Writing I/O-Free
  (Sans-I/O) Protocol Implementations." <https://sans-io.readthedocs.io/how-to-sans-io.html>
- **sans-IO in Rust**: Thomas Eizinger, "sans-IO: The secret to effective Rust
  for network services," Firezone Blog, 2024. <https://www.firezone.dev/blog/sans-io>
- **Functional core, imperative shell**: Gary Bernhardt, "Boundaries" (talk, SCNA
  2012) <https://www.destroyallsoftware.com/talks/boundaries>, and the "Functional
  Core, Imperative Shell" screencast
  <https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell>.
  A recent mainstream restatement: Arham Jain, "Simplify Your Code: Functional
  Core, Imperative Shell," Google Testing Blog, 2025.
  <https://testing.googleblog.com/2025/10/simplify-your-code-functional-core.html>
- **Functional architecture = ports & adapters**: Mark Seemann, "Functional
  architecture is Ports and Adapters," 2016.
  <https://blog.ploeh.dk/2016/03/18/functional-architecture-is-ports-and-adapters/>
- **Hexagonal (ports & adapters), the primary source**: Alistair Cockburn,
  "Hexagonal (Ports & Adapters) Architecture," 2005.
  <https://alistair.cockburn.us/hexagonal-architecture/>
- **Dependency injection (the Move that achieves the split)**: Martin Fowler,
  "Inversion of Control Containers and the Dependency Injection pattern," 2004.
  <https://martinfowler.com/articles/injection.html>

## 5. Faithful round-trips

- **The round-trip property.** Scott Wlaschin, "Choosing properties for
  property-based testing": the "there and back again" property (an operation
  composed with its inverse returns the original, so encoding then decoding yields
  the input unchanged) is exactly what faithfulness (5a) and symmetry (5b) ask a
  design to satisfy. <https://fsharpforfunandprofit.com/posts/property-based-testing-2/>

## 6. Match strictness to the requirement

- **The strictness keywords.** RFC 2119, "Key words for use in RFCs to Indicate
  Requirement Levels" (Bradner, 1997): MUST/SHOULD/MAY.
  <https://www.rfc-editor.org/rfc/rfc2119>
- **The capitalization is load-bearing.** RFC 8174 (Leiba, 2017) clarifies that
  only the ALL-CAPS keywords carry RFC-2119 meaning. Together they are **BCP 14**.
  <https://www.rfc-editor.org/rfc/rfc8174>

*The deeper treatment of proportionality, matching the guard to the stakes, is
Point 6 of the [Correct by
Construction](https://github.com/chuckwondo/digital-garden/blob/main/content/correct-by-construction.md)
guide.*

## 7. Names encode shape

**Park: cited nothing on purpose.** The nearest canonical term, Kent Beck's
*intention-revealing names*, is about a name *reading clearly*; this sounding is
narrower and different: a name must be honest about the type's *shape* (a
`*Result` that is really a value-plus-failures record is a lying name, not merely
an unclear one). No source maps that claim exactly, so none is cited. Naming the
gap is the honest move.

## 8. Put each check where it belongs

**Park: plumb's own synthesis.** The rule (cheap local invariants at
construction; cross-cutting or data-scanning checks in an opt-in pass) is a
composition of ideas that already have homes elsewhere in this file (construction
control in sounding 1, proportionality in sounding 6) rather than a single named
principle with its own literature. Nothing to cite here that the other sections
don't already carry.

## 9. Reversibility: one-way vs two-way doors

- **Type 1 / Type 2 decisions.** Jeff Bezos, 2015 Letter to Shareholders
  (Amazon, published 2016): the origin of the framing this sounding uses.
  Reversible decisions are "changeable, reversible," and "two-way doors,"
  deserving proportionally less deliberation than irreversible one-way doors.
  <https://ir.aboutamazon.com/files/doc_financials/annual/2015-Letter-to-Shareholders.PDF>

## 10. Hunt the breaking edge

**Park: the obvious cite doesn't fit.** Property-based testing (Koen Claessen &
John Hughes, "QuickCheck," ICFP 2000, DOI 10.1145/351240.351266) is the tempting
anchor, but it founds *random property testing* broadly; the minimal-failing-case
*shrinking* that would make it about hunting the breaking edge is not this
sounding's claim either. The round-trip half of QuickCheck's lineage is already
cited under sounding 5 (Wlaschin). Rather than force a loose match, this sounding
stays uncited: it is an operating discipline (name the assumption, construct the
legal input that violates it, run it), not a restatement of a named result.
