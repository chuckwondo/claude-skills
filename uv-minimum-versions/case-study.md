# From untested floors to a tested contract (covjson-msgspec #65, #259)

The worked example the `uv-minimum-versions` skill was distilled from. It is
here for the reasoning, not the version numbers: watch where a plausible plan
met a hard fact and had to bend.

## Setting the scene

covjson-msgspec is a fast, fully-typed CoverageJSON library built on msgspec: a
thin core (msgspec + langcodes) plus opt-in bridges, each behind an extra
(`numpy`, `xarray`, `pandas`, `geo`, `fastapi`). Its Python floor is `>=3.11`,
deliberately coupled to titiler. Supported Pythons: 3.11 through 3.14.

Issue #65 listed three faults in the runtime dependency floors, and they are the
faults *every* library drifts into:

- **Arbitrary.** Some floors were deliberate (`xarray>=2024.10` for `DataTree`,
  `fastapi>=0.110` for the titiler coupling). Others (`msgspec>=0.18`,
  `geopandas>=0.14`) were set once and never justified.
- **Untested.** CI only ever resolved the *latest* versions, so every floor was
  an unverified claim. A recent change had added new msgspec usage and nobody
  knew whether the declared `msgspec>=0.18` still held.
- **Silently auto-raised.** Dependabot bumped floors on each upstream release
  (a PR tried `geopandas>=0.14` -> `>=1.1.4`), narrowing user compatibility for
  versions the library uses nothing from.

The work ran in four streams: (1) stop Dependabot raising floors
[`lockfile-only`, shipped first, standalone]; (2) audit and set deliberate
floors; (3) test both ends in CI; (4) record the policy in ADR-0010. Streams 2-4
shipped together in PR #68. Nearly three months later, #259 found that the floor
job had never tested the floors (Phase 5).

## How to read this

The value is in the places where the obvious move was wrong: a floor that looked
fine but did not ship a wheel, a CI matrix that looked complete but could not
exist, a one-line change that tried to drag 700 lines of churn with it, and a
floor job that passed for months without testing the floors.

Trap numbers and "procedure step N" refer to `SKILL.md`. A bare step number,
like "(step 19)", is one of this file's numbered steps. Notes marked
**Correction** were added after #259 and its follow-up checks showed that some
claims in Phases 1 to 4 were wrong or unverified. The Groundwork section defines
the terms.

Contents: Setting the scene, Phases 1 to 5, What made it converge, and
Groundwork (terms).

## Phase 1: The audit, and the fact that moved a floor

**1. Start with a baseline.** Before changing any floor, I installed the current
floors on Python 3.11 with `uv sync --resolution lowest-direct`, which picks the
lowest version each declaration allows. It installed msgspec 0.18.0, numpy
1.24.0, cftime **1.6.0**, pandas **2.1.0**, geopandas 0.14.0, shapely 2.0.0, and
the rest at their declared floors. Then I ran the test suite, and all 709 tests
passed. I took that as the answer to the issue's main worry: the declared
floors, msgspec's included, still worked.

> **Correction (#259).** The versions listed are accurate, because the sync
> printed them. The test result is not reliable. Nothing records how the tests
> were run, and if they were run with a plain `uv run`, they ran against the
> newest releases instead of these floors (Phase 5). So the conclusion that the
> floors still worked is unverified.

Two of those versions matter later. cftime 1.6.0 turns out not to ship a wheel
for Python 3.11 (step 2). pandas installed at 2.1.0, although its declared floor
is 2.0, because another dependency requires 2.1 (step 3).

**2. The cftime catch: a floor must ship a wheel.** cftime looked like a
free lowering: I dropped it to `>=1.5`, re-resolved, and the suite passed. It
would have shipped, except the wheel check contradicted the passing suite.
Asking PyPI directly:

```text
cftime 1.5.0 -> (no cp311 wheels)
cftime 1.6.0 -> (no cp311 wheels)
cftime 1.6.1 -> (no cp311 wheels)
cftime 1.6.2 -> cp311 wheels present
```

cftime is Cython-compiled. 1.6.0 and 1.6.1, *including the version the baseline
had just resolved*, do not ship a cp311 wheel. The local pass was a lie, because
my machine had a C compiler and silently built cftime from source. On a clean
runner, or for a user on a slim image, that install fails. So the existing
`cftime>=1.6` was not merely arbitrary, it was **too low to be installable by
wheel on the Python floor.** It went *up*, to `>=1.6.2`, the audit's one real
correction.

> **Correction (#259).** The test result here is not reliable. If the tests were
> run with a plain `uv run`, they ran against the newest cftime, not 1.5
> (Phase 5). Raising the floor to `cftime>=1.6.2` is still right, because that
> decision rests on PyPI's wheel list, not on the tests: no cftime release
> before 1.6.2 has a cp311 wheel.

**3. numpy and pandas would not go lower, because a sibling dependency holds
them up.** I tried `numpy>=1.23` and `pandas>=1.5`. Both re-resolved right back
to 1.24.0 and 2.1.0: xarray requires them that high, and xarray is always
present in the all-extras environment CI builds. So lowering their
*declarations* changed nothing installable and could never be verified below
xarray's constraint. They stayed at the resolved versions, now with a recorded
reason: a comment saying xarray pins them there. This is the sibling trap: a
lower number you cannot prove is not a wider contract, it is a fiction.

> **Correction (#259).** Only numpy stayed at its resolved version. pandas kept
> `>=2.0`, below the 2.1.0 that actually installs, with a comment saying 2.0 is
> untested. Keeping an untested floor is a valid choice, but only if nothing
> reports it as verified. ADR-0010 did report every floor as verified, pandas
> included, until #259 corrected it (step 19).

**4. msgspec stayed put on purpose.** I probed whether the core dep could drop:
`uv run --isolated --with msgspec==0.16` confirmed 0.16 already has every API
the library uses (`json.format`, `schema_components(ref_template=)`,
`structs.replace`) and ships cp311 wheels. Mechanically, the floor *could* be
0.16. It stayed at 0.18, because msgspec is a fast-moving, pre-1.0 *core*
dependency, few users need anything older, and I did not want to vouch for
behavior that old. "Arbitrary" was fixed by writing the reason down, not by
minimizing.

**5. geopandas stayed at 0.14.** Lowering it to 0.13 looked safe, because the
tests passed and geopandas is pure Python, so it installs on any Python version.
But few users need 0.13 rather than 0.14, so lowering it gained little. The real
problem with geopandas was Dependabot trying to raise its floor to 1.1.4 (see
Setting the scene), and stream 1 had already stopped that. So the floor stayed
at 0.14, with a recorded reason.

> **Correction (#259).** No reason for 0.14 was recorded. The comment beside the
> floor in `pyproject.toml` explains why the geo extra lists pandas and numpy,
> and that geopandas is pure Python, but not why 0.14. ADR-0010 now lists the
> floor as lacking a reason, and covjson-msgspec #267 tracks the fix. The 0.13
> test result is not reliable either: if the tests ran through a plain `uv run`,
> they tested the newest geopandas, not 0.13 (Phase 5).

Net result: of nine floors, one was wrong (cftime). The others were judged
defensible and given a reason. The goal was never the lowest possible floors,
but floors you could each defend in one sentence.

> **Correction (#259).** Not every floor got a reason. langcodes and geopandas
> still have none (covjson-msgspec #266 and #267), and fastapi's stated reason,
> matching titiler's floor, was false (step 19).

## Phase 2: The matrix that could not exist (the catch that mattered)

**6. The plan, and its confident error.** Stream 3 was "test both ends," and the
issue's recorded choice was a full cross: `resolution: [highest, lowest-direct]`
times the whole Python matrix, 3.11 through 3.14. I wired it and pushed. My
stated assumption was that on newer Pythons uv would "self-raise" the floors via
wheel availability.

**7. It failed on 3.12-3.14:**

```text
ModuleNotFoundError: No module named 'pkg_resources'
hint: `shapely` (v2.0.0) was included because `covjson-msgspec[all]` depends on `shapely`
```

**8. The diagnosis, and the correction to my own model.** uv resolves by
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

So on 3.14, `lowest-direct` pins shapely 2.0.0 (its metadata permits it), cannot
find a wheel, and tries to build from source, which fails. My "self-raise"
assumption was simply false. The floors do not rise on newer Pythons. They just
become uninstallable there.

**9. The fix, and the insight underneath it.** A dependency floor is only
coherent *paired with the Python floor*. The declared floors are a 3.11-era
snapshot. The only interpreter they ship wheels for is 3.11. So `lowest-direct`
belongs on the floor Python alone. I set the matrix to `highest` across the full
range plus one `lowest-direct` job on the Python floor (3.11), added through a
matrix `include` (five jobs total). Every job passed. What began as a CI failure
became the skill's central idea, and ADR-0010 records *why* the full cross was
dropped.

> **Correction (#259).** The `lowest-direct` job passed without testing the
> floors. Its test step, `uv run --quiet pytest`, replaced the floors with the
> newest releases before running the tests (Phase 5). The matrix shape is still
> right, because the 3.12-3.14 failures happened in the install step, which
> really did install the floors.

## Phase 3: The one-line change that tried to bring friends

**10. 714 lines of churn for a one-line intent.** After the floor edits, the
`uv.lock` diff was enormous: `uv lock` had re-resolved the whole graph and
bumped ~25 stale indirect pins (ast-serialize 0.5.0 -> 0.6.0, and so on) plus
rewrote resolution-markers. The only change I *meant* was cftime's specifier.
The churn was unrelated upgrade risk riding in on the coattails of a policy PR.

**11. Strip it to the intent.** `git checkout main -- uv.lock` to discard the
churn, hand-edit the single line (`specifier = ">=1.6"` -> `">=1.6.2"`), then
`uv lock --check` to confirm the lock was still consistent. Final `uv.lock`
diff: one line. Keeping transitives fresh is Dependabot's job now
(`lockfile-only`), not a side effect of a floor PR. (The churn reappeared once
more from a stray `uv sync`, and was discarded the same way.)

> **Correction (#259 follow-up).** Dependabot does not keep indirect
> dependencies fresh. Under `lockfile-only` it updates only direct dependencies
> (dependabot-core#14073). By October 2026, covjson-msgspec's lock was behind on
> 31 indirect dependencies, ast-serialize still among them at 0.6.0. A scheduled
> lock refresh now does that job (`reference.md`, Keep indirect dependencies
> fresh).

## Phase 4: Shipping and the gate

**12. Both ends, blocking.** PR #68 merged to main on 2026-07-08 (commit
3ca0d87): 709 passed at both `highest` and `lowest-direct` on 3.11, all five
jobs passing, ADR-0010 written (and the previously-missing ADR-0009 index entry
fixed in passing).

> **Correction (#259).** The 709 passes at `lowest-direct` came from the newest
> releases, the same versions the `highest` jobs tested (Phase 5). No CI run
> tested the floors until #259.

**13. Verify the gate really gates the new job.** main is governed by a ruleset
(`default`, id 18134093) that requires a single status check: `Required checks`.
That is an aggregator job that
`needs: [config, checks, typecheck, test, coverage]`. Because a matrix job is
one node in `needs:` that succeeds only if every job it creates succeeds, the
`lowest-direct` job is gated *transitively*. A failing job fails `test`, which
fails `Required checks`, which blocks the merge. And because the ruleset
requires the stable aggregator, not the per-job names, adding the job required
no branch-protection change at all. That aggregator pattern is what let the
whole matrix change stay invisible to the ruleset.

> **Correction (#259).** The gate worked, but the job behind it could not catch
> a bad floor, because it never tested the floors. Lowering a floor on purpose
> (procedure step 4) would have revealed that, because the job would still have
> passed.

## Phase 5: The floor job never tested the floors (#259)

**14. A failure that should have been impossible.** On 2026-09-29, msgspec
0.22.0 changed the error for an integer too large for a float (msgspec#1122),
and a covjson-msgspec test that checked that error failed. It failed only in the
`lowest-direct` job. The `highest` jobs install from the lock, which still had
msgspec 0.21.1. So the job meant to test msgspec 0.18 was the only one running
0.22.0.

**15. Replaying the job.** The install step installed msgspec 0.18.0 and pytest
8.0.0. Then the test step, `uv run --quiet pytest`, synced again in uv's default
`highest` mode and installed msgspec 0.22.0 and pytest 9.1.1. The job had been
testing the newest releases since the day it was added, step 12's 709 included.
The July logs had expired, so I replayed the July job with that month's uv
(0.11.28) and got the same result.

**16. The problem had been found a month earlier.** In August, titiler-covjson,
whose CI came from this skill's recipe, had the same broken job, which its
PR #94 fixed. The skill was updated to use `uv run --no-sync`, but nobody fixed
covjson-msgspec, so its job kept testing the newest releases for six more weeks.
Fixing a recipe does not fix the projects already built from it.

**17. A sturdier fix than `--no-sync`.** `--no-sync` protects only its own step.
If any earlier step runs `uv run`, the floors are already gone. Setting
`UV_RESOLUTION: ${{ matrix.resolution }}` on the job makes every uv command in
it use the floors. The job also prints `uv tree --frozen --depth 1`, so the log
shows what was tested. (Trap 5.)

**18. The first real run failed, but no runtime floor was wrong.** At the real
floors, 6 tests failed and 1 test module could not be collected. Every failure
came from the tests or dev tools relying on newer releases, not from the
library. The fixes were test inputs that print the same on every version, a dev
floor of `pytest>=8.1.1`, and a different HTTP test client. No runtime floor
went up. (Trap 6. The full list is in `reference.md`.)

**19. A floor lowered, and a probe that misled.** The fastapi floor, `>=0.110`,
claimed to match titiler's, but no titiler release since 2024 had used 0.110.
The library needs at least 0.99.0, the first release that emits OpenAPI 3.1. A
hand-built test environment with fastapi 0.99.0 passed, so 0.99 became the plan.
But `uv.lock` resolves all dependency groups together, and the `bench`
dependency group, used for benchmarks, needs pydantic 2, which fastapi supports
only from 0.100.0. So CI could never install 0.99. The probe showed that 0.99
works, not that CI would install it. The floor became 0.100, and moving `bench`
to its own lock is tracked in #264. The same review found ADR-0010 calling every
floor verified, though xarray forces pandas to 2.1. It now says the
`pandas>=2.0` floor is untested. (Trap 2.)

**20. Proving the job can fail.** In a throwaway draft pull request (#263),
lowering pytest's floor back to 8.0 made the floor job install pytest 8.0.0 and
fail on the doctest for covjson-msgspec's `validate` function, while the
`highest` jobs passed. A local preview of this first passed by mistake. Its
`uv.lock` was left over from an earlier floor run, and uv kept the pytest 8.1.1
already in it. Starting from the committed lock, as CI does, fixed that.

## What made it converge

These facts did the work, and each is a trap in the skill:

- **A passing suite is not a valid floor.** cftime passed locally and was still
  wrong, because it did not ship a cp311 wheel. The wheel requirement is not
  bookkeeping. It caught the one real bug. (Trap 1.)
- **The environment, not the declaration, decides.** numpy and pandas could not
  be lowered because xarray holds them up, and fastapi could not be tested below
  0.100 because the benchmark group holds it up. The declaration is cosmetic
  below a sibling's floor. (Trap 2.)
- **The matrix has a shape reality imposes.** "Test every floor on every Python"
  is incoherent, because floor-era wheels only exist for the floor-era Python.
  The failure taught the shape. (Trap 1's consequence.)
- **A passing floor job may not have tested the floors.** This one passed for
  nearly three months at the newest releases. Only its installed versions showed
  it. (Trap 5.)
- **A failure at the floors is not always a floor problem.** None of the first
  real run's failures was. (Trap 6.)

And one stance under all of it: the goal was a *defensible* contract, not a
minimal one. Most floors did not move. What they needed was a recorded reason,
not a lower number. (Trap 3.)

## Groundwork (terms)

- **Floor / lower bound**: the oldest version of a dependency a library promises
  to support (`pkg>=X`).
- **Direct / indirect dependency**: a direct dependency is one `pyproject.toml`
  declares. An indirect (transitive) dependency is one that another dependency
  pulls in.
- **Extra**: an optional set of dependencies a user requests by name, e.g.,
  `covjson-msgspec[xarray]`. The *all-extras* environment installs every extra.
- **Python floor**: the lowest Python version the library supports (3.11 here).
- **Floor job**: the CI job that runs the tests with uv's `--resolution
  lowest-direct`, so each direct dependency is installed at its floor. Also
  called the `lowest-direct` job.
- **`highest`**: uv's default resolution, the newest release each constraint
  allows. The `highest` CI jobs install from the committed `uv.lock`.
- **`--resolution lowest-direct`**: uv resolves *direct* dependencies to their
  declared floors and indirect ones to their newest releases. It is the way to
  test whether the floors work.
- **`requires-python` vs wheel**: a resolver picks a version by
  `requires-python` metadata, then installs a wheel *if one exists* for the
  target, else builds from source. The two can disagree, and that gap is trap 1.
- **cp311**: the wheel tag for CPython 3.11. A release without a cp311 wheel has
  to be built from source on Python 3.11.
- **Sibling pin**: dep A's version forced up by dep B's requirement on A. Below
  it, A's own declared floor is unverifiable. A dependency group can be the
  sibling, because `uv.lock` resolves every group together.
- **`UV_RESOLUTION`**: the environment variable version of `--resolution`. Set
  on a CI job, it applies to every uv command in the job.
- **Dependency group**: a named set of development-only dependencies in
  `pyproject.toml` (here `dev`, `typecheck`, `bench`, and `docs`). Users never
  install them.
- **`lockfile-only`**: Dependabot mode that refreshes `uv.lock` but never
  rewrites `pyproject.toml` bounds, so floors move only deliberately.
- **ADR**: architecture decision record, a short document that records a design
  decision and its reasons. covjson-msgspec's floor policy is ADR-0010.
- **titiler**: a map tile server built on FastAPI. covjson-msgspec matches its
  Python floor so that titiler-based services can use it.
- **Aggregator check**: one stable CI job that `needs:` all others, so branch
  protection gates the whole matrix through a single name that never drifts.
