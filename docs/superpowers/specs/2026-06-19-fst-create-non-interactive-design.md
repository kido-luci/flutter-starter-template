# `fst create` — non-interactive mode (flags + `--yes`)

- **Date:** 2026-06-19
- **Status:** Approved (design)
- **Scope:** `tool/cli` (the `flutter_starter_template_cli` package, a git submodule
  mirrored to pub.dev)
- **Owner:** kido-luci

## Problem

`fst create` collects its four inputs — display name, Dart package name, bundle
ID, organisation — exclusively through interactive `Input`/`Confirm` prompts
(`tool/cli/lib/src/commands/create_command.dart`). Two consequences:

1. **No automation.** The command cannot run in CI or a script because it blocks
   on a TTY. There is no way to pass the inputs as arguments.
2. **`create` is effectively untestable.** The input-collection logic is inlined
   in `run()` alongside cloning and rewriting, and it requires a terminal, so
   there is no unit coverage of how inputs become a `ProjectConfig`.

The clone, clean-slate, rewrite, and setup steps already exist and are pure
enough to reuse unchanged. The only missing piece is a non-interactive way to
supply the four inputs.

## Goals

- Accept all four inputs as command-line flags, plus a `--yes` flag that runs the
  command non-interactively (no prompts, no confirmation).
- Keep the existing interactive flow as the default when flags are absent.
- Extract the non-interactive input resolution into a pure, IO-free function so
  the safety-critical logic (validation, derivation, missing-input errors) is
  unit-tested.
- Make invalid input fail loudly (non-zero exit) rather than silently falling
  back to a prompt.

## Non-goals

- No change to clone, clean-slate (`prepareCleanSlate`), rewrite
  (`rewriteProject`), `setup.sh` execution, the generated README, or the Firebase
  warning. They are reused as-is.
- No new customization dimension (feature selection, Firebase, icons, env URLs).
  This change only unlocks the four *existing* inputs for automation.
- No interactive `prompter` abstraction / fake-prompter test harness. The
  interactive path stays inline and remains uncovered, as today.

## Design

### New flags on `create`

Added to the existing `argParser` alongside `-o, --output-dir` and `--no-setup`:

| Flag | Abbr | Meaning |
|------|------|---------|
| `--name` | `-n` | App display name |
| `--package-name` | — | Dart package name (snake_case) |
| `--bundle-id` | — | Bundle / App ID (reverse-DNS) |
| `--org` | — | Organisation / author |
| `--yes` | `-y` | Non-interactive: no prompts, skip the confirmation |

`--yes` is a non-negatable flag (matches `--no-setup`'s style).

### Single resolution rule (per input)

For each of the four inputs:

1. **Flag provided** → always use it. Validate with the existing validators
   (`isValidPackageName`, `isValidBundleId`). An invalid flag value prints an
   error and exits with code `1` — in **both** interactive and `--yes` mode (an
   explicitly-passed bad value is a user mistake; do not fall back to a prompt).
2. **Flag absent, not `--yes`** → prompt exactly as today (same prompt text,
   same defaults).
3. **Flag absent, `--yes`** → error, *unless the value is derivable* (see below).

`--yes` additionally skips the final `Confirm` step.

### Derivation rules (preserve today's interactive defaults)

Today's interactive defaults split into two kinds:

- **A real derivation:** `--package-name`'s default is `toSnakeCase(name)`. This
  is a deterministic transform of a real input, not a placeholder. So under
  `--yes`, if `--package-name` is omitted it is derived from `--name` (no error).
- **Placeholders:** `--name` (`My App`), `--bundle-id` (`com.example.<pkg>`),
  `--org` (`My Organisation`) default to placeholder values in interactive mode.
  Under `--yes`, a missing one of these is an **error** — we never scaffold a
  project with placeholder identity.

**Therefore, `--yes` requires at minimum: `--name`, `--bundle-id`, `--org`.**
`--package-name` is optional (derived from `--name` when omitted).

`--output-dir` keeps its current behaviour: defaults to the resolved package
name when omitted, in every mode.

### Pure resolver (the testable unit)

A new IO-free function resolves the non-interactive (`--yes`) path:

```dart
/// Builds a [ProjectConfig] from non-interactive flag values, or returns an
/// error message describing the first problem. Performs no IO and no prompting.
sealed class ConfigResult {}
class ConfigOk extends ConfigResult { final ProjectConfig config; ... }
class ConfigError extends ConfigResult { final String message; ... }

ConfigResult resolveProjectConfig({
  required String? name,
  required String? packageName,
  required String? bundleId,
  required String? org,
  required String? outputDir, // null → derive from package name
});
```

Contract:

- `name` null/empty → `ConfigError` ("`--name` is required with `--yes`.").
- `bundleId` null/empty → `ConfigError` ("`--bundle-id` is required with `--yes`.").
- `org` null/empty → `ConfigError` ("`--org` is required with `--yes`.").
- `packageName` null → derive `toSnakeCase(name)`; if the result is empty →
  `ConfigError`.
- `packageName` provided but `!isValidPackageName` → `ConfigError`.
- `bundleId` provided but `!isValidBundleId` → `ConfigError`.
- `outputDir` null → use the resolved package name.
- All valid → `ConfigOk(ProjectConfig(...))` with `outputDir` made absolute by
  the caller (path resolution stays in the command to keep the function pure /
  platform-independent), or absolutised here via `package:path` if convenient —
  decide in the plan; either keeps the function deterministic for tests.

The exact return shape (sealed class vs. record vs. throwing a typed exception)
is an implementation detail to settle in the plan; the requirement is that it is
pure and unit-testable. The interactive path stays inline in `run()` using the
`flag ?? prompt` rule above and reuses the same validators.

### Control flow in `run()`

1. Read the flag values from `argResults`.
2. If `--yes`: call `resolveProjectConfig(...)`. On `ConfigError`, `_logger.err`
   + return `1`. On `ConfigOk`, take the config and skip all prompts/confirm.
3. Else (interactive): for each input apply the `flag ?? prompt` rule (validating
   any provided flag the same way the resolver does), build the summary, and run
   the `Confirm` step unchanged.
4. From the resolved `ProjectConfig` onward — directory-exists check, clone,
   clean slate, rewrite, README, setup, next-steps — the code is **unchanged**.

## Testing

New unit tests for `resolveProjectConfig` (no TTY needed):

- All four flags valid → `ConfigOk` with matching fields.
- Missing `--name` / `--bundle-id` / `--org` (each) → `ConfigError`.
- `--package-name` omitted → derived snake_case from `--name`.
- `--package-name` provided invalid → `ConfigError`.
- `--bundle-id` provided invalid → `ConfigError`.
- `--output-dir` omitted → equals resolved package name.
- `--name` that snake-cases to empty (e.g. `"!!!"`) → `ConfigError`.

Existing tests (`validators_test`, `rewriter_test`, etc.) are unaffected.

## Files touched

- `tool/cli/lib/src/commands/create_command.dart` — new flags; resolver call;
  `flag ?? prompt` per input.
- `tool/cli/lib/src/project_config.dart` *(or a new `lib/src/config_resolver.dart`)* —
  `resolveProjectConfig` + result type. Location decided in the plan.
- `tool/cli/test/config_resolver_test.dart` *(new)* — resolver unit tests.
- `tool/cli/README.md` — document the new flags under **Options** with a
  non-interactive example.
- `tool/cli/CHANGELOG.md` — new entry.

## Risks

- **Low.** The interactive path is preserved as the default; the new code is
  additive. The only behavioural change for existing users is that an invalid
  *explicitly-passed flag* errors instead of prompting — which only affects new
  flag usage, not the current prompt-only flow.
