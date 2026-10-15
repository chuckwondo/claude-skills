# uv-minimum-versions -- reference

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
  dependencies fresh, and recording an architecture decision record (ADR)
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
  and emits them as JSON keeps the matrix from drifting from declared support;
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
|---|---|---|---|
| shapely | 2.0.0 | cp37-cp311 | >=3.7 |
| numpy | 1.24.0 | cp38-cp311 | >=3.8 |
| pandas | 2.0.0 | cp38-cp311 | >=3.8 |
| cftime | 1.6.2 | cp37-cp311 | >=3.7 |
| msgspec | 0.18.0 | cp38-cp311 | >=3.8 |

So on Python 3.12-3.14, `lowest-direct` pins these same 3.11-era versions (their
metadata permits it) and there is no wheel. **Fix: run `lowest-direct` on the
floor Python only; `highest` covers the newer Pythons against modern (wheeled)
deps -- the pairing users actually run.**

### 2. A sibling or a dependency group can pin a dependency higher

Under an all-extras `lowest-direct` resolve, a dependency can be forced above its
own declared floor by a *sibling* dependency's requirement. Probe it: declare the
floor lower, delete the lock, and see whether the version actually moves.

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
floors are genuinely lowerable and should drop; others are best kept and simply
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
lower bounds on each upstream release -- narrowing user compatibility for a
version you use nothing from. Set it to refresh the lockfile only:

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

The fix is a lock refresh, in its own pull request and never mixed into a floor
change (trap 4):

```sh
uv lock --upgrade --no-build
```

- `--upgrade` moves every locked version to the newest allowed. It never
  changes the floors in `pyproject.toml`.
- `--no-build` stops uv from running any package's build code while resolving.
  It works only if every locked package ships a wheel.

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

Run it from a scheduled workflow rather than by hand, because a manual
reminder slips silently. This workflow runs monthly and opens a pull request
when the lock changes. The lock job holds only read access, so code that runs
during resolving never sees a token that can write. Before the first run, turn
on the repository setting "Allow GitHub Actions to create and approve pull
requests" (Settings, then Actions, then General). Without it, `gh pr create`
fails after the branch is already pushed, leaving a stray branch:

```yaml
name: Refresh uv.lock

on:
  schedule:
    - cron: "0 6 1 * *" # monthly
  workflow_dispatch:

permissions: {}

jobs:
  lock:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@<sha>
        with:
          persist-credentials: false
      - uses: astral-sh/setup-uv@<sha>
      # --no-build: never run a package's build code while resolving. The
      # 7-day cooldown comes from [tool.uv] exclude-newer in pyproject.toml.
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

**Getting CI to run on the refresh pull request.** GitHub does not start
workflow runs from events made with a run's own `GITHUB_TOKEN`, to prevent
loops. So the
pull request opens with no checks, and a ruleset that requires them blocks the
merge. That fails safe, but someone has to start CI. In order of preference:

1. **Close and reopen the pull request** (or open it as a draft and mark it
   ready for review). Your action triggers CI. This adds no credential, and the
   open pull request is its own reminder.
2. **Start CI from the refresh workflow** with `gh workflow run`, which
   `GITHUB_TOKEN` is allowed to trigger. This needs `workflow_dispatch` in the
   CI workflow and `actions: write` on the job. Untested: confirm once that
   your ruleset counts checks from a dispatched run before relying on it.
3. **A GitHub App token**, created per run with a one-hour lifetime. This needs
   the App's private key as a secret, and anyone who holds the key can push
   branches and open pull requests. Keep `--no-build` and the read-only lock
   job, so the key never reaches code that runs during resolving.

A personal access token also works, but it acts as you and expires. A deploy
key triggers only `push` workflows.

### Record it in an ADR

The policy is a cross-cutting decision whose rationale a reader cannot recover
from the code, so it warrants an ADR. Record:

- the floor-selection principle (lowest version with the used APIs + a wheel on
  the Python floor);
- test-both-ends (`highest` full matrix + `lowest-direct` on the floor Python,
  both blocking);
- the Dependabot `lockfile-only` stance, and how indirect dependencies stay
  fresh (the scheduled lock refresh);
- the cooldown (`[tool.uv] exclude-newer`), which applies to every resolution;
- what the floor job guarantees: tests run at the installed floors, and the job
  logs the versions it tested;
- any declared floor the job cannot test (because of a pin), marked untested;
- the dev floors, which must work too, because the job installs them;
- **the named accepted cost:** `lowest-direct` holds direct dependencies low
  while resolving indirect ones to their newest releases, so a newly published
  indirect release can occasionally clash with an old direct floor and fail the
  blocking job through no change of yours. The resolution is deliberate: raise
  that floor, or make the code work at it. This is a feature (the job surfaced a
  real incompatibility), priced as an occasional maintenance nudge.

## Sources

Prior art (the only skill-form equivalent, wrong ecosystem):

- `cargo-minimal-versions` -- "test Rust crates with minimum dependency
  versions" (javimosch/supercli, via skillsmp.com). Validates the practice;
  there is no published Python equivalent (checked anthropics/skills,
  claudeskills.info, skillsmp.com, mhattingpete/claude-skills-marketplace,
  awesomeclaude.ai).

uv / Dependabot:

- uv resolution docs: https://docs.astral.sh/uv/reference/settings/#resolution
- uv `UV_RESOLUTION` environment variable: https://docs.astral.sh/uv/reference/environment/#uv_resolution
- Astral Dependabot guide: https://docs.astral.sh/uv/guides/integration/dependabot/
- dependabot-core#12162 (uv `lockfile-only` support), #14073 (stale indirect dependencies)
- uv `exclude-newer` setting: https://docs.astral.sh/uv/reference/settings/#exclude-newer
- GitHub, why `GITHUB_TOKEN` events start no workflows: https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#triggering-a-workflow-from-a-workflow
- peter-evans/create-pull-request, the workarounds for running CI on a bot's pull request: https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#triggering-further-workflow-runs

The Python practice (established but scattered -- this skill distills it):

- pytest-dev/pytest#13317 -- specify minimum requirements for dependencies
- pypa/build#267 (Henry Schreiner) -- require minimum versions of dependencies
- pypa/pip#12344, #10741 -- install the oldest available versions
- astral-sh/uv#5492 -- resolve lowest versions of specific packages only
- python-poetry/poetry#3527 -- lock with lowest solvable versions
- shap/shap#3854 -- CI: test against lowest supported versions of key deps
- psf/black#2795 -- run tests with minimum versions installed
- jupyterlab/jupyterlab#16105 -- `dependency_type: minimum` for the min-versions check
