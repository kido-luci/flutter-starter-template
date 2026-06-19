# `fst create` — feature selection, env URL, launcher icon (#1, #6, #4)

- **Date:** 2026-06-19
- **Status:** Approved (design) — batched decisions confirmed; implement to completion.
- **Scope:** template (markers in app shell + feature wiring) and `tool/cli`
- **Owner:** kido-luci
- **Builds on:** non-interactive `fst create` (0.4.0) + Firebase-optional (0.5.0).

## Goals (three gaps, sequenced #1 → #6 → #4)

1. **Feature selection** — let `fst create` scaffold without the demo content
   features (bookmarks, collections, notifications), excising them cleanly.
2. **Backend URL** — let the user set the staging/prod API base URL at create
   time instead of shipping the template placeholders.
3. **Launcher icon** — let the user pass an app icon that the CLI installs and
   generates from.

Default behaviour is unchanged in every case (keep all features, keep template
URLs, keep template icon), preserving backward compatibility.

---

## #1 — Feature selection

### Selectable set
Only the three demo content features are removable: **bookmarks, collections,
notifications**. `auth`, `home`, `profile`, `splash` are core (session,
redirects, shell, startup) and always kept.

### Dependency
`feature_bookmarks` imports `feature_collections` (master-detail widgets). If
`collections` is excluded but `bookmarks` is kept, the CLI **auto-excludes
bookmarks too** and logs a notice. (`profile`→`auth` is within the always-kept
core, so it never triggers.)

### CLI surface
- Interactive (no flag, not `--yes`): a multi-select "Features to include" with
  all three pre-selected; the excluded set = the three minus the selection.
- `--exclude-feature <name>` (repeatable; validated against the selectable set).
- `--yes` without the flag → exclude none (keep all).

### Mechanism — marker-based excision (template prep required)
Each removable region in the app shell / wiring is wrapped with block markers:

```
// fst:feature:<name>:start
…region…
// fst:feature:<name>:end
```

(`#` form in `pubspec.yaml`.) Regions to wrap, per feature:

- `pubspec.yaml` — the `workspace:` entry and the `feature_<name>` dependency.
- `lib/app/di/injection.dart` — the package import and the `ExternalModule(...)`.
- `lib/app/features.dart` — the package import, the `enabledFeatures` entry, and
  the `_<Name>Module` class.
- `lib/app/router.dart` — the package import, and (bookmarks, notifications only)
  the `TypedStatefulShellBranch` block and the typed route class(es).
- `lib/app/widgets/app_shell.dart` — (bookmarks, notifications only) the nav
  destination.

`collections` has no shell branch / nav entry (it surfaces inside bookmarks and
contributes routes via `enabledFeatures`), so it wraps fewer regions.

### CLI logic
For each excluded feature: apply the pure transform `removeFeatureRegions(content,
name)` to every wiring file (removes all `:start`..`:end` blocks for that name),
then delete `packages/features/<name>/`. Runs **before** `setup.sh` so codegen
(`router.g.dart`, DI) regenerates against the trimmed tree.

### Tests
- `removeFeatureRegions`: removes one block; leaves other features' blocks and
  unrelated lines; multiple blocks in one file; idempotent; no-op when absent.
- Dependency rule: excluding `collections` yields `{collections, bookmarks}`.
- Name validation: unknown feature → error.
- IO orchestration on a fixture tree (files trimmed + package dir deleted).

---

## #6 — Backend API base URL

### Behaviour
- Prompt/flag `--api-url <url>` for a single base URL applied to **staging and
  prod**; `dev` keeps `http://localhost:8080`. Timeouts unchanged.
- Blank / omitted → keep the template values (no change).
- `--yes` without the flag → keep template values.

### Mechanism
Pure transform `setApiBaseUrl(jsonContent, url)` rewrites the `API_BASE_URL`
value in an env JSON string (preserving formatting). Applied to
`env/staging.json` and `env/prod.json` only.

### Tests
`setApiBaseUrl` replaces the URL, preserves other keys/formatting, idempotent;
invalid (non-http) URL → error (validated before applying).

---

## #4 — Launcher icon

### Behaviour
- Optional flag `--icon <path>` (interactive: prompt, blank = skip).
- If provided: validate the file exists and is a PNG; copy it to
  `tool/launcher_icons/app_icon.png` and `app_icon_foreground.png`; run
  `dart run flutter_launcher_icons` (the config already exists in `pubspec.yaml`).
- If omitted: leave the template icon untouched.
- Splash is **out of scope** (no `flutter_native_splash` configured).

### Mechanism
Command-level IO (copy + process run); no pure transform needed. Runs after
`setup.sh` (needs dependencies resolved for `flutter_launcher_icons`).

### Tests
Path/PNG validation is a small pure helper (`isUsableIconPath`) — unit-tested.
The copy+generate step is exercised manually (needs the Flutter toolchain).

---

## Command flow (integration)

`fst create` resolves, in order: identity (existing) → Firebase (existing) →
**features to exclude** (new) → **API URL** (new) → **icon path** (new) →
summary → confirm. Excision + env rewrite happen after the existing rewrite,
before `setup.sh`; icon generation happens after `setup.sh`.

`--yes` defaults: keep all features, keep template URLs, no icon. Non-interactive
runs never block.

## Files touched

**Template:** `pubspec.yaml`, `lib/app/di/injection.dart`, `lib/app/features.dart`,
`lib/app/router.dart`, `lib/app/widgets/app_shell.dart` (add `fst:feature:*`
markers). No behavioural change — markers are comments.

**CLI (`tool/cli`):**
- `lib/src/rewrite/features.dart` — `removeFeatureRegions`, the dependency rule,
  `excludeFeatures(projectDir, names)` IO.
- `lib/src/rewrite/env.dart` — `setApiBaseUrl`.
- `lib/src/rewrite/icon.dart` — `isUsableIconPath` + install/generate IO.
- `lib/src/commands/create_command.dart` — new flags, prompts, summary lines,
  wiring of the three steps.
- new tests; `README.md`, `CHANGELOG.md`, `pubspec.yaml` (bump to 0.6.0).

## Ordering / risk

- Template markers must land on `main` before the CLI's excision works e2e
  (CLI clones `origin/main`); unit tests don't depend on this.
- `removeFeatureRegions` is marker-driven and idempotent — robust to formatting.
- Excising a nav-shell feature relies on the markers wrapping the *whole*
  `TypedStatefulShellBranch` + typed route block; the plan verifies the trimmed
  `router.dart` still parses and `router.g.dart` regenerates.

## Decisions defaulted (not separately asked)
- Exclude semantics via `--exclude-feature` (repeatable); interactive multi-select.
- `--api-url` applies to staging+prod only; dev stays localhost; timeouts kept.
- `--icon` PNG only; splash excluded; generation after setup.
- All three integrate with `--yes` (safe keep-all/keep-template defaults).
