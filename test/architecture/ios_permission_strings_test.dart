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

  // The permission usage-description keys whose copy must stay generic.
  const usageKeys = <String>[
    'NSCameraUsageDescription',
    'NSMicrophoneUsageDescription',
    'NSPhotoLibraryUsageDescription',
    'NSPhotoLibraryAddUsageDescription',
  ];

  // Words tied to the template's own demo features — copy that would be wrong
  // for an app scaffolded from this template.
  const bannedTerms = <String>['bookmark', 'collection'];

  test('every declared usage description is present and non-empty', () {
    for (final key in usageKeys) {
      expect(
        descriptions[key]?.trim().isNotEmpty ?? false,
        isTrue,
        reason: '$key is missing or empty in ios/Runner/Info.plist.',
      );
    }
  });

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

  // These permissions exist only for the bookmarks media-capture flow. The
  // `fst` CLI strips them when bookmarks is removed by stripping the
  // `fst:feature:bookmarks` region — so every usage key must stay inside it,
  // otherwise a trimmed app ships permissions it never requests.
  test(
    'every usage description sits inside an fst:feature:bookmarks region',
    () {
      final xml = infoPlist.readAsStringSync();
      final start = xml.indexOf('fst:feature:bookmarks:start');
      final end = xml.indexOf('fst:feature:bookmarks:end');

      expect(
        start,
        greaterThanOrEqualTo(0),
        reason:
            'Missing the fst:feature:bookmarks:start marker. The CLI needs '
            'it to strip the media permissions when bookmarks is removed.',
      );
      expect(
        end,
        greaterThan(start),
        reason: 'fst:feature:bookmarks:end must follow its :start marker.',
      );

      final outside = usageKeys.where((key) {
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
