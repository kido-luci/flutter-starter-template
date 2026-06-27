# Android Fastlane — Google Play

A scaffold for building each flavor (`dev` / `staging` / `prod`) as a signed
app bundle and uploading it to Google Play. All account-specific values live in
`fastlane/.env` and `android/key.properties`, both git-ignored, so this template
ships with **no secrets and nothing to scrub** before reuse on a new project.

**Prerequisites:** a paid Google Play Developer account, and an app created in
the Play Console for each flavor's applicationId you intend to ship.

## One-time setup

1. **Ruby + bundler.** The repo pins Ruby via `.ruby-version` (3.2.2); install
   it with `rbenv`/`asdf`. `Gemfile.lock` is committed, so:

   ```bash
   cd android
   bundle install
   ```

2. **Release signing.** Generate an upload keystore and wire it up — without
   this, release builds fall back to the *debug* keystore and Play will reject
   them:

   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   cp key.properties.example key.properties   # then fill in paths/passwords
   ```

   `android/app/build.gradle.kts` loads `key.properties` automatically when
   present.

3. **Play service account.** In the Google Play Console (*Users and
   permissions*), grant a Google Cloud service account release access, download
   its JSON key, and store it **outside the repo**.

4. **Configure `.env`.**

   ```bash
   cp fastlane/.env.example fastlane/.env
   # set PLAY_STORE_JSON_KEY_PATH to the JSON key, and ANDROID_PACKAGE_NAME_BASE
   ```

5. **First upload must be manual.** Google Play requires the very first build
   of a package to be uploaded by hand in the Console; fastlane can take over
   for every release after that.

## Usage

```bash
cd android
bundle exec fastlane beta flavor:prod       # prod → Play internal track
bundle exec fastlane beta flavor:staging
bundle exec fastlane beta flavor:dev
```

The `beta` lane: builds with `flutter build appbundle --flavor <f>
--build-number <n>`, then uploads the `.aab` to the flavor's Play track as a
**draft** release. Change `release_status` to `"completed"` in the `Fastfile`
to publish straight to the track's testers, or pass `track:` to target a
different track (`bundle exec fastlane beta flavor:prod track:beta`).

### Build numbers

Play rejects a duplicate or non-increasing `versionCode`. The lane sets it
from, in order: a `build_number:` arg, the `BUILD_NUMBER` env var (CI sets
this), else the git commit count. Pass one explicitly when needed:

```bash
bundle exec fastlane beta flavor:prod build_number:42
```

## CI

`.github/workflows/release.yml` runs this lane on `ubuntu-latest` (no Xcode
needed) on tag push / manual dispatch, with `FLUTTER_CMD=flutter` and
`BUILD_NUMBER` from the run number. The workflow restores `key.properties`, the
keystore, `google-services.json`, and the Play key file from secrets, then runs
the lane. Expected repository secrets/vars:

| Name | Kind | Purpose |
|---|---|---|
| `ANDROID_PACKAGE_NAME_BASE` | var | Base applicationId |
| `PLAY_STORE_JSON_KEY` | secret | Play service-account JSON (raw contents) |
| `ANDROID_KEYSTORE_BASE64` | secret | base64 of the upload keystore |
| `ANDROID_KEYSTORE_PASSWORD` | secret | Keystore password |
| `ANDROID_KEY_PASSWORD` | secret | Key password |
| `ANDROID_KEY_ALIAS` | secret | Key alias |
| `ANDROID_GOOGLE_SERVICES_JSON` | secret | base64 of `google-services.json` (git-ignored) |

From the repository root, push all of these in one shot with
`tool/ci-secrets-setup.sh --platform android` instead of pasting them into the
Settings UI by hand. The workflow also fails fast at the top of the job if any
required secret or variable is missing, naming exactly which.

## Troubleshooting (first real run)

The lane is wired but has not been run end-to-end against a real account. Watch
for these on the first release:

- **"APK/AAB not allowed" / package not found** — you skipped the manual first
  upload (setup step 5). Upload one build by hand, then retry.
- **Upload succeeds but nothing reaches testers** — releases go up as `draft`
  by default. Change `release_status` to `"completed"` in the `Fastfile`, or
  promote the draft in the Console.
- **"Version code already used"** — a re-run of the same CI workflow reuses
  `github.run_number`. Pass `build_number:` explicitly or bump the run.
- **Bundle path not found** — the lane expects
  `build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab`; if your
  Gradle variant naming differs, adjust the `aab` path in the `Fastfile`.
