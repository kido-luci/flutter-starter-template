// Drives `integration_test/screenshots_test.dart` and persists each
// `takeScreenshot` call's bytes to `doc/screenshots/<name>.png` so the README
// gallery can reference real, up-to-date captures of the assembled app.
//
// Run via `fvm flutter drive` (see the doc comment at the top of
// `integration_test/screenshots_test.dart` for the exact command).

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('doc/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
