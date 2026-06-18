import 'dart:async';

import 'package:feature_auth/feature_auth.dart';
import 'package:feature_bookmarks/feature_bookmarks.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_splash/feature_splash.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'widgets/app_shell.dart';

part 'router.g.dart';

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(path: '/', name: 'home'),
      ],
    ),
    TypedStatefulShellBranch<BookmarksBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<BookmarksListRoute>(
          path: '/bookmarks',
          name: 'bookmarks',
        ),
      ],
    ),
    TypedStatefulShellBranch<NotificationsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<NotificationsRoute>(
          path: '/notifications',
          name: 'notifications',
        ),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ProfileRoute>(
          path: '/profile',
          name: 'profile',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<ChangePasswordRoute>(
              path: 'change-password',
              name: 'change-password',
            ),
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

class BookmarksBranchData extends StatefulShellBranchData {
  const BookmarksBranchData();
}

class NotificationsBranchData extends StatefulShellBranchData {
  const NotificationsBranchData();
}

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

class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsScreen();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

class ChangePasswordRoute extends GoRouteData with $ChangePasswordRoute {
  const ChangePasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChangePasswordScreen();
}

class BookmarksListRoute extends GoRouteData with $BookmarksListRoute {
  const BookmarksListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarksListScreen();
}

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

/// Builds the app router and wires auth redirects to [bloc] state changes.
///
/// [featureRoutes] are the non-shell routes contributed by the feature
/// packages (and auth's login/register). They are mounted alongside the
/// generated shell routes ([$appRoutes]) so adding a feature's screens never
/// edits this file — the feature ships its own route table.
({GoRouter router, DeepLinkState deepLink}) buildRouterWithDeepLink(
  AuthBloc bloc, {
  required List<RouteBase> featureRoutes,
  List<NavigatorObserver>? observers,
}) {
  final deepLink = DeepLinkState();
  final homeLocation = const HomeRoute().location;
  final splashLocation = const SplashRoute().location;
  const loginLocation = AuthRoutes.login;
  const registerLocation = AuthRoutes.register;

  final router = GoRouter(
    // No initialLocation — GoRouter resolves the platform deep-link URI on
    // cold start and the redirect below captures it before sending the user
    // through splash / auth.
    routes: [...$appRoutes, ...featureRoutes],
    observers: observers,
    refreshListenable: _BlocListenable(bloc.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final auth = bloc.state;

      // ── Phase 1: Before splash completes ──
      // Intercept every navigation until restoreSession and the splash
      // minimum display time complete. The splash screen flips
      // splashCompleted after both gates finish.
      if (!deepLink.splashCompleted) {
        // Already on splash — let it run.
        if (location == splashLocation) return null;
        // Any other location (deep link or default '/') — capture and
        // send through splash first.
        deepLink.pendingRedirect ??= state.uri.toString();
        return splashLocation;
      }

      // ── Phase 2: Unauthenticated ──
      // Splash completed with no session, or user signed out.
      if (auth is AuthInitial || auth is AuthFailure) {
        if (location == loginLocation || location == registerLocation) {
          return null;
        }
        deepLink.pendingRedirect ??= state.uri.toString();
        return loginLocation;
      }

      // ── Phase 3: Authenticated (incl. mid-sign-out) ──
      // AuthSigningOut still holds a user; let the screen stay put until the
      // op completes and AuthBloc emits AuthInitial.
      if (auth is AuthAuthenticated || auth is AuthSigningOut) {
        final target = deepLink.pendingRedirect;
        if (target != null) {
          deepLink.pendingRedirect = null;
          if (target != state.uri.toString()) return target;
        }
        // Leaving splash or login/register — restore the captured deep link.
        if (location == splashLocation ||
            location == loginLocation ||
            location == registerLocation) {
          return homeLocation;
        }
        // Already on a valid, protected route — allow it.
        return null;
      }

      // AuthSubmitting — don't interfere.
      return null;
    },
  );

  return (router: router, deepLink: deepLink);
}

/// Adapts a [Stream] to the [Listenable] contract GoRouter needs for
/// `refreshListenable`.
class _BlocListenable extends ChangeNotifier {
  _BlocListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
