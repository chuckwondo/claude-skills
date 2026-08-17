# CI Workflow (Python + uv)

Target file: `.github/workflows/ci.yml`

Adapt the template below to the repository. The job split is deliberate: a
tiny `config` job derives the Python matrix once and exposes it as an output
(single source of truth -- see the Matrix rule below); a `checks` job runs the
whole pre-commit suite once via `prek` -- so the fast, version-independent
checks (ruff, formatting, actionlint, zizmor, gitleaks, lockfile sync, file
hygiene) are defined once in `.pre-commit-config.yaml` and *enforced* in CI
rather than restated as workflow steps (see `references/pre-commit.md`); and
`typecheck` (mypy) and `test` (pytest) each fan out across that shared matrix.

The principle: define each check once, where its nature fits. Fast,
deterministic, version-independent checks live in pre-commit (instant local
feedback + autofix) and are enforced in CI by running that same config -- the
local/CI overlap is defense-in-depth, not duplicated *definitions*.
Version-dependent checks (mypy, pytest) are matrixed in CI; they are
deliberately not pre-commit hooks (see the Matrix note and
`references/pre-commit.md`).

Type-checking is matrixed -- not run once -- because a project's *types* can
depend on the Python version. A dependency whose version is gated by
`python_full_version` in `uv.lock` (e.g., `numpy` ships 2.2.x for Python 3.10
but 2.4.x for >=3.11) installs different type stubs per interpreter, so mypy
can pass under one Python and fail under another. `[tool.mypy] python_version`
sets analysis *semantics*, not which stubs are installed, so it does not cover
this. Running mypy once under whichever Python CI happens to pick silently
skips the others. If the project pins a single dependency set across all
Pythons (no `python_full_version` markers in the lock), you may collapse
`typecheck` to a single job -- but matrixing is the safe default and mypy is
cheap.

## Adaptation rules

- **Matrix, defined once**: the `config` job derives the version list from the
  `Programming Language :: Python :: 3.x` classifiers in `pyproject.toml` and
  emits it as JSON; `typecheck` and `test` consume it with
  `${{ fromJSON(needs.config.outputs.python-versions) }}`. This keeps the
  matrix from drifting from the project's declared support -- update the
  classifiers and CI follows. GitHub Actions has no YAML anchors and forbids
  `env`/vars inside `matrix:`, so a job output is the canonical way to share
  one matrix across jobs. If the project declares no per-version classifiers,
  fall back to a literal list derived from `requires-python`, quoted (`"3.10"`,
  not `3.10` -- YAML floats truncate trailing zeros), in each job.
- **Fast checks via pre-commit, not standalone steps**: ruff, formatting,
  actionlint, zizmor, gitleaks, lockfile sync, and file hygiene live in
  `.pre-commit-config.yaml`; the `checks` job runs them with
  `prek run --all-files`. Do not also add them as separate CI steps -- that
  re-states the list in two places. A modify-on-fix hook (ruff `--fix`, the
  formatter) exits non-zero when it changes a file, so the `checks` job fails
  CI on unformatted/unlinted code with no extra `--check` step. mypy and
  pytest are NOT pre-commit hooks (version-dependent) -- they get the matrixed
  `typecheck`/`test` jobs.
- **Locked sync**: use `--locked` only when `uv.lock` is committed.
- **Coverage**: if the project configures pytest-cov, keep its flags; do not
  add coverage reporting the project has not asked for.

## Template

```yaml
# Continuous integration: lint once, then type-check and run the test suite
# across the supported Python versions, on each code change.
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # Single source of truth for the Python matrix: derive it from the
  # `Programming Language :: Python :: 3.x` classifiers in pyproject.toml so the
  # typecheck and test jobs cannot drift from the project's declared support.
  config:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    outputs:
      python-versions: ${{ steps.derive.outputs.python-versions }}
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Derive Python versions from pyproject classifiers
        id: derive
        shell: python
        run: |
          import json
          import os
          import pathlib
          import re
          import tomllib

          pyproject = tomllib.loads(pathlib.Path("pyproject.toml").read_text())
          classifier_prefix = "Programming Language :: Python :: "
          python_versions = [
              classifier.removeprefix(classifier_prefix)
              for classifier in pyproject["project"]["classifiers"]
              if classifier.startswith(classifier_prefix)
              and re.fullmatch(r"3\.\d+", classifier.removeprefix(classifier_prefix))
          ]
          with open(os.environ["GITHUB_OUTPUT"], "a") as github_output:
              github_output.write(f"python-versions={json.dumps(python_versions)}\n")

  # Runs the full pre-commit suite (ruff, formatting, actionlint, zizmor,
  # gitleaks, lockfile sync, file hygiene) so CI enforces the same checks
  # developers run locally -- defined once in .pre-commit-config.yaml, not
  # restated here. Backstops commits made with --no-verify or without hooks.
  checks:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Set up uv
        uses: astral-sh/setup-uv@{SHA} # {TAG}
        with:
          enable-cache: true
      - name: Install dependencies
        run: uv sync --locked --quiet
      - name: Run pre-commit hooks (prek)
        run: uv run --quiet prek run --all-files --show-diff-on-failure

  typecheck:
    needs: config
    runs-on: ubuntu-latest
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        python-version: ${{ fromJSON(needs.config.outputs.python-versions) }}
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Set up uv and Python ${{ matrix.python-version }}
        uses: astral-sh/setup-uv@{SHA} # {TAG}
        with:
          python-version: ${{ matrix.python-version }}
          enable-cache: true
      - name: Install dependencies
        run: uv sync --locked --quiet
      - name: Type-check (mypy)
        run: uv run --quiet mypy

  test:
    needs: config
    runs-on: ubuntu-latest
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        python-version: ${{ fromJSON(needs.config.outputs.python-versions) }}
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Set up uv and Python ${{ matrix.python-version }}
        uses: astral-sh/setup-uv@{SHA} # {TAG}
        with:
          python-version: ${{ matrix.python-version }}
          enable-cache: true
      - name: Install dependencies
        run: uv sync --locked --quiet
      - name: Run tests (pytest)
        run: uv run --quiet pytest
```

## Notes

- `astral-sh/setup-uv` installs uv and (with `python-version`) the requested
  CPython, and `enable-cache: true` caches the uv cache directory keyed on
  the lockfile -- no separate `actions/setup-python` or `actions/cache`
  steps are needed.
- `fail-fast: false` keeps the other matrix legs running when one Python
  version fails, which is the information the user actually wants from a
  matrix.
- The matrixed `typecheck` job catches version-specific mypy failures that a
  single run hides -- e.g., `unused "type: ignore"` (`unused-ignore`) or
  `Need type annotation` (`var-annotated`) errors that appear only under the
  numpy version a newer Python resolves. Fix these in the code so it is clean
  under every supported version (mypy's `# type: ignore[code, unused-ignore]`
  idiom covers ignores needed in only some versions); do not pin CI to the one
  Python where it happens to pass.
- The `config` job uses `shell: python` so the derivation is a plain script
  (no heredoc), reading `pyproject.toml` with `tomllib` (stdlib on the
  runner's preinstalled Python 3.11+) and appending to `$GITHUB_OUTPUT`. It
  needs no uv, no setup-python, and no third-party deps. Its cost is one extra
  job and a `needs:` edge that delays `typecheck`/`test` by that job's
  start-up; worth it once a matrix is shared by 2+ jobs, skippable for a
  single matrixed job (inline the literal list there instead).
- If the project has OS-specific behavior (file paths, rasterio/GDAL wheels,
  etc.), offer an OS matrix (`ubuntu-latest`, `macos-latest`,
  `windows-latest`) but do not add it by default -- it triples CI cost.

## Coverage (optional, no API key)

`pytest-cov` (coverage.py) reports coverage with no external service or token.
Only add this if the project wants it. Run it in a dedicated single-version
job rather than the `test` matrix, so you get one canonical number with no
matrix-gating; pin it to the minimum supported version via
`fromJSON(needs.config.outputs.python-versions)[0]`. Configure the source once
in `pyproject.toml` (so `pytest --cov` works the same locally and in CI):

```toml
[tool.coverage.run]
source = ["src/<package>"]
branch = true
```

The baseline job -- text report in the log plus a markdown table on the run's
summary page, both keyless:

```yaml
  coverage:
    needs: config
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Set up uv and Python ${{ fromJSON(needs.config.outputs.python-versions)[0] }}
        uses: astral-sh/setup-uv@{SHA} # {TAG}
        with:
          python-version: ${{ fromJSON(needs.config.outputs.python-versions)[0] }}
          enable-cache: true
      - name: Install dependencies
        run: uv sync --locked --quiet
      - name: Run tests with coverage
        run: uv run --quiet pytest --cov --cov-report=term-missing
      - name: Write coverage summary to the job summary
        run: uv run --quiet coverage report --format=markdown --show-missing >> "$GITHUB_STEP_SUMMARY"
```

Other keyless publish targets, in increasing persistence -- add on request:

- **HTML artifact** -- add `--cov-report=html` and upload `htmlcov/` with
  `actions/upload-artifact`; browsable, downloadable per run.
- **PR comment + README badge** -- `py-cov-action/python-coverage-comment-action`
  posts a coverage comment on PRs and stores a shields.io badge + HTML in a
  data branch, using only the built-in `GITHUB_TOKEN` (no external key). Needs
  `contents: write` + `pull-requests: write`; this is the no-key way to get a
  persistent README badge.
- **GitHub Pages** -- deploy `htmlcov/` to Pages for a persistent public URL
  (GITHUB_TOKEN + Pages enabled; one deploy job).

Codecov and Coveralls are deliberately omitted -- they want a token, which
this skill avoids by default.
