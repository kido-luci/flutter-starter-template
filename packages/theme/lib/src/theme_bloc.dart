import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

part 'theme_event.dart';

const _kThemeModeKey = 'app.theme_mode';
const _kThemeSchemeKey = 'app.theme_scheme';

@lazySingleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._prefs, this._analytics) : super(_readInitial(_prefs)) {
    on<ThemeModeChanged>(_onModeChanged, transformer: sequential());
    on<ThemeSchemeChanged>(_onSchemeChanged, transformer: sequential());
  }

  final SharedPreferences _prefs;
  final AnalyticsService _analytics;

  static ThemeState _readInitial(SharedPreferences prefs) {
    final modeRaw = prefs.getString(_kThemeModeKey);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == modeRaw,
      orElse: () => ThemeMode.system,
    );

    final schemeRaw = prefs.getString(_kThemeSchemeKey);
    final scheme = FlexScheme.values.firstWhere(
      (s) => s.name == schemeRaw,
      orElse: () => ThemeState.defaultScheme,
    );

    return ThemeState(mode: mode, scheme: scheme);
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.mode == state.mode) return;
    emit(state.copyWith(mode: event.mode));
    await _prefs.setString(_kThemeModeKey, event.mode.name);
    _analytics.trackThemeModeChanged(event.mode.name).fire();
  }

  Future<void> _onSchemeChanged(
    ThemeSchemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.scheme == state.scheme) return;
    emit(state.copyWith(scheme: event.scheme));
    await _prefs.setString(_kThemeSchemeKey, event.scheme.name);
    _analytics.trackThemeSchemeChanged(event.scheme.name).fire();
  }
}
