import 'dart:async';
import 'dart:developer' as developer;

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:theme/theme.dart';

import '../core/extensions/build_context_extensions.dart';
import 'di/injection.dart';
import 'feature_module.dart';
import 'features.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    this.authBloc,
    this.themeBloc,
    this.features,
    this.navigatorObservers,
    this.session,
    this.videoPlayerService,
  });

  final AuthBloc? authBloc;
  final ThemeBloc? themeBloc;

  /// Optional feature overrides — primarily for testing. Defaults to
  /// [enabledFeatures] from `features.dart`.
  final List<FeatureModule>? features;
  final List<NavigatorObserver>? navigatorObservers;
  final Session? session;
  final VideoPlayerService? videoPlayerService;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final Session _session;
  late final GoRouter _router;
  late final DeepLinkState _deepLink;
  late final List<FeatureSyncController> _syncControllers;
  late final VideoPlayerService _videoPlayerService;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authBloc = widget.authBloc ?? getIt<AuthBloc>();
    _themeBloc = widget.themeBloc ?? getIt<ThemeBloc>();
    _session = widget.session ?? AuthSession(_authBloc);
    final result = buildRouterWithDeepLink(
      _authBloc,
      observers: widget.navigatorObservers ?? [getIt<AnalyticsRouteObserver>()],
    );
    _router = result.router;
    _deepLink = result.deepLink;
    _syncControllers = (widget.features ?? enabledFeatures)
        .map((f) => f.syncController)
        .whereType<FeatureSyncController>()
        .toList(growable: false);
    _videoPlayerService =
        widget.videoPlayerService ?? getIt<VideoPlayerService>();
    _authSub = _authBloc.stream.listen(_onAuthChanged);
  }

  void _onAuthChanged(AuthState state) {
    for (final c in _syncControllers) {
      unawaited(
        (state is AuthAuthenticated ? c.start() : c.stop()).catchError(
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
    _authSub?.cancel();
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
    _session.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DeepLinkScope(
      deepLink: _deepLink,
      child: SessionScope(
        session: _session,
        child: RepositoryProvider<VideoPlayerService>.value(
          value: _videoPlayerService,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _authBloc),
              BlocProvider.value(value: _themeBloc),
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
        ),
      ),
    );
  }
}
