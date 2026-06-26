// Unit tests for the splash/auth redirect state machine that drives the app's
// cold-start flow. The logic lives in `resolveSplashRedirect`
// (lib/app/router.dart), extracted from GoRouter's `redirect` callback so the
// three phases can be exercised without assembling a router + widget tree.
//
// The phases:
//   1. Before splash completes — capture the requested URI, force /splash.
//   2. Splash done, unauthenticated — force /login (allowing login/register).
//   3. Splash done, authenticated — replay a captured deep link, otherwise
//      bounce off splash/login/register to home and allow protected routes.

import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_starter_template/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

const splash = '/splash';
const home = '/';
const String login = AuthRoutes.login;
const String register = AuthRoutes.register;

/// Builds a fresh deep-link gate for one navigation.
DeepLinkState gate({bool splashCompleted = false, String? pending}) {
  return DeepLinkState()
    ..splashCompleted = splashCompleted
    ..pendingRedirect = pending;
}

/// Resolves a redirect with the app's real locations wired in. [requestedUri]
/// defaults to [location] (the common case where they match).
String? resolve({
  required AuthState auth,
  required String location,
  required DeepLinkState deepLink,
  String? requestedUri,
}) {
  return resolveSplashRedirect(
    status: sessionStatusFor(auth),
    location: location,
    requestedUri: requestedUri ?? location,
    deepLink: deepLink,
    splashLocation: splash,
    loginLocation: login,
    registerLocation: register,
    homeLocation: home,
  );
}

void main() {
  group('Phase 1 — before splash completes', () {
    test('stays on splash when already there, capturing nothing', () {
      final deepLink = gate();
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: splash,
          deepLink: deepLink,
        ),
        isNull,
      );
      expect(deepLink.pendingRedirect, isNull);
    });

    test('captures the default location and routes through splash', () {
      final deepLink = gate();
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: home,
          deepLink: deepLink,
        ),
        splash,
      );
      expect(deepLink.pendingRedirect, home);
    });

    test('captures a cold-start deep link before sending through splash', () {
      final deepLink = gate();
      expect(
        resolve(
          auth: const AuthState.authenticated(testUser),
          location: '/bookmarks',
          deepLink: deepLink,
        ),
        splash,
      );
      expect(deepLink.pendingRedirect, '/bookmarks');
    });

    test('does not overwrite an already-captured target', () {
      final deepLink = gate(pending: '/bookmarks');
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: '/notifications',
          deepLink: deepLink,
        ),
        splash,
      );
      expect(deepLink.pendingRedirect, '/bookmarks');
    });
  });

  group('Phase 2 — splash done, unauthenticated', () {
    test('AuthInitial on a protected route captures it and goes to login', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: '/profile',
          deepLink: deepLink,
        ),
        login,
      );
      expect(deepLink.pendingRedirect, '/profile');
    });

    test('AuthFailure behaves like AuthInitial', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.failure(testFailure),
          location: '/profile',
          deepLink: deepLink,
        ),
        login,
      );
    });

    test('allows the login route', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: login,
          deepLink: deepLink,
        ),
        isNull,
      );
      expect(deepLink.pendingRedirect, isNull);
    });

    test('allows the register route', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: register,
          deepLink: deepLink,
        ),
        isNull,
      );
    });

    test('does not overwrite an already-captured target', () {
      final deepLink = gate(splashCompleted: true, pending: '/bookmarks');
      expect(
        resolve(
          auth: const AuthState.initial(),
          location: '/profile',
          deepLink: deepLink,
        ),
        login,
      );
      expect(deepLink.pendingRedirect, '/bookmarks');
    });
  });

  group('Phase 3 — splash done, authenticated', () {
    test('replays a captured deep link, beating the splash→home bounce', () {
      final deepLink = gate(splashCompleted: true, pending: '/bookmarks');
      expect(
        resolve(
          auth: const AuthState.authenticated(testUser),
          location: splash,
          deepLink: deepLink,
        ),
        '/bookmarks',
      );
      expect(deepLink.pendingRedirect, isNull);
    });

    test(
      'clears the captured target without redirecting when already there',
      () {
        final deepLink = gate(splashCompleted: true, pending: '/bookmarks');
        expect(
          resolve(
            auth: const AuthState.authenticated(testUser),
            location: '/bookmarks',
            deepLink: deepLink,
          ),
          isNull,
        );
        expect(deepLink.pendingRedirect, isNull);
      },
    );

    test('bounces off splash to home', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.authenticated(testUser),
          location: splash,
          deepLink: deepLink,
        ),
        home,
      );
    });

    test('bounces off login to home', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.authenticated(testUser),
          location: login,
          deepLink: deepLink,
        ),
        home,
      );
    });

    test('bounces off register to home', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.authenticated(testUser),
          location: register,
          deepLink: deepLink,
        ),
        home,
      );
    });

    test('allows a protected route', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.authenticated(testUser),
          location: '/profile',
          deepLink: deepLink,
        ),
        isNull,
      );
    });

    test('AuthSigningOut keeps the user on the current protected route', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.signingOut(testUser),
          location: '/profile',
          deepLink: deepLink,
        ),
        isNull,
      );
    });

    test('AuthSigningOut still bounces off splash to home', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.signingOut(testUser),
          location: splash,
          deepLink: deepLink,
        ),
        home,
      );
    });
  });

  group('transient states do not interfere once splash has completed', () {
    test('AuthSubmitting allows the navigation', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.submitting(),
          location: '/profile',
          deepLink: deepLink,
        ),
        isNull,
      );
    });

    test('AuthRestoring allows the navigation', () {
      final deepLink = gate(splashCompleted: true);
      expect(
        resolve(
          auth: const AuthState.restoring(),
          location: '/profile',
          deepLink: deepLink,
        ),
        isNull,
      );
    });
  });
}
