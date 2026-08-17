# Pre-commit Hooks (run with prek)

Target file: `.pre-commit-config.yaml`

Local hooks that catch formatting, lint, workflow, and secret problems
before they reach CI. The config is the standard `.pre-commit-config.yaml`
format; the recommended runner is [`prek`](https://github.com/j178/prek), a
fast Rust drop-in for `pre-commit` that reads the same file unchanged. Every
`pre-commit` command has a `prek` equivalent, so a project can adopt either
without changing this file.

## Why prek

`prek` is a single static binary with no Python bootstrap, so hooks start
faster and there is no `pre-commit` virtualenv to manage. It honors the same
`.pre-commit-config.yaml`, the same hook repos, and the same `rev` pinning, so
nothing below is prek-specific except the command names. If the user prefers
stock `pre-commit`, the identical file works -- just substitute the commands.

## Adaptation rules

- **This file is the single definition of the project's fast checks.** CI runs
  the very same config (see the `checks` job in `references/ci.md`:
  `uv run prek run --all-files`), so "passes locally" equals "passes CI" by
  construction -- the checks are not restated as workflow steps. Include only
  tools the project actually uses (check `[tool.ruff]`, `[dependency-groups]`).
- **Auto-fix hooks double as the CI gate.** `ruff-check --fix` and `ruff-format`
  rewrite files locally so the developer commits clean code; in CI the same
  hooks run under `prek` and exit non-zero when they *would* change a file, so
  CI fails on unformatted/unlinted code with no separate read-only step.
- **Do not put mypy or pytest here.** Both are version-dependent: a single
  local Python can pass while CI's matrix fails (the classic trap -- a
  `python_full_version`-gated dependency like numpy ships different type stubs
  per Python). They belong in the matrixed `typecheck`/`test` jobs in
  `references/ci.md`; developers run them on demand with `uv run mypy` /
  `uv run pytest`. Keeping them out also means the CI `prek` run does not
  redundantly re-run them.
- **uv-lock only for uv projects.** The `uv-lock` hook keeps `uv.lock` in sync
  with `pyproject.toml`. For a `requirements.txt`/pip project, remove it.
- **Workflow hooks pull their weight here.** `actionlint` and `zizmor` are the
  same validators this skill runs by hand; as hooks they keep
  `.github/workflows/` clean on every commit, not just at generation time.
- **`validate-pyproject` for any Python project**, and the shebang pair
  (`check-executables-have-shebangs`, `check-shebang-scripts-are-executable`)
  -- the former schema-validates `pyproject.toml` beyond mere TOML syntax, the
  latter keep shebang/executable-bit in sync. Add **`shellcheck`**
  (`shellcheck-py/shellcheck-py`) only when the project ships `.sh` scripts
  (actionlint shellchecks workflow `run:` blocks, but not standalone scripts).
- **`shfmt` (formatter) pairs with `shellcheck` (linter)** for shell, the way
  `ruff-format` pairs with `ruff-check` -- add it (`scop/pre-commit-shfmt`,
  id `shfmt`) alongside shellcheck when the project ships `.sh` scripts, ordered
  *before* it so shellcheck lints formatted code. Drive its options from
  `.editorconfig`, not flags: `[*.sh] indent_size = 2` and
  `switch_case_indent = true` give Google Shell Style (2-space indent, indented
  `case` alternatives), and the hook passes only `args: [-w]`. This matters --
  shfmt **ignores `.editorconfig` entirely if any printer flag (`-i`, `-ci`,
  ...) *or* `-s` is passed**, so putting those on the CLI defeats the file;
  `-w` is an action and leaves `.editorconfig` in charge. (Trade-off: `-s`
  simplify has no `.editorconfig` key, so the editorconfig-driven setup forgoes
  it.) The `.editorconfig` doubles as editor configuration.
- **Keep each `hooks:` list sorted ascending by `id` (case-insensitive).** A
  stable order makes additions reviewable and diffs minimal. (Order does not
  affect execution within a repo's hook list.)

## Versioning and supply chain

**Pin each `rev` to a full commit SHA, with the tag in a trailing comment** --
the same rule this skill applies to GitHub Actions, and for the same reason: a
floating tag can be repointed if the hook repo is compromised, and pre-commit
hooks run arbitrary code on the developer's machine at commit time, so the
blast radius is worse than a CI action. pre-commit and prek both accept a SHA
in `rev` and check it out exactly like a tag:

```yaml
rev: 3e8a8703264a2f4a69428a0aa4dcb512790b2c8c # v6.0.0
```

The template below shows tags for readability; harden it to SHAs immediately
after writing by running the pin script (see "Updating the pins"). If a team
explicitly prefers tag pins for simpler maintenance, that is a defensible
downgrade -- say so rather than leaving it implicit.

**There is no Dependabot ecosystem for pre-commit hooks**, so unlike the
workflow SHAs (which Dependabot bumps), these are maintained by hand. That is
what the pin script and the autoupdate cycle below are for -- tell the user the
pins will silently rot otherwise.

## Updating the pins

`prek autoupdate` (or `pre-commit autoupdate`) moves every `rev` to the latest
release **tag** -- it does not understand SHAs and will overwrite them. So the
maintenance cycle is two steps: autoupdate to discover new versions, then
re-pin to SHAs.

```bash
prek autoupdate                  # rev: -> latest tags (drops SHA pins)
scripts/pin-precommit-shas.sh    # tags -> SHA # tag (restores immutable pins)
prek run --all-files             # exercise the new versions; fix fallout
```

`scripts/pin-precommit-shas.sh` (in this skill) rewrites each hook's `rev` to
the commit SHA of its tag using `git ls-remote` (no auth, any git host),
preserving the `# tag` comment as the source of truth. It is idempotent and
skips `repo: local` / `repo: meta`. Run it on first generation too, to convert
the template's tags to SHAs. Copy it into the target repo (e.g.,
`scripts/`) so the maintenance command lives with the project.

The `rev-must-be-sha` local hook in the template **enforces** this: it fails
(locally and in CI, since the `checks` job runs `prek`) whenever a `rev:` is a
bare tag rather than a SHA -- i.e., an `autoupdate` that skipped the re-pin
step. It is offline and lookahead-free (Rust-regex safe for prek). This is the
guardrail that makes the manual pin step safe to forget; the failure message
names the script to run.

## Template

```yaml
# Local hooks run by prek (https://github.com/j178/prek), a fast Rust drop-in
# for pre-commit that reads this same file. Set up once with `prek install`;
# run on demand with `prek run --all-files`. (`pre-commit` works unchanged too.)
#
# Each `rev` is pinned to a commit SHA (tag in the trailing comment) so a
# repointed tag cannot silently change the code these hooks run. To update:
#
#     prek autoupdate && ./scripts/pin-precommit-shas.sh
#
# autoupdate moves revs to the latest tags; the script re-pins them to SHAs.
repos:
  # General hygiene
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks: # ids sorted ascending (case-insensitive)
      - id: check-added-large-files
      - id: check-case-conflict
      - id: check-executables-have-shebangs
      - id: check-json
      - id: check-merge-conflict
      - id: check-shebang-scripts-are-executable
      - id: check-toml
      - id: check-yaml
      - id: debug-statements
      - id: detect-private-key
      - id: end-of-file-fixer
      - id: mixed-line-ending
      - id: trailing-whitespace

  # Python lint + format -- mirrors the CI ruff steps (auto-fixes locally)
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.15.17
    hooks:
      - id: ruff-check
        args: [--fix]
      - id: ruff-format

  # Keep uv.lock in sync with pyproject.toml (uv projects only)
  - repo: https://github.com/astral-sh/uv-pre-commit
    rev: 0.11.21
    hooks:
      - id: uv-lock

  # Schema-validate pyproject.toml (beyond TOML syntax)
  - repo: https://github.com/abravalheri/validate-pyproject
    rev: v0.25
    hooks:
      - id: validate-pyproject

  # GitHub Actions workflow lint + security (same tools this skill validates with)
  - repo: https://github.com/rhysd/actionlint
    rev: v1.7.12
    hooks:
      - id: actionlint
  - repo: https://github.com/zizmorcore/zizmor-pre-commit
    rev: v1.25.2
    hooks:
      - id: zizmor

  # Shell script formatting + linting -- include only if the project ships .sh
  # scripts. shfmt runs before shellcheck (format, then lint). Its style options
  # come from .editorconfig ([*.sh] indent_size + switch_case_indent = Google
  # style); the hook passes only -w, since any printer flag or -s makes shfmt
  # ignore .editorconfig.
  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.13.1-1
    hooks:
      - id: shfmt
        args: [-w]
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.11.0.1
    hooks:
      - id: shellcheck

  # Secret scanning
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks:
      - id: gitleaks

  # Fail if any hook `rev:` is a bare tag instead of a commit SHA -- catches a
  # `prek autoupdate` that was not followed by ./scripts/pin-precommit-shas.sh.
  - repo: local
    hooks:
      - id: rev-must-be-sha
        name: pre-commit revs must be SHA-pinned (run ./scripts/pin-precommit-shas.sh)
        language: pygrep
        files: '^\.pre-commit-config\.yaml$'
        # Matches a rev: whose value has a non-hex char (i.e. a tag, not a SHA).
        # Lookahead-free so it works under prek's (Rust) regex engine too.
        entry: '(?m)^\s*rev:\s+[0-9a-fA-F]*[^0-9a-fA-F\s#]'

# mypy and pytest are deliberately omitted: both are version-dependent, so a
# single-version local hook can pass while CI's Python matrix fails. They run
# in the matrixed CI jobs; locally, run `uv run mypy` / `uv run pytest`.
```

## Install and validate

```bash
uv tool install prek          # or: uvx prek ... / brew install prek / pipx install prek
prek install                  # register the git hook(s) in .git/hooks
prek run --all-files          # run every hook over the whole tree (do this once now)
```

`prek run --all-files` is the validation step: run it after writing the file
and fix everything it reports, exactly as you would `actionlint`/`zizmor` for
workflows. The first run often rewrites files (ruff format/fix, end-of-file,
trailing whitespace) -- re-stage and re-run until clean. If `check-added-large-files`
trips on a legitimately large committed file (e.g., a vendored fixture), raise
its limit with `args: ["--maxkb=NNN"]` rather than deleting the hook.

## Run in CI

Local hooks are advisory -- a developer can `git commit --no-verify` or never
install them. Enforce the same suite server-side with one CI job that runs
`prek` over the whole tree (the `checks` job in `references/ci.md`):

```yaml
      - name: Run pre-commit hooks (prek)
        run: uv run --quiet prek run --all-files --show-diff-on-failure
```

This reuses the project's uv setup and the `prek` dev dependency -- no extra
action to pin -- and is the single enforcement point: define the fast checks
once here, and CI runs them by invoking `prek`, never by restating
ruff/actionlint/etc. as separate steps. (If hook-download time in CI matters,
[`j178/prek-action`](https://github.com/j178/prek-action) caches hook
environments at the cost of one more SHA-pinned action.) Because mypy and
pytest are not hooks, this run does not duplicate the matrixed
`typecheck`/`test` jobs.
