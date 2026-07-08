# uv-minimum-versions -- reference

Depth behind `SKILL.md`: the exact CI recipe, each trap with the evidence that
proves it, the one-off probes for wheels and API-introduction versions, the
lockfile discipline, the policy/ADR layer, and sources. The worked example is
`case-study.md`.

## The CI recipe

Add a `resolution` axis to the existing test job. `highest` stays across the
full Python matrix; add **one** `lowest-direct` leg on the Python floor via a
matrix `include`.

```yaml
  test:
    needs: config          # a job that derives the Python matrix (see below)
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python-version: ${{ fromJSON(needs.config.outputs.python-versions) }}
        resolution: [highest]
        # lowest-direct is coherent only on the Python floor (trap 1): the
        # declared floors are a floor-era snapshot whose wheels stop at the
        # floor Python's cp tag. Add a single leg pinned to python-versions[0].
        include:
          - python-version: ${{ fromJSON(needs.config.outputs.python-versions)[0] }}
            resolution: lowest-direct
    steps:
      - uses: actions/checkout@<sha>
      - uses: astral-sh/setup-uv@<sha>
        with:
          python-version: ${{ matrix.python-version }}
          enable-cache: true
          # Namespace the cache per resolution so the highest and lowest-direct
          # legs (same Python, different resolved deps) don't race to save one key.
          cache-suffix: ${{ matrix.resolution }}
      # --resolution lowest-direct re-resolves and CANNOT combine with --locked
      # (uv ignores the lockfile when the resolution mode changes), so the two
      # ends need distinct install commands.
      - name: Install (highest, from lockfile)
        if: matrix.resolution == 'highest'
        run: uv sync --locked
      - name: Install (lowest-direct floors)
        if: matrix.resolution == 'lowest-direct'
        run: uv sync --resolution lowest-direct
      - run: uv run pytest
```

Notes:

- **All extras synced.** Sync whatever installs every runtime extra (a dev group
  that pulls `[all]` + any framework extras), so every runtime floor is
  exercised, not just the core.
- **Both ends blocking.** The `lowest-direct` leg is the point; do not make it
  `continue-on-error`.
- **The matrix `include` idiom.** With `resolution: [highest]` as the only axis
  value, an `include` whose `resolution: lowest-direct` conflicts with every
  base combination cannot merge into any of them, so GitHub creates one new
  combination: `{floor-Python, lowest-direct}`. Result: full `highest` matrix +
  one `lowest-direct` leg.
- **Derive the Python matrix from one source.** A small `config` job that reads
  the `Programming Language :: Python :: 3.x` classifiers from `pyproject.toml`
  and emits them as JSON keeps the matrix from drifting from declared support;
  `python-versions[0]` is then the floor.

### Gate it without per-leg churn

Branch protection / rulesets should require **one stable aggregator check**, not
the per-leg names (which change as the matrix changes):

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

A matrix job is a *single* node in `needs:` that succeeds only if all its legs
succeed, so `required-checks` gates the `lowest-direct` leg transitively. Point
the ruleset's `required_status_checks` at `Required checks` and never touch it
again when legs are added or Pythons bumped.

## The traps, with evidence

### 1. Wheels =/= requires-python

Resolvers (uv, pip) choose a version by its `requires-python` metadata, then
install a wheel *if one exists for the target*, else build from sdist. Old
releases of compiled packages declare an open-ended `requires-python` but only
shipped wheels for the Pythons that existed at release. So `lowest-direct` on a
newer interpreter pins the ancient floor version -- which has no wheel there --
and the source build fails.

The failure we hit, verbatim:

```
ModuleNotFoundError: No module named 'pkg_resources'
hint: `shapely` (v2.0.0) was included because `covjson-msgspec[all]` depends on `shapely`
```

Evidence -- floor releases ship wheels only through cp311, yet all declare an
open-ended `requires-python`:

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

### 2. Siblings pin a dep up

Under an all-extras `lowest-direct` resolve, a dependency can be forced above its
own declared floor by a *sibling* dependency's requirement. Probe it: declare the
floor lower and see whether it actually moves.

- Declared `numpy>=1.23`, still resolved `numpy==1.24.0` -> xarray requires
  `>=1.24`. Declared `pandas>=1.5`, still resolved `pandas==2.1.0` -> pinned up
  by xarray.
- Consequence: lowering numpy's / pandas's *declaration* below the sibling
  constraint changes nothing in the all-extras environment and cannot be
  verified there. Keep the floor at the version that resolves, and record *why*
  (a sibling pins it). Chasing a lower number is theater.

### 3. "Arbitrary" is not "must be lowered"

The audit's job is to make each floor *defensible*, not merely *minimal*. Some
floors are genuinely lowerable and should drop; others are best kept and simply
given a reason.

- msgspec: probed 0.16 -- it has all the APIs used (`json.format`,
  `schema_components(ref_template=)`, `structs.replace`) and cp311 wheels. Still
  kept at `>=0.18`: a fast-moving pre-1.0 *core* dependency is best held at a
  recent, deliberate baseline; reach below it is negligible and not worth
  vouching for old behavior. The fix for "arbitrary" here was a recorded
  rationale, not a lower number.

### 4. Lockfile churn

The only intended lock change is the floor specifier(s) you edited. But a bare
`uv sync` / `uv lock` re-resolves and bumps stale *transitive* pins (a lock that
lags the registry can move dozens of packages). Keep the diff clean:

```sh
git checkout <base> -- uv.lock          # discard the churn
# hand-edit only the changed specifier line(s), e.g.:
#   specifier = ">=1.6"  ->  specifier = ">=1.6.2"
uv lock --check                          # verify the lock is still consistent
```

`uv sync --locked` (highest leg) and `uv sync --resolution lowest-direct`
(floor leg) are both safe to run without rewriting the committed lock. Keeping
transitives fresh is then Dependabot's job (see below), not a side effect of
your floor PR.

## Probes (one-off checks while auditing)

**Does version X ship a wheel for cp3YY?** Query the PyPI JSON API:

```sh
curl -s https://pypi.org/pypi/<pkg>/<version>/json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); \
      print(sorted({f['filename'] for f in d['urls'] if 'cp3' in f['filename'] \
                    or f['filename'].endswith('py3-none-any.whl')}))"
```

A `py3-none-any.whl` means pure-Python (installs on any Python -- wheel criterion
trivially satisfied). No `cp3YY` entry for your floor Python means the version
fails criterion (b); raise the floor to the first release that has one.

**Does version X provide the APIs we use?** Import it in an ephemeral env
without touching the project:

```sh
uv run --isolated --no-project --with "<pkg>==X" python -c "import <pkg>; ..."
```

This answers "can the floor go this low on APIs" cheaply, separately from the
wheel question.

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
```

`lockfile-only` refreshes `uv.lock` (and dev/CI deps) but never touches
`[project.dependencies]` / `[project.optional-dependencies]` bounds, so a floor
rises only by a deliberate decision. Supported for the uv ecosystem per
dependabot-core#12162. Caveat: it can leave *transitive* lock entries stale
(dependabot-core#14073); a periodic `uv lock --upgrade` covers it if that
matters.

### Record it in an ADR

The policy is a cross-cutting decision whose rationale a reader cannot recover
from the code, so it warrants an ADR. Record:

- the floor-selection principle (lowest version with the used APIs + a wheel on
  the Python floor);
- test-both-ends (`highest` full matrix + `lowest-direct` on the floor Python,
  both blocking);
- the Dependabot `lockfile-only` stance;
- **the named accepted cost:** `lowest-direct` holds direct deps low while
  resolving transitive deps modern, so a newly published transitive release can
  occasionally clash with an old direct floor and red the blocking leg through
  no change of yours. The resolution is always deliberate: raise that floor.
  This is a feature (the job surfaced a real incompatibility), priced as an
  occasional maintenance nudge.

## Sources

Prior art (the only skill-form equivalent, wrong ecosystem):

- `cargo-minimal-versions` -- "test Rust crates with minimum dependency
  versions" (javimosch/supercli, via skillsmp.com). Validates the practice;
  there is no published Python equivalent (checked anthropics/skills,
  claudeskills.info, skillsmp.com, mhattingpete/claude-skills-marketplace,
  awesomeclaude.ai).

uv / Dependabot:

- uv resolution docs: https://docs.astral.sh/uv/reference/settings/#resolution
- Astral Dependabot guide: https://docs.astral.sh/uv/guides/integration/dependabot/
- dependabot-core#12162 (uv `lockfile-only` support), #14073 (stale transitives caveat)

The Python practice (established but scattered -- this skill distills it):

- pytest-dev/pytest#13317 -- specify minimum requirements for dependencies
- pypa/build#267 (Henry Schreiner) -- require minimum versions of dependencies
- pypa/pip#12344, #10741 -- install the oldest available versions
- astral-sh/uv#5492 -- resolve lowest versions of specific packages only
- python-poetry/poetry#3527 -- lock with lowest solvable versions
- shap/shap#3854 -- CI: test against lowest supported versions of key deps
- psf/black#2795 -- run tests with minimum versions installed
- jupyterlab/jupyterlab#16105 -- `dependency_type: minimum` for the min-versions check
