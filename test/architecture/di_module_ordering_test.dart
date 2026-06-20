// Architecture guardrail: locks the order of the injectable external package
// modules in `lib/app/di/injection.dart`.
//
// `@InjectableInit(externalPackageModulesBefore: [...])` registers each
// package module in list order. Most modules are order-independent, but one
// constraint is load-bearing and currently documented only in a prose
// comment beside the list:
//
//   * `SharedContractsPackageModule` registers `ActivityNotifier`, which
//     `feature_notifications`' BLoC resolves at construction — so it must be
//     registered before `FeatureNotificationsPackageModule`.
//
// Reordering the list to violate this constraint compiles and analyzes
// cleanly; it fails only at runtime, when a consumer resolves a not-yet-
// registered dependency. This test turns that latent footgun into a fast,
// deterministic failure: it parses the module order out of the source and
// asserts each documented "before -> after" edge still holds.
//
// When a new ordering constraint becomes load-bearing, add it to [_mustPrecede]
// with a comment. When you rename or remove a module named here, the coverage
// test below fails until the constraint is updated — so the guard can't quietly
// stop guarding.
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Load-bearing ordering edges: each key module must be registered *before*
/// every module in its value set. Keep every edge commented with its reason —
/// an edge here is a real runtime dependency, not a style preference.
const _mustPrecede = <String, Set<String>>{
  // shared_contracts registers ActivityNotifier, consumed by the notifications
  // BLoC at construction.
  // fst:feature:notifications:start
  'SharedContractsPackageModule': {'FeatureNotificationsPackageModule'},
  // fst:feature:notifications:end
};

void main() {
  final injection = File('lib/app/di/injection.dart');

  test('lib/app/di/injection.dart exists (run from the package root)', () {
    expect(
      injection.existsSync(),
      isTrue,
      reason:
          'Expected to find lib/app/di/injection.dart relative to the current '
          'directory. Run this test from the repository root.',
    );
  });

  // Read defensively at registration time: if the file is missing, fall back
  // to empty so the existence test above still reports its friendly message
  // instead of a raw FileSystemException aborting the whole suite load.
  final order = _externalModuleOrder(
    injection.existsSync() ? injection.readAsStringSync() : '',
  );
  final rank = {for (var i = 0; i < order.length; i++) order[i]: i};

  test('externalPackageModulesBefore is non-empty and parsed', () {
    expect(
      order,
      isNotEmpty,
      reason:
          'Could not parse any ExternalModule(...) entries from '
          'externalPackageModulesBefore. Has the @InjectableInit list moved or '
          'changed shape? Update _externalModuleOrder to match.',
    );
  });

  test('every module named in an ordering constraint is in the list', () {
    final named = <String>{
      ..._mustPrecede.keys,
      for (final after in _mustPrecede.values) ...after,
    };
    final missing = named.where((m) => !rank.containsKey(m)).toList()..sort();
    expect(
      missing,
      isEmpty,
      reason:
          'These modules are referenced by _mustPrecede but no longer appear '
          'in externalPackageModulesBefore (renamed or removed?). Update the '
          'constraint so the guard keeps matching reality:\n\n'
          '${missing.map((m) => '  $m').join('\n')}',
    );
  });

  test('load-bearing module ordering is preserved', () {
    final violations = <String>[];

    _mustPrecede.forEach((before, afters) {
      final beforeRank = rank[before];
      if (beforeRank == null) return; // reported by the coverage test above
      for (final after in afters) {
        final afterRank = rank[after];
        if (afterRank == null) continue; // reported by the coverage test above
        if (beforeRank >= afterRank) {
          violations.add(
            '$before (position $beforeRank) must come before '
            '$after (position $afterRank)',
          );
        }
      }
    });

    expect(
      violations,
      isEmpty,
      reason:
          'externalPackageModulesBefore is ordered so a module is registered '
          'before a dependency it relies on. This compiles but fails at '
          'runtime when the dependency is resolved. Reorder the list in '
          'lib/app/di/injection.dart:\n\n'
          '${violations.map((v) => '  $v').join('\n')}',
    );
  });
}

/// Captures each `ExternalModule(<Name>)`, in source order, from the
/// `externalPackageModulesBefore: [...]` list in [source].
List<String> _externalModuleOrder(String source) {
  final listStart = source.indexOf('externalPackageModulesBefore');
  if (listStart == -1) return const [];

  final open = source.indexOf('[', listStart);
  final close = source.indexOf(']', open);
  if (open == -1 || close == -1) return const [];

  final body = source.substring(open + 1, close);
  return RegExp(
    r'ExternalModule\(\s*([A-Za-z0-9_]+)\s*\)',
  ).allMatches(body).map((m) => m.group(1)!).toList();
}
