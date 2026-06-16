import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/user_activity.dart';

part 'notifications_state.freezed.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(false) bool isLoading,
    @Default([]) List<AppNotification> notifications,
    @Default([]) List<UserActivity> activities,
    Failure? failure,
  }) = _NotificationsState;
  const NotificationsState._();

  /// Number of unread notifications, surfaced as a badge in the header.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// `true` when the feed has neither notifications nor activity to show.
  bool get hasNoContent => notifications.isEmpty && activities.isEmpty;
}
