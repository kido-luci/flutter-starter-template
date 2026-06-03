part of 'notifications_widgets.dart';

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.notifications,
    required this.unreadCount,
  });

  final List<AppNotification> notifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionHeader(
            title: context.l10n.notificationsSection,
            badgeCount: unreadCount,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notifications.isEmpty)
            _TabEmptyState(
              icon: FontAwesomeIcons.bell,
              title: context.l10n.notificationsNoNotifications,
              message: context.l10n.notificationsEmptyMessage,
            )
          else
            for (final (index, notification) in notifications.indexed)
              _NotificationTile(
                notification: notification,
                onTap: () => context.read<NotificationsBloc>().add(
                  NotificationMarkReadRequested(notification.id),
                ),
              ).animateSlideUp(delay: (50 * index).ms),
        ],
      ),
    );
  }
}

class _ActivitiesList extends StatelessWidget {
  const _ActivitiesList({required this.activities});

  final List<UserActivity> activities;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionHeader(title: context.l10n.notificationsActivitySection),
          const SizedBox(height: AppSpacing.sm),
          if (activities.isEmpty)
            _TabEmptyState(
              icon: FontAwesomeIcons.clockRotateLeft,
              title: context.l10n.notificationsEmptyTitle,
              message: context.l10n.notificationsEmptyMessage,
            )
          else
            for (final (index, activity) in activities.indexed)
              _ActivityTile(
                activity: activity,
              ).animateSlideUp(delay: (50 * index).ms),
        ],
      ),
    );
  }
}

Future<void> _refresh(BuildContext context) {
  final bloc = context.read<NotificationsBloc>()
    ..add(const NotificationsLoadRequested());
  // Keep the spinner visible until the reload settles. Fall back to the
  // current state if the bloc closes mid-refresh so the future never throws.
  return bloc.stream.firstWhere(
    (s) => !s.isLoading,
    orElse: () => bloc.state,
  );
}

class _TabEmptyState extends StatelessWidget {
  const _TabEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final FaIconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: AppEmptyView(
        icon: icon,
        title: title,
        message: message,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.badgeCount = 0});

  final String title;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (badgeCount > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              context.l10n.notificationsUnreadCount(badgeCount),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
