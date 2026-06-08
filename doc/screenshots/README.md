# Screenshots

The PNGs here back the gallery in the root [`README.md`](../../README.md#-screenshots).

| File                   | Screen                          |
|------------------------|---------------------------------|
| `sign_in.png`          | Sign-in screen                  |
| `register.png`         | Register screen                 |
| `home.png`             | Home dashboard                  |
| `bookmarks.png`        | Bookmarks list                  |
| `create_bookmark.png`  | New-bookmark form               |
| `bookmark_detail.png`  | Bookmark detail                 |
| `notifications.png`    | Notifications / activity feed   |
| `profile.png`          | Profile (light theme)           |

## Regenerating them

Capture is driven by the committed `integration_test/screenshots_test.dart`
(plus `test_driver/integration_test.dart`) through a booted iOS Simulator,
signed in as a `demo` account, so the shots stay in sync with the real UI.

> The committed PNGs are framed Simulator-*window* grabs (device bezel +
> Dynamic Island, with the macOS title bar cropped). That framing is applied by
> a **local helper script that is intentionally not committed** — it relies on
> macOS Screen Recording permission and `screencapture`, which can't run in CI.
> The steps below reproduce the **app-surface** PNGs from a clean clone; framing
> them in the device bezel is an optional local extra.

1. **Start the dev backend** (separate terminal):

   ```bash
   cd simple_backend_server && go run .
   ```

2. **Create the `demo` account with a few bookmarks.** The capture signs in as
   `demo` / `demo1234`, so that account must exist with some content — add it
   through the app, or via the API:

   ```bash
   TOKEN=$(curl -s localhost:8080/api/auth/register \
     -d '{"username":"demo","password":"demo1234"}' \
     | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
   curl -s localhost:8080/api/bookmarks -H "Authorization: Bearer $TOKEN" \
     -d '{"title":"Flutter","url":"https://flutter.dev","description":"Google'\''s UI toolkit","tags":["flutter"],"image_urls":[],"video_url":""}'
   ```

3. **Capture** — writes the PNGs into this folder:

   ```bash
   fvm flutter drive \
     --driver=test_driver/integration_test.dart \
     --target=integration_test/screenshots_test.dart \
     --dart-define=API_BASE_URL=http://localhost:8080 \
     --dart-define=FLAVOR=dev \
     -d <ios-simulator-id>      # from `fvm flutter devices`
   ```

The app stores its bookmarks (and the offline-first sync cursor) locally, so if
the seeded rows don't appear, a prior run may have left a stale cursor. Reset by
reinstalling the app:
`xcrun simctl uninstall booted com.luci-studio.flutterStarterTemplate`.
