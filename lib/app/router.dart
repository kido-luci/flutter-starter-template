// fst:auth:start
import 'package:feature_auth/feature_auth.dart';
// fst:auth:end
// fst:feature:bookmarks:start
import 'package:feature_bookmarks/feature_bookmarks.dart';
// fst:feature:bookmarks:end
import 'package:feature_home/feature_home.dart';
// fst:feature:notifications:start
import 'package:feature_notifications/feature_notifications.dart';
// fst:feature:notifications:end
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_splash/feature_splash.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_contracts/shared_contracts.dart';

import 'widgets/app_shell.dart';

part 'router.g.dart';

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(path: '/', name: 'home'),
      ],
    ),
    // fst:feature:bookmarks:start
    TypedStatefulShellBranch<BookmarksBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<BookmarksListRoute>(
          path: '/bookmarks',
          name: 'bookmarks',
        ),
      ],
    ),
    // fst:feature:bookmarks:end
    // fst:feature:notifications:start
    TypedStatefulShellBranch<NotificationsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<NotificationsRoute>(
          path: '/notifications',
          name: 'notifications',
        ),
      ],
    ),
    // fst:feature:notifications:end
    TypedStatefulShellBranch<ProfileBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ProfileRoute>(
          path: '/profile',
          name: 'profile',
          routes: <TypedRoute<RouteData>>[
            // fst:auth:start
            TypedGoRoute<ChangePasswordRoute>(
              path: 'change-password',
              name: 'change-password',
            ),
            // fst:auth:end
          ],
        ),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

// fst:feature:bookmarks:start
class BookmarksBranchData extends StatefulShellBranchData {
  const BookmarksBranchData();
}
// fst:feature:bookmarks:end

// fst:feature:notifications:start
class NotificationsBranchData extends StatefulShellBranchData {
  const NotificationsBranchData();
}
// fst:feature:notifications:end

class ProfileBranchData extends StatefulShellBranchData {
  const ProfileBranchData();
}

@TypedGoRoute<SplashRoute>(path: '/splash', name: 'splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SplashScreen(
    onRestored: (context) {
      DeepLinkScope.of(context).splashCompleted = true;
      const HomeRoute().go(context);
    },
  );
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

// fst:feature:notifications:start
class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsScreen();
}
// fst:feature:notifications:end

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

// fst:auth:start
class ChangePasswordRoute extends GoRouteData with $ChangePasswordRoute {
  const ChangePasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChangePasswordScreen();
}
// fst:auth:end

// fst:feature:bookmarks:start
class BookmarksListRoute extends GoRouteData with $BookmarksListRoute {
  const BookmarksListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarksListScreen();
}
// fst:feature:bookmarks:end

/// Tracks deep-link targets and splash-screen completion so the redirect can
/// capture cold-start URIs and replay them after auth resolves.
class DeepLinkState {
  String? pendingRedirect;
  bool splashCompleted = false;
}

class DeepLinkScope extends InheritedWidget {
  const DeepLinkScope({
    super.key,
    required this.deepLink,
    required super.child,
  });

  final DeepLinkState deepLink;

  static DeepLinkState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DeepLinkScope>();
    assert(scope != null, 'No DeepLinkScope found in context.');
    return scope!.deepLink;
  }

  @override
  bool updateShouldNotify(DeepLinkScope oldWidget) =>
      deepLink != oldWidget.deepLink;
}

/// Builds the app router and wires auth redirects to [session] status changes.
///
/// [featureRoutes] are the non-shell routes contributed by the feature
/// packages (and auth's login/register). They are mounted alongside the
/// generated shell routes ([$appRoutes]) so adding a feature's screens never
/// edits this file — the feature ships its own route table.
({GoRouter router, DeepLinkState deepLink}) buildRouterWithDeepLink(
  Session? session, {
  required List<RouteBase> featureRoutes,
  String? loginLocation,
  String? registerLocation,
  List<NavigatorObserver>? observers,
}) {
  final deepLink = DeepLinkState();
  final homeLocation = const HomeRoute().location;
  final splashLocation = const SplashRoute().location;

  final router = GoRouter(
    // No initialLocation — GoRouter resolves the platform deep-link URI on
    // cold start and the redirect below captures it before sending the user
    // through splash / auth.
    routes: [...$appRoutes, ...featureRoutes],
    observers: observers,
    refreshListenable: session,
    redirect: (context, state) => resolveSplashRedirect(
      status: session?.status,
      location: state.matchedLocation,
      requestedUri: state.uri.toString(),
      deepLink: deepLink,
      splashLocation: splashLocation,
      loginLocation: loginLocation,
      registerLocation: registerLocation,
      homeLocation: homeLocation,
    ),
  );

  return (router: router, deepLink: deepLink);
}

/// Resolves the auth/splash redirect for a single navigation.
///
/// Pure decision function behind [buildRouterWithDeepLink]'s `redirect`: given
/// the current session [status], the [location] GoRouter matched, the
/// [requestedUri] the user is trying to reach, and the mutable [deepLink] gate,
/// it returns the location to redirect to, or `null` to allow the navigation.
/// Extracted so the three-phase state machine can be unit-tested without
/// assembling a full [GoRouter] and widget tree.
///
/// Mutates [DeepLinkState.pendingRedirect] to capture a cold-start/deep-link
/// target before splash/auth, then replays it once the user is authenticated.
@visibleForTesting
String? resolveSplashRedirect({
  required SessionStatus? status,
  required String location,
  required String requestedUri,
  required DeepLinkState deepLink,
  required String splashLocation,
  required String homeLocation,
  String? loginLocation,
  String? registerLocation,
}) {
  // ── Phase 1: Before splash completes ──
  // Intercept every navigation until restoreSession and the splash minimum
  // display time complete. The splash screen flips splashCompleted after both
  // gates finish.
  if (!deepLink.splashCompleted) {
    // Already on splash — let it run.
    if (location == splashLocation) return null;
    // Any other location (deep link or default '/') — capture and send
    // through splash first.
    deepLink.pendingRedirect ??= requestedUri;
    return splashLocation;
  }

  // ── No auth pillar (status == null) ──
  // Splash is the only gate: replay any captured deep link, bounce off splash
  // to home, and otherwise allow the navigation.
  if (status == null) {
    final target = deepLink.pendingRedirect;
    if (target != null) {
      deepLink.pendingRedirect = null;
      if (target != requestedUri) return target;
    }
    if (location == splashLocation) return homeLocation;
    return null;
  }

  // ── Phase 2: Unauthenticated ──
  // Splash completed with no session, or user signed out.
  if (status == SessionStatus.unauthenticated) {
    if (location == loginLocation || location == registerLocation) {
      return null;
    }
    deepLink.pendingRedirect ??= requestedUri;
    return loginLocation;
  }

  // ── Phase 3: Authenticated (incl. mid-sign-out) ──
  // A signing-out session still holds a user; let the screen stay put until the
  // op completes and the session settles to unauthenticated.
  if (status == SessionStatus.authenticated) {
    final target = deepLink.pendingRedirect;
    if (target != null) {
      deepLink.pendingRedirect = null;
      if (target != requestedUri) return target;
    }
    // No pending deep link; bounce off splash/login/register to home.
    if (location == splashLocation ||
        location == loginLocation ||
        location == registerLocation) {
      return homeLocation;
    }
    // Already on a valid, protected route — allow it.
    return null;
  }

  // SessionStatus.unknown — still restoring/submitting; don't interfere.
  return null;
}
