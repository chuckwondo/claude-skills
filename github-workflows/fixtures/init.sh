#!/usr/bin/env bash
# Create or remove the git repository inside each fixture.
#
#   ./init.sh            create the repos (before running evals)
#   ./init.sh --clean    remove them (before committing)
#
# The eval harness copies a fixture directory wholesale, .git included, so a
# fixture has to be a real repository at run time. Git cannot track a nested
# repository as anything but a gitlink, which would clone empty, so .git is
# never committed. A .gitignore does NOT suppress that detection: the only
# thing that works is the directory not being there.
#
# Both modes are idempotent.

set -euo pipefail

cd "$(dirname "$0")"

clean=false
[ "${1:-}" = "--clean" ] && clean=true

for fixture in */; do
  fixture="${fixture%/}"
  [ -d "$fixture" ] || continue

  if $clean; then
    if [ -d "$fixture/.git" ]; then
      rm -rf "${fixture:?}/.git"
      echo "clean  $fixture"
    else
      echo "skip   $fixture (not a repo)"
    fi
    continue
  fi

  if [ -d "$fixture/.git" ]; then
    echo "skip   $fixture (already a repo)"
    continue
  fi

  git -C "$fixture" init -q
  git -C "$fixture" add -A
  git -C "$fixture" -c user.name="fixture" -c user.email="fixture@localhost" \
    commit -q -m "initial"
  echo "init   $fixture"
done
