# uv-minimum-versions: reference

Details behind `SKILL.md`. The worked example is `case-study.md`.

This file uses `SKILL.md`'s terms and trap numbers. A *floor* is a dependency's
lowest supported version, and the *Python floor* is the lowest supported Python.
The *floor job* is the CI job that tests the floors with `--resolution
lowest-direct`. `highest` is uv's default resolution, the newest versions the
constraints allow. *Indirect* (transitive) dependencies are the ones your
dependencies pull in.

Contents:

- The CI recipe, and gating it without per-job churn
- The traps, with evidence (traps 1 to 6)
- Probes (one-off checks while auditing)
- Operating the gate
- The policy layer: stopping Dependabot raising floors, keeping indirect
  dependencies fresh, choosing how the refresh runs, bounding a broken release
  that a refresh finds, and recording an architecture decision record (ADR)
- Sources

## The CI recipe

Add a `resolution` axis to the existing test job. `highest` stays across the
full Python matrix, and a matrix `include` adds **one** `lowest-direct` job on
the Python floor.

```yaml
  test:
    needs: config          # derives the Python matrix (see Notes)
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python-version: ${{ fromJSON(needs.config.outputs.python-versions) }}
        resolution: [highest]
        # Run lowest-direct on the Python floor only, because old floor
        # releases ship no wheels for newer Pythons (trap 1).
        include:
          - python-version: ${{ fromJSON(needs.config.outputs.python-versions)[0] }}
            resolution: lowest-direct
    # Apply the job's mode to every uv command, not just the install.
    # Otherwise `uv run` re-syncs in the default `highest` mode and replaces
    # the floors (trap 5).
    env:
      UV_RESOLUTION: ${{ matrix.resolution }}
    steps:
      - uses: actions/checkout@<sha>
      - uses: astral-sh/setup-uv@<sha>
        with:
          python-version: ${{ matrix.python-version }}
          enable-cache: true
          # Namespace the cache per resolution so the highest and lowest-direct
          # jobs (same Python, different resolved deps) don't race to save one key.
          cache-suffix: ${{ matrix.resolution }}
      # The committed lock records highest mode, so lowest-direct re-resolves
      # and cannot use --locked.
      - name: Install (highest, from lockfile)
        if: matrix.resolution == 'highest'
        run: uv sync --locked
      - name: Install (lowest-direct floors)
        if: matrix.resolution == 'lowest-direct'
        run: uv sync
      # Log the tested versions. This job's lock is never committed.
      - name: List the locked direct dependency versions
        if: matrix.resolution == 'lowest-direct'
        run: uv tree --frozen --depth 1
      - run: uv run pytest
```

Notes:

- **All extras synced.** Sync whatever installs every runtime extra (a dev group
  that pulls `[all]` + any framework extras), so every runtime floor is
  exercised, not just the core. This also installs the default dev group at its
  floors (trap 6).
- **One mode per job.** Job-level `UV_RESOLUTION` also covers steps added later.
  `--no-sync` on the test step would protect only that step (trap 5).
- **Log what was tested.** `uv tree` prints each direct dependency's version
  from the lock, and pytest's header line shows the installed pytest as a
  cross-check. Check both on the first run. If they show the newest releases,
  the job is not testing the floors.
- **Both resolutions block.** The floor job is the point, so do not make it
  `continue-on-error`.
- **The matrix `include` idiom.** With `resolution: [highest]` as the only axis
  value, an `include` whose `resolution: lowest-direct` conflicts with every
  base combination cannot merge into any of them, so GitHub creates one new
  combination: `{floor-Python, lowest-direct}`. Result: full `highest` matrix +
  one `lowest-direct` job.
- **Derive the Python matrix from one source.** A small `config` job that reads
  the `Programming Language :: Python :: 3.x` classifiers from `pyproject.toml`
  and emits them as JSON keeps the matrix from drifting from declared support.
  `python-versions[0]` is then the floor.

### Gate it without per-job churn

Branch protection / rulesets should require **one stable aggregator check**, not
the names of the jobs a matrix creates (which change as the matrix changes):

```yaml
  required-checks:
    name: Required checks
    if: always()
    needs: [config, checks, typecheck, test, coverage]
    runs-on: ubuntu-latest
    steps:
      - if: contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') || contains(needs.*.result, 'skipped')
        run: exit 1
```

A matrix job counts as one entry in `needs:`, and it fails if any of its jobs
fails. So `required-checks` covers the `lowest-direct` job too. Point the
ruleset's `required_status_checks` at `Required checks`, and it never needs to
change when jobs are added or Pythons bumped.

## The traps, with evidence

### 1. Wheels are not `requires-python`

Resolvers (uv, pip) choose a version by its `requires-python` metadata, then
install a wheel *if one exists for the target*, else build from the source
distribution (sdist). Old releases of compiled packages declare an open-ended
`requires-python` but only shipped wheels for the Pythons that existed at
release. So `lowest-direct` on a newer interpreter pins the ancient floor
version, which does not ship a wheel there, and the source build fails.

The failure covjson-msgspec hit, verbatim:

```text
ModuleNotFoundError: No module named 'pkg_resources'
hint: `shapely` (v2.0.0) was included because `covjson-msgspec[all]` depends on `shapely`
```

Evidence: the floor releases ship wheels only through cp311 (CPython 3.11), yet
all declare an open-ended `requires-python`:

| package | floor version | cp wheel tags shipped | requires-python |
| --- | --- | --- | --- |
| shapely | 2.0.0 | cp37-cp311 | >=3.7 |
| numpy | 1.24.0 | cp38-cp311 | >=3.8 |
| pandas | 2.0.0 | cp38-cp311 | >=3.8 |
| cftime | 1.6.2 | cp37-cp311 | >=3.7 |
| msgspec | 0.18.0 | cp38-cp311 | >=3.8 |

So on Python 3.12-3.14, `lowest-direct` pins these same 3.11-era versions (their
metadata permits it) and there is no wheel. **Fix: run `lowest-direct` on the
floor Python only, and let `highest` cover the newer Pythons against modern
(wheeled) deps, the pairing users actually run.**

### 2. A sibling or a dependency group can pin a dependency higher

Under an all-extras `lowest-direct` resolve, a dependency can be forced above
its own declared floor by a *sibling* dependency's requirement. Probe it:
declare the floor lower, delete the lock, and see whether the version actually
moves.

- Declared `numpy>=1.23`, still resolved `numpy==1.24.0` -> xarray requires
  `>=1.24`. Declared `pandas>=1.5`, still resolved `pandas==2.1.0` -> pinned up
  by xarray.
- Consequence: lowering numpy's / pandas's *declaration* below the sibling
  constraint changes nothing in the all-extras environment and cannot be
  verified there. Raise the declaration to what resolves, or keep it and record
  it as untested. covjson-msgspec keeps `pandas>=2.0`, and its architecture
  decision record (ADR-0010) says 2.0 is untested, because the floor job
  installs 2.1.0.
- Dependency groups pin too, because `uv.lock` holds one version of each package
  across the project, its extras, and all groups. covjson-msgspec's `bench`
  dependency group (benchmarks) needs `covjson-pydantic`, which needs pydantic
  2, which fastapi supports only from 0.100.0. So the lock never has a fastapi
  below 0.100. With `fastapi>=0.98`, a fresh lowest-direct lock resolved
  0.100.0, and 0.98.0 once `bench` was removed. The floor job never installs
  `bench`, so its log gives no hint. To find a group pin, re-resolve in a
  throwaway copy with the group removed.

### 3. "Arbitrary" is not the same as "should be lowered"

The audit's job is to make each floor *defensible*, not merely *minimal*. Some
floors are genuinely lowerable and should drop. Others are best kept and simply
given a reason.

- msgspec: probed 0.16, which has all the APIs used (`json.format`,
  `schema_components(ref_template=)`, `structs.replace`) and cp311 wheels. Still
  kept at `>=0.18`, because a fast-moving pre-1.0 *core* dependency is best held
  at a recent, deliberate baseline. Few users need anything older, and it is not
  worth vouching for old behavior. The fix for "arbitrary" here was a recorded
  rationale, not a lower number.

### 4. A floor change must not re-resolve the whole lock

The only intended lock change is the floor specifier(s) you edited. But a bare
`uv sync` / `uv lock` re-resolves and bumps stale *indirect* pins (a lock that
lags the registry can move dozens of packages). Keep the diff clean:

```sh
git checkout <base> -- uv.lock          # discard the churn
# hand-edit only the changed specifier line(s), e.g.:
#   specifier = ">=1.6"  ->  specifier = ">=1.6.2"
uv lock --check                          # verify the lock is still consistent
```

`uv sync --locked` never rewrites the lock. A lowest-direct sync does, to record
`resolution-mode = "lowest-direct"` and the floor versions. Locally, run the
floors in a throwaway copy (see Probes) or restore the lock before committing.
Keeping indirect dependencies fresh is the scheduled lock refresh's job (see The
policy layer), not your floor PR's.

The uv release matters too. `uv.lock` records the format `revision` of the uv
that wrote it. uv 0.13 is the first release that writes `revision = 5`. An
older uv still reads that lock, but it writes 3 or lower whenever it re-locks.
titiler-covjson's lock refresh, run with an older uv, turned 5 into 3 along
with the version updates. Require the first release that writes your lock's
revision:

```toml
[tool.uv]
required-version = ">=0.13"
```

An older uv then stops with "Required uv version `>=0.13` does not match the
running version". setup-uv reads this setting, and for a minimum like this one
it still installs the latest uv. Any other uv that locks the project must meet
the minimum too, or it fails:

- Dependabot's built-in uv, set by the `uv==` line in dependabot-core's
  `uv/helpers/requirements.txt` (0.13.5 in October 2026)
- a uv with a fixed version, such as the one the pre-commit `uv-lock` hook's
  `rev` selects

To find the release that introduced a revision, compare `const REVISION` in
astral-sh/uv's `crates/uv-lock/src/lock/mod.rs` (`crates/uv-resolver/` before
0.13) across release tags.

### 5. A bare `uv run` undoes the floors

covjson-msgspec's floor job, replayed on Python 3.11:

| step | msgspec | pytest |
| --- | --- | --- |
| `uv sync --resolution lowest-direct` | 0.18.0 | 8.0.0 |
| then `uv run --quiet pytest` | 0.22.0 | 9.1.1 |

The second row is a fresh `highest` resolution, newer even than the committed
lock (msgspec 0.21.1). uv 0.11.28, current when the job was added, behaves the
same as 0.12.21. The job passed like this for nearly three months. It failed
only when msgspec 0.22.0 changed an error that a test checked. With job-level
`UV_RESOLUTION`, `uv run` keeps the floors.

### 6. A failure at the floors is not always a floor problem

At its real floors, covjson-msgspec's suite had 6 failures and 1 collection
error. None was caused by a runtime floor being too low.

| failure | cause | fix |
| --- | --- | --- |
| three tests expecting `ValueError` | before msgspec 0.21, `ValidationError` is not a `ValueError` | expect `msgspec.ValidationError` |
| a test that converts a numpy structured-array element to text | numpy 1.x prints `2.0` as `2.` | use `2.5`, which prints the same on both |
| the doctest for `to_xarray` | xarray 2026.4 changed the order of a Dataset repr | order the axes so both versions print the same |
| the doctest for `validate` | pytest 8.0 imports modules twice in `importlib` mode | dev floor `pytest>=8.1.1` (pytest#11475) |
| collecting `tests/test_fastapi.py` | an old Starlette's `TestClient` needs `httpx`, not `httpx2` | use `httpx2.ASGITransport` instead |

The only floor raised was pytest's, a dev tool. The run also installed
pandas-stubs 1.0.4.2, because the dev group does not set a floor for it. That is
harmless while the floor job does not run a type checker.

## Probes (one-off checks while auditing)

**Does version X ship a wheel for cp3YY?** Query the PyPI JSON API:

```sh
curl -s https://pypi.org/pypi/<pkg>/<version>/json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); \
      print(sorted({f['filename'] for f in d['urls'] if 'cp3' in f['filename'] \
                    or f['filename'].endswith('py3-none-any.whl')}))"
```

A `py3-none-any.whl` is pure Python, so it installs on any Python and always
meets the wheel requirement. If a version does not ship a `cp3YY` wheel for your
floor Python, it cannot be the floor. Raise the floor to the first release that
has one.

**Does version X provide the APIs we use?** Import it in an ephemeral env
without touching the project:

```sh
uv run --isolated --no-project --with "<pkg>==X" python -c "import <pkg>; ..."
```

This answers "can the floor go this low on APIs" cheaply, separately from the
wheel question. It does not tell you what CI will install, because other
dependencies and groups can force a higher version (trap 2). The **Do the floors
pass?** probe answers that.

**What does the floor release depend on?** Dependencies can change between
releases, so check the floor release, not just the latest:

```sh
curl -s https://pypi.org/pypi/<pkg>/<version>/json \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['info']['requires_dist'])"
```

langcodes 3.5.1 does not require any dependency, but 3.5.0 requires
`language-data`, which needs the compiled `marisa-trie`. So `langcodes>=3.5` can
install a compiled dependency, even though 3.5.1 does not.

**Do the floors pass?** Run the floor sync in a throwaway copy, because it
rewrites `uv.lock`. Export both settings so every command keeps them. A
`--python` flag on `uv sync` alone lets a later `uv run` switch to the Python in
`.python-version`, the same way a bare `uv run` loses the floors (trap 5):

```sh
copy=$(mktemp -d)
rsync -a --exclude .venv --exclude .git ./ "$copy/"
cd "$copy"
export UV_RESOLUTION=lowest-direct   # for every uv command, not just sync
export UV_PYTHON=3.11                # your Python floor, likewise
uv sync
uv tree --frozen --depth 1           # what is being tested
uv run pytest
```

Delete the copy's `uv.lock` before each re-run. Otherwise uv keeps any locked
version that still fits, and a lowered floor seems to change nothing.

## Operating the gate

### Prove the job can fail

In a throwaway draft pull request, lower one floor to a release you know breaks.
Change the same specifier in `uv.lock`, so `uv sync --locked` in the `highest`
jobs still accepts the lock. The floor job should fail, for the reason you
expect, while the `highest` jobs pass. covjson-msgspec lowered pytest's floor
back to 8.0, and the floor job failed on the doctest for its `validate`
function.

Choose a floor that nothing else pins higher (trap 2), or the job will still
pass. To preview this locally, start from the committed lock, not one that an
earlier floor run rewrote.

### After fixing main, update branches instead of re-running

Re-running a pull request's CI reuses the merge commit it already built, so it
tests the old main. Update the branch instead: comment `@dependabot rebase` on a
Dependabot pull request, or update a fork's branch (its workflow runs may also
need approval).

### Check what an old job tested

GitHub deletes workflow logs after 90 days by default (an expired log returns
HTTP 410). To find out what an old job tested, replay its steps with the uv
version it would have used. If `setup-uv` was unpinned, that is the uv release
current on that date.

## The policy layer

### Stop Dependabot raising floors

For a library, Dependabot's default `versioning-strategy` rewrites your declared
lower bounds on each upstream release, narrowing user compatibility for a
release whose changes you do not use. Set it to refresh the lockfile only:

```yaml
# .github/dependabot.yml
updates:
  - package-ecosystem: uv
    directory: /
    versioning-strategy: lockfile-only
    schedule: { interval: weekly }
    cooldown: { default-days: 7 }
```

`lockfile-only` refreshes `uv.lock` but never touches `pyproject.toml`, so a
floor rises only by a deliberate decision. Supported for the uv ecosystem per
dependabot-core#12162. The cooldown holds back releases younger than 7 days, the
same window the lock refresh uses. Under `lockfile-only`, Dependabot updates
only your direct dependencies, so indirect ones go stale
(dependabot-core#14073). See Keep indirect dependencies fresh.

### Keep indirect dependencies fresh

Stale indirect dependencies fail nothing, so they pile up unnoticed. In October
2026, covjson-msgspec's lock was behind on 31 indirect dependencies, some
pinned since May or June (pydantic 2.13.4 with 2.14.1 out, and starlette 1.3.1
with 1.8.0 out).

Only the top end of the range suffers. The floor job resolves indirect
dependencies fresh on every run, because uv sets aside a lock recorded in
another resolution mode. The `highest` jobs install from the lock, so they test
old indirect releases that a new install would never get.

The floor job's fresh resolve covers only the Python floor. A release that
requires a newer Python never reaches the floor job, so no CI job sees it until
the lock moves. pint 0.26.2 requires Python 3.12 or later and breaks ucumvert,
so on those Pythons, installing titiler-covjson with pip pulled in pint 0.26.2,
and `import titiler_covjson` failed. titiler-covjson's floor job, on Python
3.11, resolved pint 0.25.3, and its `highest` jobs installed 0.25.3 from the
lock. CI stayed green until a lock refresh moved pint to 0.26.2, and then only
the 3.12 and 3.13 `highest` jobs failed.

The fix is a lock refresh, in its own pull request and never mixed into a floor
change (trap 4):

```sh
uv lock --upgrade --no-build
```

- `--upgrade` moves every locked version to the newest allowed. It never
  changes the floors in `pyproject.toml`.
- `--no-build` stops uv from building a package to read its metadata, which
  would run that package's build code. It works only if every locked package
  ships a wheel.

Set a cooldown in `pyproject.toml`, not on the command line:

```toml
[tool.uv]
exclude-newer = "7 days"
```

uv records this setting in `uv.lock`. Passed only as an `--exclude-newer` flag,
it is recorded all the same, and every later `uv lock --check` or
`uv sync --locked` without the flag fails. In `pyproject.toml`, it gives every
resolution in the project, the floor job's included, the same 7-day window as
Dependabot's cooldown, so a malicious or broken release has a week to be
caught. To adopt one newer release on purpose, override the window for that
package in the same table, e.g.,
`exclude-newer-package = { pkg = "2026-10-15T00:00:00Z" }`. A command-line
override breaks the lock check the same way.

### Choose how the refresh runs

Schedule the refresh, because one that waits on someone remembering slips
silently. Two workflows can run it, and one repository setting picks between
them: "Allow GitHub Actions to create and approve pull requests" (Settings,
then Actions, then General). Read it instead of asking:

```sh
gh api repos/<owner>/<repo>/actions/permissions/workflow \
  --jq .can_approve_pull_request_reviews
```

- `true`: use the pull request workflow.
- `false`, or the call fails: ask the developer whether to turn the setting on.
  Say that the same checkbox lets every workflow in the repository approve pull
  requests, because that is the part some maintainers refuse. An organization
  can also turn it off for all its repositories. If it stays off, use the
  reminder issue workflow.

The pull request workflow is the default, because it fixes how the refresh
runs (the latest uv, always with `--no-build`), and the maintainer only
reopens, reviews, and merges. The reminder issue workflow leaves the refresh to
a person's machine and memory.

**The pull request workflow.** It runs monthly and opens a pull request when
the lock changes. Only the lock job runs uv, and it holds only read access (the
comment on that job says why). Without the setting,
`gh pr create` fails after the branch is already pushed, leaving a stray
branch:

```yaml
name: Refresh uv.lock

on:
  schedule:
    - cron: "0 6 1 * *" # monthly
  workflow_dispatch:

permissions: {}

jobs:
  # This job runs `uv lock --upgrade`, which picks the newest allowed version of
  # every dependency and writes uv.lock. --no-build keeps uv from running any
  # package's build code, and as a second guard this job holds only read
  # access. The job that holds write access never runs uv, and only commits the
  # uv.lock this job uploads. Jobs run on separate runners, so nothing that runs
  # here can reach the write token. Steps within one job share a runner, so code
  # from an earlier step could reach a token scoped to a later one.
  lock:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@<sha>
        with:
          persist-credentials: false
      - uses: astral-sh/setup-uv@<sha>
      # The 7-day cooldown comes from [tool.uv] exclude-newer in pyproject.toml.
      - run: uv lock --upgrade --no-build
      - uses: actions/upload-artifact@<sha>
        with:
          name: uv-lock
          path: uv.lock

  pull-request:
    needs: lock
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@<sha>
        with:
          persist-credentials: false
      - uses: actions/download-artifact@<sha>
        with:
          name: uv-lock
      - name: Open a pull request if the lock changed
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          git diff --quiet -- uv.lock && exit 0
          gh auth setup-git
          branch="lock-refresh/$(date -u +%Y-%m-%d)"
          git switch -c "$branch"
          git -c user.name="github-actions[bot]" \
            -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
            commit -m "Refresh uv.lock" -- uv.lock
          git push origin "$branch"
          gh pr create --head "$branch" --title "Refresh uv.lock" \
            --body "Monthly uv lock --upgrade. Close and reopen this pull request to run CI."
```

**Starting CI on the refresh pull request.** GitHub does not start workflow
runs from events made with a run's own `GITHUB_TOKEN`, to prevent loops. So the
pull request opens with no checks, and a ruleset that requires them blocks the
merge. That fails safe. Close and reopen the pull request (or open it as a
draft and mark it ready for review), and your action starts CI. This adds no
credential, and the open pull request is its own reminder.

To have CI start by itself, open the pull request with a GitHub App token,
created per run with a one-hour lifetime. That needs the App's private key as a
secret, and anyone who holds the key can push branches and open pull requests.
Keep `--no-build` and the read-only lock job, so the key never reaches a job
that runs uv. A personal access token also works, but it acts as
you and expires.

**The reminder issue workflow.** It opens an issue that asks a maintainer to
run the refresh, as titiler-covjson does. It needs only `issues: write`, and CI
starts normally, because a person opens the pull request. The refresh then
runs with that person's uv, which is how titiler-covjson's lock lost its format
revision, so set `required-version` too (trap 4):

````yaml
name: Lock refresh reminder

on:
  schedule:
    - cron: "0 6 1 * *" # monthly
  workflow_dispatch:

permissions: {}

jobs:
  remind:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      issues: write
    steps:
      - uses: actions/checkout@<sha>
        with:
          persist-credentials: false
      - uses: astral-sh/setup-uv@<sha>
      # Skip while a reminder is open, so reminders do not stack up.
      - id: open
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          n=$(gh issue list --state open --search '"Refresh uv.lock" in:title' \
            --json number --jq length)
          echo "count=$n" >> "$GITHUB_OUTPUT"
      # Preview the refresh in the issue. A failed resolve still opens the
      # issue, with the error. This step does not receive the token, and
      # --no-build keeps package build code from running in a job that can
      # write issues.
      - if: steps.open.outputs.count == '0'
        run: |
          {
            cat .github/lock-refresh-issue-body.md
            echo
            echo '## Preview'
            echo '```text'
            uv lock --upgrade --dry-run --no-build 2>&1 || true
            echo '```'
          } > body.md
      - if: steps.open.outputs.count == '0'
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh issue create --title "Refresh uv.lock" --body-file body.md
````

The body file holds the steps: on a branch, run `uv lock --upgrade --no-build`,
`uv sync --locked`, and `uv run pytest`, then open a pull request whose body
includes `Closes #<issue>`. Merging it closes the reminder, so the next
scheduled run opens a new one. Keep the body file to one line per paragraph,
because GitHub renders issue bodies with hard line breaks.

### When the refresh finds a broken release

When a refresh fails CI because a new release of an indirect dependency breaks
your library, new installs of your library already get that release. Bound it
in `[project].dependencies`, even though you do not import it:

```toml
dependencies = [
    "ucumvert>=0.3.0",
    # pint 0.26.2 breaks ucumvert, whose pint requirement has no upper bound
    # (https://github.com/dalito/ucumvert/issues/82). Not imported here. Drop
    # this once a ucumvert release supports pint 0.26.2.
    "pint<0.26.2",
]
```

Do not use `[tool.uv] constraint-dependencies`. That setting applies only when
uv resolves your project, so it fixes `uv.lock` and CI while pip still installs
the broken release for users. `[project].dependencies` becomes your package's
metadata, which every installer reads.

The bound also changes what the floor job tests, because the dependency is now
direct, and `lowest-direct` installs the oldest release that every requirement
allows. With the bound, titiler-covjson's floor resolve installs pint 0.25, the
floor that ucumvert 0.3.0 declares, instead of 0.25.3. uv also warns "The
direct dependency `pint` is unpinned", which `uv sync --quiet` hides. Leave the
floor off anyway, because the job then tests the oldest pint that ucumvert
accepts, which users can install too, and a copied floor goes stale when
ucumvert raises its own.

### Record it in an ADR

The policy is a cross-cutting decision whose rationale a reader cannot recover
from the code, so it warrants an ADR. Record:

- the floor-selection principle (lowest version with the used APIs + a wheel on
  the Python floor)
- test-both-ends (`highest` full matrix + `lowest-direct` on the floor Python,
  both blocking)
- the Dependabot `lockfile-only` stance, and how indirect dependencies stay
  fresh (the scheduled lock refresh, and which workflow runs it)
- the cooldown (`[tool.uv] exclude-newer`), which applies to every resolution
- what the floor job guarantees: tests run at the installed floors, and the job
  logs the versions it tested
- any declared floor the job cannot test (because of a pin), marked untested
- the dev floors, which must work too, because the job installs them
- **the named accepted cost:** `lowest-direct` holds direct dependencies low
  while resolving indirect ones to their newest releases, so a newly published
  indirect release can occasionally clash with an old direct floor and fail the
  blocking job through no change of yours. The resolution is deliberate: raise
  that floor, or make the code work at it. This is a feature (the job surfaced a
  real incompatibility), priced as an occasional maintenance nudge.

## Sources

Prior art (the only skill-form equivalent, wrong ecosystem):

- `cargo-minimal-versions`: "test Rust crates with minimum dependency versions"
  (javimosch/supercli, via skillsmp.com). It validates the practice. No
  published Python equivalent exists (checked anthropics/skills,
  claudeskills.info, skillsmp.com, mhattingpete/claude-skills-marketplace,
  awesomeclaude.ai).

uv / Dependabot:

- uv resolution docs: <https://docs.astral.sh/uv/reference/settings/#resolution>
- uv `UV_RESOLUTION` environment variable: <https://docs.astral.sh/uv/reference/environment/#uv_resolution>
- Astral Dependabot guide: <https://docs.astral.sh/uv/guides/integration/dependabot/>
- dependabot-core#12162 (uv `lockfile-only` support), #14073 (stale indirect
  dependencies)
- uv `exclude-newer` setting: <https://docs.astral.sh/uv/reference/settings/#exclude-newer>
- GitHub, why `GITHUB_TOKEN` events do not start workflows: <https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#triggering-a-workflow-from-a-workflow>
- peter-evans/create-pull-request, the workarounds for running CI on a bot's pull request: <https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#triggering-further-workflow-runs>

The Python practice (established but scattered, and this skill distills it):

- pytest-dev/pytest#13317: specify minimum requirements for dependencies
- pypa/build#267 (Henry Schreiner): require minimum versions of dependencies
- pypa/pip#12344, #10741: install the oldest available versions
- astral-sh/uv#5492: resolve lowest versions of specific packages only
- python-poetry/poetry#3527: lock with lowest solvable versions
- shap/shap#3854: in CI, test against lowest supported versions of key deps
- psf/black#2795: run tests with minimum versions installed
- jupyterlab/jupyterlab#16105: `dependency_type: minimum` for the min-versions
  check
