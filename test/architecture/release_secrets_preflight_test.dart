// Architecture guardrail: keeps the release workflow's fail-fast preflight in
// sync with the secrets it actually consumes — per job.
//
// .github/workflows/release.yml verifies every required store-deploy
// secret/var at the top of each job (the `required=( … )` lists), so a
// misconfigured repo fails in ~2s with a clear message instead of ~15 min into
// a Fastlane build. The check is scoped per job: a name consumed by the Android
// job must be guarded by the *Android* preflight, not merely by some list in
// the iOS job. If someone wires a new `secrets.X` / `vars.X` into a build step
// but forgets its job's preflight list, that fail-fast guarantee silently
// regresses — this test catches it.
//
// Pure file-scan, no third-party dependency; runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final workflow = File('.github/workflows/release.yml');

  // Names a job's preflight intentionally omits from its required list because
  // the workflow gates them on a runtime condition this static test can't
  // evaluate. Keyed by job. Keep each entry tiny and justified.
  const optionalByJob = <String, Set<String>>{
    // The iOS preflight requires MATCH_GIT_BASIC_AUTHORIZATION only when
    // MATCH_GIT_URL is HTTPS — a runtime check — and skips it for SSH. The
    // transport rule lives in the workflow; here we just exempt it from the
    // static presence check.
    'ios': {'MATCH_GIT_BASIC_AUTHORIZATION'},
  };

  late final Map<String, String> jobs;

  setUpAll(() {
    expect(
      workflow.existsSync(),
      isTrue,
      reason:
          'Expected .github/workflows/release.yml relative to the current '
          'directory. Run this test from the repository root.',
    );
    jobs = _jobSections(workflow.readAsStringSync());
  });

  test('release.yml exposes the android and ios jobs (sanity)', () {
    expect(jobs.keys, containsAll(<String>['android', 'ios']));
  });

  test('each job guards every secret/var it consumes with its own preflight '
      'fail-fast list (or a justified optional)', () {
    final problems = <String>[];
    jobs.forEach((job, body) {
      final referenced = _referencedSecretsAndVars(body);
      final guarded = _guardedNames(body);
      final optional = optionalByJob[job] ?? const <String>{};
      final unguarded =
          referenced
              .where((n) => !guarded.contains(n) && !optional.contains(n))
              .map((n) => '[$job] $n')
              .toList()
            ..sort();
      problems.addAll(unguarded);
    });
    expect(
      problems,
      isEmpty,
      reason:
          'These secrets/vars are consumed by a release.yml job but are not '
          "covered by that job's preflight required=( … ) list, so a "
          'misconfigured repo would fail deep in the build instead of fast. '
          'Add each to the right job (or, if gated on a runtime condition, to '
          'optionalByJob in this test):\n\n${problems.join('\n')}',
    );
  });
}

/// Slices release.yml into `{jobName: jobBody}` for the top-level jobs — the
/// 2-space-indented keys under `jobs:` — so coverage is checked per job rather
/// than against the union of every job's references and lists.
Map<String, String> _jobSections(String yaml) {
  final lines = yaml.split('\n');
  final jobsStart = lines.indexWhere((line) => line == 'jobs:');
  expect(
    jobsStart,
    isNonNegative,
    reason: 'release.yml has no top-level `jobs:` key.',
  );

  final header = RegExp(r'^  ([A-Za-z0-9_-]+):\s*$');
  final sections = <String, String>{};
  String? current;
  final buffer = StringBuffer();
  void flush() {
    final name = current;
    if (name != null) sections[name] = buffer.toString();
    buffer.clear();
  }

  for (final line in lines.skip(jobsStart + 1)) {
    final match = header.firstMatch(line);
    if (match != null) {
      flush();
      current = match.group(1);
    } else if (current != null) {
      buffer.writeln(line);
    }
  }
  flush();
  return sections;
}

/// Every distinct `secrets.X` / `vars.X` name referenced in [yaml], minus
/// `GITHUB_TOKEN` (provided automatically by Actions, never user-configured).
Set<String> _referencedSecretsAndVars(String yaml) {
  final pattern = RegExp(r'\$\{\{\s*(?:secrets|vars)\.(\w+)\s*\}\}');
  return {for (final match in pattern.allMatches(yaml)) match.group(1)!}
    ..remove('GITHUB_TOKEN');
}

/// The names listed inside every `required=( … )` bash array in [yaml] — the
/// workflow's own source of truth for what each preflight checks.
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
