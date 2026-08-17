---
name: uv-minimum-versions
description: >-
  Choose and VERIFY a Python library's dependency lower bounds (floors) as a
  deliberate, tested compatibility contract, using uv's `--resolution
  lowest-direct` as the oracle and a blocking GitHub Actions leg as the gate.
  A floor is the lowest version that (a) provides the APIs you actually use and
  (b) ships a wheel on your Python floor -- lower is wider reach, raised only by
  deliberate decision, and never asserted without a test. Covers the four traps
  that bite (wheels vs requires-python; siblings pinning a dep up; "arbitrary"
  is not "lower it"; lockfile churn), the CI matrix shape (highest across the
  full Python matrix + one lowest-direct leg on the Python floor), and the
  policy layer (Dependabot lockfile-only, an ADR). Use when setting or auditing
  a library's minimum supported dependency versions, when a `lowest-direct` CI
  job fails (no wheel / "No module named pkg_resources" / source build), when
  Dependabot keeps raising your floors, or when deciding how low a dependency
  can go. Triggers: "minimum versions", "lowest supported versions", "dependency
  floors", "lower bounds", "oldest dependencies", "test minimum dependencies",
  "lowest-direct", "how low can this dep go", "why does my lowest-direct build
  fail", "Dependabot raising floors", "pin minimum versions". Python / uv
  libraries specifically (not applications, not other ecosystems).
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

Every rule below is a *judgment call*, not a rote step, so each carries its
reasoning -- the mechanism and the consequence -- so you can apply it to a
dependency these examples do not cover. The evidence tables, exact CI YAML, and
probe commands live in `reference.md`; the worked example is `case-study.md`.

## What this is / is NOT

- It IS: choosing *and verifying* lower bounds for a Python library published to
  others, so the declared minimum is real.
- It is NOT `ponytail` (use *fewer* dependencies) -- this bounds the versions of
  the ones you already depend on.
- It is NOT application pinning. An app pins an exact, reproducible set; a
  library declares the *widest* range it honestly supports. Opposite goals.
- It is NOT upper bounds. Libraries avoid artificial ceilings; this is floors
  only.

## The principle

Each floor is the **lowest version that both**:

- **(a) provides every API you actually use**, and
- **(b) ships a wheel for your Python floor** (e.g. 3.11), so a user on your
  minimum Python installs it cleanly -- never a source build.

Lower floor = wider reach. Raise a floor only by a deliberate, recorded
decision, never by default. And a floor is a *claim* until a test installs it
and runs your suite: verify, do not assert.

### Why a wheel, and not "allow a source build"?

This is the non-obvious half of criterion (b), and it is a real choice with real
trade-offs, so here is the whole argument. "Allow the build" is not *wrong* -- it
just trades away something a library floor should not trade.

**A floor is a promise of installability, and a wheel is the only thing that
keeps that promise for everyone on your minimum Python -- not just users with a
build toolchain.**

1. **Not everyone can build.** A source build of a compiled dependency (cftime,
   shapely) needs a C compiler, Cython, and headers -- and for the geo stack,
   system GEOS / PROJ that are not even pip-installable. Windows users, slim
   containers, and locked-down enterprise / CI environments routinely have none
   of that. A wheelless floor silently redefines your minimum as "supported *if
   you can compile C*," which is the opposite of what a low floor is for (widest
   reach). It is especially wrong for a library aimed at web / container
   deployment, where slim wheel-only images are the norm.
2. **Builds are non-deterministic; wheels are not.** A source build compiles
   against whatever compiler, headers, and system libraries happen to be
   present. Making "does my library install at its minimum" depend on the
   *user's* build environment is a weaker contract and a worse thing to test --
   you are no longer testing version numbers, you are testing their machine.
3. **"Just make the build succeed" fixes the wrong thing.** You *can* make the
   build pass (uv's `[tool.uv.extra-build-dependencies]`, or installing GEOS in
   CI). That turns *your* CI green while leaving the *user-facing* floor false: a
   user on a newer Python who pins that dependency low still finds no wheel. You
   would be validating a configuration (a source-built ancient release) that no
   real user runs. Green ceremony, not verification.
4. **It is per-Python -- the same coin as "floors pair with the Python floor."**
   The criterion is that the floor ships a wheel on the *floor* Python. A floor
   release having no wheel for a *newer* Python is fine, because on that newer
   Python the resolver should pair you with a newer, wheeled release. This is
   exactly why the `lowest-direct` CI leg runs on the floor Python only (see trap
   1). Wheel-criterion and floor-Python-only are two faces of one idea.

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
requirement your users share*, or are you *hiding a wheel gap so your CI goes
green*? The first is legitimate; the second is the anti-pattern in point 3.

## The procedure

1. **Baseline.** With current floors, run `uv sync --resolution lowest-direct`
   then your tests **via `uv run --no-sync`**, on the Python floor. Green here
   means the current floors already hold; failures point at floors that are too
   low (or too low to have a wheel). This first run is often the first time the
   declared floors are ever exercised at all. `--no-sync` is what makes it a
   real run: a bare `uv run` re-locks and syncs first, restoring the lockfile's
   versions and discarding the floors the sync just installed, so the "floor"
   test silently tests current dependencies instead.
2. **Decide each floor.** For every runtime dependency, find the lowest version
   satisfying (a) and (b). Lower the arbitrary ones; keep the deliberate ones;
   write a one-line rationale for each in `pyproject.toml`. Watch the traps
   below -- several floors that *look* lowerable are not.
3. **Verify, iterating to green.** Re-run the lowest-direct sync + tests until
   green. A red run is the signal a floor must rise; raise that one floor. This
   is why floor selection and the CI job are one change: the job is how you know
   the floors are right.
4. **Wire the gate, then prove it.** Add a blocking CI leg that runs
   lowest-direct on the Python floor (recipe in `reference.md`), and land it
   green *with* the floor changes. Then make it go red once, on purpose: drop
   one floor below a version you know fails, confirm the leg catches it, and
   restore. A gate that has never failed is indistinguishable from a gate that
   cannot fail.
5. **Stop the drift + record it.** Set Dependabot `versioning-strategy:
   lockfile-only` so it never rewrites floors, and record the policy in an ADR.

## The traps  (the part folklore misses)

### 1. Wheels are not `requires-python`

**Mechanism.** A resolver (uv, pip) chooses a *version* by reading each
release's `requires-python` metadata, and only *then* looks for an installable
artifact: a wheel if one exists for the target interpreter and platform,
otherwise a source build from the sdist. Those are two independent facts, and
old releases of compiled packages get them out of sync -- they declare an
open-ended `requires-python` (`>=3.8`, no upper bound) but only ever shipped
wheels for the interpreters that existed when they were released. So when
`lowest-direct` pins such a release on a *newer* Python, the metadata says
"compatible," the resolver accepts it, and then there is no wheel -- so it falls
back to a source build, which fails on any runner without the full C toolchain
(the `pkg_resources` / missing-GEOS class of error).

**Consequence you carry to a new project.** A floor is only coherent paired with
the Python floor: the declared floors are a snapshot of one era, installable by
wheel only on that era's Python. So run `lowest-direct` on the floor Python
only, and let `highest` cover the newer Pythons against modern (wheeled)
versions -- the pairing real users actually get. A source build appearing in a
`lowest-direct` run is this trap, every time.

### 2. A sibling can pin a dependency up -- and then you cannot verify it lower

**Mechanism.** Under an all-extras `lowest-direct` resolve, a dependency's
installed version is the highest of *all* lower-bound constraints on it,
including constraints from *other* dependencies. If xarray requires
`numpy>=1.24`, numpy resolves to 1.24 regardless of your own `numpy>=`, as long
as yours is lower.

**Consequence.** Two things follow: (a) lowering your *declaration* below the
sibling's floor changes nothing in the environment CI actually builds, and (b)
that lower number is therefore a claim no test ever exercises -- unverifiable by
construction. Set the floor to the version that actually resolves and record
*why* (a sibling pins it); do not chase a lower number you cannot prove. To find
out whether a dep is sibling-pinned, declare it lower and re-resolve: if it does
not move, it is pinned, and the declaration is cosmetic.

### 3. "Arbitrary" is not the same as "should be lowered"

**The real target is deliberateness, not minimization.** A floor fails the bar
when it has no recorded reason -- not merely when it is higher than the
theoretical minimum. Minimizing is a *means* to the end (widest honest reach),
and it stops being worth it when the reach gained is negligible or the cost of
vouching for an ancient version is high.

**The clearest case is a fast-moving, pre-1.0 core dependency.** The APIs you
use may exist several minor versions back, but "how low do we genuinely support"
is a judgment about what behavior you are willing to stand behind, not a
mechanical floor. Keeping such a dependency at a recent baseline *with a stated
reason* satisfies the policy exactly as well as lowering it would. Often the fix
for an "arbitrary" floor is a one-line rationale, not a smaller number.

### 4. A floor PR changes the contract -- it must not re-resolve the world

**Mechanism.** The only intended change to `uv.lock` is the specifier line(s)
you edited. But a bare `uv sync` / `uv lock` re-resolves the whole graph and
bumps stale *transitive* pins (a lockfile that lags the registry can move dozens
of packages), burying your one intentional line under unrelated churn and
dragging in upgrade risk you did not choose.

**Discipline.** Keep the diff to what you meant: restore the lock from the base
branch, hand-edit only the changed specifier, and confirm consistency with `uv
lock --check`. Keeping transitives fresh is a separate concern with its own
owner (Dependabot `lockfile-only`), not a side effect of a floor change.

## Anti-patterns

- **Raising a floor to make a *newer-Python* test pass.** Narrows reach for a
  configuration users on the old Python never hit -- you would be degrading the
  contract to satisfy a test that trap 1 says should not exist.
- **`--resolution lowest` (floors *transitive* deps too).** Fails on third-party
  interactions you neither own nor can fix by editing your own declarations. Use
  `lowest-direct`, which tests the contract you actually make (your direct
  floors) while letting transitive deps resolve modern.
- **Trusting a *local* lowest-direct pass.** Your machine may have silently built
  a wheelless package from source (you have a compiler); a clean CI runner will
  not, and neither will many of your users. Believe the CI leg, not your laptop.
- **Letting Dependabot raise floors PR by PR.** Each narrows compatibility by
  default and must be argued down one at a time. `lockfile-only` inverts the
  default so a floor moves only when you mean it.

## The CI shape, and why it takes this form

The verification job tests both ends of the declared range:

- **`highest`** (from the lockfile, `uv sync --locked`) across the **full Python
  matrix** -- this is what most users get; it proves you work against current
  dependencies on every supported Python.
- **one `lowest-direct` leg** (`uv sync --resolution lowest-direct`, which
  *cannot* use `--locked` because changing the resolution mode makes uv ignore
  the lockfile) on the **Python floor only** -- because of trap 1, the floor
  versions are installable by wheel only on the floor Python; crossing
  `lowest-direct` with newer Pythons tests a configuration that has no wheels and
  no users.

Both legs block -- the `lowest-direct` leg is the entire point, so it must be
able to fail the build. It can only fail if the test step runs
`uv run --no-sync`; without that flag the leg installs the floors and then
discards them, and a floor set arbitrarily low still shows green (procedure
step 4 is where you prove otherwise). Gate branch protection on a single stable
**aggregator
check** (a job that `needs:` the matrix job and fails if any needed job did not
succeed), not the per-leg names: a matrix job is one node in `needs:`, so the
aggregator gates every leg transitively, and adding or renaming legs never forces
a change to the ruleset. Exact YAML in `reference.md`.

## Output

When applying this, report per dependency: the floor, keep/lower/raise, the
one-line reason, and the verification result. Close with the CI leg's status at
both ends. All-clear: **floors are load-bearing** -- every declared minimum is
justified and a blocking job proves it installs and passes.

## See also

- `reference.md` -- the exact CI recipe (matrix `include`, split install steps,
  aggregator gate), each trap's evidence (wheel-tag tables, the verbatim
  failure, the sibling-pin probe), how to probe wheels and API-introduction
  versions, the lockfile discipline, the policy/ADR layer, and sources (incl.
  the Rust prior art `cargo-minimal-versions`).
- `case-study.md` -- the covjson-msgspec #65 worked example, problems to
  solutions to reasoning, that this skill was distilled from.
