# Repo Hygiene Workflows

These automate maintenance chores. They touch issues and PRs that humans
wrote, so defaults should be gentle -- an over-aggressive stale bot is a
community-relations problem. Confirm the user actually wants each one;
never add hygiene automation as a side effect of "set up CI".

## Stale issues and PRs

`.github/workflows/stale.yml`:

```yaml
# Marks issues and PRs stale after a period of inactivity and closes them later
# unless someone responds. Runs on a schedule; exempt labels are the escape hatch.
name: Close stale issues and PRs

on:
  schedule:
    - cron: "37 2 * * *"

permissions:
  contents: read

jobs:
  stale:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    permissions:
      issues: write
      pull-requests: write
    steps:
      - name: Mark and close stale issues and PRs
        uses: actions/stale@{SHA} # {TAG}
        with:
          days-before-stale: 60
          days-before-close: 14
          stale-issue-message: >
            This issue has been automatically marked as stale because it has
            not had recent activity. It will be closed in 14 days if no
            further activity occurs. Comment to keep it open.
          stale-pr-message: >
            This pull request has been automatically marked as stale because
            it has not had recent activity. It will be closed in 14 days if
            no further activity occurs. Comment or push to keep it open.
          exempt-issue-labels: pinned,security
          exempt-pr-labels: pinned,security
```

60/14 days is a conservative default; ask the user if they want different
windows. Always keep the `exempt-*-labels` escape hatch.

## PR title check (Conventional Commits)

Only offer this when the repo demonstrably uses Conventional Commits
(check `git log --oneline`) or the user asks. Enforcing a convention the
team does not follow just makes CI red.

`.github/workflows/pr-title.yml`:

```yaml
# Validates that each pull request title follows Conventional Commits.
name: PR title

on:
  pull_request:
    types: [opened, edited, synchronize]

permissions:
  contents: read

jobs:
  lint-title:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    permissions:
      pull-requests: read
    steps:
      - name: Validate PR title
        uses: amannn/action-semantic-pull-request@{SHA} # {TAG}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This validates the PR title via the API; it does not check out or execute
any PR code, which is why plain `pull_request` with read permissions is
sufficient (no `pull_request_target` needed).

## Labeler

Path-based PR labeling. Requires a `.github/labeler.yml` config mapping
labels to path globs -- generate one from the repo's top-level structure
(e.g., `docs/**` -> `documentation`, `tests/**` -> `tests`).

`.github/workflows/labeler.yml`:

```yaml
# Applies labels to pull requests based on the file paths they touch
# (mapping lives in .github/labeler.yml).
name: Labeler

on: [pull_request_target]

permissions:
  contents: read

jobs:
  label:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    permissions:
      contents: read
      pull-requests: write
    steps:
      - name: Apply labels by path
        uses: actions/labeler@{SHA} # {TAG}
```

This is the one sanctioned `pull_request_target` use in this skill: labeling
fork PRs requires a write-capable token, and `actions/labeler` reads its
config from the base branch and never checks out or executes PR head code.
Do not add a checkout step to this job -- that is exactly the combination
the security baseline forbids.
