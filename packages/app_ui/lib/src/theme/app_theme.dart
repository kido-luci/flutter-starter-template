import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_elevation.dart';
import 'app_radius.dart';
import 'semantic_colors.dart';

/// Shared component theming applied to both [AppTheme.light] and
/// [AppTheme.dark].
///
/// Centralizing this as one [FlexSubThemesData] keeps the two brightness
/// variants visually consistent and lets every Material widget (cards,
/// inputs, buttons, dialogs, navigation, ...) pick up polished defaults from
/// the design tokens (`AppRadius`, `AppElevation`) instead of each feature
/// styling them inline.
const _componentThemes = FlexSubThemesData(
  // Cards: rounded and gently lifted, matching the "lifted" look used
  // elsewhere (e.g. `AppScaffold`'s loading overlay, `AppElevation.cardShadow`).
  cardRadius: AppRadius.lg,
  cardElevation: AppElevation.sm,

  // Inputs: filled, borderless until focused — converging with the look
  // hand-built in `AppTextField` so both paths look the same.
  inputDecoratorRadius: AppRadius.lg,
  inputDecoratorIsFilled: true,
  inputDecoratorBorderType: FlexInputBorderType.outline,
  inputDecoratorUnfocusedBorderIsColored: false,
  inputDecoratorFocusedBorderWidth: 1.5,

  // Buttons / FAB / chips: radius scale consistent with `AppButton._style()`
  // (10/14/16 across small/medium/large) and elevation 2 for primary actions.
  filledButtonRadius: 14,
  elevatedButtonRadius: 14,
  elevatedButtonElevation: AppElevation.md - 1,
  outlinedButtonRadius: 14,
  textButtonRadius: 14,
  fabRadius: AppRadius.lg,
  chipRadius: AppRadius.sm,

  // Dialogs / bottom sheets: rounded, with a drag handle on sheets.
  dialogRadius: AppRadius.xl,
  bottomSheetRadius: AppRadius.xl,

  // Navigation, snackbars, list tiles, dividers: rounded indicator, floating
  // snackbar with matching radius, and a subtle hairline divider.
  navigationBarIndicatorRadius: AppRadius.lg,
  snackBarRadius: AppRadius.sm,
  snackBarElevation: AppElevation.md,
  useM2StyleDividerInM3: false,

  // AppBar: flat, doesn't pick up extra elevation/tint when content scrolls
  // beneath it.
  appBarScrolledUnderElevation: AppElevation.none,
);

/// The app's centralized theme.
///
/// Built on `flex_color_scheme` so light and dark variants share a single
/// seed [FlexScheme] and component theming (see [_componentThemes]),
/// guaranteeing that visual polish propagates to every feature automatically.
class AppTheme {
  const AppTheme._();

  /// The light theme variant.
  static ThemeData light({FlexScheme scheme = FlexScheme.blue}) {
    return FlexThemeData.light(
      scheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
      subThemesData: _componentThemes,
      appBarElevation: AppElevation.none,
      appBarStyle: FlexAppBarStyle.surface,
    ).copyWith(
      extensions: const [SemanticColors.light],
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
    );
  }

  /// The dark theme variant.
  static ThemeData dark({FlexScheme scheme = FlexScheme.blue}) {
    return FlexThemeData.dark(
      scheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
      subThemesData: _componentThemes,
      appBarElevation: AppElevation.none,
      appBarStyle: FlexAppBarStyle.surface,
    ).copyWith(
      extensions: const [SemanticColors.dark],
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
    );
  }
}

extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  SemanticColors get semanticColors =>
      theme.extension<SemanticColors>() ?? SemanticColors.light;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}
