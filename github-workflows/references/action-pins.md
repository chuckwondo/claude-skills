# Bundled Action Pin Snapshot

Verified `tag -> commit SHA` mappings for every action used by this skill's
templates, resolved live from the GitHub API. Use these when network access
is unavailable at generation time, so workflows are SHA-pinned even offline.
They may lag the latest release; once Dependabot is configured for the
`github-actions` ecosystem (see `references/security.md`), it will bump both
the SHAs and the tag comments automatically.

**Snapshot date: 2026-06-11.** If you have network access, prefer live
resolution (see SKILL.md) over this table.

| Action | Tag | Commit SHA |
|---|---|---|
| actions/checkout | v6.0.3 | df4cb1c069e1874edd31b4311f1884172cec0e10 |
| astral-sh/setup-uv | v8.2.0 | fac544c07dec837d0ccb6301d7b5580bf5edae39 |
| actions/upload-artifact | v7.0.1 | 043fb46d1a93c77aae656e7c1c64a875d1fc6a0a |
| actions/download-artifact | v8.0.1 | 3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c |
| pypa/gh-action-pypi-publish | v1.14.0 | cef221092ed1bacb1cc03d23a2d87d1d172e277b |
| github/codeql-action | v4.36.2 | 8aad20d150bbac5944a9f9d289da16a4b0d87c1e |
| actions/dependency-review-action | v5.0.0 | a1d282b36b6f3519aa1f3fc636f609c47dddb294 |
| actions/stale | v10.3.0 | eb5cf3af3ac0a1aa4c9c45633dd1ae542a27a899 |
| amannn/action-semantic-pull-request | v6.1.1 | 48f256284bd46cdaab1048c3721360e808335d50 |
| actions/labeler | v6.1.0 | f27b608878404679385c85cfa523b85ccb86e213 |

Example usage (SHA first, tag as a trailing comment so humans and Dependabot
can read the version):

```yaml
- uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
```

## Special case: github/codeql-action

The `releases/latest` endpoint for `github/codeql-action` returns CodeQL
*bundle* tags (`codeql-bundle-vX.Y.Z`), not action version tags. When
resolving live, list the action's own tags instead:

```bash
TAG=$(gh api 'repos/github/codeql-action/git/matching-refs/tags/v4.' --jq '.[-1].ref' | sed 's|refs/tags/||')
SHA=$(gh api "repos/github/codeql-action/commits/$TAG" --jq .sha)
```

Both `init` and `analyze` are subpaths of the same repository and share one
pin.
