---
name: uv-minimum-versions
description: >-
  Choose and verify a Python library's dependency lower bounds (floors) as a
  tested compatibility contract, using uv's `--resolution lowest-direct` as the
  test and a blocking GitHub Actions job as the gate. A floor is the lowest
  version that provides the APIs you use and ships a wheel on your Python floor.
  Covers the traps that make a floor job lie (missing wheels, sibling and group
  pins, a bare `uv run` undoing the floors), the CI matrix shape, and the policy
  layer (Dependabot lockfile-only, a scheduled lock refresh, an ADR). Use when
  setting or auditing minimum dependency versions, when a lowest-direct CI job
  fails (e.g., "No module named pkg_resources") or might not be testing the
  floors, when Dependabot keeps raising floors, or when deciding how low a
  dependency can go. Triggers: "minimum versions", "dependency floors", "lower
  bounds", "lowest-direct". Python / uv libraries only, not applications.
---

# uv-minimum-versions

A library's dependency lower bounds are a **contract**: they promise the oldest
versions a user may bring. Most projects leave that contract arbitrary,
untested, and silently rising. This skill makes it deliberate, verified, and
stable.

The move that separates this from folklore: **treat CI as the oracle, not your
judgment.** You do not reason your way to "msgspec 0.18 still works." You
declare a floor as a hypothesis and let a blocking `uv --resolution
lowest-direct` job prove or refute it. The floor selection and the CI job are
one change, not two.

Every rule in this skill is a *judgment call*, not a rote step. Each one carries
its reasoning (the mechanism and the consequence), so you can apply it to a
dependency these examples do not cover. The evidence tables, exact CI YAML, and
probe commands live in `reference.md`, and the worked example is
`case-study.md`.

## What this is / is NOT

- It IS: choosing *and verifying* lower bounds for a Python library published to
  others, so the declared minimum is real.
- It is NOT `ponytail` (use *fewer* dependencies). This skill bounds the
  versions of the ones you already depend on.
- It is NOT application pinning. An app pins an exact, reproducible set, while a
  library declares the *widest* range it honestly supports. Opposite goals.
- It is NOT upper bounds. Libraries avoid artificial ceilings, so this skill
  covers floors only.

## The principle

Each floor is the **lowest version that both**:

- **(a) provides every API you actually use**, and
- **(b) ships a wheel for your Python floor** (e.g., 3.11), so a user on your
  minimum Python installs it cleanly, never from a source build.

Lower floor = wider reach. Raise a floor only by a deliberate, recorded
decision, never by default. And a floor is a *claim* until a test installs it
and runs your suite: verify, do not assert.

### Why a wheel, and not "allow a source build"?

This is the non-obvious half of criterion (b), and it is a real choice with real
trade-offs, so here is the whole argument. "Allow the build" is not *wrong*. It
just trades away something a library floor should not trade.

**A floor is a promise of installability, and a wheel is the only thing that
keeps that promise for everyone on your minimum Python, not just users with a
build toolchain.**

1. **Not everyone can build.** A source build of a compiled dependency (cftime,
   shapely) needs a C compiler, Cython, and headers. The geo stack also needs
   system GEOS / PROJ, which are not even pip-installable. Windows users, slim
   containers, and locked-down enterprise / CI environments routinely have none
   of that. A wheelless floor silently redefines your minimum as "supported *if
   you can compile C*," which is the opposite of what a low floor is for (widest
   reach). It is especially wrong for a library aimed at web / container
   deployment, where slim wheel-only images are the norm.
2. **Builds are non-deterministic, but wheels are not.** A source build compiles
   against whatever compiler, headers, and system libraries happen to be
   present. Making "does my library install at its minimum" depend on the
   *user's* build environment is a weaker contract and a worse thing to test,
   because you would be testing their machine, not version numbers.
3. **"Just make the build succeed" fixes the wrong thing.** You *can* make the
   build pass (uv's `[tool.uv.extra-build-dependencies]`, or installing GEOS in
   CI). That makes *your* CI pass while leaving the *user-facing* floor false: a
   user on a newer Python who pins that dependency low still finds no wheel. You
   would be validating a configuration (a source-built ancient release) that no
   real user runs. A passing check, not verification.
4. **It is per-Python, the same coin as "floors pair with the Python floor."**
   The criterion is that the floor ships a wheel on the *floor* Python. A floor
   release having no wheel for a *newer* Python is fine, because on that newer
   Python the resolver should pair you with a newer, wheeled release. This is
   exactly why the `lowest-direct` CI job runs on the floor Python only (see
   trap 1). Wheel-criterion and floor-Python-only are two faces of one idea.

**When to relax it.** The criterion assumes the mainstream scientific / web
stack, where wheels are the norm. Relax it when either holds:

- **A dependency genuinely never ships wheels** (a niche pure-C or source-only
  package). Then a build is unavoidable: keep the floor at the lowest version
  with the APIs you use, but *document* that this dependency requires a build
  toolchain, and make CI install that toolchain so it mirrors real user
  conditions rather than pretending the floor is wheel-clean.
- **Your target platform is itself unusual** (an embedded arch, a niche OS with
  no wheels). Same move: the floor is honest only if paired with a documented
  toolchain expectation, and CI must reflect it.

The test for relaxing: are you *documenting a real, unavoidable build
requirement your users share*, or are you *hiding a wheel gap so your CI
passes*? The first is legitimate. The second is the anti-pattern in point 3.

## The procedure

1. **Baseline.** In a throwaway copy of the project (the sync rewrites
   `uv.lock`), export `UV_RESOLUTION=lowest-direct` and `UV_PYTHON` set to your
   Python floor, so every uv command keeps both (trap 5). Then sync and run your
   tests. Check the installed versions with `uv tree --frozen --depth 1` before
   you trust the result. If the tests pass, the current floors hold. If they
   fail, a floor is too low, a floor does not ship a wheel, or the code relies
   on a newer release (trap 6). This is often the first time the declared floors
   have ever been tested.
2. **Decide each floor.** For every runtime dependency, find the lowest version
   satisfying (a) and (b). Lower the arbitrary ones, keep the deliberate ones,
   and write a one-line rationale for each in `pyproject.toml`. Also check what
   the floor release itself depends on, because dependencies can change between
   releases (`reference.md`, Probes). Watch the traps, because several floors
   that *look* lowerable are not.
3. **Iterate until it passes.** Delete the copy's `uv.lock` and re-run the sync
   and tests after each change. Otherwise uv keeps any locked version that still
   fits, and a lowered floor seems to change nothing. For each failure, either
   raise the one floor that is too low, or fix the code (tests and doctests
   included) that relies on a newer release (trap 6). Choosing floors and adding
   the CI job belong in one change, because the job is how you know the floors
   are right.
4. **Add the gate, then prove it.** Add a blocking CI job that runs
   lowest-direct on the Python floor (the *floor job*, with its recipe in
   `reference.md`), and merge it with the floor changes once it passes. Then
   prove it can fail. In a throwaway draft pull request, lower one floor to a
   release you know breaks, change the same specifier in `uv.lock`, and check
   that the floor job fails for that reason (`reference.md`, Operating the
   gate). A gate that has never failed is indistinguishable from a gate that
   cannot fail.
5. **Stop the drift + record it.** Set Dependabot
   `versioning-strategy: lockfile-only` so it never rewrites floors, schedule a
   monthly lock refresh so indirect dependencies stay current, and record the
   policy in an ADR.

## The traps (the part folklore misses)

### 1. Wheels are not `requires-python`

**Mechanism.** A resolver (uv, pip) chooses a *version* by reading each
release's `requires-python` metadata, and only *then* looks for an installable
artifact: a wheel if one exists for the target interpreter and platform,
otherwise a source build from the sdist. Those are two independent facts, and
old releases of compiled packages get them out of sync. They declare an
open-ended `requires-python` (`>=3.8`, no upper bound) but only ever shipped
wheels for the interpreters that existed when they were released. So when
`lowest-direct` pins such a release on a *newer* Python, the metadata says
"compatible," the resolver accepts it, and then it cannot find a wheel. It falls
back to a source build, which fails on any runner without the full C toolchain
(the `pkg_resources` / missing-GEOS class of error).

**Consequence you carry to a new project.** A floor is only coherent paired with
the Python floor, because the declared floors are a snapshot of one era,
installable by wheel only on that era's Python. So run `lowest-direct` on the
floor Python only, and let `highest` cover the newer Pythons against modern
(wheeled) versions, the pairing real users actually get. A source build
appearing in a `lowest-direct` run is this trap, every time.

### 2. A sibling or a dependency group can pin a dependency higher

**Mechanism.** Under an all-extras `lowest-direct` resolve, a dependency's
installed version is the highest of *all* lower-bound constraints on it,
including constraints from *other* dependencies. If xarray requires
`numpy>=1.24`, numpy resolves to 1.24 regardless of your own `numpy>=`, as long
as yours is lower.

Dependency groups count too. `uv.lock` holds one version of each package for the
whole project: its extras and every dependency group. So a dev or benchmark
group can force a runtime dependency higher, even in a job that never installs
that group, and that job's log will not show why.

**Consequence.** A declared floor below the pinned version changes nothing CI
installs, so no test ever checks it. You have two honest options: raise the
declaration to the version that resolves, or keep it and record it as untested,
along with what holds it up. Do not call it verified, because the job's log
shows the pinned version, not your floor. To check for a pin, declare a lower
floor, delete the lock, and re-resolve. If the version does not move, it is
pinned. If the pin comes from a group users never install, such as benchmarks,
move that group into its own project with its own lock.

### 3. "Arbitrary" is not the same as "should be lowered"

**The real target is deliberateness, not minimization.** A floor fails the bar
when it lacks a recorded reason, not merely when it is higher than the
theoretical minimum. Minimizing is a *means* to the end (widest honest reach),
and it stops being worth it when the reach gained is negligible or the cost of
vouching for an ancient version is high.

**The clearest case is a fast-moving, pre-1.0 core dependency.** The APIs you
use may exist several minor versions back, but "how low do we genuinely support"
is a judgment about what behavior you are willing to stand behind, not a
mechanical floor. Keeping such a dependency at a recent baseline *with a stated
reason* satisfies the policy exactly as well as lowering it would. Often the fix
for an "arbitrary" floor is a one-line rationale, not a smaller number.

### 4. A floor change must not re-resolve the whole lock

**Mechanism.** The only intended change to `uv.lock` is the specifier line(s)
you edited. But a bare `uv sync` / `uv lock` re-resolves the whole graph and
bumps stale *indirect* (transitive) pins (a lockfile that lags the registry can
move dozens of packages), burying your one intentional line under unrelated
churn and dragging in upgrade risk you did not choose.

**Discipline.** Keep the diff to what you meant: restore the lock from the base
branch, hand-edit only the changed specifier, and confirm consistency with
`uv lock --check`. Keeping indirect dependencies fresh is a separate concern
with its own owner (the scheduled lock refresh), not a side effect of a floor
change.

A lowest-direct sync also rewrites `uv.lock`, to record the floor versions. That
is harmless in CI, where the runner is thrown away. Locally, run the floors in a
throwaway copy so you never commit that lock.

### 5. A bare `uv run` undoes the floors

**Mechanism.** `--resolution` applies only to the command it is passed to.
`uv sync --resolution lowest-direct` installs the floors. A later plain `uv run`
syncs again first, in the default `highest` mode, and installs the newest
release of everything. The tests then run against those, so the floor job passes
no matter what the floors are, and its log does not show it.

Adding `--no-sync` to the test step fixes that step only. Any earlier step that
uses `uv run` has already replaced the floors.

**Fix.** Set `UV_RESOLUTION: ${{ matrix.resolution }}` at job level, so every uv
command in the job uses the job's mode. Also print the versions the floor job
tested (`uv tree --frozen --depth 1`), because that job's lock is never
committed and the log is the only record. Recipe in `reference.md`.

### 6. A failure at the floors is not always a floor problem

**Mechanism.** The floor job runs your tests against old releases, and installs
your dev group at its floors too. So it can fail for reasons no user would hit:

- **Tests that depend on newer output.** A repr that changed order, a float that
  numpy 1.x prints as `2.` and numpy 2 as `2.0`, an exception that became a
  `ValueError` subclass in a later release. The library works. The test checks
  an incidental detail.
- **Dev tools below what your suite needs.** pytest before 8.1.1 imports modules
  twice in `importlib` mode, which broke a doctest.
- **Test helpers that change dependencies between releases.** Starlette's
  `TestClient` uses `httpx` before 1.2 and `httpx2` from 1.2, so a dev group
  with only `httpx2` cannot run those tests against an old fastapi.

Dev dependencies without a floor resolve to very old releases too (pandas-stubs
1.0.4.2). That matters only if a type checker runs in the floor job.

**Consequence.** Find the cause before raising anything. Raise a runtime floor
only when the library needs the newer release. If a test depends on newer
output, change the test input so the output is the same on every supported
release. Raising a runtime floor to fix a test narrows what every user can
install. Raising a dev tool's floor costs users nothing.

## Anti-patterns

- **Raising a floor to make a *newer-Python* test pass.** Narrows reach for a
  configuration users on the old Python never hit, so you would be degrading the
  contract to satisfy a test that trap 1 says should not exist.
- **`--resolution lowest` (floors *indirect* dependencies too).** Fails on
  third-party interactions you neither own nor can fix by editing your own
  declarations. Use `lowest-direct`, which tests the contract you actually make
  (your direct floors) while letting indirect dependencies resolve to their
  newest releases.
- **Trusting a *local* lowest-direct pass.** Your machine may have silently
  built a wheelless package from source (you have a compiler). A clean CI runner
  will not, and neither will many of your users. Believe the CI job, not your
  laptop.
- **Trusting a passing floor job without checking its versions.** If it tested
  the newest releases, it passes whatever the floors are (trap 5). Check the
  logged versions on its first run and whenever its steps change.
- **Letting Dependabot raise floors PR by PR.** Each narrows compatibility by
  default and must be argued down one at a time. `lockfile-only` inverts the
  default so a floor moves only when you mean it.

## The CI shape, and why it takes this form

The verification job tests both ends of the declared range:

- **`highest`** (from the lockfile, `uv sync --locked`) across the **full Python
  matrix**. This is what most users get, and it proves you work against current
  dependencies on every supported Python.
- **one `lowest-direct` job, the floor job** (`uv sync` with
  `UV_RESOLUTION=lowest-direct`, which cannot use `--locked`, because a
  different resolution mode makes uv ignore the lockfile) on the **Python floor
  only**. Because of trap 1, the floor versions are installable by wheel only on
  the floor Python, so crossing `lowest-direct` with newer Pythons tests a
  configuration with no wheels and no users.

Each end of the range lives in a different file, and something different moves
it:

| End of the range | Where it lives | Tested by | Moved by |
| --- | --- | --- | --- |
| Floor (oldest supported) | lower bounds in `pyproject.toml` | the floor job |
a person, by deliberate decision |

Dependabot's `lockfile-only` setting enforces that split. Its pull requests
update `uv.lock` and never touch `pyproject.toml`, and each one runs both ends:
the `highest` jobs test the new release, and the floor job retests the unchanged
floors. Without the setting, each update would also raise a floor, and the floor
job would keep passing, because it tests whatever the floor was just raised to.
Under `lockfile-only`, Dependabot updates only direct dependencies, so a
scheduled `uv lock --upgrade` keeps the indirect ones current. Without the
refresh, the `highest` jobs drift behind what a new install gets
(`reference.md`, Keep indirect dependencies fresh).

Both jobs block. The floor job exists to fail when a floor is wrong, and it can
do that only if every uv command in it runs at the floors, which job-level
`UV_RESOLUTION` ensures (trap 5). It also logs the versions it tested. Prove it
can fail with procedure step 4.

For branch protection, require one stable **aggregator check** (a job that
`needs:` the matrix job and fails if any of its jobs failed), not each job the
matrix creates. Adding or renaming those jobs then never requires a ruleset
change. YAML in `reference.md`.

## Output

When applying this, report per dependency: the floor, keep/lower/raise, the
one-line reason, and the verification result. Close with the CI jobs' status at
both ends and the versions the floor job logged. All-clear, **floors are
load-bearing**: every declared minimum is justified and a blocking job proves it
installs and passes.

## See also

- `reference.md`: read it when writing the CI workflow, the Dependabot or
  lock-refresh setup, or the ADR, or when running a probe. It holds the CI
  recipe, evidence for each trap, probe commands, running the floors locally,
  operating the gate, the lockfile discipline, the policy/ADR layer, and sources
  (incl. the Rust prior art `cargo-minimal-versions`).
- `case-study.md`: read it to see the reasoning applied to a real project. It is
  the covjson-msgspec #65 worked example this skill was distilled from, plus the
  #259 follow-up, which found that the floor job had never tested the floors.
