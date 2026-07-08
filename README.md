# claude-skills

Personal [Claude Code](https://claude.com/claude-code) skills, versioned here so
they're durable and portable across machines, and symlinked into `~/.claude/skills/`
so edits in this repo are live immediately.

## Skills

- **[plumb](plumb/SKILL.md)** -- a structural / design-integrity review and
  design-time guide. Reviews a diff, plan, or design for *shape* (are outcomes
  modeled as values? do names encode shape? is it decoupled?), at the altitude
  above `ponytail-review` (over-engineering) and `code-review` (bugs). Principles
  are called *soundings*; the all-clear is "Plumb is true." **Status: work in
  progress**, a draft superset of candidate soundings; see
  [plumb/REFINEMENT.md](plumb/REFINEMENT.md) for the tightening plan and
  [plumb/LANDSCAPE.md](plumb/LANDSCAPE.md) for prior art & neighboring skills.

### Python CI

Narrow, single-purpose skills for a Python library's GitHub CI. Kept as distinct
skills (not one broad "python-ci" skill) so each has a sharp trigger; if the
family grows, they can be bundled into a distributable plugin later.

- **[uv-minimum-versions](uv-minimum-versions/SKILL.md)** -- choose and *verify*
  a library's dependency lower bounds (floors) as a deliberate, tested
  compatibility contract: the floor is the lowest version that provides the APIs
  you use *and* ships a wheel on your Python floor, proven by a blocking `uv
  --resolution lowest-direct` CI leg on the floor Python. Covers the four traps
  (wheels vs `requires-python`; siblings pinning a dep up; "arbitrary" is not
  "lower it"; lockfile churn) and the Dependabot `lockfile-only` / ADR policy
  layer. Distilled from
  [uv-minimum-versions/case-study.md](uv-minimum-versions/case-study.md)
  (covjson-msgspec #65).

## Case studies

Worked examples the skills were distilled from.

- **[temporal-conversion](case-studies/temporal-conversion.md)** -- the design
  iteration log (covjson-msgspec #12) that seeded plumb. A visual version is
  published as a Claude artifact; the HTML source lives beside the markdown for
  redeploying or editing.

## How it's wired

Each skill lives in its own directory (`<skill>/SKILL.md`) and is symlinked into
the machine-local skills directory:

```sh
ln -s "$PWD/plumb" ~/.claude/skills/plumb
```

Editing `plumb/SKILL.md` in this repo *is* editing the live skill. Reload Claude
Code to pick up a newly-added skill.

## Setup on a new machine

```sh
git clone <this-repo> ~/src/chuckwondo/claude-skills
cd ~/src/chuckwondo/claude-skills
mkdir -p ~/.claude/skills
ln -s "$PWD/plumb" ~/.claude/skills/plumb
ln -s "$PWD/uv-minimum-versions" ~/.claude/skills/uv-minimum-versions
```

Once a skill stabilizes, it can graduate to a distributable Claude Code **plugin**
(a git repo + manifest, installable via a marketplace) for one-command install and
sharing.
