part of 'notifications_widgets.dart';

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final UserActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colorScheme.secondaryContainer,
          child: FaIcon(
            _activityIcon(activity.type),
            color: context.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(activity.description),
        subtitle: Text(formatRelativeTime(context, activity.createdAt)),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _notificationColor(context, notification.type);
    return Card(
      elevation: notification.isRead ? 0 : 1,
      color: notification.isRead
          ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
          : context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ListTile(
        onTap: notification.isRead ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.15),
          child: FaIcon(_notificationIcon(notification.type), color: accent),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              formatRelativeTime(context, notification.createdAt),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

FaIconData _activityIcon(UserActivityType type) => switch (type) {
  UserActivityType.created => FontAwesomeIcons.circlePlus,
  UserActivityType.updated => FontAwesomeIcons.penToSquare,
  UserActivityType.deleted => FontAwesomeIcons.trashCan,
  UserActivityType.signedIn => FontAwesomeIcons.arrowRightToBracket,
  UserActivityType.other => FontAwesomeIcons.clockRotateLeft,
};

FaIconData _notificationIcon(NotificationType type) => switch (type) {
  NotificationType.system => FontAwesomeIcons.circleInfo,
  NotificationType.social => FontAwesomeIcons.users,
  NotificationType.reminder => FontAwesomeIcons.clock,
  NotificationType.promotion => FontAwesomeIcons.tag,
};

Color _notificationColor(BuildContext context, NotificationType type) =>
    switch (type) {
      NotificationType.system => context.colorScheme.primary,
      NotificationType.social => context.semanticColors.info,
      NotificationType.reminder => context.semanticColors.warning,
      NotificationType.promotion => context.semanticColors.success,
    };

/// Formats [timestamp] as a compact, localized relative time
/// (e.g. "Just now", "5m ago", "3h ago", "2d ago", or an absolute date).
String formatRelativeTime(BuildContext context, DateTime timestamp) {
  final l10n = context.l10n;
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
  final local = timestamp.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
