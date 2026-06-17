import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/change_password.dart';
import 'package:feature_auth/src/domain/usecases/delete_account.dart';
import 'package:feature_auth/src/domain/usecases/register.dart';
import 'package:feature_auth/src/domain/usecases/restore_session.dart';
import 'package:feature_auth/src/domain/usecases/sign_in.dart';
import 'package:feature_auth/src/domain/usecases/sign_out.dart';
import 'package:feature_bookmarks/feature_bookmarks.dart';
import 'package:feature_collections/feature_collections.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:test_utils/test_utils.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

class MockActivityNotifier extends Mock implements ActivityNotifier {}

class MockSignIn extends Mock implements SignInUseCase {}

class MockRegister extends Mock implements RegisterUseCase {}

class MockSignOut extends Mock implements SignOutUseCase {}

class MockDeleteAccount extends Mock implements DeleteAccountUseCase {}

class MockRestoreSession extends Mock implements RestoreSessionUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockListBookmarks extends Mock implements ListBookmarksUseCase {}

class MockBookmarkStatsReader extends Mock implements BookmarkStatsReader {}

class MockCollectionsReader extends Mock implements CollectionsReader {}

class MockCollectionsSyncController extends Mock
    implements CollectionsSyncController {}

class MockListLocalBookmarks extends Mock
    implements ListLocalBookmarksUseCase {}

class MockGetBookmark extends Mock implements GetBookmarkUseCase {}

class MockCreateBookmark extends Mock implements CreateBookmarkUseCase {}

class MockUpdateBookmark extends Mock implements UpdateBookmarkUseCase {}

class MockDeleteBookmark extends Mock implements DeleteBookmarkUseCase {}

class MockBookmarksSyncController extends Mock
    implements BookmarksSyncController {}

class MockNotificationsSyncController extends Mock
    implements NotificationsSyncController {}

class FakeBookmarkInput extends Fake implements BookmarkInput {}

class FakeCollectionInput extends Fake implements CollectionInput {}

class FakeUpdateCollectionParams extends Fake
    implements UpdateCollectionParams {}

// Notifications use-cases
class MockGetNotificationsFeed extends Mock
    implements GetNotificationsFeedUseCase {}

class MockGetNotificationsFeedLocal extends Mock
    implements GetNotificationsFeedLocalUseCase {}

class MockMarkNotificationRead extends Mock
    implements MarkNotificationReadUseCase {}

// Collections use-cases
class MockListCollections extends Mock implements ListCollectionsUseCase {}

class MockListLocalCollections extends Mock
    implements ListLocalCollectionsUseCase {}

class MockDeleteCollection extends Mock implements DeleteCollectionUseCase {}

class MockGetCollection extends Mock implements GetCollectionUseCase {}

class MockCreateCollection extends Mock implements CreateCollectionUseCase {}

class MockUpdateCollection extends Mock implements UpdateCollectionUseCase {}

class MockBookmarkSummariesReader extends Mock
    implements BookmarkSummariesReader {}

// Auth use-cases (additional)
class MockChangePassword extends Mock implements ChangePasswordUseCase {}

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
