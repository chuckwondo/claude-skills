---
name: github-workflows
description: Populate a repository with production-quality GitHub Actions workflows for Python projects managed with uv -- CI (test/lint/typecheck), release with PyPI Trusted Publishing, security scanning (CodeQL, dependency review, Dependabot), and repo hygiene. Every generated workflow applies security safeguards (actions pinned to commit SHAs, least-privilege permissions, OIDC instead of long-lived secrets, injection-safe shell steps). Use this whenever the user asks to add or set up GitHub Actions, CI/CD, workflows, automated testing or release pipelines, Dependabot, CodeQL, or says things like "add CI", "set up releases", or "automate publishing" -- even if they do not mention security or best practices.
---

# GitHub Workflows for Python/uv Projects

Generate GitHub Actions workflows that a security-conscious reviewer would
approve without changes. The templates in `references/` encode the structure;
your job is to adapt them to the repository at hand, resolve action versions
to commit SHAs, validate the result, and tell the user what repository
settings the workflows assume.

## Process

1. **Inspect the repository** before writing anything.
2. **Select workflows** from the user's request (ask if ambiguous).
3. **Read the matching reference file(s)** -- only the ones you need.
4. **Resolve action SHAs** (see below) and write the workflow files.
5. **Validate** with actionlint and zizmor when available.
6. **Report required repository settings** the user must configure manually.

## Step 1: Inspect the repository

Read these before generating anything, because the templates must be adapted,
not copied verbatim:

- `pyproject.toml` -- `requires-python` determines the test matrix; the
  `[dependency-groups]` / tool config sections determine which check commands
  exist (e.g., ruff, mypy, pytest). Only generate steps for tools the project
  actually uses.
- `uv.lock` -- if present, use `uv sync --locked` so CI fails when the
  lockfile is stale instead of silently re-resolving.
- `.github/workflows/` -- never overwrite existing workflows without showing
  the user a diff and getting confirmation.
- Whether the repo is public or private (`gh repo view --json visibility`) --
  dependency review and CodeQL require GitHub Advanced Security on private
  repos, so flag that instead of generating workflows that will fail.

## Step 2: Select workflows and read references

| User intent | File(s) to generate | Reference |
|---|---|---|
| CI: tests, lint, types | `.github/workflows/ci.yml` | `references/ci.md` |
| Release / publish to PyPI | `.github/workflows/release.yml` | `references/release.md` |
| Security scanning | `.github/workflows/codeql.yml`, `.github/workflows/dependency-review.yml`, `.github/dependabot.yml` | `references/security.md` |
| Pre-commit hooks (local checks via prek) | `.pre-commit-config.yaml` | `references/pre-commit.md` |
| Repo hygiene | `.github/workflows/stale.yml`, PR title check | `references/hygiene.md` |

If the user says something broad like "set up workflows for this repo",
propose CI + security as the default set, and offer release, pre-commit, and
hygiene as opt-ins. CI and Dependabot are nearly always wanted; pre-commit is
nearly always wanted for Python projects (its actionlint/zizmor hooks also
reinforce the workflow security this skill cares about); stale-issue
automation is a team-culture decision, so do not add it unasked.

## Resolving action SHAs

Templates reference actions as `owner/repo@{SHA} # {TAG}`. Mutable tags like
`@v4` can be repointed by an attacker who compromises the action repository
(this happened in the March 2025 tj-actions/changed-files incident), so pin
every third-party and first-party action to a full-length commit SHA, with
the human-readable tag in a trailing comment so reviewers and Dependabot can
still tell what version it is.

Resolve the latest release tag and its commit SHA at generation time:

```bash
TAG=$(gh api repos/actions/checkout/releases/latest --jq .tag_name)
SHA=$(gh api "repos/actions/checkout/commits/$TAG" --jq .sha)
# -> uses: actions/checkout@$SHA # $TAG
```

The `commits/$TAG` endpoint dereferences annotated tags to the commit SHA,
which is what the `uses:` key needs. (`github/codeql-action` is a special
case -- its `releases/latest` returns bundle tags; see
`references/action-pins.md` for the correct lookup.)

If `gh` is unavailable or the network is blocked, do NOT fall back to
mutable tags. Use the verified snapshot in `references/action-pins.md`
instead: those are real commit SHAs (possibly a few releases behind), which
preserves the immutability guarantee. Tell the user the pins came from the
skill's snapshot and that the Dependabot config (see
`references/security.md`) will bump them to current releases.

## Security baseline (applies to every workflow)

Apply all of these regardless of which workflow you are generating. They are
cheap, and their absence is what security scanners flag first:

- **Top-level `permissions:`** on every workflow, as restrictive as possible
  (`contents: read`, or `{}` when jobs declare their own). Elevate per-job,
  never workflow-wide. The default `GITHUB_TOKEN` grants are too broad.
- **`persist-credentials: false`** on every `actions/checkout` unless a later
  step pushes commits. The default leaves a write-capable token on disk for
  every subsequent step to read.
- **Injection-safe shell steps.** Never interpolate attacker-controllable
  expressions (`github.event.pull_request.title`, branch names, issue bodies,
  commit messages) directly into `run:` blocks -- that is shell injection.
  Pass them through `env:` instead:

  ```yaml
  # BAD: title is evaluated into the script before the shell runs
  - run: echo "${{ github.event.pull_request.title }}"
  # GOOD: title is data, not code
  - env:
      TITLE: ${{ github.event.pull_request.title }}
    run: echo "$TITLE"
  ```

- **No `pull_request_target`** unless the user explicitly needs
  fork-PR access to secrets, and never combine it with a checkout of the PR
  head. Use plain `pull_request` and explain the trade-off if asked.
- **`concurrency` groups** on CI-style workflows so superseded runs cancel:

  ```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true
  ```

- **OIDC over secrets.** Publishing uses PyPI Trusted Publishing
  (OpenID Connect identity tokens) rather than long-lived API tokens stored
  in repository secrets. There is nothing to leak or rotate.
- **`timeout-minutes`** on every job. The 6-hour default turns a hung test
  into a billing problem.

## Readability conventions (apply to every file)

These do not affect behavior but make the generated files self-explanatory --
apply them to every fixture, including the ones shown without them in older
examples:

- **Top-of-file purpose comment.** Begin every generated file (`.yml`
  workflows, `dependabot.yml`, `.pre-commit-config.yaml`, any helper script)
  with a short comment stating what the file is for and when it runs, so a
  reader does not have to infer it from the body. The templates in
  `references/` open with this comment; keep it and tailor it to the repo.
- **Name every workflow step.** Give each `steps:` entry a `name:`, even
  trivial `run:`/`uses:` steps. Unnamed steps appear in the Actions log as the
  raw command or action ref (`Run uv run mypy`, `Run actions/checkout@<sha>`);
  a `name:` like `Type-check (mypy)` makes the log scannable and the failing
  step obvious. Keep names short and imperative.
- **Quiet uv in CI.** uv's resolution/download progress is a wall of tty noise
  in CI logs. Pass `--quiet` to uv invocations: `uv sync --locked --quiet`,
  `uv build --quiet`, and `uv run --quiet <tool>`. Note the placement -- on
  `uv run` the flag goes *before* the tool (`uv run --quiet pytest`), since
  it is uv's flag, not the tool's; it suppresses only uv's own output, so the
  tool's results (test failures, lint errors) still print in full.

## Step 5: Validate

Run both tools if installed; if missing, offer to install via Homebrew:

```bash
actionlint                      # syntax, expression, and shellcheck errors
zizmor .github/workflows/       # security smells (unpinned actions, injection, credentials)
# missing? -> brew install actionlint zizmor
```

Fix everything they report before showing the user the result. Zizmor
findings at `Medium` or above should never ship; use your judgment on
pedantic/`Low` findings and say so explicitly when you leave one in place.

## Step 6: Report required settings

Generated workflows often assume one-time repository configuration that no
YAML file can perform. End by listing what applies, concretely -- for
example:

- **Release**: create the PyPI Trusted Publisher (PyPI project settings ->
  Publishing -> add GitHub publisher with owner, repo, workflow filename,
  and environment name `pypi`) and the matching GitHub environment, ideally
  with required reviewers.
- **CodeQL / dependency review on private repos**: requires GitHub Advanced
  Security.
- **Branch protection**: suggest requiring the CI check on `main` once the
  first run is green.
- **Dependabot**: no settings needed for version updates via
  `.github/dependabot.yml`, but security updates are toggled in repo
  Settings -> Advanced Security.
