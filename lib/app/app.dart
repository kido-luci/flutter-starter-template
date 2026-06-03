import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:theme/theme.dart';

import '../core/extensions/build_context_extensions.dart';
import '../features/auth/presentation/auth_session.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import '../l10n/app_localizations.dart';
import '../shared/domain/session.dart';
import '../shared/presentation/session_scope.dart';
import 'di/injection.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    this.authBloc,
    this.themeBloc,
    this.bookmarksSync,
    this.navigatorObservers,
    this.session,
    this.videoPlayerService,
  });

  final AuthBloc? authBloc;
  final ThemeBloc? themeBloc;
  final BookmarksSyncController? bookmarksSync;
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
  late final BookmarksSyncController _sync;
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
    _sync = widget.bookmarksSync ?? getIt<BookmarksSyncController>();
    _videoPlayerService =
        widget.videoPlayerService ?? getIt<VideoPlayerService>();
    _authSub = _authBloc.stream.listen(_onAuthChanged);
    // Session restoration is driven by SplashScreen so it can gate routing
    // on completion instead of racing the redirect.
  }

  void _onAuthChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _sync.start();
    } else {
      _sync.stop();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _sync.stop();
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
