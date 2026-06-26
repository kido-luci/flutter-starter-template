import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Mocks and fakes for the cross-feature `shared_contracts` types.
///
/// These doubles reference only `shared_contracts`/`architecture`, so they live
/// in `test_utils` and are reused by feature tests and the app-level widget
/// tests alike.

class MockActivityNotifier extends Mock implements ActivityNotifier {}

class MockBookmarkStatsReader extends Mock implements BookmarkStatsReader {}

class MockCollectionsReader extends Mock implements CollectionsReader {}

class MockBookmarkSummariesReader extends Mock
    implements BookmarkSummariesReader {}

/// In-memory [Session] double for widget tests.
class FakeSession extends ChangeNotifier implements Session {
  FakeSession({this.currentUser, this.isSigningOut = false, SessionStatus? status})
    : status =
          status ??
          (currentUser != null
              ? SessionStatus.authenticated
              : SessionStatus.unauthenticated);

  @override
  AuthUser? currentUser;

  @override
  bool isSigningOut;

  @override
  SessionStatus status;

  @override
  Future<void> restore() async {}

  @override
  void signOut() {
    currentUser = null;
    isSigningOut = false;
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void clearSession() {
    currentUser = null;
    isSigningOut = false;
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }
}
