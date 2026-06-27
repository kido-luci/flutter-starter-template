#!/usr/bin/env bash
#
# Bootstrap the GitHub Actions secrets/variables that
# .github/workflows/release.yml needs to deploy to the App Store and Google
# Play, pushing them with the `gh` CLI so you configure them once instead of
# pasting ~15 values into Settings → Secrets by hand.
#
# Targets the repo `gh` is pointed at (override with --repo owner/name). Pick a
# platform with --platform ios|android|both (default both). Re-runnable: setting
# a secret again just overwrites it. Leave any prompt blank to skip that entry
# (an optional secret, or one you already set). Nothing is written to disk —
# file inputs are read and piped straight to `gh`.
#
# Usage: tool/ci-secrets-setup.sh [--repo owner/name] [--platform ios|android|both]
set -euo pipefail

repo=""
platform="both"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="${2:?--repo needs owner/name}"; shift 2 ;;
    --platform) platform="${2:?--platform needs ios|android|both}"; shift 2 ;;
    -h|--help) sed -n '3,14p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'; exit 0 ;;
    *) echo "error: unknown argument '$1' (try --help)" >&2; exit 1 ;;
  esac
done

case "$platform" in ios|android|both) ;; *)
  echo "error: --platform must be ios, android, or both" >&2; exit 1 ;;
esac

command -v gh >/dev/null 2>&1 || {
  echo "error: GitHub CLI (gh) not found — see https://cli.github.com" >&2
  exit 1
}
gh auth status >/dev/null 2>&1 || {
  echo "error: gh is not authenticated — run 'gh auth login' first" >&2
  exit 1
}

if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi
echo "Target repo: $repo"
echo "Leave a prompt blank to skip it."
echo

# A repository variable (non-secret, e.g. a bundle-id base).
var_from_input() {  # NAME PROMPT
  local name="$1" prompt="$2" value
  read -r -p "  $prompt: " value || true
  if [[ -z "$value" ]]; then echo "  ↳ skipped $name"; return; fi
  gh variable set "$name" --repo "$repo" --body "$value"
  echo "  ↳ set variable $name"
}

# A repository secret typed in directly. Pass a third arg of `hidden` to mask
# the input (passwords); omit it for non-sensitive ids stored as secrets.
secret_from_input() {  # NAME PROMPT [hidden]
  local name="$1" prompt="$2" hidden="${3:-}" value
  if [[ "$hidden" == hidden ]]; then
    read -rs -p "  $prompt: " value || true; echo
  else
    read -r -p "  $prompt: " value || true
  fi
  if [[ -z "$value" ]]; then echo "  ↳ skipped $name"; return; fi
  printf '%s' "$value" | gh secret set "$name" --repo "$repo"
  echo "  ↳ set secret $name"
}

# A repository secret read from a file. encode=base64 for binary blobs the
# workflow base64-decodes (keystore, plists); encode=raw for text stored
# verbatim (the Play service-account JSON).
secret_from_file() {  # NAME PROMPT base64|raw
  local name="$1" prompt="$2" encode="$3" path
  read -r -p "  $prompt: " path || true
  path="${path/#\~/$HOME}"
  if [[ -z "$path" ]]; then echo "  ↳ skipped $name"; return; fi
  if [[ ! -f "$path" ]]; then
    echo "  ↳ error: no file at '$path' — skipped $name" >&2; return
  fi
  if [[ "$encode" == base64 ]]; then
    base64 < "$path" | gh secret set "$name" --repo "$repo"
  else
    gh secret set "$name" --repo "$repo" < "$path"
  fi
  echo "  ↳ set secret $name (from $path)"
}

if [[ "$platform" == both || "$platform" == android ]]; then
  echo "Android → Google Play"
  var_from_input    ANDROID_PACKAGE_NAME_BASE    "Base applicationId (e.g. com.acme.app)"
  secret_from_file  ANDROID_GOOGLE_SERVICES_JSON "Path to google-services.json" base64
  secret_from_file  ANDROID_KEYSTORE_BASE64      "Path to the upload keystore (.jks)" base64
  secret_from_input ANDROID_KEYSTORE_PASSWORD    "Keystore password" hidden
  secret_from_input ANDROID_KEY_PASSWORD         "Key password" hidden
  secret_from_input ANDROID_KEY_ALIAS            "Key alias"
  secret_from_file  PLAY_STORE_JSON_KEY          "Path to the Play service-account JSON" raw
  echo
fi

if [[ "$platform" == both || "$platform" == ios ]]; then
  echo "iOS → App Store"
  var_from_input    IOS_BUNDLE_ID_BASE                 "Base bundle id (e.g. com.acme.app)"
  secret_from_input APPLE_TEAM_ID                      "Apple Developer Team ID"
  secret_from_input APP_STORE_CONNECT_API_KEY_ID       "App Store Connect API key id"
  secret_from_input APP_STORE_CONNECT_API_ISSUER_ID    "App Store Connect API issuer id"
  secret_from_file  APP_STORE_CONNECT_API_KEY_CONTENT  "Path to the AuthKey_*.p8" base64
  secret_from_file  IOS_GOOGLE_SERVICE_INFO_PLIST      "Path to GoogleService-Info.plist" base64
  secret_from_input MATCH_GIT_URL                      "match signing-assets repo URL"
  secret_from_input MATCH_PASSWORD                     "match encryption passphrase" hidden
  secret_from_input MATCH_GIT_BASIC_AUTHORIZATION      "match HTTPS auth, base64 user:token (blank for SSH)" hidden
  echo
fi

echo "Done. The release workflow's preflight step lists anything still missing."
