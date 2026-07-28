// Architecture guardrail: keeps the iOS permission usage descriptions generic
// and app-name-aware, so every project scaffolded from this template ships
// correct copy instead of the template's own demo-feature wording.
//
// The `fst` CLI rewrites the iOS display name (the APP_DISPLAY_NAME build
// setting in `ios/Flutter/*.xcconfig`) but does NOT touch these strings. So a
// usage description must not name a template-specific feature (e.g.
// "bookmarks") and should interpolate the app name via the
// `$(APP_DISPLAY_NAME)` build setting — which Xcode resolves at build time —
// rather than hardcoding "This app".
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final infoPlist = File('ios/Runner/Info.plist');
  late final Map<String, String> descriptions;

  setUpAll(() {
    expect(
      infoPlist.existsSync(),
      isTrue,
      reason:
          'Expected to find ios/Runner/Info.plist relative to the current '
          'directory. Run this test from the repository root.',
    );
    descriptions = _usageDescriptions(infoPlist);
  });

  test('ios/Runner/Info.plist exists (run from the repository root)', () {
    expect(
      infoPlist.existsSync(),
      isTrue,
      reason:
          'Expected to find ios/Runner/Info.plist relative to the current '
          'directory. Run this test from the repository root.',
    );
  });

  // The permission usage-description keys whose copy must stay generic. All
  // four are declared for the bookmarks media-capture flow, so a project
  // scaffolded without that feature declares none of them — the assertions
  // that require them are marked, the rest hold either way.
  //
  // This list is deliberately NOT inside a marker region: the region test
  // below needs it, and that test cannot be marked because its own source
  // contains the marker strings it searches for — the stripper matches by
  // substring and would close the region on them.
  const usageKeys = <String>[
    'NSCameraUsageDescription',
    'NSMicrophoneUsageDescription',
    'NSPhotoLibraryUsageDescription',
    'NSPhotoLibraryAddUsageDescription',
  ];

  // Words tied to the template's own demo features — copy that would be wrong
  // for an app scaffolded from this template.
  const bannedTerms = <String>['bookmark', 'collection'];

  // fst:feature:bookmarks:start
  test('every declared usage description is present and non-empty', () {
    for (final key in usageKeys) {
      expect(
        descriptions[key]?.trim().isNotEmpty ?? false,
        isTrue,
        reason: '$key is missing or empty in ios/Runner/Info.plist.',
      );
    }
  });
  // fst:feature:bookmarks:end

  test('usage descriptions name no template-specific demo feature', () {
    final offenders = <String>[];
    descriptions.forEach((key, value) {
      final lower = value.toLowerCase();
      for (final term in bannedTerms) {
        if (lower.contains(term)) {
          offenders.add('$key mentions "$term": "$value"');
        }
      }
    });
    expect(
      offenders,
      isEmpty,
      reason:
          'iOS permission strings must be generic so scaffolded apps inherit '
          'correct copy. Remove the feature-specific wording:\n\n'
          '${offenders.join('\n')}',
    );
  });

  // fst:feature:bookmarks:start
  test(
    r'usage descriptions interpolate the app name via $(APP_DISPLAY_NAME)',
    () {
      final missing = usageKeys.where((key) {
        final value = descriptions[key] ?? '';
        return !value.contains(r'$(APP_DISPLAY_NAME)');
      }).toList();
      expect(
        missing,
        isEmpty,
        reason:
            'Interpolate APP_DISPLAY_NAME (the build setting the CLI rewrites, '
            'not these strings) so the copy resolves to the app name at build '
            'time. Missing in:\n\n${missing.map((k) => '  $k').join('\n')}',
      );
    },
  );
  // fst:feature:bookmarks:end

  // These permissions exist only for the bookmarks media-capture flow. The
  // `fst` CLI strips them when bookmarks is removed by stripping the
  // `fst:feature:bookmarks` region — so every usage key must stay inside it,
  // otherwise a trimmed app ships permissions it never requests.
  test(
    'every usage description sits inside an fst:feature:bookmarks region',
    () {
      final xml = infoPlist.readAsStringSync();
      // Built by interpolation on purpose. The CLI's stripper matches marker
      // needles by plain substring, so a source line spelling one out in full
      // would open or close a region in this very file.
      const marker = 'fst:feature:bookmarks';
      final start = xml.indexOf('$marker:start');
      final end = xml.indexOf('$marker:end');

      // A project scaffolded without bookmarks declares none of these keys,
      // so there is nothing left to keep inside a region and the invariant
      // holds vacuously. Asserted rather than assumed: if any key survived
      // without its region, the checks below still run and catch it.
      final declared = usageKeys
          .where((key) => xml.contains('<key>$key</key>'))
          .toList();
      if (declared.isEmpty) return;

      expect(
        start,
        greaterThanOrEqualTo(0),
        reason:
            'Missing the $marker start marker. The CLI needs it to strip the '
            'media permissions when bookmarks is removed.',
      );
      expect(
        end,
        greaterThan(start),
        reason: 'The $marker end marker must follow its start marker.',
      );

      final outside = declared.where((key) {
        final at = xml.indexOf('<key>$key</key>');
        return at < start || at > end;
      }).toList();
      expect(
        outside,
        isEmpty,
        reason:
            'These usage keys are outside the fst:feature:bookmarks region, '
            'so the CLI would leave them behind when bookmarks is stripped:\n\n'
            '${outside.map((k) => '  $k').join('\n')}',
      );
    },
  );
}

/// Extracts the `<key>NS…UsageDescription</key><string>…</string>` pairs from
/// the Info.plist as a map. A deliberately small regex scan — enough to assert
/// on the usage-description copy without pulling in a full plist parser.
Map<String, String> _usageDescriptions(File infoPlist) {
  final xml = infoPlist.readAsStringSync();
  final pattern = RegExp(
    r'<key>(NS\w*UsageDescription)</key>\s*<string>(.*?)</string>',
    dotAll: true,
  );
  return {
    for (final m in pattern.allMatches(xml)) m.group(1)!: m.group(2)!,
  };
}
