// Architecture guardrail: enforces the cross-feature import boundary
// documented in CLAUDE.md ("a feature must not import another feature").
//
// A file under `lib/features/<A>/` may not import code from another feature
// `lib/features/<B>/` (whether through a `package:` or a relative import).
// Shared state must be read through a `shared/` contract, and shared infra
// through the workspace packages instead.
//
// The one documented escape hatch is the "capability" exception: a
// presentation object that one feature deliberately surfaces inside another
// while it has a single consumer. Those exact imports are whitelisted in
// [_allowedCrossFeatureImports]. When you intentionally add such a capability,
// add its import here with a comment; when a second consumer appears, promote
// the contract to `shared/` and remove the entry (the staleness test below
// will remind you if a whitelisted import disappears).
//
// This is a pure file-scan test on purpose: it has no third-party dependency,
// runs inside the normal `fvm flutter test` / CI flow, and can't break when
// the analyzer or pinned SDK is upgraded.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The package name from `pubspec.yaml`, used to detect absolute
/// `package:flutter_starter_template/features/...` imports.
const _packageName = 'flutter_starter_template';

/// Documented capability exceptions, keyed by the importing feature.
///
/// Each value is the set of import targets (paths relative to `lib/features/`)
/// that feature is allowed to reach into. Keep this list minimal and
/// commented — every entry is a deliberate exception to the boundary rule.
const _allowedCrossFeatureImports = <String, Set<String>>{
  // `profile` surfaces auth's account-deletion capability (single consumer).
  // See CLAUDE.md "Feature-specific capabilities" / the DeleteAccountCubit
  // worked example.
  'profile': {
    'auth/presentation/bloc/delete_account_cubit.dart',
    'auth/presentation/bloc/delete_account_state.dart',
  },
  // `bookmarks` surfaces two collections capabilities (single consumer each):
  // the "add to collection" sheet on the bookmark detail screen, and the
  // collections list embedded in the bookmarks "Collections" tab. Home reads
  // collections through the shared `CollectionsReader` contract instead, so
  // bookmarks remains the only consumer of these presentation widgets.
  'bookmarks': {
    'collections/presentation/widgets/add_to_collection_sheet.dart',
    'collections/presentation/widgets/collections_list_view.dart',
  },
};

void main() {
  final featuresDir = Directory('lib/features');

  test('lib/features exists (run from the package root)', () {
    expect(
      featuresDir.existsSync(),
      isTrue,
      reason:
          'Expected to find lib/features relative to the current '
          'directory. Run this test from the package root.',
    );
  });

  final featureNames = featuresDir
      .listSync()
      .whereType<Directory>()
      .map((dir) => _posix(dir.path).split('/').last)
      .toSet();

  final crossFeatureImports = _collectCrossFeatureImports(
    featuresDir,
    featureNames,
  );

  test(
    'no feature imports another feature outside the documented allowlist',
    () {
      final violations = crossFeatureImports
          .where(
            (i) =>
                !(_allowedCrossFeatureImports[i.sourceFeature]?.contains(
                      i.targetPath,
                    ) ??
                    false),
          )
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'Cross-feature imports break the feature boundary documented in '
            'CLAUDE.md. Read shared state through a shared/ contract, or — if '
            'this is a deliberate single-consumer capability — add it to '
            '_allowedCrossFeatureImports in this test.\n\n'
            '${violations.map((v) => '  $v').join('\n')}',
      );
    },
  );

  test('every allowlisted capability import still exists (no stale entries)', () {
    final actual = crossFeatureImports
        .map((i) => '${i.sourceFeature} -> ${i.targetPath}')
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

/// A single import that crosses from one feature into another.
class _CrossFeatureImport {
  _CrossFeatureImport({
    required this.file,
    required this.line,
    required this.sourceFeature,
    required this.targetFeature,
    required this.targetPath,
    required this.uri,
  });

  /// Path of the importing file, relative to the package root.
  final String file;

  /// 1-based line number of the import directive.
  final int line;

  /// Feature that owns [file].
  final String sourceFeature;

  /// Feature being imported.
  final String targetFeature;

  /// Import target relative to `lib/features/`
  /// (e.g. `auth/presentation/bloc/delete_account_cubit.dart`).
  final String targetPath;

  /// The raw import URI as written in source.
  final String uri;

  @override
  String toString() =>
      '$file:$line imports $sourceFeature -> $uri '
      '(resolves to features/$targetPath)';
}

/// Matches `import '...'` / `export '...'` and captures the URI.
final _importDirective = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
);

List<_CrossFeatureImport> _collectCrossFeatureImports(
  Directory featuresDir,
  Set<String> featureNames,
) {
  final results = <_CrossFeatureImport>[];

  final dartFiles = featuresDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final relPath = _posix(file.path);
    final sourceFeature = _featureOf(relPath, featureNames);
    if (sourceFeature == null) continue;

    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final match = _importDirective.firstMatch(lines[i]);
      if (match == null) continue;

      final uri = match.group(1)!;
      final targetPath = _resolveFeatureTarget(uri, relPath);
      if (targetPath == null) continue;

      final targetFeature = targetPath.split('/').first;
      if (targetFeature == sourceFeature) continue;

      results.add(
        _CrossFeatureImport(
          file: relPath,
          line: i + 1,
          sourceFeature: sourceFeature,
          targetFeature: targetFeature,
          targetPath: targetPath,
          uri: uri,
        ),
      );
    }
  }

  return results;
}

/// Returns the feature segment that owns [relPath], or `null` if the path is
/// not directly under a known feature.
String? _featureOf(String relPath, Set<String> featureNames) {
  const prefix = 'lib/features/';
  if (!relPath.startsWith(prefix)) return null;
  final rest = relPath.substring(prefix.length);
  final feature = rest.split('/').first;
  return featureNames.contains(feature) ? feature : null;
}

/// Resolves an import [uri] (from a file at [fromRelPath]) to its target path
/// relative to `lib/features/`, or `null` if it doesn't point into a feature.
String? _resolveFeatureTarget(String uri, String fromRelPath) {
  const featuresPrefix = 'lib/features/';

  // Absolute package import into this package's features.
  const packageFeatures = 'package:$_packageName/features/';
  if (uri.startsWith(packageFeatures)) {
    return uri.substring(packageFeatures.length);
  }

  // Any other package: import (flutter, workspace packages, ...) is fine.
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;

  // Relative import: resolve against the importing file's directory.
  final fromDir = _posix(_dirname(fromRelPath));
  final resolved = _normalize('$fromDir/$uri');
  if (!resolved.startsWith(featuresPrefix)) return null;
  return resolved.substring(featuresPrefix.length);
}

String _dirname(String path) {
  final i = path.lastIndexOf('/');
  return i < 0 ? '.' : path.substring(0, i);
}

/// Normalizes a POSIX-style path, collapsing `.` and `..` segments.
String _normalize(String path) {
  final out = <String>[];
  for (final part in path.split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (out.isNotEmpty && out.last != '..') {
        out.removeLast();
      } else {
        out.add(part);
      }
    } else {
      out.add(part);
    }
  }
  return out.join('/');
}

/// Converts a filesystem path to POSIX separators so the test behaves the same
/// on Windows CI runners.
String _posix(String path) => path.replaceAll(r'\', '/');
