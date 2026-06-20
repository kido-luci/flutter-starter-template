#!/usr/bin/env bash
#
# Generate build_runner output across the workspace.
#
# Feature packages under packages/features/<name> own internal codegen
# (retrofit / json_serializable / freezed part files) that is git-ignored and
# regenerated on demand. The app-root build_runner does NOT generate code inside
# path-dependency packages, so each feature package must be built individually —
# otherwise the app fails to compile against missing `part '*.g.dart'` files.
#
# Build the feature packages first, then the app root, so the app's analysis and
# build see the generated parts. The ObjectBox binding under packages/database is
# a tracked exception (committed, holds stable schema UIDs) and is regenerated +
# verified separately in CI, so it is not built here.
#
# Prefers the FVM-pinned SDK when `fvm` is installed (this template pins Flutter
# via .fvmrc); otherwise falls back to the `dart` on PATH (the action-managed SDK
# in CI). Safe to call from any directory — it resolves the repo root itself.
#
# The fvm shim lives here, not only in setup.sh: setup.sh's dart()/flutter()
# functions don't propagate to this child process, and this script is also run
# standalone (e.g. by `fst add-feature`).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if command -v fvm >/dev/null 2>&1; then
  dart() { fvm dart "$@"; }
fi

run_pkg() {
  local dir="$1"
  echo "::group::build_runner: $dir"
  (cd "$dir" && dart run build_runner build --delete-conflicting-outputs)
  echo "::endgroup::"
}

for pkg in packages/features/*/; do
  [ -f "${pkg}pubspec.yaml" ] || continue
  grep -q 'build_runner' "${pkg}pubspec.yaml" || continue
  run_pkg "${pkg%/}"
done

echo "::group::build_runner: app root"
dart run build_runner build --delete-conflicting-outputs
echo "::endgroup::"

# The micro-package DI module (di.module.dart) is generated in a style that does
# not match `dart format`, so normalize it here — otherwise the formatting guard
# rejects the freshly generated output. Generated *.g.dart / *.freezed.dart /
# *.config.dart already come out format-clean and are left untouched.
module_files=$(find packages -path '*/.dart_tool' -prune -o -name 'di.module.dart' -print)
if [ -n "$module_files" ]; then
  echo "::group::dart format: generated DI modules"
  # shellcheck disable=SC2086
  dart format $module_files
  echo "::endgroup::"
fi
