// Architecture guardrail: enforces the cross-feature import boundary
// documented in CLAUDE.md ("a feature must not import another feature").
//
// Features now live as workspace packages under `packages/features/<name>`
// (Dart package `feature_<name>`). A feature package may not import another
// feature package — shared *state* is read through a `shared_contracts`
// contract and shared visuals come from `shared_ui`, so a direct
// `package:feature_<other>` import is a boundary crossing.
//
// The one documented escape hatch is the "capability" exception: a
// presentation object that one feature deliberately surfaces inside another
// while it has a single consumer. Those exact edges are whitelisted in
// [_allowedCrossFeatureImports]. When you intentionally add such a capability,
// add its edge here with a comment; when a second consumer appears, promote
// the contract to `shared_*` and remove the entry (the staleness test below
// will remind you if a whitelisted edge disappears).
//
// This complements `package_layering_test`: that test ranks the feature
// packages and enforces their dependency *direction* (a feature may only
// depend on strictly lower layers), while this scan enforces the *capability
// allowlist* — which specific feature-to-feature edges are permitted at all.
//
// A pure file-scan test on purpose: no third-party dependency, runs inside the
// normal `fvm flutter test` / CI flow, and can't break when the analyzer or
// pinned SDK is upgraded.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Documented capability exceptions, keyed by the importing feature package.
///
/// Each value is the set of feature packages it is allowed to import. Keep this
/// list minimal and commented — every entry is a deliberate exception to the
/// boundary rule.
const _allowedCrossFeatureImports = <String, Set<String>>{
  // fst:feature:bookmarks:start
  // bookmarks surfaces collections' "add to collection" sheet and embedded
  // collections list (single consumer). See the capability exception in
  // CLAUDE.md; promote to shared_ui if a second consumer appears.
  'feature_bookmarks': {'feature_collections'},
  // fst:feature:bookmarks:end
  // fst:auth:start
  // profile surfaces auth's account-deletion flow (DeleteAccountCubit, single
  // consumer). See the DeleteAccountCubit worked example in CLAUDE.md.
  'feature_profile': {'feature_auth'},
  // fst:auth:end
};

void main() {
  final featuresDir = Directory('packages/features');

  test('packages/features exists (run from the package root)', () {
    expect(
      featuresDir.existsSync(),
      isTrue,
      reason:
          'Expected to find packages/features relative to the current '
          'directory. Run this test from the package root.',
    );
  });

  // Maps each feature package directory to its Dart package name.
  final featurePackages = <String, String>{};
  for (final entity in featuresDir.listSync().whereType<Directory>()) {
    final pubspec = File('${entity.path}/pubspec.yaml');
    if (!pubspec.existsSync()) continue;
    final name = _packageName(pubspec.readAsLinesSync());
    if (name != null) featurePackages[_posix(entity.path)] = name;
  }
  final featurePackageNames = featurePackages.values.toSet();

  final crossFeatureImports = _collectCrossFeatureImports(
    featurePackages,
    featurePackageNames,
  );

  test(
    'no feature imports another feature outside the documented allowlist',
    () {
      final violations = crossFeatureImports
          .where(
            (i) =>
                !(_allowedCrossFeatureImports[i.sourceFeature]?.contains(
                      i.targetFeature,
                    ) ??
                    false),
          )
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'Cross-feature imports break the feature boundary documented in '
            'CLAUDE.md. Read shared state through a shared_contracts contract, '
            'or — if this is a deliberate single-consumer capability — add it '
            'to _allowedCrossFeatureImports in this test.\n\n'
            '${violations.map((v) => '  $v').join('\n')}',
      );
    },
  );

  test('every allowlisted capability import still exists (no stale entries)', () {
    final actual = crossFeatureImports
        .map((i) => '${i.sourceFeature} -> ${i.targetFeature}')
        .toSet();

    final stale = <String>[];
    _allowedCrossFeatureImports.forEach((feature, targets) {
      for (final target in targets) {
        if (!actual.contains('$feature -> $target')) {
          stale.add('$feature -> $target');
        }
      }
    });

    expect(
      stale,
      isEmpty,
      reason:
          'These whitelisted capability imports no longer exist. Remove '
          'them from _allowedCrossFeatureImports — a stale allowlist hides '
          'real boundary violations:\n\n${stale.map((s) => '  $s').join('\n')}',
    );
  });
}

/// A single import that crosses from one feature package into another.
class _CrossFeatureImport {
  _CrossFeatureImport({
    required this.file,
    required this.line,
    required this.sourceFeature,
    required this.targetFeature,
    required this.uri,
  });

  /// Path of the importing file, relative to the package root.
  final String file;

  /// 1-based line number of the import directive.
  final int line;

  /// Feature package that owns [file] (e.g. `feature_bookmarks`).
  final String sourceFeature;

  /// Feature package being imported (e.g. `feature_collections`).
  final String targetFeature;

  /// The raw import URI as written in source.
  final String uri;

  @override
  String toString() => '$file:$line imports $sourceFeature -> $targetFeature';
}

/// Matches `import '...'` / `export '...'` and captures the URI.
final _importDirective = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
);

/// Matches the package segment of a `package:feature_<name>/...` URI.
final _featurePackageUri = RegExp('^package:(feature_[a-z0-9_]+)/');

List<_CrossFeatureImport> _collectCrossFeatureImports(
  Map<String, String> featurePackages,
  Set<String> featurePackageNames,
) {
  final results = <_CrossFeatureImport>[];

  featurePackages.forEach((dirPath, ownName) {
    final libDir = Directory('$dirPath/lib');
    if (!libDir.existsSync()) return;

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final relPath = _posix(file.path);
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final match = _importDirective.firstMatch(lines[i]);
        if (match == null) continue;

        final uri = match.group(1)!;
        final pkgMatch = _featurePackageUri.firstMatch(uri);
        if (pkgMatch == null) continue;

        final targetFeature = pkgMatch.group(1)!;
        if (targetFeature == ownName) continue;
        if (!featurePackageNames.contains(targetFeature)) continue;

        results.add(
          _CrossFeatureImport(
            file: relPath,
            line: i + 1,
            sourceFeature: ownName,
            targetFeature: targetFeature,
            uri: uri,
          ),
        );
      }
    }
  });

  return results;
}

/// Reads the `name:` field from a pubspec's lines.
String? _packageName(List<String> lines) {
  for (final line in lines) {
    final match = RegExp(r'^name:\s*(\S+)').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

/// Converts a filesystem path to POSIX separators so the test behaves the same
/// on Windows CI runners.
String _posix(String path) => path.replaceAll(r'\', '/');
