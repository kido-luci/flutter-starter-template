import 'dart:async';
import 'dart:developer' as developer;

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
// fst:auth:start
import 'package:feature_auth/feature_auth.dart';
// fst:auth:end
// fst:feature:notifications:start
import 'package:feature_notifications/feature_notifications.dart';
// fst:feature:notifications:end
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_contracts/shared_contracts.dart';
// fst:auth:start
import 'package:shared_ui/shared_ui.dart';
// fst:auth:end
import 'package:theme/theme.dart';

import '../core/extensions/build_context_extensions.dart';
import 'di/injection.dart';
import 'feature_module.dart';
import 'features.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    // fst:auth:start
    this.authBloc,
    this.session,
    // fst:auth:end
    this.themeBloc,
    this.features,
    this.navigatorObservers,
    this.videoPlayerService,
  });

  // fst:auth:start
  final AuthBloc? authBloc;
  final Session? session;
  // fst:auth:end
  final ThemeBloc? themeBloc;

  /// Optional feature overrides — primarily for testing. Defaults to
  /// [enabledFeatures] from `features.dart`.
  final List<FeatureModule>? features;
  final List<NavigatorObserver>? navigatorObservers;
  final VideoPlayerService? videoPlayerService;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // fst:auth:start
  late final AuthBloc _authBloc;
  // fst:auth:end
  late final ThemeBloc _themeBloc;
  Session? _session;
  // fst:auth:start
  // Whether this State created _session (and so must dispose it). An injected
  // widget.session is owned by the caller and must outlive this widget.
  bool _ownsSession = false;
  // fst:auth:end
  late final GoRouter _router;
  late final DeepLinkState _deepLink;
  late final List<FeatureSyncController> _syncControllers;
  late final VideoPlayerService _videoPlayerService;

  @override
  void initState() {
    super.initState();
    // fst:auth:start
    _authBloc = widget.authBloc ?? getIt<AuthBloc>();
    // fst:auth:end
    _themeBloc = widget.themeBloc ?? getIt<ThemeBloc>();
    // fst:auth:start
    _session = widget.session ?? AuthSession(_authBloc);
    _ownsSession = widget.session == null;
    // fst:auth:end
    final features = widget.features ?? enabledFeatures;
    final result = buildRouterWithDeepLink(
      _session,
      featureRoutes: [
        // fst:auth:start
        ...authRoutes,
        // fst:auth:end
        for (final f in features) ...f.routes,
      ],
      // fst:auth:start
      loginLocation: AuthRoutes.login,
      registerLocation: AuthRoutes.register,
      // fst:auth:end
      observers: widget.navigatorObservers ?? [getIt<AnalyticsRouteObserver>()],
    );
    _router = result.router;
    _deepLink = result.deepLink;
    _syncControllers = features
        .map((f) => f.syncController)
        .whereType<FeatureSyncController>()
        .toList(growable: false);
    _videoPlayerService =
        widget.videoPlayerService ?? getIt<VideoPlayerService>();
    final session = _session;
    if (session != null) {
      session.addListener(_onSessionChanged);
    } else {
      // No auth pillar: nothing gates sync, so run it for the whole app.
      _setSyncActive(active: true);
    }
  }

  void _onSessionChanged() {
    // Sync runs only for a settled, signed-in user — not while signing out or
    // still restoring (both leave no active user).
    final session = _session!;
    _setSyncActive(
      active: session.currentUser != null && !session.isSigningOut,
    );
  }

  void _setSyncActive({required bool active}) {
    for (final c in _syncControllers) {
      unawaited(
        (active ? c.start() : c.stop()).catchError(
          (Object error, StackTrace stackTrace) {
            developer.log(
              'Feature sync lifecycle failed',
              name: 'App',
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _session?.removeListener(_onSessionChanged);
    for (final c in _syncControllers) {
      unawaited(
        c.stop().catchError((Object error, StackTrace stackTrace) {
          developer.log(
            'Feature sync stop failed during dispose',
            name: 'App',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    }
    // fst:auth:start
    if (_ownsSession) {
      _session?.dispose();
    }
    // fst:auth:end
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget app = RepositoryProvider<VideoPlayerService>.value(
      value: _videoPlayerService,
      child: MultiBlocProvider(
        providers: [
          // fst:auth:start
          BlocProvider.value(value: _authBloc),
          // fst:auth:end
          BlocProvider.value(value: _themeBloc),
          // fst:feature:notifications:start
          BlocProvider.value(value: getIt<NotificationsBloc>()),
          // fst:feature:notifications:end
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.appTitle,
            theme: AppTheme.light(scheme: themeState.scheme),
            darkTheme: AppTheme.dark(scheme: themeState.scheme),
            themeMode: themeState.mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          ),
        ),
      ),
    );
    // fst:auth:start
    app = SessionScope(session: _session!, child: app);
    // fst:auth:end
    return DeepLinkScope(deepLink: _deepLink, child: app);
  }
}
