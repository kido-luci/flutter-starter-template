import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('authRoutes', () {
    final paths = authRoutes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    test('contributes the unauthenticated entry paths', () {
      expect(paths, [AuthRoutes.login, AuthRoutes.register]);
    });

    test('does not include change-password (mounted under the profile tab)', () {
      // change-password is nested inside the app shell's profile branch, so the
      // shell mounts it — auth must not also contribute it as a top-level route.
      expect(paths, isNot(contains(AuthRoutes.changePassword)));
    });
  });
}
