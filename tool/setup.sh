#!/usr/bin/env bash
#
# One-shot bootstrap: takes a fresh clone of this template to a compile-ready,
# runnable state. Idempotent — safe to re-run anytime your tree needs a refresh.
#
# It chains the steps documented in the README Quick Start and the iOS one-time
# setup note: submodules, FVM SDK, disabling Swift Package Manager (macOS),
# dependencies, code generation, backend deps, and the pre-push hook.
#
# Usage: tool/setup.sh [options]
#   --no-hooks      Don't enable the .githooks pre-push gate (enabled by default).
#   --no-codegen    Skip build_runner (dep-only refresh).
#   --no-backend    Skip fetching Go backend dependencies.
#   -h, --help      Show this help and exit.
#
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backend_dir="$repo_root/simple_backend_server"

# --- options ----------------------------------------------------------------
enable_hooks=1
run_codegen=1
setup_backend=1

usage() {
  # Print the comment header above (between the shebang and `set -euo`).
  sed -n '3,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-hooks) enable_hooks=0 ;;
    --no-codegen) run_codegen=0 ;;
    --no-backend) setup_backend=0 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "✖ Unknown option: $1" >&2
      echo "  Run 'tool/setup.sh --help' for usage." >&2
      exit 1
      ;;
  esac
  shift
done

cd "$repo_root"

# Prefer the FVM-pinned SDK (this repo pins Flutter via .fvmrc); fall back to a
# plain toolchain if FVM is not installed. Mirrors .githooks/pre-push.
if command -v fvm >/dev/null 2>&1; then
  has_fvm=1
  dart() { fvm dart "$@"; }
  flutter() { fvm flutter "$@"; }
else
  has_fvm=0
fi

# --- 1. preflight / doctor --------------------------------------------------
echo "▶ setup: checking required tooling…"

if ! command -v git >/dev/null 2>&1; then
  echo "✖ git not found in PATH. Install git and retry." >&2
  exit 1
fi

if ! command -v dart >/dev/null 2>&1 || ! command -v flutter >/dev/null 2>&1; then
  echo "✖ Missing required tooling: dart/flutter not found in PATH." >&2
  echo "  Install FVM (recommended — https://fvm.app) or the Flutter SDK," >&2
  echo "  then retry. This template pins Flutter $(cat .fvmrc | grep -o '[0-9.]*') via .fvmrc." >&2
  exit 1
fi

if [[ "$has_fvm" -eq 0 ]]; then
  echo "  ⚠ fvm not found — using the Flutter SDK on PATH. Versions may differ" >&2
  echo "    from the pinned .fvmrc ($(cat .fvmrc | grep -o '[0-9.]*'))." >&2
fi

if ! command -v go >/dev/null 2>&1; then
  echo "  ⚠ go not found — the companion backend won't run until Go is installed." >&2
fi
if ! command -v node >/dev/null 2>&1; then
  echo "  ⚠ node not found — only needed for the optional firebase MCP server." >&2
fi
echo "✓ tooling OK"

# --- 2. submodules ----------------------------------------------------------
echo "▶ setup: syncing git submodules (backend)…"
git submodule update --init --recursive
echo "✓ submodules ready"

# --- 3. FVM SDK -------------------------------------------------------------
if [[ "$has_fvm" -eq 1 ]]; then
  if [[ ! -d "$repo_root/.fvm/flutter_sdk" ]]; then
    echo "▶ setup: installing the pinned Flutter SDK (fvm install)…"
    fvm install
    echo "✓ Flutter SDK installed"
  else
    echo "✓ Flutter SDK already installed (.fvm/flutter_sdk)"
  fi
fi

# --- 4. iOS one-time: disable Swift Package Manager (macOS only) ------------
# Firebase needs an iOS 15 deployment target, but Flutter 3.44 hardcodes the
# SPM-generated package to 13.0 and two plugins lack SPM support — so this
# project must build via CocoaPods. The setting is machine-global, so every
# machine runs it once. See CLAUDE.md.
if [[ "$(uname)" == "Darwin" ]]; then
  echo "▶ setup: disabling Swift Package Manager (CocoaPods required on iOS)…"
  flutter config --no-enable-swift-package-manager >/dev/null
  echo "✓ SPM disabled"
fi

# --- 5. dependencies --------------------------------------------------------
echo "▶ setup: installing Dart/Flutter dependencies (pub get)…"
flutter pub get
echo "✓ dependencies installed"

# --- 6. code generation -----------------------------------------------------
# Generated files (*.g.dart, *.freezed.dart, etc.) are git-ignored, so a fresh
# clone won't compile until they're produced.
if [[ "$run_codegen" -eq 1 ]]; then
  echo "▶ setup: generating code (build_runner)…"
  dart run build_runner build --delete-conflicting-outputs
  echo "✓ code generated"
else
  echo "• skipping code generation (--no-codegen) — the tree won't compile" \
    "until you run build_runner."
fi

# --- 7. backend dependencies ------------------------------------------------
if [[ "$setup_backend" -eq 1 ]]; then
  if command -v go >/dev/null 2>&1 && [[ -f "$backend_dir/go.mod" ]]; then
    echo "▶ setup: fetching backend Go dependencies…"
    (cd "$backend_dir" && go mod download)
    echo "✓ backend dependencies ready"
  else
    echo "• skipping backend deps (go missing or submodule empty)."
  fi
fi

# --- 8. git hooks (opt-in, default on) --------------------------------------
if [[ "$enable_hooks" -eq 1 ]]; then
  current_hooks_path="$(git config --get core.hooksPath || true)"
  if [[ "$current_hooks_path" != ".githooks" ]]; then
    echo "▶ setup: enabling the pre-push hook (git config core.hooksPath)…"
    git config core.hooksPath .githooks
    echo "✓ pre-push hook enabled (bypass once with: git push --no-verify)"
  else
    echo "✓ pre-push hook already enabled"
  fi
fi

# --- 9. Firebase reminder ---------------------------------------------------
if [[ ! -f "$repo_root/android/app/google-services.json" ]] ||
  [[ ! -f "$repo_root/ios/Runner/GoogleService-Info.plist" ]]; then
  echo "• Firebase config is git-ignored and missing. The app builds with"
  echo "  placeholders, but for real Firebase run 'flutterfire configure' and"
  echo "  drop google-services.json / GoogleService-Info.plist into place."
fi

# --- 10. summary ------------------------------------------------------------
fvm_prefix=""
[[ "$has_fvm" -eq 1 ]] && fvm_prefix="fvm "
cat <<EOF

✓ Setup complete. Next steps:

  # start the local backend (in another terminal)
  cd simple_backend_server && go run .        # → http://localhost:8080

  # run the app
  ${fvm_prefix}flutter run

EOF
