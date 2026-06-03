part of 'home_widgets.dart';

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _StatCard(
            icon: FontAwesomeIcons.solidBookmark,
            value: state.totalBookmarks.toString(),
            label: context.l10n.homeStatsTotal,
            color: context.colorScheme.primary,
          ).animateSlideUp(delay: 180.ms),
          _StatCard(
            icon: FontAwesomeIcons.clock,
            value: state.recentBookmarks.toString(),
            label: context.l10n.homeStatsRecent,
            color: context.semanticColors.success,
          ).animateSlideUp(delay: 260.ms),
          _StatCard(
            icon: FontAwesomeIcons.tag,
            value: state.uniqueTags.toString(),
            label: context.l10n.homeStatsTags,
            color: context.semanticColors.info,
          ).animateSlideUp(delay: 340.ms),
        ];

        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              for (final (index, card) in cards.indexed) ...[
                if (index > 0) const SizedBox(height: AppSpacing.sm),
                SizedBox(height: 82, child: card),
              ],
            ],
          );
        }

        return SizedBox(
          height: 92,
          child: Row(
            children: [
              for (final (index, card) in cards.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: card),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final FaIconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _ElevatedSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: FaIcon(
                icon,
                size: AppIconSize.md,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
