// Architecture guardrail: keeps the release workflow's fail-fast preflight in
// sync with the secrets it actually consumes.
//
// .github/workflows/release.yml verifies every required store-deploy
// secret/var at the top of each job (the `required=( … )` lists), so a
// misconfigured repo fails in ~2s with a clear message instead of ~15 min into
// a Fastlane build. If someone wires a new `secrets.X` / `vars.X` into a build
// step but forgets to add it to a preflight list, that fail-fast guarantee
// silently regresses — this test catches it.
//
// Pure file-scan, no third-party dependency; runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final workflow = File('.github/workflows/release.yml');

  // Names intentionally left out of the required lists: the preflight warns
  // instead of failing when they're unset. Keep this set tiny and justified.
  const optional = <String>{
    // Only HTTPS match repos need basic-auth; SSH setups don't.
    'MATCH_GIT_BASIC_AUTHORIZATION',
  };

  late final Set<String> referenced;
  late final Set<String> guarded;

  setUpAll(() {
    expect(
      workflow.existsSync(),
      isTrue,
      reason:
          'Expected .github/workflows/release.yml relative to the current '
          'directory. Run this test from the repository root.',
    );
    final yaml = workflow.readAsStringSync();
    referenced = _referencedSecretsAndVars(yaml);
    guarded = _guardedNames(yaml);
  });

  test('release.yml references store-deploy secrets (sanity)', () {
    expect(referenced, isNotEmpty);
  });

  test('every secret/var consumed by release.yml is covered by a preflight '
      'fail-fast check (or allow-listed as optional)', () {
    final unguarded =
        referenced
            .where(
              (name) => !guarded.contains(name) && !optional.contains(name),
            )
            .toList()
          ..sort();
    expect(
      unguarded,
      isEmpty,
      reason:
          'These secrets/vars are used by release.yml but no "Verify '
          'required …" preflight step guards them, so a misconfigured repo '
          'would fail deep inside the build instead of fast. Add each to a '
          'required=( … ) list in the relevant job (or, if genuinely '
          'optional, to the allowlist in this test):\n\n'
          '${unguarded.join('\n')}',
    );
  });
}

/// Every distinct `secrets.X` / `vars.X` name referenced anywhere in the
/// workflow, minus `GITHUB_TOKEN` (provided automatically by Actions, never
/// user-configured).
Set<String> _referencedSecretsAndVars(String yaml) {
  final pattern = RegExp(r'\$\{\{\s*(?:secrets|vars)\.(\w+)\s*\}\}');
  return {
    for (final match in pattern.allMatches(yaml)) match.group(1)!,
  }..remove('GITHUB_TOKEN');
}

/// The names listed inside every `required=( … )` bash array across the
/// preflight steps — the workflow's own source of truth for what it checks.
Set<String> _guardedNames(String yaml) {
  final blocks = RegExp(r'required=\(([^)]*)\)');
  final names = <String>{};
  for (final block in blocks.allMatches(yaml)) {
    for (final line in block.group(1)!.split('\n')) {
      final name = line.trim();
      if (name.isNotEmpty) names.add(name);
    }
  }
  return names;
}
