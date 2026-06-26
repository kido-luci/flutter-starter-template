# AGENTS.md

Guidance for AI coding agents (OpenCode, Codex, Claude, Cursor) working in
this repository. High-signal, repo-specific facts only — see the `README.md`
for the full narrative.

## Toolchain — Flutter is pinned via FVM

Flutter is pinned to **3.44.0** in `.fvmrc`. Always invoke Flutter and Dart
through FVM so the pinned SDK is used (CI and the pre-push hook do the same).

```bash
fvm flutter <command>
fvm dart <command>
```

If `.fvm/flutter_sdk` is missing, run `fvm install` once (or just run
`tool/setup.sh`, which does this plus pub get, codegen, backend deps, and the
pre-push hook in one idempotent pass).

## Common commands

```bash
fvm flutter pub get
fvm flutter run --flavor dev --dart-define-from-file=env/dev.json   # staging|prod likewise
fvm dart run build_runner build --delete-conflicting-outputs         # REQUIRED after clone / pub get
fvm dart run build_runner watch --delete-conflicting-outputs         # incremental
fvm flutter analyze
fvm dart format .
fvm dart fix --apply
```

### Tests — mind the golden tag

```bash
fvm flutter test --exclude-tags golden                    # root tests (CI does this)
fvm flutter test test/widget_test.dart                    # one file
fvm flutter test --name "signs in"                        # by name match
fvm flutter test --update-goldens --tags golden           # regenerate golden baselines (macOS only)
(cd packages/network && fvm flutter test --exclude-tags golden)   # one package's tests
```

Golden tests are tagged `golden` and **excluded in CI** (baselines are
generated on macOS, CI runs on Ubuntu). Running plain `fvm flutter test`
locally will execute goldens and may fail on non-macOS — prefer
`--exclude-tags golden` unless you're intentionally working on goldens.

### Local verification gate (CI parity) — run before pushing

```bash
fvm dart format .
fvm flutter analyze
fvm flutter test --exclude-tags golden
for package in packages/*; do
  if [ -d "$package/test" ]; then (cd "$package" && fvm flutter test --exclude-tags golden); fi
done
```

The pre-push hook (`.githooks/pre-push`) runs build_runner → `dart format` →
`flutter analyze` automatically once enabled: `git config core.hooksPath .githooks`.
Bypass in an emergency with `git push --no-verify`.

### E2E (integration tests)

```bash
tool/run_e2e.sh                # resets + starts backend, runs, tears down
tool/run_e2e.sh <device-id>    # target a specific device
```

Needs a booted **iOS Simulator** (only `ios/` ships `GoogleService-Info.plist`)
and the live Go backend. Not run in CI. Run before cutting a release.

## Architecture — Dart Pub Workspace

The root `lib/` is a thin **composition root** (routing, DI, Firebase
bootstrap, optional-feature wiring) and owns **no feature code**. There is no
`lib/features/` directory.

- Features are self-contained `feature_<name>` packages under
  `packages/features/<name>/` with their own `lib/src/{data,domain,presentation}`
  and a micro-package DI module (`Feature<Name>PackageModule`).
- Reusable infrastructure lives in `packages/` (`network`, `database`,
  `storage`, `config`, `analytics`, `app_platform`, `theme`, `app_ui`,
  `shared_ui`, `shared_contracts`, `localization`, `architecture`, …),
  consumed via package barrels like `package:network/network.dart`.
- App-level cross-feature glue lives in `lib/core/` (ObjectBox bootstrap,
  sync cursor store, app-wide DI module, Firebase platform bootstrap).
- Dependencies point **downward only**: `app → features → shared/infra → architecture`.
  A feature may **not** import another feature except through a documented
  single-consumer capability (e.g. `bookmarks` embeds `collections` widgets,
  `profile` surfaces `auth`'s delete-account). Enforced by guardrail tests
  under `test/architecture/`.
- The app depends on workspace packages, never raw third-party libs — e.g.
  depend on `network`, not `dio`/`retrofit` directly.

## Scaffolding features — use the `fst` CLI

Don't hand-create a feature package. From the **repo root**:

```bash
fst add-feature <name>          # scaffolds packages/features/<name>/ + wires workspace, DI, routing
```

The wiring edits land at `# fst:` / `// fst:` markers in `pubspec.yaml`,
`lib/app/di/injection.dart`, and `lib/app/features.dart` — **leave the
markers in place** (the generator never parses Dart; it relies on them).

## Code generation — required, git-ignored, with one exception

Most generated output (`*.g.dart`, `*.freezed.dart`, `*.config.dart`,
`*.gen.dart`) is **git-ignored** and regenerated on demand. After cloning or
any `pub get`, run `build_runner` once before the project compiles — until
then the analyzer will show errors for missing generated sources.

**ObjectBox is the deliberate exception:** `lib/objectbox.g.dart` **and**
`lib/objectbox-model.json` are **version-controlled**. They hold the stable
entity/property UIDs that keep on-device data intact across schema migrations
— regenerating them from scratch risks a destructive schema change. Treat
both as source-of-truth; CI fails if the tracked binding drifts from the
`@Entity` definitions.

Generators in play: freezed, retrofit, json_serializable, injectable,
objectbox, go_router_builder, flutter_gen.

Do **not** hand-edit any generated file — update the source and regenerate.

## Conventions

- Lint set: `very_good_analysis` ^10.2.0 with strict-casts, strict-inference,
  strict-raw-types (see `analysis_options.yaml`).
- **Prefer relative imports** (`prefer_relative_imports: true`) — not
  package: imports within a package.
- State management: BLoC (`flutter_bloc` + `bloc_concurrency`); sealed state
  unions via Freezed. Tests use `bloc_test`.
- DI: `get_it` + `injectable` codegen — never hand-wire registrations; add
  `@injectable` / `@singleton` and regenerate.
- Immutable models + Freezed unions where the surrounding code does.
- Routing: `go_router` with typed `TypedGoRoute` routes (go_router_builder).
- Localization: ARB sources + `gen-l10n` live in the `localization` package
  (`packages/localization/lib/l10n/`). Edit ARB there, then
  `(cd packages/localization && fvm flutter gen-l10n)`. Consume via
  `package:localization/localization.dart` / `context.l10n`.
- Submodules (`published/rev_sync`, `published/cli`, `simple_backend_server`)
  are independently maintained — their own pubspec, SDK, and CI. Don't
  reformat or analyze them from the root (they're excluded in
  `analysis_options.yaml`).

## Flavors & environment

Three flavors driven by `--dart-define-from-file` with typed `EnvConfig`
(`packages/config`):

```bash
fvm flutter run --flavor dev     --dart-define-from-file=env/dev.json
fvm flutter run --flavor staging --dart-define-from-file=env/staging.json
fvm flutter run --flavor prod    --dart-define-from-file=env/prod.json
```

## iOS — CocoaPods, not Swift Package Manager

iOS builds must use CocoaPods. Flutter 3.44.0 hardcodes the SPM-generated
package to deployment target 13.0, but Firebase needs 15.0, and
`permission_handler_apple` + `objectbox_flutter_libs` don't support SPM yet.
This is a **machine-global** Flutter config — every new machine and CI runner
must run it once before the first iOS build (`tool/setup.sh` does this on
macOS):

```bash
fvm flutter config --no-enable-swift-package-manager
```

## Backend (companion Go server)

`simple_backend_server/` is a git submodule (SQLite-backed, `chi/v5` + JWT).
If empty: `git submodule update --init --recursive`.

```bash
cd simple_backend_server && go run .     # → http://localhost:8080
```

Any username/password works in dev. Bookmarks & collections carry a per-owner
`rev` + `deleted_at` tombstones; clients pull deltas with `?since=<rev>` and
send `X-Expected-Rev` on writes (`409` on conflict).

## MCP servers

Project-scoped config in `.mcp.json`.

- `dart` (`fvm dart mcp-server`) — prefer for static analysis, formatting,
  package management, tests, runtime diagnostics, hot reload, Flutter
  inspector.
- `codegraph` (`codegraph serve --mcp --path .`) — prefer for structural
  code questions (symbol search, callers/callees, impact, focused context).
- `firebase` (`npx -y firebase-tools@latest mcp`) — prefer for Firebase
  projects, resources, and data.

If `.codegraph/` is missing, ask before building the index:
`codegraph init -i`.

## Agent skills

Official task playbooks from `flutter/skills`, `dart-lang/skills`, and
`firebase/agent-skills` are vendored under `.agents/skills/` and hash-pinned
in `skills-lock.json`. When a task matches a skill, open its `SKILL.md` and
follow it rather than improvising. Common mappings:

- Routing: `flutter-setup-declarative-routing`
- JSON serialization: `flutter-implement-json-serialization`
- Widget tests: `flutter-add-widget-test`
- Unit tests: `dart-add-unit-test`
- Static analysis: `dart-run-static-analysis`
- Runtime errors: `dart-fix-runtime-errors`
- Responsive layout: `flutter-build-responsive-layout`
- Layout errors: `flutter-fix-layout-issues`
- Localization: `flutter-setup-localization`
- REST calls: `flutter-use-http-package`
- Firebase basics: `firebase-basics`
- Firestore database: `firebase-firestore`

<!-- CODEGRAPH_START -->
## CodeGraph

This project has a CodeGraph MCP server (`codegraph_*` tools) configured.
CodeGraph is a tree-sitter-parsed knowledge graph of every symbol, edge, and
file. Reads are sub-millisecond and return structural information grep cannot.

### When to prefer codegraph over native search

Use codegraph for structural questions: what calls what, what would break,
where a symbol is defined, and what a signature looks like. Use native search
only for literal text queries, comments, log messages, or after you already
have a specific file open.

| Question | Tool |
|---|---|
| "Where is X defined?" / "Find symbol named X" | `codegraph_search` |
| "What calls function Y?" | `codegraph_callers` |
| "What does Y call?" | `codegraph_callees` |
| "What would break if I changed Z?" | `codegraph_impact` |
| "Show me Y's signature / source / docstring" | `codegraph_node` |
| "Give me focused context for a task/area" | `codegraph_context` |
| "See several related symbols' source at once" | `codegraph_explore` |
| "What files exist under path/" | `codegraph_files` |
| "Is the index healthy?" | `codegraph_status` |

### Rules of thumb

- For "how does X work", architecture, trace, feature, or bug-context
  questions, use `codegraph_context` first.
- Use one `codegraph_explore` call for source of several related symbols rather
  than looping over many `codegraph_node` calls.
- Do not grep first when looking up a symbol by name.
- Use `rg` for literal text and file-content searches.
- CodeGraph's file watcher debounces behind writes; do not re-query
  immediately after editing a file in the same turn.

### If `.codegraph/` does not exist

Ask the user:

> I notice this project does not have CodeGraph initialized. Want me to run
> `codegraph init -i` to build the index?
<!-- CODEGRAPH_END -->
