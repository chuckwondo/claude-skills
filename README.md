# claude-skills

Personal [Claude Code](https://claude.com/claude-code) skills, versioned here so
they're durable and portable across machines, and symlinked into
`~/.config/claude/skills/` so edits in this repo are live immediately.

## Skills

- **[plumb](plumb/SKILL.md)** -- a structural / design-integrity review and
  design-time guide. Reviews a diff, plan, or design for *shape* (are outcomes
  modeled as values? do names encode shape? is it decoupled?), at the altitude
  above `ponytail-review` (over-engineering) and `code-review` (bugs). Principles
  are called *soundings*; the all-clear is "Plumb is true." The sounding set has
  converged to **10 grouped soundings (19 facets)**; see
  [plumb/EXAMPLES.md](plumb/EXAMPLES.md) for a worked example per facet and
  [plumb/REFERENCES.md](plumb/REFERENCES.md) for the verified bibliography.

### Python CI

Narrow, single-purpose skills for a Python library's GitHub CI. Kept as distinct
skills (not one broad "python-ci" skill) so each has a sharp trigger; if the
family grows, they can be bundled into a distributable plugin later.

- **[github-workflows](github-workflows/SKILL.md)** -- generate GitHub Actions
  workflows for a Python/uv project that a security-conscious reviewer would
  approve unchanged: CI (test/lint/typecheck), release via PyPI Trusted
  Publishing, security scanning (CodeQL, dependency review, Dependabot), and
  repo hygiene. Actions are pinned to commit SHAs, `permissions` blocks are
  least-privilege, releases use OIDC rather than long-lived secrets, and shell
  steps are injection-safe. Output is validated with actionlint and zizmor.
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

Worked examples the skills were distilled from. Each lives beside the skill it
belongs to.

- **[temporal-conversion](plumb/case-studies/temporal-conversion.md)** (plumb):
  the design iteration log (covjson-msgspec #12) that seeded plumb. A visual
  version is published as a Claude artifact; the HTML source lives beside the
  markdown for redeploying or editing.
- **[resolve-the-repair](plumb/case-studies/resolve-the-repair.md)** (plumb):
  how the same "name the repair" test placed one check in two tiers
  (covjson-msgspec #147), and why resolving the value, not counting the repairs,
  decided it.

## How it's wired

Each skill lives in its own directory (`<skill>/SKILL.md`) and is symlinked into
the machine-local skills directory, `~/.config/claude/skills/` (the location
follows `CLAUDE_CONFIG_DIR`). The symlinks themselves are managed by chezmoi in
`chuckwondo/dotfiles`, which stores them as `symlink_<skill>` entries rather
than copying any content, so this repo stays the single source of truth.

Editing `plumb/SKILL.md` in this repo *is* editing the live skill. Reload Claude
Code to pick up a newly-added skill.

## Setup on a new machine

```sh
git clone <this-repo> ~/src/chuckwondo/claude-skills
chezmoi apply
```

`chezmoi apply` creates all three symlinks under `~/.config/claude/skills/`.
Clone this repo first, or they will dangle until you do.

To add a new skill to the arrangement:

```sh
ln -s "$PWD/<skill>" ~/.config/claude/skills/<skill>
chezmoi add ~/.config/claude/skills/<skill>
```

Once a skill stabilizes, it can graduate to a distributable Claude Code
**plugin** (a git repo + manifest, installable via a marketplace) for
one-command install and sharing.
