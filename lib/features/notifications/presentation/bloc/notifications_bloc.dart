import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/domain/activity_notifier.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/services/notifications_sync_controller.dart';
import '../../domain/usecases/get_notifications_feed.dart';
import '../../domain/usecases/get_notifications_feed_local.dart';
import '../../domain/usecases/mark_notification_read.dart';
import 'notifications_state.dart';

part 'notifications_event.dart';

@lazySingleton
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(
    this._getFeed,
    this._getFeedLocal,
    this._markRead,
    ActivityNotifier activityNotifier,
    NotificationsSyncController sync,
  ) : super(const NotificationsState()) {
    on<NotificationsLoadRequested>(
      _onLoadRequested,
      transformer: droppable(),
    );
    on<NotificationMarkReadRequested>(
      _onMarkReadRequested,
      transformer: sequential(),
    );
    on<_NotificationsReloadSilently>(
      _onReloadSilently,
      transformer: droppable(),
    );

    _activitySubscription = activityNotifier.onActivityOccurred.listen((_) {
      if (isClosed) return;
      add(const NotificationsLoadRequested());
    });
    // Refresh the cached view after every sync cycle so server-side changes
    // appear without the user pulling-to-refresh.
    _syncSubscription = sync.onSynced.listen((_) {
      if (isClosed) return;
      add(const _NotificationsReloadSilently());
    });
  }

  late final StreamSubscription<void> _activitySubscription;
  late final StreamSubscription<void> _syncSubscription;

  final GetNotificationsFeed _getFeed;
  final GetNotificationsFeedLocal _getFeedLocal;
  final MarkNotificationRead _markRead;

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _getFeed();
    switch (result) {
      case Ok(value: final feed):
        emit(
          state.copyWith(
            isLoading: false,
            notifications: feed.notifications,
            activities: feed.activities,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onMarkReadRequested(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final id = event.id;
    final hasUnreadTarget = state.notifications.any(
      (n) => n.id == id && !n.isRead,
    );
    if (!hasUnreadTarget) return;

    // Optimistically flip to read so the UI responds immediately.
    emit(state.copyWith(notifications: _withRead(id, isRead: true)));
    final result = await _markRead(id);
    if (result is Err) {
      // Roll back if the server rejected the change.
      emit(state.copyWith(notifications: _withRead(id, isRead: false)));
    }
  }

  Future<void> _onReloadSilently(
    _NotificationsReloadSilently event,
    Emitter<NotificationsState> emit,
  ) async {
    // Read the cache only — going through _getFeed() would trigger another
    // sync, which would emit onSynced again and loop.
    final result = await _getFeedLocal();
    if (result case Ok(value: final feed)) {
      emit(
        state.copyWith(
          failure: null,
          notifications: feed.notifications,
          activities: feed.activities,
        ),
      );
    }
  }

  List<AppNotification> _withRead(String id, {required bool isRead}) {
    return state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: isRead) : n)
        .toList(growable: false);
  }

  @override
  Future<void> close() async {
    await _activitySubscription.cancel();
    await _syncSubscription.cancel();
    return super.close();
  }
}
