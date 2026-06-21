// Architecture guardrail: the authenticated (unnamed) `Dio` provider must live
// in the `network` infra package — never in a feature package. Before this was
// enforced, `feature_auth` provided the Dio and every other feature silently
// resolved it from the shared GetIt (an invisible feature->feature edge). The
// runtime composition is covered by test/widget_test.dart; this test locks the
// ownership so a feature can't quietly start providing its own Dio again.
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('network declares the authenticated Dio provider', () {
    final source = File(
      'packages/network/lib/src/network_module.dart',
    ).readAsStringSync();
    expect(
      RegExp(r'\bDio\s+provideDio\s*\(').hasMatch(source),
      isTrue,
      reason:
          'packages/network/lib/src/network_module.dart should declare the '
          'authenticated `Dio provideDio(...)`. Did it move or get renamed?',
    );
  });

  test('no feature package provides its own Dio', () {
    final featuresDir = Directory('packages/features');
    final offenders = <String>[];

    for (final entity in featuresDir.listSync()) {
      if (entity is! Directory) continue;
      final lib = Directory('${entity.path}/lib');
      if (!lib.existsSync()) continue;
      for (final file in lib.listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        // Skip generated DI output.
        if (file.path.endsWith('.module.dart') ||
            file.path.endsWith('.config.dart')) {
          continue;
        }
        // Match ANY Dio provider declaration — `Dio <name>(` as well as
        // async-wrapped `Future<Dio>` / `FutureOr<Dio>` providers — so a
        // feature can't bypass the guard by renaming or wrapping its provider.
        if (RegExp(
          r'\b(?:Future(?:Or)?\s*<\s*)?Dio(?:\s*>)?\s+\w+\s*\(',
        ).hasMatch(file.readAsStringSync())) {
          offenders.add(file.path);
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Feature packages must resolve the authenticated Dio from `network`, '
          'not provide their own. Offending files:\n'
          '${offenders.map((p) => '  $p').join('\n')}',
    );
  });
}
