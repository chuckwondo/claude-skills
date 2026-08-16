# Field note: covjson-msgspec #110 plan (plan-altitude, self-plumbed)

*Raw capture, not rendered. Emitted from a covjson-msgspec session on 2026-08-16 while
context was hot, for a later claude-skills session to render into `DOGFOOD-LOG.md`.
Capture, not polish -- do not treat wording here as house style.*

**Corpus:** self-plumbed; clean; Python (3.11 floor, msgspec + numpy); library
(CoverageJSON wire model with opt-in bridges); brownfield (20 ADRs, established idioms,
prior art for `match`/`assert_never` at `references.py:399-405`, `validation.py:1282-1301`,
`temporal.py:175-185`, and prescribed in prose at `referencing.py:223`)

**Subject:** plan-altitude review of the implementation plan for issue #110, aligning error
contracts across `NdArray`'s value-conversion surface (`values_as` / `to_numpy` /
`from_numpy`). The plan was self-authored by the same model that then plumbed it.

**Fired:** 1e (headline), 1d, 1a x2, 6.

Co-fires:

- **1e x 1d on the same site.** The `_PROJECTION` dict is both a type lie and a lost
  exhaustiveness check; one move (a `match` with `assert_never`) fixes both.
- **1a x 10.** The validate/`to_numpy` divergence cannot be made a compile error, so the
  1a move *is* an enforcing test -- 10 is the verification arm of the 1a claim.
- **6 x charter.** The `Raises` omission traced not to a consumer but to the issue's own
  acceptance criterion ("reflects what it actually raises"), i.e. the work's charter.

## Breaking case + downstream trace (verbatim)

The plan proposed, as its §1 implementation sketch:

```python
_PROJECTION: Final = {"float": float, "integer": int, "string": str}
...
projected = self.values_as(_PROJECTION[self.data_type])
```

with this hedge in the plan's own prose -- the smell that triggered the probe, a caveat
standing in for a run:

> Typing caveat to settle first: `_PROJECTION`'s values are
> `type[float] | type[int] | type[str]`, so `_ScalarT` binds to the whole union and the
> projection types as `tuple[float | int | str | None, ...]`. That is fine for feeding
> `np.array`, but confirm it under both mypy strict and basedpyright strict before
> committing to the map.

Run, not reasoned (`mypy --config-file /dev/null --strict`):

```
def dict_form(a: NdArray) -> None:
    reveal_type(a.values_as(_PROJECTION[a.data_type]))
# <string>:8: note: Revealed type is "tuple[None, ...]"
# Success: no issues found in 1 source file
```

The plan's own prediction (`tuple[float | int | str | None, ...]`) was **wrong**. Actual is
`tuple[None, ...]`: no single `_ScalarT` binding fits a union of `type[...]`, so mypy
settles on `None`. Green, and wrong about a tuple that holds floats at runtime.

**Downstream consumer:** `to_numpy`'s body, where `projected` is fed to `np.array(...)` and
(in the plan's sketch) to `[math.nan if v is None else v for v in projected]`. The checker
believes every element is `None`, so every downstream expression over `projected` is checked
against the wrong element type and passes. A wrong answer that type-checks, inside the very
method whose purpose in this diff is to stop silently-wrong conversions.

Contrast, same run, the recommended move:

```
case "string":  reveal_type(a.values_as(str))    # tuple[str | None, ...]
case "integer": reveal_type(a.values_as(int))    # tuple[int | None, ...]
case "float":   reveal_type(a.values_as(float))  # tuple[float | None, ...]
```

**1d, same site**, verified by feeding a known-red input (dropped the `case "float"` arm):

```
error: Argument 1 to "assert_never" has incompatible type "Literal['float']"; expected "Never"  [arg-type]
```

A dict lookup degrades that compile-time error to a runtime `KeyError`.

**1a (validate vs to_numpy).** The plan's remedy for the divergence was a docstring
sentence. Concrete instance --
`NdArray(data_type="float", values=(10**400,), shape=(1,), axis_names=("x",))`:

```
validate(arr, check_values=True).ok  ->  True
arr.to_numpy()                       ->  msgspec.ValidationError: value out of range for float
```

Consumer that breaks the prose: `validation.py:3615`,
`_NARROW_VALUE_TYPE["float"] = tuple[int | float | None, ...]`. Tidying that to
`tuple[float | None, ...]` reads as an obvious cleanup (it makes the two rules agree),
silently closes the divergence, stales the docstring, and leaves the suite green -- the
plan's `test_to_numpy_float_out_of_range_is_validation_error` pins only the `to_numpy` half.

## Verdict vs true shape

Plumb said "not plumb-true; five findings, 1e highest-leverage." That held.

On the parked item plumb was also correct to park: the `from_numpy` arity guard is enforced
at one door while `NdArray(...)` still accepts a rank mismatch. Legitimate, because ADR-0002
requires the wire door stay permissive so `validate` can report `ndarray.shape-rank`. But
the park needed its reason written into the docstring, or a later reader files it as an
inconsistency.

No sounding misfired. Sounding **2 was explicitly considered and closed** rather than fired:
the two `data_type` matches look like one duplicated mapping, but a shared helper cannot
serve `to_numpy` at all (it reintroduces the union -> `tuple[None, ...]` collapse), which is
exactly the 2-boundary test ("could one helper serve every site without a parameter that
re-encodes the very difference?").

## Provenance

- **1e, 1d, 1a x2, 6 -- me (the model)**, reviewing my own plan, on explicit user
  instruction (`"plumb the plan"`). Not spontaneous: the user's prompt was the trigger,
  matching the skill's own note that a self-authored design does not reliably run its own
  claims.
- The `_PROJECTION` sketch that 1e indicted -- **me**, in the plan, and it **survived a Plan
  subagent's adversarial pass**, which not only failed to flag it but *recommended* it as
  step 1 of its implementation checklist, including "Do not inline the dict literal in the
  method body (it would rebuild per call...)".
- The `tuple[None, ...]` fact -- **run**, not read. Plan author and reviewing subagent
  reasoned it wrong in the same direction.
- Later rounds, post-plumb, **user-driven**: the user caught a loop-invariant dispatch in
  `from_numpy`, then asked to merge the resulting match block. That surfaced that an
  *annotated* `Mapping[Literal[...], Callable[...]]` **does** preserve exhaustiveness:

  ```
  error: Invalid index type "Literal['float', 'integer', 'string', 'boolean']" for
  "Mapping[Literal['float', 'integer', 'string'], Callable[[Any], float | int | str]]";
  expected type "Literal['float', 'integer', 'string']"  [index]
  ```

  So the 1e/1d objection is specific to *union-of-`type[...]` values consumed as a type
  argument*, not to lookup tables generally. This **refines the 1e finding's scope** and was
  not visible at plan altitude.

## Drove

Into the **work**. All five landed in the diff (PR #188, merged-pending): `match` +
`assert_never` in `to_numpy`; `test_validate_clean_does_not_guarantee_to_numpy` pinning the
pair rather than either half; `ModuleNotFoundError` added to `range.py` plus four bridge
`Raises` sections; the arity park's rationale written into `from_numpy`'s docstring.

Nothing drove into the skill -- no coverage-gap or wording-gap observed this run.

**Recorded, not claimed as a gap:** the 1e worked example may want the distinction the later
rounds surfaced -- a lookup table is a type lie *when its values are a union of `type[...]`
consumed as a type argument*, and is sound when the values are homogeneous and the key type
is annotated. Both forms now sit in the same file: `_PROJECTION` rejected in `to_numpy`,
`_CONVERTERS` accepted in `from_numpy`, with a comment on the latter explaining why the
former cannot share it. Whether that belongs in EXAMPLES.md is for the claude-skills session
to judge.

## HELD

**Yes -- all five findings.** Every one was authored by the model that authored the plan
under review; the author cannot land their own claim.

Provenance is **doubly weak** here: the sole external check (a Plan subagent) actively
recommended the construct 1e indicted. The counterweight is that the load-bearing claims
were verified by *running* -- `mypy --strict` `reveal_type`; a deleted `case` arm going red;
a fourth `Literal` member erroring at the index site -- rather than by argument. But the
*selection* of what to probe was still the author's.
