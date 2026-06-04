part of 'notifications_widgets.dart';

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (notifications.isEmpty)
            _TabEmptyState(
              icon: FontAwesomeIcons.bell,
              title: context.l10n.notificationsNoNotifications,
              message: context.l10n.notificationsEmptyMessage,
            )
          else ...[
            if (unread.isNotEmpty) ...[
              _NotificationSectionLabel(context.l10n.notificationsSectionNew),
              ..._tiles(context, unread),
            ],
            if (read.isNotEmpty) ...[
              if (unread.isNotEmpty) const SizedBox(height: AppSpacing.lg),
              _NotificationSectionLabel(
                context.l10n.notificationsSectionEarlier,
              ),
              ..._tiles(context, read, indexOffset: unread.length),
            ],
          ],
        ],
      ),
    );
  }

  List<Widget> _tiles(
    BuildContext context,
    List<AppNotification> items, {
    int indexOffset = 0,
  }) {
    return [
      for (final (index, notification) in items.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _NotificationTile(
            notification: notification,
            onTap: () => context.read<NotificationsBloc>().add(
              NotificationMarkReadRequested(notification.id),
            ),
          ),
        ).animateSlideUp(delay: (50 * (indexOffset + index)).ms),
    ];
  }
}

/// An uppercase, tracked-out section label (e.g. "NEW", "EARLIER") used to
/// group the notification feed.
class _NotificationSectionLabel extends StatelessWidget {
  const _NotificationSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.sm,
        ),
        child: Text(
          label.toUpperCase(),
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.outline,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
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
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
