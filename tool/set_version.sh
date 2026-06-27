#!/usr/bin/env bash
#
# Stamp a version onto pubspec.yaml. The release workflow calls this on a tag
# push so the published version name comes from the git tag (e.g. v1.2.3 →
# 1.2.3), with the CI run number as the build number. Run from the repo root.
#
# Usage: tool/set_version.sh <version> [build-number]
#   tool/set_version.sh 1.2.3 42   → "version: 1.2.3+42"
#   tool/set_version.sh 1.2.3      → "version: 1.2.3"
set -euo pipefail

version="${1:?usage: tool/set_version.sh <version> [build-number]}"
build="${2:-}"

# Basic shape check: MAJOR.MINOR.PATCH with an optional pre-release/build suffix.
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  echo "error: '$version' is not a valid version (expected MAJOR.MINOR.PATCH…)" >&2
  exit 1
fi

new="$version"
[[ -n "$build" ]] && new="$version+$build"

# Rewrite the top-level `version:` line (column 0, so dependency versions — which
# are indented — are never touched). awk writes $new literally, so a version
# containing sed-special characters (`&` or `\`) can't corrupt the line.
tmp="$(mktemp)"
awk -v v="$new" '!seen && /^version: / { print "version: " v; seen = 1; next } { print }' \
  pubspec.yaml >"$tmp" && mv "$tmp" pubspec.yaml

echo "pubspec.yaml version → ${new}"
