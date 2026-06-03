part of 'profile_widgets.dart';

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return RadioGroup<ThemeMode>(
          groupValue: state.mode,
          onChanged: (selected) {
            if (selected != null) {
              context.read<ThemeBloc>().add(ThemeModeChanged(selected));
            }
          },
          child: Column(
            children: ThemeMode.values.map((option) {
              return RadioListTile<ThemeMode>(
                value: option,
                title: Text(_labelFor(context, option)),
                secondary: FaIcon(_iconFor(option)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _labelFor(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.l10n.profileThemeSystemDefault,
    ThemeMode.light => context.l10n.profileThemeLight,
    ThemeMode.dark => context.l10n.profileThemeDark,
  };

  FaIconData _iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => FontAwesomeIcons.circleHalfStroke,
    ThemeMode.light => FontAwesomeIcons.sun,
    ThemeMode.dark => FontAwesomeIcons.moon,
  };
}

class _ColorSchemeSelector extends StatelessWidget {
  const _ColorSchemeSelector();

  static const double _swatchSize = 40;
  static const double _swatchInnerSize = 28;

  static const List<FlexScheme> _schemes = [
    FlexScheme.material,
    FlexScheme.deepPurple,
    FlexScheme.indigo,
    FlexScheme.blue,
    FlexScheme.green,
    FlexScheme.red,
    FlexScheme.mango,
    FlexScheme.gold,
    FlexScheme.sakura,
    FlexScheme.hippieBlue,
    FlexScheme.aquaBlue,
    FlexScheme.jungle,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: _schemes.map((scheme) {
              final isActive = scheme == state.scheme;
              return Semantics(
                button: true,
                selected: isActive,
                label: _labelFor(scheme),
                child: GestureDetector(
                  onTap: () =>
                      context.read<ThemeBloc>().add(ThemeSchemeChanged(scheme)),
                  child: AnimatedContainer(
                    duration: AppDurations.xfast,
                    width: _swatchSize,
                    height: _swatchSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? context.colorScheme.primary
                            : context.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                        width: isActive ? 3 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: _swatchInnerSize,
                        height: _swatchInnerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _schemeColors(scheme),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Screen-reader label for a swatch. These are color-theme proper names, so
  /// they are intentionally not localized (the same approach the scheme uses
  /// throughout).
  String _labelFor(FlexScheme scheme) => switch (scheme) {
    FlexScheme.material => 'Material',
    FlexScheme.deepPurple => 'Deep purple',
    FlexScheme.indigo => 'Indigo',
    FlexScheme.blue => 'Blue',
    FlexScheme.green => 'Green',
    FlexScheme.red => 'Red',
    FlexScheme.mango => 'Mango',
    FlexScheme.gold => 'Gold',
    FlexScheme.sakura => 'Sakura',
    FlexScheme.hippieBlue => 'Hippie blue',
    FlexScheme.aquaBlue => 'Aqua blue',
    FlexScheme.jungle => 'Jungle',
    _ => scheme.name,
  };

  List<Color> _schemeColors(FlexScheme scheme) => switch (scheme) {
    FlexScheme.material => const [Color(0xFF6750A4), Color(0xFFB4B0D0)],
    FlexScheme.deepPurple => const [Color(0xFF673AB7), Color(0xFFB39DDB)],
    FlexScheme.indigo => const [Color(0xFF3F51B5), Color(0xFF9FA8DA)],
    FlexScheme.blue => const [Color(0xFF2196F3), Color(0xFF90CAF9)],
    FlexScheme.green => const [Color(0xFF4CAF50), Color(0xFFA5D6A7)],
    FlexScheme.red => const [Color(0xFFF44336), Color(0xFFEF9A9A)],
    FlexScheme.mango => const [Color(0xFFFF9800), Color(0xFFFFCC80)],
    FlexScheme.gold => const [Color(0xFFFFC107), Color(0xFFFFE082)],
    FlexScheme.sakura => const [Color(0xFFE91E63), Color(0xFFF48FB1)],
    FlexScheme.hippieBlue => const [Color(0xFF4A90A2), Color(0xFFA8D8C8)],
    FlexScheme.aquaBlue => const [Color(0xFF03A9F4), Color(0xFF81D4FA)],
    FlexScheme.jungle => const [Color(0xFF388E3C), Color(0xFFA5D6A7)],
    _ => const [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
  };
}
