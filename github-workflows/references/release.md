# Release Workflow (PyPI Trusted Publishing)

Target file: `.github/workflows/release.yml`

The build/publish job split is a security boundary, not a style choice: the
build job runs the project's own code (`uv build` executes the build
backend) with no privileges, while the publish job holds the OIDC
(OpenID Connect) `id-token: write` permission but runs no project code --
it only downloads the built artifact and uploads it. A compromised build
dependency therefore never executes in a job that can mint a PyPI token.

## Template

```yaml
# Release: on a vX.Y.Z tag, build the distributions and publish them to PyPI
# via Trusted Publishing (OIDC). Build and publish run as separate jobs so
# project code never executes in the job that can mint a PyPI token.
name: Release

on:
  push:
    tags: ["v*"]

permissions: {}

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    permissions:
      contents: read
    steps:
      - name: Check out repository
        uses: actions/checkout@{SHA} # {TAG}
        with:
          persist-credentials: false
      - name: Set up uv
        uses: astral-sh/setup-uv@{SHA} # {TAG}
      - name: Check tag matches project version
        env:
          # Tag names are attacker-influenced; pass via env, never inline.
          TAG: ${{ github.ref_name }}
        run: |
          VERSION="$(uv version --short)"
          if [ "$TAG" != "v$VERSION" ]; then
            echo "::error::Tag $TAG does not match pyproject.toml version $VERSION"
            exit 1
          fi
      - name: Build distributions
        run: uv build --quiet
      - name: Upload distributions
        uses: actions/upload-artifact@{SHA} # {TAG}
        with:
          name: dist
          path: dist/

  publish:
    needs: build
    runs-on: ubuntu-latest
    timeout-minutes: 10
    environment: pypi
    permissions:
      id-token: write
    steps:
      - name: Download distributions
        uses: actions/download-artifact@{SHA} # {TAG}
        with:
          name: dist
          path: dist/
      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@{SHA} # {TAG}
```

## Optional: GitHub Release with artifacts

If the user also wants a GitHub Release, add a third job (after `publish`,
or independent of it) rather than widening the publish job's permissions:

```yaml
  github-release:
    needs: build
    runs-on: ubuntu-latest
    timeout-minutes: 10
    permissions:
      contents: write
    steps:
      - name: Download distributions
        uses: actions/download-artifact@{SHA} # {TAG}
        with:
          name: dist
          path: dist/
      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
          TAG: ${{ github.ref_name }}
        run: gh release create "$TAG" dist/* --repo "$GITHUB_REPOSITORY" --generate-notes
```

Note `TAG` passes through `env:` -- tag names are attacker-influenced in
forks and must not be interpolated into `run:` directly.

## Required one-time setup (tell the user)

1. **PyPI**: project page -> Publishing -> "Add a new publisher" -> GitHub,
   with owner, repository name, workflow filename (`release.yml`), and
   environment name (`pypi`). For a first release of a brand-new package,
   use PyPI's "pending publisher" flow, which reserves the name.
2. **GitHub**: Settings -> Environments -> create `pypi`. Recommend adding
   required reviewers so a pushed tag cannot publish without a human
   approval, and restricting the environment to protected tags/branches.
3. Tag with `git tag vX.Y.Z && git push origin vX.Y.Z`. Remind the user to
   bump `version` in `pyproject.toml` and commit before tagging -- the
   build job's version check fails the release on mismatch, so a stale
   version is caught before anything reaches PyPI.
