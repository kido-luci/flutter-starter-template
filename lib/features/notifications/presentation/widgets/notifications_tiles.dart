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

/// A single notification, rendered in one of two visual treatments:
///
/// unread notifications get a prominent, elevated card (the "New" section)
/// while read ones get a quieter, flat bordered card (the "Earlier" section).
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _notificationColor(context, notification.type);
    return notification.isRead
        ? _ReadNotificationTile(notification: notification, accent: accent)
        : _UnreadNotificationTile(
            notification: notification,
            accent: accent,
            onTap: onTap,
          );
  }
}

class _UnreadNotificationTile extends StatelessWidget {
  const _UnreadNotificationTile({
    required this.notification,
    required this.accent,
    required this.onTap,
  });

  final AppNotification notification;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.32)
                : accent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accent.withValues(alpha: 0.15),
                  child: FaIcon(
                    _notificationIcon(notification.type),
                    color: accent,
                    size: AppIconSize.md,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            formatRelativeTime(context, notification.createdAt),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadNotificationTile extends StatelessWidget {
  const _ReadNotificationTile({
    required this.notification,
    required this.accent,
  });

  final AppNotification notification;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: scheme.surfaceContainerHigh,
              child: FaIcon(
                _notificationIcon(notification.type),
                color: scheme.onSurfaceVariant,
                size: AppIconSize.sm,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        formatRelativeTime(context, notification.createdAt),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.body,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
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
