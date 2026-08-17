# Security Scanning Workflows

Three pieces, independently useful; generate the subset the user wants:

| File | What it does | Constraint |
|---|---|---|
| `.github/workflows/codeql.yml` | Static analysis for vulnerabilities in project code (often better as Settings-based "default setup" -- see below) | Free on public repos; needs GitHub Advanced Security on private |
| `.github/workflows/dependency-review.yml` | Blocks PRs that introduce dependencies with known vulnerabilities | Same constraint as CodeQL |
| `.github/dependabot.yml` | Automated PRs for outdated/vulnerable dependencies and action pins | Works everywhere |

Check repo visibility first (`gh repo view --json visibility`) and skip or
flag the Advanced-Security-gated workflows on private repos instead of
shipping workflows that will fail on first run.

## CodeQL

CodeQL has two setup modes; **prefer default setup for most projects** and skip
the workflow below entirely:

- **Default setup** -- enabled in *Settings -> Code security -> Code scanning ->
  CodeQL -> Set up -> Default*. GitHub auto-detects languages, picks the query
  suite, and runs on push/PR plus a schedule, with **no workflow file to
  maintain** (no `codeql-action` SHA to pin, no Dependabot bumps).
- **Advanced setup** -- the `codeql.yml` workflow below; full control of
  languages, query suites, triggers, and build steps.

The two are **mutually exclusive** -- if default setup is on, do not also ship
`codeql.yml` (they conflict). For an interpreted project (Python, JS/TS, Ruby,
Go) using the default query suite, default setup is *equivalent* scanning with
zero maintenance -- recommend it and do not generate the workflow. Reach for
the advanced workflow only when the project needs a custom query suite
(`queries: security-extended`), custom build steps for a compiled language
(C/C++, Java, Swift) that default setup cannot auto-build, non-standard
triggers, or wants its scanning config version-controlled in the repo.

Billing is identical between the modes (both run CodeQL as Actions jobs):
**free on public repos** (Actions minutes are unlimited there; code scanning
needs no GitHub Advanced Security); on private repos both consume metered
Actions minutes and require GHAS. The cost is not a reason to pick one mode
over the other.

If default setup's language picker auto-includes `actions`, deselect it when
the project already lints workflows with zizmor in CI (see `references/ci.md`),
keeping the same no-redundant-scanning stance the workflow comment below notes.

Advanced-setup workflow (only when you need the customization above):

```yaml
# CodeQL static analysis: scans the project's code for security
# vulnerabilities, on code changes and on a recurring schedule. (Workflow files
# are covered by zizmor in the CI `checks` job, so the CodeQL `actions`
# language is intentionally omitted to avoid redundant scanning.)
name: CodeQL

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: "23 5 * * 1" # pick an arbitrary minute to avoid load spikes

permissions:
  contents: read

jobs:
  analyze:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    permissions:
      contents: read
      security-events: write
    strategy:
      fail-fast: false
      matrix:
        language: [python]
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Initialize CodeQL (${{ matrix.language }})
        uses: github/codeql-action/init@{SHA} # {TAG}
        with:
          languages: ${{ matrix.language }}
      - name: Analyze (${{ matrix.language }})
        uses: github/codeql-action/analyze@{SHA} # {TAG}
        with:
          category: "/language:${{ matrix.language }}"
```

The `schedule` trigger matters: it catches newly published CVE patterns in
code that has not changed, which push/PR triggers never re-scan.

Workflow files are deliberately not scanned here. CodeQL's `actions` language
detects workflow misconfigurations (expression injection into `run:` blocks,
excessive permissions, unpinned actions) -- but `zizmor` already covers exactly
those, and the recommended setup runs zizmor in CI via the pre-commit `checks`
job (see `references/ci.md` and `references/pre-commit.md`). Adding `actions`
here too would be redundant, so the matrix is `[python]` only. Add `actions`
back **only** for a project that does not lint its workflows with zizmor in CI
-- then CodeQL's actions queries become the workflow safety net instead. (The
per-language `category` keeps analyses separate in the code-scanning UI when
more than one language is present.)

## Dependency review

```yaml
# Reviews dependency manifest changes in a pull request and blocks it when the
# change would add a dependency whose known vulnerabilities meet the configured
# severity threshold, before merge. Complements Dependabot (which patches
# existing dependencies) by guarding the inbound diff.
name: Dependency review

on: [pull_request]

permissions:
  contents: read

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Review dependency changes
        uses: actions/dependency-review-action@{SHA} # {TAG}
        with:
          fail-on-severity: high
```

`fail-on-severity: high` is a pragmatic default -- blocking on `low` teaches
teams to ignore the check. Mention that the user can tighten it.

## Dependabot

`.github/dependabot.yml` (configuration file, not a workflow):

```yaml
# Dependabot: opens grouped PRs to update GitHub Actions pins and dependencies
# on a schedule. A cooldown holds back brand-new releases (see note below).
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    # Wait this many days after a release before opening an update PR, so a
    # freshly published (possibly compromised or soon-yanked) version is not
    # adopted immediately. Only `default-days` applies to github-actions.
    cooldown:
      default-days: 7
    groups:
      actions:
        patterns: ["*"]

  - package-ecosystem: uv
    directory: /
    schedule:
      interval: weekly
    cooldown:
      default-days: 7
    groups:
      dev-dependencies:
        dependency-type: development
```

- The `github-actions` ecosystem understands SHA pins with tag comments
  (`@abc123 # v4.2.2`) and keeps both current -- this is what makes SHA
  pinning maintainable rather than a one-time gesture.
- The `uv` ecosystem updates `uv.lock` and `pyproject.toml`. If the project
  uses `requirements.txt` instead, use `pip` as the ecosystem.
- Grouping reduces PR noise; one grouped PR per week is reviewable, fifteen
  individual ones get rubber-stamped.
- `cooldown` delays update PRs until a release is `default-days` old, blunting
  the "auto-adopt a brand-new malicious or soon-yanked release" supply-chain
  risk. Only `default-days` is honored for the `github-actions`, `uv`, and
  `pip` ecosystems -- the finer `semver-major-days` / `semver-minor-days` /
  `semver-patch-days` keys are supported only by a specific set of ecosystems
  (Bundler, Cargo, npm/Yarn, Maven, NuGet, etc.), so do not add them for the
  ecosystems in this template; they would be silently ignored. 7 days is a
  sane default; tell the user it is tunable.
