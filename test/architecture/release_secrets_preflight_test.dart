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
// A name can also be exempt from a job's `required=( … )` list when the job
// gates it on a runtime condition this static test can't evaluate (e.g.
// MATCH_GIT_BASIC_AUTHORIZATION is required only for an HTTPS match repo). Such
// exemptions are *earned*: they hold only while the job body still contains the
// runtime guard, so deleting the guard re-arms the static check.
//
// Pure file-scan, no third-party dependency; runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// An exemption from a job's `required=( … )` list, valid only while every
/// guard pattern still matches the job body. If the runtime guard is removed,
/// the exemption lapses and the name must return to `required=( … )`.
const _exemptions = <({String job, String name, List<String> guards})>[
  (
    job: 'ios',
    name: 'MATCH_GIT_BASIC_AUTHORIZATION',
    // The iOS preflight requires the token only for HTTPS match repos and
    // hard-fails when it's missing under that branch; SSH repos don't need it.
    // The guard matches the whole hard-fail path in order — the HTTPS scheme
    // test, then the MATCH_GIT_BASIC_AUTHORIZATION check, then `exit 1` — so the
    // exemption lapses if that specific path is removed. (A stray `exit 1`
    // elsewhere in the job — e.g. the missing-secrets block — no longer counts.)
    guards: [
      r'MATCH_GIT_URL"?\s*=~\s*\^https\?://[\s\S]*?MATCH_GIT_BASIC_AUTHORIZATION[\s\S]*?exit\s+1',
    ],
  ),
];

void main() {
  final workflow = File('.github/workflows/release.yml');

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
      'fail-fast list (or an earned runtime exemption)', () {
    final problems = <String>[];
    jobs.forEach((job, body) {
      final referenced = _referencedSecretsAndVars(body);
      final guarded = _guardedNames(body);
      final unguarded =
          referenced
              .where(
                (n) => !guarded.contains(n) && !_isExempt(job, n, body),
              )
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
          "covered by that job's preflight required=( … ) list (nor an earned "
          'runtime exemption), so a misconfigured repo would fail deep in the '
          'build instead of fast. Add each to the right job (or, if gated on a '
          'runtime condition, register an exemption in this test):\n\n'
          '${problems.join('\n')}',
    );
  });

  test("every runtime exemption is still earned by its job's guard", () {
    for (final exemption in _exemptions) {
      final body = jobs[exemption.job] ?? '';
      for (final guard in exemption.guards) {
        expect(
          RegExp(guard).hasMatch(body),
          isTrue,
          reason:
              'The ${exemption.job} preflight no longer matches /$guard/, '
              'so the ${exemption.name} exemption is unjustified. Restore the '
              'runtime guard, or move ${exemption.name} back into '
              'required=( … ).',
        );
      }
    }
  });
}

/// Whether [name] is exempt from job [job]'s required list because the job
/// [body] still carries every guard the exemption depends on.
bool _isExempt(String job, String name, String body) => _exemptions.any(
  (e) =>
      e.job == job &&
      e.name == name &&
      e.guards.every((pattern) => RegExp(pattern).hasMatch(body)),
);

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
