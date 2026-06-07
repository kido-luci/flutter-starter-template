# Screenshots

Drop captured PNGs here, then uncomment the gallery block in the root
[`README.md`](../../README.md#-screenshots) and delete the "coming soon"
placeholder.

Expected files (each ~240px wide, portrait phone frame):

| File                  | Screen                          |
|-----------------------|---------------------------------|
| `sign_in.png`         | Sign-in screen                  |
| `home.png`            | Home dashboard                  |
| `bookmarks.png`       | Bookmarks list                  |
| `bookmark_detail.png` | Bookmark detail                 |
| `collections.png`     | Collections list                |
| `profile_dark.png`    | Profile, true-black dark theme  |

Quick capture from a booted simulator:

```bash
xcrun simctl io booted screenshot doc/screenshots/home.png
```
