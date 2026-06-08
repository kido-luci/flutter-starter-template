# Screenshots

The PNGs here back the gallery in the root [`README.md`](../../README.md#-screenshots).

| File                  | Screen                          |
|-----------------------|---------------------------------|
| `sign_in.png`         | Sign-in screen                  |
| `home.png`            | Home dashboard                  |
| `bookmarks.png`       | Bookmarks list                  |
| `bookmark_detail.png` | Bookmark detail                 |
| `collections.png`     | Collections list                |
| `profile_dark.png`    | Profile, true-black dark theme  |

## Regenerating them

They are captured automatically by an `integration_test` driven through a
booted iOS Simulator, signed in as a pre-seeded demo user, so they stay in sync
with the real UI. Three steps:

```bash
# 1. Start the dev backend (separate terminal)
cd simple_backend_server && go run .

# 2. Seed the demo account (demo / demo1234) with bookmarks + collections
tool/seed_demo.sh

# 3. Capture — writes the six PNGs into this folder
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=FLAVOR=dev \
  -d <ios-simulator-id>      # from `fvm flutter devices`
```

The app stores its data (and the offline-first sync cursor) locally, so if a
prior run left a stale cursor the demo rows won't pull. Reset with
`xcrun simctl uninstall booted com.luci-studio.flutterStarterTemplate.dev`
before re-capturing.
