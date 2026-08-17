# Eval fixtures

## solarwatt

A synthetic Python/uv package used as the input repository for the evals in
[../evals/evals.json](../evals/evals.json). It is not a real project; it exists
to be the "before" state that the skill acts on.

It deliberately ships **no `.github/` directory**. Each eval drops Claude into a
copy of it with a prompt such as "add CI to this repo", runs once with the skill
loaded and once without, and grades the resulting workflow files.

The package metadata encodes the correct answers, which is what makes the
assertions mechanically checkable rather than a matter of taste:

| Fixture fact | What a correct workflow must do |
| --- | --- |
| `requires-python = ">=3.11"` | test a 3.11 / 3.12 / 3.13 matrix |
| `dev = ["pytest>=8.0", "ruff", "mypy"]` | run exactly those three tools |
| committed `uv.lock` | use `uv sync --locked` |

Change the metadata and the expected output changes with it, so treat edits here
as edits to the eval contract.

## The fixture must be a git repo, but only while evals run

The harness copies the fixture directory wholesale, `.git` included, so a
fixture has to be a real git repository at run time. Git cannot track a nested
repository as anything but a gitlink, which clones empty, so `.git` is never
committed. A `.gitignore` does **not** suppress that detection; the only thing
that works is the directory being absent. So the repo is transient:

```sh
./init.sh           # before running evals
./init.sh --clean   # before committing
```

Both modes are idempotent. `init.sh` reproduces the original state exactly: a
single commit named `initial` containing every file, with no remote. It was
verified to rebuild the same tree object as the fixture's original commit
(`3281f083`), so only the commit SHA differs, and nothing references it.

If you commit while a fixture is initialized, git will stage `solarwatt` as a
gitlink and the tracked files will disappear from clones. Run `--clean` first.

## Recorded benchmark

From the last eval round before this directory was folded into the skill
(2026-06-12, three runs per configuration across evals 0, 1, and 2):

| Metric | With skill | Without skill | Delta |
| --- | --- | --- | --- |
| Pass rate | 100% ± 0% | 60% ± 3% | +0.40 |
| Time | 97.8s ± 5.9s | 81.2s ± 25.0s | +16.7s |
