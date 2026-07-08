# From untested floors to a tested contract (covjson-msgspec #65)

The worked example the `uv-minimum-versions` skill was distilled from. It is
here for the reasoning, not the version numbers: watch where a plausible plan
met a hard fact and had to bend.

## Setting the scene

covjson-msgspec is a fast, fully-typed CoverageJSON library built on msgspec: a
thin core (msgspec + langcodes) plus opt-in bridges, each behind an extra
(`numpy`, `xarray`, `pandas`, `geo`, `fastapi`). Its Python floor is `>=3.11`,
deliberately coupled to titiler. Supported Pythons: 3.11 through 3.14.

Issue #65 named three faults in the runtime dependency floors, and they are the
faults *every* library drifts into:

- **Arbitrary.** Some floors were deliberate (`xarray>=2024.10` for `DataTree`,
  `fastapi>=0.110` for the titiler coupling); others (`msgspec>=0.18`,
  `geopandas>=0.14`) were set once and never justified.
- **Untested.** CI only ever resolved the *latest* versions, so every floor was
  an unverified claim. A recent change had added new msgspec usage and nobody
  knew whether the declared `msgspec>=0.18` still held.
- **Silently auto-raised.** Dependabot bumped floors on each upstream release
  (a PR tried `geopandas>=0.14` -> `>=1.1.4`), narrowing user compatibility for
  versions the library uses nothing from.

The work ran in four streams: (1) stop Dependabot raising floors
[`lockfile-only`, shipped first, standalone]; (2) audit and set deliberate
floors; (3) test both ends in CI; (4) record the policy in ADR-0010. Streams
2-4 shipped together in PR #68.

## How to read this

The value is in three places where the obvious move was wrong: a floor that
looked fine but had no wheel, a CI matrix that looked complete but could not
exist, and a one-line change that tried to drag 700 lines of churn with it.

## Phase 1 -- The audit, and the fact that moved a floor

**1. Baseline first.** Before changing anything: `uv sync --resolution
lowest-direct` then the suite, on Python 3.11. It went green -- 709 passed --
which already answered the issue's sharpest worry: the declared floors *do*
hold. The resolver reported the floors it actually installed: msgspec 0.18.0,
numpy 1.24.0, cftime **1.6.0**, pandas **2.1.0** (declared `>=2.0`), geopandas
0.14.0, shapely 2.0.0, and the rest at their declared values.

Two of those resolved numbers were already telling a story (pandas came out
*above* its floor -- hold that thought), but the baseline's real job was to turn
"are the floors OK?" from an argument into a test.

**2. The cftime catch -- criterion (b) earns its place.** cftime looked like a
free lowering: I dropped it to `>=1.5`, re-resolved, and the suite passed. It
would have shipped, except the wheel check contradicted the green suite. Asking
PyPI directly:

```
cftime 1.5.0 -> (no cp311 wheels)
cftime 1.6.0 -> (no cp311 wheels)
cftime 1.6.1 -> (no cp311 wheels)
cftime 1.6.2 -> cp311 wheels present
```

cftime is Cython-compiled. 1.6.0 and 1.6.1 -- *including the version the baseline
had just resolved* -- ship no cp311 wheel. The local pass was a lie: my machine
had a C compiler and silently built cftime from source. On a clean runner, or
for a user on a slim image, that install fails. So the existing `cftime>=1.6`
was not merely arbitrary, it was **too low to be installable by wheel on the
Python floor.** It went *up*, to `>=1.6.2` -- the audit's one real correction.

**3. numpy and pandas would not go lower -- because a sibling holds them.** I
tried `numpy>=1.23` and `pandas>=1.5`. Both re-resolved right back to 1.24.0 and
2.1.0: xarray requires them that high, and xarray is always present in the
all-extras environment CI builds. So lowering their *declarations* changed
nothing installable and could never be verified below xarray's constraint.
They stayed at the resolved versions, now with a recorded reason ("pinned up by
xarray"). This is the sibling trap: a lower number you cannot prove is not a
wider contract, it is a fiction.

**4. msgspec stayed put on purpose.** I probed whether the core dep could drop:
`uv run --isolated --with msgspec==0.16` confirmed 0.16 already has every API the
library uses (`json.format`, `schema_components(ref_template=)`,
`structs.replace`) and ships cp311 wheels. Mechanically, the floor *could* be
0.16. It stayed at 0.18: msgspec is a fast-moving, pre-1.0 *core* dependency,
the reach below 0.18 is negligible, and I did not want to vouch for behavior
that old. "Arbitrary" was fixed by writing the reason down, not by minimizing.

**5. geopandas held.** 0.13 passed and is pure-Python (wheel-safe anywhere), but
0.13-vs-0.14 is negligible reach; the real win against geopandas was stream 1
(no more auto-bumps). Kept at 0.14 with a rationale.

Net audit: nine floors, one actually wrong (cftime), the rest defensible and now
justified. The point was never to minimize -- it was to make each floor a
sentence you could defend.

## Phase 2 -- The matrix that could not exist *(the catch that mattered)*

**6. The plan, and its confident error.** Stream 3 was "test both ends," and the
issue's recorded choice was a full cross: `resolution: [highest, lowest-direct]`
times the whole Python matrix, 3.11 through 3.14. I wired it and pushed. My
stated assumption was that on newer Pythons uv would "self-raise" the floors via
wheel availability.

**7. It went red on 3.12-3.14:**

```
ModuleNotFoundError: No module named 'pkg_resources'
hint: `shapely` (v2.0.0) was included because `covjson-msgspec[all]` depends on `shapely`
```

**8. The diagnosis -- and the correction to my own model.** uv resolves by
`requires-python` metadata, *not* by wheel availability. The floor releases
declare open-ended `requires-python` but stopped shipping wheels at their era's
Python:

| package | floor | cp wheel tags | requires-python |
|---|---|---|---|
| shapely | 2.0.0 | cp37-cp311 | >=3.7 |
| numpy | 1.24.0 | cp38-cp311 | >=3.8 |
| pandas | 2.0.0 | cp38-cp311 | >=3.8 |
| cftime | 1.6.2 | cp37-cp311 | >=3.7 |
| msgspec | 0.18.0 | cp38-cp311 | >=3.8 |

So on 3.14, `lowest-direct` pins shapely 2.0.0 (its metadata permits it), finds
no wheel, and tries to build from source -- which fails. My "self-raise"
assumption was simply false: the floors do not rise on newer Pythons, they just
become uninstallable there.

**9. The fix, and the insight underneath it.** A dependency floor is only
coherent *paired with the Python floor*. The declared floors are a 3.11-era
snapshot; the only interpreter they ship wheels for is 3.11. So `lowest-direct`
belongs on the floor Python alone. I set the matrix to `highest` across the full
range plus one `lowest-direct` leg on `python-versions[0]`, added through a
matrix `include` (five legs total). Green. What began as a CI failure became the
skill's central idea, and ADR-0010 records *why* the full cross was dropped.

## Phase 3 -- The one-line change that tried to bring friends

**10. 714 lines of churn for a one-line intent.** After the floor edits, the
`uv.lock` diff was enormous: `uv lock` had re-resolved the whole graph and bumped
~25 stale transitive pins (ast-serialize 0.5.0 -> 0.6.0, and so on) plus rewrote
resolution-markers. The only change I *meant* was cftime's specifier. The churn
was unrelated upgrade risk riding in on the coattails of a policy PR.

**11. Strip it to the intent.** `git checkout main -- uv.lock` to discard the
churn, hand-edit the single line (`specifier = ">=1.6"` -> `">=1.6.2"`), then
`uv lock --check` to confirm the lock was still consistent. Final `uv.lock` diff:
one line. Keeping transitives fresh is Dependabot's job now (`lockfile-only`),
not a side effect of a floor PR. (The churn reappeared once more from a stray
`uv sync`; same discipline, discarded again.)

## Phase 4 -- Shipping and the gate

**12. Both ends, blocking.** PR #68 merged to main (commit 3ca0d87): 709 passed
at both `highest` and `lowest-direct` on 3.11, all five legs green, ADR-0010
written (and the previously-missing ADR-0009 index entry fixed in passing).

**13. Verify the gate really gates the new leg.** main is governed by a ruleset
(`default`, id 18134093) that requires a single status check: `Required checks`.
That is an aggregator job that `needs: [config, checks, typecheck, test,
coverage]`. Because a matrix job is one node in `needs:` that succeeds only if
all legs succeed, the `lowest-direct` leg is gated *transitively* -- a red leg
reds `test`, which reds `Required checks`, which blocks the merge. And because
the ruleset names the stable aggregator, not the per-leg names, adding the leg
required no branch-protection change at all. That aggregator pattern is what let
the whole matrix change stay invisible to the ruleset.

## What made it converge

Three facts did the work, and each is a trap in the skill:

- **A green suite is not a valid floor.** cftime passed locally and was still
  wrong -- no cp311 wheel. Criterion (b) is not bookkeeping; it caught the one
  real bug. (Trap 1 / the wheel argument.)
- **The environment, not the declaration, decides.** numpy and pandas could not
  be lowered because xarray holds them; the declaration is cosmetic below a
  sibling's floor. (Trap 2.)
- **The matrix has a shape reality imposes.** "Test every floor on every Python"
  is incoherent, because floor-era wheels only exist for the floor-era Python.
  The failure taught the shape. (Trap 1's consequence.)

And one stance under all of it: the goal was a *defensible* contract, not a
minimal one. Most floors did not move; they earned a sentence. (Trap 3.)

## Groundwork (terms in one line)

- **Floor / lower bound**: the oldest version of a dependency a library promises
  to support (`pkg>=X`).
- **`--resolution lowest-direct`**: uv resolves *direct* deps to their declared
  floors, transitive deps to modern; the oracle for "do my floors work."
- **`requires-python` vs wheel**: a resolver picks a version by `requires-python`
  metadata, then installs a wheel *if one exists* for the target, else builds
  from source. The two can disagree -- that gap is trap 1.
- **Sibling pin**: dep A's version forced up by dep B's requirement on A; below
  it, A's own declared floor is unverifiable.
- **`lockfile-only`**: Dependabot mode that refreshes `uv.lock` but never
  rewrites `pyproject.toml` bounds, so floors move only deliberately.
- **Aggregator check**: one stable CI job that `needs:` all others, so branch
  protection gates the whole matrix through a single name that never drifts.
