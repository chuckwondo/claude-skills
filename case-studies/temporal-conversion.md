# From `datetime | None` to `TemporalResult`

*A design iteration log for covjson-msgspec #12 (opt-in temporal conversion +
validation). Where each step landed, the friction we hit, what we applied and
why, and the state it left us in. This is the case study the [plumb](../plumb/SKILL.md)
skill was distilled from.*

> Visual version (interactive timeline):
> <https://claude.ai/code/artifact/51702f13-32e3-48ad-bfac-fb7ed6c01ccb>

## Setting the scene

**What's being built.** [CoverageJSON](https://covjson.org/) is a JSON format for
spatiotemporal data: weather grids, sensor time series, forecast trajectories. A
*coverage* has a *domain* (its axes: longitude `x`, latitude `y`, height `z`, time
`t`) and *ranges* (the data values over that domain).
[covjson-msgspec](https://github.com/chuckwondo/covjson-msgspec) is a fast,
fully-typed Python library for reading and writing it, built on
[msgspec](https://jcristharif.com/msgspec/).

**The feature (#12).** On the time axis, values are
[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) strings like `"2018"` or
`"2020-01-01T00:00:00Z"`. The library stored them verbatim (*byte-faithful*, never
altering the input), which is safe but did nothing more: it couldn't hand you a
real Python `datetime`, and it never noticed a broken value like `"2010-13-99"`.
The task was to add both, without giving up faithful storage.

**Why it's worth writing down.** The rival library
[covjson-pydantic](https://github.com/KNMI/covjson-pydantic) solved the same
problem the opposite way: it forces every time value into a `datetime`, which
[silently corrupts](https://github.com/KNMI/covjson-pydantic/issues/34) the ones
that don't fit. Avoiding that trap took real design care, and the interesting part
is *how*: a dozen rounds of pushback, review, and naming that turned a plausible
first idea into a genuinely better one, and improved parts of the codebase that had
nothing to do with time.

**Where it ended up.** `resolve(str) -> TemporalResult = Moment | Unrepresentable
| Malformed`: instead of returning a value *or nothing*, the converter returns
exactly one of three typed outcomes, so the reason is never lost. `to_datetime` is
a one-line convenience over it; an opt-in `temporal.lexical-form` **warning** flags
bad values; and the work surfaced a codebase-wide *Result*-vs-*Report* naming
convention.

## How to read this

Every step has the same four beats: **Landed** (the state we were in), **Friction**
(what was wrong), **Move** (what we changed, and *why*), **Result** (the new state,
which the next step builds on). Each step opens with a one-line *context* framing
the stakes.

---

## Phase 1 -- Choosing the work

### 1. #12 over #14

*Context: two features were left in the release milestone. Picking well meant
choosing the one that was both cheaper to build and would compound with work just
finished.*

- **Landed:** two candidates remained: opt-in temporal conversion (#12), and a
  separate bridge that would describe the library's types to API tooling (#14).
- **Move:** chose #12. It touches only the core (no web-framework or
  extra-dependency surface), and it *reuses machinery merged days earlier* -- the
  library had just learned to model validation findings and fetch failures as
  typed values. That same shape would turn out to be exactly what temporal
  conversion needed.
- **Result:** work begins on #12, with the "errors as typed values" culture already
  in mind. Not a coincidence to forget by step 5.

## Phase 2 -- The converter's shape *(the central iteration)*

### 2. Start: value, or nothing

*Context: the first question is the whole feature in miniature -- when you ask the
library to turn a time string into a real datetime, what should it hand back?*

- **Landed:** the obvious answer, an *option type*: `to_datetime(str) -> datetime |
  None` -- you get a `datetime`, or `None` when it can't. Open sub-question: what
  about *reduced-precision* forms like `"2020"` (a whole year, no month or day) or
  `"2020-06"` (a month)?
- **Friction:** `None` can only say *"no value."* It can't say *why*. A value that
  is perfectly legal in the spec but simply too big for Python looks identical to
  outright garbage -- the caller can't tell them apart.
- **Move:** rather than pick a flavor, paused to ask how these awkward values are
  handled *in the real world*.
- **Result:** a requirements probe instead of a premature API choice.

### 3. Probe: the values Python can't hold

*Context: some time strings are perfectly legal yet impossible for Python to
represent -- and understanding who actually hits them decided the whole contract.*

- **Landed:** the question "what do we return for `"+102020"` or `"0000"`?" ISO 8601
  allows *expanded years* (a sign and extra digits, for dates far in the past or
  future) and year zero.
- **Friction:** Python's built-in `datetime` only spans years 1 through 9999. Those
  values are *spec-valid* but unrepresentable.
- **Move:** established that nobody forces such values into a stdlib `datetime`.
  They keep the raw string (which the library already preserves faithfully) or
  reach for [cftime](https://unidata.github.io/cftime/), a library built for
  deep-time and climate calendars -- one this project's data-export path already
  falls back to. So "can't produce a `datetime`" is a normal, expected outcome, not
  a failure.
- **Result:** clear requirements. But then I overreached.

### 4. My overreach, corrected

*Context: a moment of the maintainer catching me getting ahead of the shared
decision, and untangling two ideas I'd fused together.*

- **Landed:** I announced "out-of-range returns `None`, settled," and narrowed the
  discussion to just the reduced-precision detail.
- **Friction:** that hadn't been agreed. And I'd quietly conflated two different
  jobs: the *validator* (does this document follow the spec?) and the *converter*
  (can I turn this string into a `datetime`?). I'd also mis-cited the spec as
  demanding these forms.
- **Move:** separated the two cleanly. The validator judges *conformance* -- a
  malformed value is a finding to report. The converter judges *representability*
  -- an out-of-range value simply can't become a `datetime`. Different questions,
  different answers.
- **Result:** the design space was honest again, with the real choice exposed
  rather than assumed.

### 5. The pivot: a Result, not an option

*Context: the turning point. The maintainer proposed a shape that dissolved the
remaining questions all at once.*

- **Landed:** still stuck choosing how the converter should *fail* -- return
  `None`, or raise an exception? Both throw information away.
- **Move:** *the maintainer proposed a Result type* -- "so we don't lose info in the
  error cases." Instead of value-or-nothing, the converter returns
  [one of several typed cases](https://en.wikipedia.org/wiki/Tagged_union) (the
  shape of Rust's [`Result`](https://doc.rust-lang.org/std/result/)): `resolve() ->
  Moment | Unrepresentable | Malformed`. This *unified every open question*. A bare
  year became a `Moment` that carries both a filled-in date *and* a label saying
  "year precision," so nothing is fabricated. A too-big value became
  `Unrepresentable`; garbage became `Malformed`, each keeping its reason as data.
  The old `to_datetime` shrank to a two-line convenience on top, and the validator
  reused the very same parse. One source of truth, three consumers.
- **Result:** the core design was settled, and better than either option I had
  offered.

## Phase 3 -- Hardening the plan

### 6. Where the check runs

*Context: a recurring architecture question -- validate the instant a document
loads, or only when asked?*

- **Landed:** should "is this a well-formed time value?" run automatically when a
  document is parsed?
- **Move:** no -- it runs only in an *opt-in* `validate()` pass. Whether a value is
  even *meant* to be temporal depends on other parts of the document (not visible
  when a single value is constructed); the check is proportional to how much data
  there is; and rejecting at load time would break the faithful-storage promise
  (you couldn't load an imperfect real-world document to inspect or repair it).
  Parsing stays permissive; judgment is a separate, deliberate step.
- **Result:** the check is opt-in; loading a document never fails on content.

### 7. Strict form, and cutting an over-build

*Context: a deep read of the plan caught both a latent bug and a piece of needless
machinery before a line was written.*

- **Landed:** a draft parser that leaned on a calendar library for leap-year math
  and accepted times without a timezone.
- **Friction:** Python's date parser *rejects the expanded-year forms outright*, so
  the naive approach would have crashed on exactly the values we'd just discussed.
  And the calendar-library dependency was solving a problem we didn't have.
- **Move:** split the parsing by form -- handle the simple forms directly, and lean
  on Python's own parser only for the ones it already validates (month, day, leap
  years, timezone). *Deleted the calendar dependency* entirely. Chose the *strict*
  reading: a time-of-day must carry a timezone, matching the spec.
- **Result:** a parser that is both correct and smaller.

## Phase 4 -- Build, then the lazy pass

### 8. Implemented and green

*Context: the first working version, with the full test and type-checking suite
passing.*

- **Landed:** the new module, the validation check, tests, a decision record, and
  doc updates -- all green (689 tests, plus linting and two strict type-checkers).
- **Result:** a working first cut, ready to be made leaner and then scrutinized.

### 9. Delete what doesn't earn its place

*Context: a deliberate simplification pass, asking of each helper -- does this need
to exist?*

- **Landed:** two small private helpers -- one wrapping a standard-library function,
  one holding a single branch used in a single place.
- **Friction:** the wrapper reimplemented something the standard library already
  does *and didn't even make the calling code shorter*; its test tested the standard
  library, not our logic.
- **Move:** deleted the wrapper (call the standard function directly) and inlined the
  single-use branch.
- **Result:** thirty fewer lines, identical behavior.

## Phase 5 -- The pedantic pass *(the catch that mattered)*

### 10. "Error" was wrong; it's a "warning"

*Context: the single most valuable catch of the whole effort, and it fixed shipped
behavior, not prose.*

- **Landed:** the new check flagged bad values as *errors*, on my stated reasoning
  that "the spec says these forms are mandatory."
- **Friction:** that reasoning was *false*, and checking the actual sources proved
  it. The spec (section 5.2) says these forms *SHOULD* be used, not *MUST* -- and
  the difference is load-bearing. In
  [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) terms, a SHOULD violation is a
  *warning*, not an error. The project's own prior decision record had already
  written exactly that rule, and even used "a temporal value outside ISO 8601 form"
  as its example of a warning.
- **Move:** changed the severity to *warning* (the codebase's first), softened the
  wording, and corrected the reasoning. A real behavior fix, traced straight back to
  bad information I'd supplied during planning.
- **Result:** the check now matches the spec's actual force and the project's own
  recorded decision.

### 11. The Unicode-digit bug

*Context: a subtle correctness hole that only a careful eye (or a very international
dataset) would find.*

- **Landed:** the pattern used to recognize a four-digit year, written as `\d{4}`.
- **Friction:** in Python, `\d` matches *any* Unicode digit (Arabic-Indic,
  Devanagari, and so on), and the number parser accepts them too. So a "year"
  written in Eastern Arabic numerals was wrongly accepted as valid.
- **Move:** restricted the patterns to ASCII digits, which is all ISO 8601 permits.
- **Result:** correct -- only `0`-`9` count as digits.

### 12. Getting the citation right

*Context: small, but it's the difference between a reference a reader can follow and
one that misleads.*

- **Landed:** the code and docs cited the temporal rules as "section 9.5.2."
- **Friction:** that is the numbering from a different edition of the standard; the
  specification this project actually links to numbers it *5.2*.
- **Move:** corrected every reference to "Spec 5.2."
- **Result:** citations a reader can actually follow.

## Phase 6 -- Convention polish

### 13. The small, exacting fixes

*Context: the unglamorous layer of consistency that separates "works" from "belongs
here."*

- **Landed:** new prose that drifted from the project's house style -- dashes where
  colons were the rule, missing commas, lines a few characters too long.
- **Move:** brought each into line with the established conventions, the kind of
  detail that keeps a codebase feeling like one hand wrote it.
- **Result:** prose indistinguishable from the surrounding code.

## Phase 7 -- The naming arc *(bikeshedding that improved the whole codebase)*

### 14. Finding the right noun

*Context: naming the three outcomes turned into a genuine design conversation,
because a good name has to tell you what the thing is.*

- **Landed:** working names -- `Resolved` for the family of outcomes, `Instant` for
  the success case.
- **Friction:** `Resolved` implies success, but two of the three outcomes are
  failures. `Instant` suggests an *exact* point in time (wrong for a value that
  might only name a year), and it collides with a well-known type of the same name
  elsewhere.
- **Move:** walked the alternatives and rejected them for concrete reasons:
  `Resolution` reads as *image/grid resolution* in a data library; `Point` is
  already a shape in this very spec; `Value` clashes with a field name. Landed on
  *`Moment`* -- soft enough to cover a fuzzy year, and colliding with nothing.
- **Result:** `Moment` for the success case. The name for the *family* was still
  open, and about to expose something bigger.

### 15. The reversal: two existing types were misnamed

*Context: bikeshedding one name surfaced a mistake that had nothing to do with this
feature, and fixing it improved the whole library.*

- **Landed:** the maintainer liked `TemporalResult` for the family, but asked how it
  squared with two *existing* types named `...Result`.
- **Friction:** those two aren't "one of several outcomes" at all. Each is a *record*
  that bundles a value *together with* a list of problems it tolerated -- a
  fundamentally different shape. The `Result` suffix was on the wrong kind of type.
- **Move:** established a rule -- a `Result` is a *one-of* choice (like the new
  `TemporalResult`); a *value-plus-problems* record is a `Report`. Renamed the two
  existing types accordingly and recorded the convention in a decision record.
- **Result:** a naming rule that now applies library-wide. Bikeshedding one type
  improved *three*.

### 16. The rule pays off in everyday code

*Context: a convention is only worth it if it makes ordinary reading easier, and
this one does, right down to variable names.*

- **Landed:** local variables named `result` that actually held one of the
  newly-renamed `Report` values.
- **Move:** renamed those to `report`, keeping `result` only for the true one-of
  type.
- **Result:** now a variable's name tells you its shape at a glance -- `result` is a
  one-of choice, `report` is a value-plus-problems record.

## Phase 8 -- Shipping

### 17. Two commits, then out the door

*Context: landing the work as clean, reviewable history rather than one
undifferentiated blob.*

- **Move:** split into two self-contained commits -- the feature, then the naming
  refactor -- arranged so each one passes its tests on its own (so future debugging
  can bisect cleanly). Opened the pull request (merged), and filed two follow-up
  issues for the deferred ideas.
- **Result:** done, and a paper trail that explains itself.

---

## What made it converge

Four patterns did the real work:

1. **Pushback beat the defaults, repeatedly.** The maintainer declined several
   "good enough" answers for better ones: the Result type (over a plain
   value-or-nothing), the `TemporalResult`/`Report` reversal, and catching a
   premature "this is settled." Design by friction, not by first draft.
2. **The pedantic passes caught a *shipped* bug, not just style.** The most
   important fix -- a validation set to "error" that should have been "warning" --
   was wrong *behavior*, and it traced back to bad information I gave during
   planning. Reviewing against the actual sources (not just re-reading the prose) is
   what surfaced it.
3. **Naming pressure found a latent improvement.** Bikeshedding one new type's name
   exposed that two *existing* types were misnamed. The fix (a `Result`-vs-`Report`
   rule) improved the whole codebase, not just the new module.
4. **The codebase's existing grain pointed the way.** The library had recently
   learned to model errors as typed values rather than exceptions. That made the
   Result type the *obvious* answer once it was proposed -- the culture already
   there did half the design work.

The outcome wasn't just an implementation of one issue. It was that, plus a naming
convention, a corrected decision record, and a validation severity that finally
matches what the spec actually says.

## Groundwork (terms in one line)

- **byte-faithful** -- reading a document and writing it back reproduces the input
  exactly; the model never rewrites what it stored.
- **option type** -- a result that is either a value or `None`. Simple, but
  "nothing" can't say *why* there's no value.
- **Result / sum type** -- a value that is
  [exactly one of several typed cases](https://en.wikipedia.org/wiki/Tagged_union),
  the shape of Rust's [Result](https://doc.rust-lang.org/std/result/). Each case can
  carry its own data, so the reason is preserved.
- **MUST vs SHOULD** -- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)
  requirement levels: MUST is mandatory (a violation is an error), SHOULD is
  recommended (a violation is a warning).
- **ISO 8601 forms** -- the permitted ways to write a date/time as a string (a year,
  a year-month, a full timestamp, and more). The spec allows five for calendar time.
- **ADR** -- an [Architecture Decision Record](https://adr.github.io/), a short,
  durable note capturing a design decision and why it was made.

## Sources & further reading

- Spec: [CoverageJSON](https://covjson.org/) and the
  [specification](https://github.com/covjson/specification/blob/master/spec.md)
  (temporal values: section 5.2)
- Library: [covjson-msgspec](https://github.com/chuckwondo/covjson-msgspec), built
  on [msgspec](https://jcristharif.com/msgspec/)
- Contrast: [covjson-pydantic](https://github.com/KNMI/covjson-pydantic) and its
  [datetime-corruption bug](https://github.com/KNMI/covjson-pydantic/issues/34)
- Standards: [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601),
  [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)
- Concepts: [Rust Result](https://doc.rust-lang.org/std/result/),
  [tagged unions](https://en.wikipedia.org/wiki/Tagged_union),
  [ADRs](https://adr.github.io/)
- Python: [datetime](https://docs.python.org/3/library/datetime.html) (years
  1-9999), [cftime](https://unidata.github.io/cftime/) (deep-time calendars)
