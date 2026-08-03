// Architecture guardrail: every tracked `di.module.dart` must sit in a package
// that `tool/codegen.sh` actually rebuilds.
//
// CI diff-guards these files: it runs codegen.sh, then fails if any tracked
// di.module.dart changed. That guard is only as wide as the script — a module
// in a package codegen.sh never builds is never regenerated, so it can never
// differ, so the guard silently passes while the committed file rots.
//
// That is not hypothetical. codegen.sh once looped over `packages/features/*/`
// only, leaving the eight infra modules tracked but unbuilt; the rev_sync
// import alias in sync_connectivity_plus drifted there and went unnoticed
// through every green CI run until someone regenerated it by hand.
//
// So this test asserts the coverage relationship itself: for each module found
// on disk, the owning package must match one of the globs in codegen.sh's build
// loop, must not be in that loop's skip list, and must declare build_runner
// (without it build_runner cannot run there at all). Adding a new package with
// a DI module that the script would not reach fails here, at test time, instead
// of years later as a mystery diff.
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final script = File('tool/codegen.sh');

  test('tool/codegen.sh exists (run from the repository root)', () {
    expect(
      script.existsSync(),
      isTrue,
      reason:
          'Expected to find tool/codegen.sh relative to the current directory. '
          'Run this test from the repository root.',
    );
  });

  // Read defensively at registration time so a missing script surfaces as the
  // friendly failure above rather than a raw FileSystemException that aborts
  // the whole suite load.
  final source = script.existsSync() ? script.readAsStringSync() : '';
  final globs = _buildLoopGlobs(source);
  final skipped = _buildLoopSkips(source);
  final modules = _trackedDiModules();

  test('the build loop in codegen.sh is still parseable', () {
    expect(
      globs,
      isNotEmpty,
      reason:
          'Could not parse the `for pkg in ...` build loop out of '
          'tool/codegen.sh. Has the loop moved or changed shape? Update '
          '_buildLoopGlobs to match.',
    );
  });

  test('di.module.dart files are discoverable under packages/', () {
    expect(
      modules,
      isNotEmpty,
      reason:
          'Found no di.module.dart under packages/. Either the DI module '
          'layout changed or this test is running from the wrong directory — '
          'in both cases the CI diff guard needs revisiting too.',
    );
  });

  test('every DI module lives in a package codegen.sh rebuilds', () {
    final unreachable = <String>[];

    for (final packageDir in modules) {
      if (skipped.contains(packageDir)) {
        unreachable.add(
          "$packageDir — excluded by the build loop's skip list, but it owns "
          'a tracked di.module.dart',
        );
        continue;
      }
      if (!globs.any((g) => g.hasMatch('$packageDir/'))) {
        unreachable.add(
          '$packageDir — matches none of the build-loop globs '
          '(${globs.map((g) => g.pattern).join(', ')})',
        );
      }
    }

    expect(
      unreachable,
      isEmpty,
      reason:
          'These packages ship a tracked di.module.dart that tool/codegen.sh '
          'never regenerates. CI\'s "Verify generated DI modules are up to '
          'date" step diffs the committed output against a fresh run, so an '
          'unreachable module is invisible to it and can drift forever. '
          'Widen the build loop in tool/codegen.sh to cover them:\n\n'
          '${unreachable.map((u) => '  $u').join('\n')}',
    );
  });

  test('every package owning a DI module declares build_runner', () {
    final missing = <String>[];

    for (final packageDir in modules) {
      final pubspec = File('$packageDir/pubspec.yaml');
      if (!pubspec.existsSync() ||
          !pubspec.readAsStringSync().contains('build_runner')) {
        missing.add(packageDir);
      }
    }

    expect(
      missing,
      isEmpty,
      reason:
          'These packages ship a di.module.dart but do not declare '
          'build_runner, so codegen.sh skips them even though its globs match '
          '— the same blind spot, one layer down:\n\n'
          '${missing.map((m) => '  $m').join('\n')}',
    );
  });
}

/// Package directories (repo-relative, no trailing slash) that contain a
/// `di.module.dart`, mirroring the `find` in codegen.sh's format pass.
List<String> _trackedDiModules() {
  final root = Directory('packages');
  if (!root.existsSync()) return const [];

  return root
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.uri.pathSegments.last == 'di.module.dart')
      .map((f) => f.path.replaceAll(r'\', '/'))
      // Build output under .dart_tool is not source; codegen.sh prunes it too.
      .where((p) => !p.contains('/.dart_tool/'))
      // packages/<...>/lib/src/di.module.dart -> packages/<...>
      .map((p) => p.split('/lib/').first)
      .toSet()
      .toList()
    ..sort();
}

/// Compiles the shell globs from codegen.sh's `for pkg in <globs>; do` header
/// into regexes anchored on a trailing slash (the loop iterates directories).
List<RegExp> _buildLoopGlobs(String source) {
  final header = RegExp('for pkg in ([^;]+); do').firstMatch(source);
  if (header == null) return const [];

  return header
      .group(1)!
      .split(RegExp(r'\s+'))
      .where((g) => g.startsWith('packages/'))
      .map((g) => RegExp('^${g.split('*').map(RegExp.escape).join('[^/]+')}\$'))
      .toList();
}

/// Package directories excluded inside the build loop via
/// `case ... ) continue ;;` — these are built elsewhere in the script.
Set<String> _buildLoopSkips(String source) {
  final arm = RegExp(
    r'case\s+"\$\{pkg%/\}"\s+in\s*\n\s*([^)]+)\)\s*continue',
  ).firstMatch(source);
  if (arm == null) return const {};

  return arm
      .group(1)!
      .split('|')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toSet();
}
