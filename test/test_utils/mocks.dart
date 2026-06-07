import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/change_password.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/delete_account.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/register.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/create_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/delete_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/get_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_bookmarks.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_local_bookmarks.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:flutter_starter_template/features/collections/domain/entities/collection.dart';
import 'package:flutter_starter_template/features/collections/domain/services/collections_sync_controller.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/create_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/delete_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/get_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/list_collections.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/list_local_collections.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/update_collection.dart';
import 'package:flutter_starter_template/features/notifications/domain/services/notifications_sync_controller.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/get_notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/get_notifications_feed_local.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_starter_template/shared/domain/activity_notifier.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_summaries.dart';
import 'package:flutter_starter_template/shared/domain/collections.dart';
import 'package:flutter_starter_template/shared/domain/entities/auth_user.dart';
import 'package:flutter_starter_template/shared/domain/session.dart';
import 'package:test_utils/test_utils.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

class MockActivityNotifier extends Mock implements ActivityNotifier {}

class MockSignIn extends Mock implements SignIn {}

class MockRegister extends Mock implements Register {}

class MockSignOut extends Mock implements SignOut {}

class MockDeleteAccount extends Mock implements DeleteAccount {}

class MockRestoreSession extends Mock implements RestoreSession {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockListBookmarks extends Mock implements ListBookmarks {}

class MockBookmarkStatsReader extends Mock implements BookmarkStatsReader {}

class MockCollectionsReader extends Mock implements CollectionsReader {}

class MockCollectionsSyncController extends Mock
    implements CollectionsSyncController {}

class MockListLocalBookmarks extends Mock implements ListLocalBookmarks {}

class MockGetBookmark extends Mock implements GetBookmark {}

class MockCreateBookmark extends Mock implements CreateBookmark {}

class MockUpdateBookmark extends Mock implements UpdateBookmark {}

class MockDeleteBookmark extends Mock implements DeleteBookmark {}

class MockBookmarksSyncController extends Mock
    implements BookmarksSyncController {}

class MockNotificationsSyncController extends Mock
    implements NotificationsSyncController {}

class FakeBookmarkInput extends Fake implements BookmarkInput {}

class FakeCollectionInput extends Fake implements CollectionInput {}

class FakeUpdateCollectionParams extends Fake
    implements UpdateCollectionParams {}

// Notifications use-cases
class MockGetNotificationsFeed extends Mock implements GetNotificationsFeed {}

class MockGetNotificationsFeedLocal extends Mock
    implements GetNotificationsFeedLocal {}

class MockMarkNotificationRead extends Mock implements MarkNotificationRead {}

// Collections use-cases
class MockListCollections extends Mock implements ListCollections {}

class MockListLocalCollections extends Mock implements ListLocalCollections {}

class MockDeleteCollection extends Mock implements DeleteCollection {}

class MockGetCollection extends Mock implements GetCollection {}

class MockCreateCollection extends Mock implements CreateCollection {}

class MockUpdateCollection extends Mock implements UpdateCollection {}

class MockBookmarkSummariesReader extends Mock
    implements BookmarkSummariesReader {}

// Auth use-cases (additional)
class MockChangePassword extends Mock implements ChangePassword {}

/// In-memory [Session] double for widget tests.
class FakeSession extends ChangeNotifier implements Session {
  FakeSession({this.currentUser, this.isSigningOut = false});

  @override
  AuthUser? currentUser;

  @override
  bool isSigningOut;

  @override
  Future<void> restore() async {}

  @override
  void signOut() {}

  @override
  void clearSession() {}
}
