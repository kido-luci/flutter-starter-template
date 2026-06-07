import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/collections/domain/entities/collection.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/notifications_feed.dart';
import 'package:flutter_starter_template/shared/domain/collections.dart';
import 'package:flutter_starter_template/shared/domain/entities/auth_user.dart';

const testUser = AuthUser(id: 'user-1', username: 'alice');

const testFailure = UnknownFailure('Something went wrong');

final testBookmark = Bookmark(
  id: '1',
  title: 'Flutter',
  url: 'https://flutter.dev',
  description: 'Flutter website',
  tags: ['dev'],
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

final testBookmark2 = Bookmark(
  id: '2',
  title: 'Dart',
  url: 'https://dart.dev',
  description: 'Dart website',
  tags: ['lang'],
  createdAt: DateTime(2025, 1, 2),
  updatedAt: DateTime(2025, 1, 2),
);

final testCollection = Collection(
  id: 'col-1',
  name: 'Dev Tools',
  // Token derived from first palette entry (FontAwesomeIcons.layerGroup).
  // collectionIconFor falls back gracefully for any unknown token.
  icon: 'e8d4',
  color: 0xFF6366F1,
  bookmarkIds: const [],
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

/// Mirrors [testCollection] — used to feed the home screen's "Featured
/// Collections" section so its "View all" action (which routes to
/// `/collections`) is rendered instead of "Create collection".
const testCollectionSummary = CollectionSummary(
  id: 'col-1',
  name: 'Dev Tools',
  icon: 'e8d4',
  color: 0xFF6366F1,
  itemCount: 0,
);

final testUnreadNotification = AppNotification(
  id: 'notif-1',
  title: 'New bookmark added',
  body: 'You saved a new bookmark.',
  type: NotificationType.system,
  isRead: false,
  createdAt: DateTime(2025, 1, 1),
);

final testReadNotification = AppNotification(
  id: 'notif-2',
  title: 'Collection updated',
  body: 'Your collection was updated.',
  type: NotificationType.system,
  isRead: true,
  createdAt: DateTime(2025, 1, 1),
);

final testNotificationFeed = NotificationsFeed(
  notifications: [testUnreadNotification, testReadNotification],
  activities: const [],
);
