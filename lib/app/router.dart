import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/bookmarks/presentation/screens/bookmark_detail_screen.dart';
import '../features/bookmarks/presentation/screens/bookmark_form_screen.dart';
import '../features/bookmarks/presentation/screens/bookmarks_list_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'widgets/app_shell.dart';

part 'router.g.dart';

/// Route data for showing [BookmarkFormScreen] outside the app shell.
///
/// The absolute path keeps the create flow free of persistent shell navigation.
@TypedGoRoute<BookmarkNewRoute>(path: '/bookmarks/new', name: 'bookmark_new')
class BookmarkNewRoute extends GoRouteData with $BookmarkNewRoute {
  /// Creates a [BookmarkNewRoute].
  const BookmarkNewRoute();

  /// Builds the bookmark creation screen.
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarkFormScreen();
}

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
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
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

@TypedGoRoute<LoginRoute>(path: '/login', name: 'login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<RegisterRoute>(path: '/register', name: 'register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegisterScreen();
}

class BookmarksListRoute extends GoRouteData with $BookmarksListRoute {
  const BookmarksListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarksListScreen();
}

/// Route data for the bookmark detail, declared outside the app shell so the
/// detail screen presents full-screen without the persistent bottom navigation
/// bar (mirrors [BookmarkNewRoute]).
@TypedGoRoute<BookmarkDetailRoute>(
  path: '/bookmarks/:id',
  name: 'bookmark_detail',
)
class BookmarkDetailRoute extends GoRouteData with $BookmarkDetailRoute {
  const BookmarkDetailRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookmarkDetailScreen(id: id);
}

/// Route data for editing a bookmark, declared outside the app shell so the
/// edit form presents full-screen without the persistent bottom navigation bar.
@TypedGoRoute<BookmarkEditRoute>(
  path: '/bookmarks/:id/edit',
  name: 'bookmark_edit',
)
class BookmarkEditRoute extends GoRouteData with $BookmarkEditRoute {
  const BookmarkEditRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookmarkFormScreen(id: id);
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
({GoRouter router, DeepLinkState deepLink}) buildRouterWithDeepLink(
  AuthBloc bloc, {
  List<NavigatorObserver>? observers,
}) {
  final deepLink = DeepLinkState();
  final homeLocation = const HomeRoute().location;
  final splashLocation = const SplashRoute().location;
  final loginLocation = const LoginRoute().location;
  final registerLocation = const RegisterRoute().location;

  final router = GoRouter(
    // No initialLocation — GoRouter resolves the platform deep-link URI on
    // cold start and the redirect below captures it before sending the user
    // through splash / auth.
    routes: $appRoutes,
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
