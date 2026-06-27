# iOS Fastlane — TestFlight

A scaffold for building each flavor (`dev` / `staging` / `prod`) and uploading
it to TestFlight. All account-specific values live in `fastlane/.env`, which is
git-ignored, so this template ships with **no secrets and nothing to scrub**
before reuse on a new project.

Signing uses [`match`](https://docs.fastlane.tools/actions/match/): the
distribution certificate and provisioning profiles are stored (encrypted) in a
private git repo and fetched at build time, so every machine and CI runner
signs identically.

**Prerequisites:** a paid Apple Developer Program membership, and a macOS
machine with Xcode (App Store builds can only be produced on macOS).

## One-time setup

1. **Ruby + bundler.** The repo pins Ruby via `.ruby-version` (3.2.2); install
   it with `rbenv`/`asdf`. `Gemfile.lock` is committed, so:

   ```bash
   cd ios
   bundle install
   ```

2. **App Store Connect API key.** In App Store Connect → *Users and Access →
   Integrations → App Store Connect API*, create a key with *App Manager* (or
   higher) access and download the `AuthKey_XXXX.p8` (you can only download it
   once). Keep the `.p8` outside the repo.

3. **App registration.** Make sure the app exists in App Store Connect for each
   flavor you ship. The lane derives the id from `IOS_BUNDLE_ID_BASE` plus the
   flavor suffix (`.dev`, `.staging`, none for prod).

4. **Configure `.env`.**

   ```bash
   cp fastlane/.env.example fastlane/.env
   # fill in the values; for the API key:
   base64 -i /path/to/AuthKey_XXXX.p8 | pbcopy   # paste as APP_STORE_CONNECT_API_KEY_CONTENT
   ```

5. **Initialize match.** Create an empty **private** git repo for the signing
   assets, set `MATCH_GIT_URL` + `MATCH_PASSWORD` in `.env`, then generate the
   cert + profiles once (this populates the repo):

   ```bash
   bundle exec fastlane match appstore
   ```

## Usage

```bash
cd ios
bundle exec fastlane beta flavor:prod      # prod → TestFlight
bundle exec fastlane beta flavor:staging
bundle exec fastlane beta flavor:dev
```

The `beta` lane: fetches signing assets with `match`, compiles with
`flutter build ios --no-codesign --flavor <f> --build-number <n>`, archives +
signs via `build_app` (manual signing with the match profile), uploads dSYMs to
Firebase Crashlytics, then uploads the build to TestFlight.

### Build numbers

TestFlight rejects a duplicate or non-increasing build number. The lane sets it
from, in order: a `build_number:` arg, the `BUILD_NUMBER` env var (CI sets
this), else the git commit count. Pass one explicitly when needed:

```bash
bundle exec fastlane beta flavor:prod build_number:42
```

## CI

`.github/workflows/release.yml` runs this lane on a macOS runner (Xcode
required) on tag push / manual dispatch, with `FLUTTER_CMD=flutter` and
`BUILD_NUMBER` from the run number. It expects these repository secrets/vars:

| Name | Kind | Purpose |
|---|---|---|
| `IOS_BUNDLE_ID_BASE` | var | Base bundle id |
| `APPLE_TEAM_ID` | secret | Developer Team ID |
| `APP_STORE_CONNECT_API_KEY_ID` | secret | API key id |
| `APP_STORE_CONNECT_API_ISSUER_ID` | secret | API issuer id |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | secret | base64 of the `.p8` |
| `MATCH_GIT_URL` | secret | Signing-assets repo URL |
| `MATCH_PASSWORD` | secret | match encryption passphrase |
| `MATCH_GIT_BASIC_AUTHORIZATION` | secret | base64 `user:token` for HTTPS clone (omit for SSH) |
| `IOS_GOOGLE_SERVICE_INFO_PLIST` | secret | base64 of `GoogleService-Info.plist` (git-ignored) |

From the repository root, push all of these in one shot with
`tool/ci-secrets-setup.sh --platform ios` instead of pasting them into the
Settings UI by hand. The workflow also fails fast at the top of the job if any
required secret or variable is missing, naming exactly which.

## Troubleshooting (first real run)

The lane is wired but has not been run end-to-end against a real account. Watch
for these on the first release:

- **"No profile for bundle id …" during export** — the lane expects match to
  name profiles `match AppStore <bundle_id>`. If yours differ, fix the
  `provisioningProfiles` map in `build_app`, or re-run
  `bundle exec fastlane match appstore` to (re)create them.
- **match can't access the certs repo on CI** — provide
  `MATCH_GIT_BASIC_AUTHORIZATION` (base64 `user:token`) for HTTPS, or a deploy
  key for SSH.
- **dSYM upload fails / `upload-symbols` not found** — point
  `CRASHLYTICS_UPLOAD_SYMBOLS_BIN` at the binary in your Pods. This step is
  best-effort and won't fail the lane's upload.
- **Xcode/Flutter mismatch on the runner** — the workflow uses `macos-15`; pin a
  specific Xcode version there if the default is incompatible with Flutter 3.44.
- **"Version already used"** — a re-run of the same CI workflow reuses
  `github.run_number`. Pass `build_number:` explicitly or bump the run.
