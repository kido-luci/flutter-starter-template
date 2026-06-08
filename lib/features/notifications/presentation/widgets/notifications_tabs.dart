part of 'notifications_widgets.dart';

class _NotificationsTabs extends StatelessWidget {
  const _NotificationsTabs();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationsBloc>().state;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: _NotificationsTabBar(state: state).animateFadeIn(),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _NotificationsList(notifications: state.notifications),
                _ActivitiesList(activities: state.activities),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTabBar extends StatelessWidget {
  const _NotificationsTabBar({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.32 : 0.48,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: context.colorScheme.onSecondaryContainer,
        unselectedLabelColor: context.colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        tabs: [
          Tab(
            child: _TabLabel(
              icon: FontAwesomeIcons.bell,
              label: context.l10n.notificationsSection,
              badgeCount: state.unreadCount,
            ),
          ),
          Tab(
            child: _TabLabel(
              icon: FontAwesomeIcons.clockRotateLeft,
              label: context.l10n.notificationsActivitySection,
              badgeCount: state.activities.length,
              showZero: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.icon,
    required this.label,
    required this.badgeCount,
    this.showZero = false,
  });

  final FaIconData icon;
  final String label;
  final int badgeCount;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount > 0 || showZero;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: AppIconSize.sm),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showBadge) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              badgeCount.toString(),
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
