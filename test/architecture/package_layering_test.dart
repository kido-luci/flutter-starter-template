// Architecture guardrail: enforces the layering between the workspace
// packages under `packages/` (the workspace packages / `app_ui` / `test_utils` set).
//
// Pub already forbids true dependency *cycles*, but it does not enforce a
// *direction*. This test does: every package is assigned a layer rank, and a
// package may only depend (at runtime) on packages in a strictly lower layer.
// That keeps the dependency graph a DAG flowing one way — e.g. architecture
// stays a pure leaf nothing reaches up into, and network can't quietly
// start depending on theme.
//
// Only runtime `dependencies:` are checked. `dev_dependencies:` are excluded
// on purpose: `test_utils` (the shared test harness, the top layer) is a dev
// dependency of almost every package, and that back-edge is intentional and
// test-only — it isn't a runtime layering violation.
//
// When you add a new workspace package, give it a layer in [_layers] (the
// coverage test below fails until you do). When you add a dependency that
// points the wrong way, either it's a mistake, or the layering is wrong and
// the ranks need rethinking — don't just bump a number to silence it.
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Layer rank per workspace package. A package may depend only on packages
/// with a strictly smaller rank.
const _layers = <String, int>{
  // 0 — pure-Dart foundation; depends on nothing in the workspace.
  'architecture': 0,
  'sync': 0, // offline-first sync engine; pure Dart, no workspace deps
  // 1 — primitives: no workspace deps, or only on architecture.
  'config': 1, // firebase_remote_config wrapper
  'storage': 1, // shared_preferences / secure storage
  'analytics': 1, // -> architecture
  'app_ui': 1, // design tokens; no workspace package deps
  // 2 — composed infra built on the primitives.
  'network': 2, // -> config
  'app_platform': 2, // -> analytics, architecture
  'theme': 2, // -> analytics, architecture
  // 3 — shared test harness, sits on top of what it provides fakes for.
  'test_utils': 3, // -> analytics, app_platform, storage
};

void main() {
  final packagesDir = Directory('packages');

  test('packages/ exists (run from the package root)', () {
    expect(
      packagesDir.existsSync(),
      isTrue,
      reason:
          'Expected to find packages/ relative to the current directory. '
          'Run this test from the repository root.',
    );
  });

  final packages = _discoverPackages(packagesDir);

  test('every workspace package has a layer assigned', () {
    final unranked =
        packages.keys.where((name) => !_layers.containsKey(name)).toList()
          ..sort();
    expect(
      unranked,
      isEmpty,
      reason:
          'These workspace packages have no entry in _layers. Assign each '
          'a layer rank so its dependency direction is enforced:\n\n'
          '${unranked.map((p) => '  $p').join('\n')}',
    );
  });

  test('packages only depend on strictly lower layers', () {
    final workspaceNames = packages.keys.toSet();
    final violations = <String>[];

    packages.forEach((name, pubspec) {
      final fromRank = _layers[name];
      if (fromRank == null) return; // reported by the coverage test above

      for (final dep in _runtimeDependencies(pubspec)) {
        if (!workspaceNames.contains(dep)) continue; // third-party dep
        final toRank = _layers[dep];
        if (toRank == null) continue; // reported by the coverage test above

        if (toRank >= fromRank) {
          final kind = toRank == fromRank ? 'same-layer' : 'upward';
          violations.add(
            '$name (layer $fromRank) -> $dep (layer $toRank)  [$kind]',
          );
        }
      }
    });

    expect(
      violations,
      isEmpty,
      reason:
          'These runtime dependencies violate the package layering '
          '(a package may only depend on strictly lower layers). Fix the '
          'dependency, or rethink the ranks in _layers if the intended '
          'architecture changed:\n\n${violations.map((v) => '  $v').join('\n')}',
    );
  });
}

/// Maps each workspace package name to the lines of its `pubspec.yaml`.
Map<String, List<String>> _discoverPackages(Directory packagesDir) {
  final result = <String, List<String>>{};
  for (final entity in packagesDir.listSync()) {
    if (entity is! Directory) continue;
    final pubspec = File('${entity.path}/pubspec.yaml');
    if (!pubspec.existsSync()) continue;
    final lines = pubspec.readAsLinesSync();
    final name = _packageName(lines);
    if (name != null) result[name] = lines;
  }
  return result;
}

String? _packageName(List<String> lines) {
  for (final line in lines) {
    final match = RegExp(r'^name:\s*(\S+)').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

/// Names listed under the top-level `dependencies:` block of a pubspec.
///
/// Intentionally ignores `dev_dependencies:` and nested keys (e.g. the
/// `sdk: flutter` under `flutter:`).
Set<String> _runtimeDependencies(List<String> lines) {
  final deps = <String>{};
  final entry = RegExp('^  ([a-zA-Z0-9_]+):');
  var inDependencies = false;

  for (final line in lines) {
    if (line.trimRight() == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    // A new top-level key (no leading whitespace) ends the block.
    if (inDependencies && line.isNotEmpty && !line.startsWith(' ')) {
      inDependencies = false;
    }
    if (!inDependencies) continue;

    final match = entry.firstMatch(line);
    if (match != null) deps.add(match.group(1)!);
  }
  return deps;
}
