import 'package:feature_bookmarks/feature_bookmarks.dart';
import 'package:feature_bookmarks/src/domain/usecases/create_bookmark.dart';
import 'package:feature_bookmarks/src/domain/usecases/delete_bookmark.dart';
import 'package:feature_bookmarks/src/domain/usecases/get_bookmark.dart';
import 'package:feature_bookmarks/src/domain/usecases/list_bookmarks.dart';
import 'package:feature_bookmarks/src/domain/usecases/list_local_bookmarks.dart';
import 'package:feature_bookmarks/src/domain/usecases/update_bookmark.dart';
import 'package:test_utils/test_utils.dart';

export 'package:test_utils/test_utils.dart';

class MockListBookmarks extends Mock implements ListBookmarksUseCase {}

class MockListLocalBookmarks extends Mock
    implements ListLocalBookmarksUseCase {}

class MockGetBookmark extends Mock implements GetBookmarkUseCase {}

class MockCreateBookmark extends Mock implements CreateBookmarkUseCase {}

class MockUpdateBookmark extends Mock implements UpdateBookmarkUseCase {}

class MockDeleteBookmark extends Mock implements DeleteBookmarkUseCase {}

class MockBookmarksSyncController extends Mock
    implements BookmarksSyncController {}

class FakeBookmarkInput extends Fake implements BookmarkInput {}

final testBookmark = Bookmark(
  id: '1',
  title: 'Flutter',
  url: 'https://flutter.dev',
  description: 'Flutter website',
  tags: ['dev'],
  createdAt: DateTime.utc(2025, 1, 1),
  updatedAt: DateTime.utc(2025, 1, 1),
);

final testBookmark2 = Bookmark(
  id: '2',
  title: 'Dart',
  url: 'https://dart.dev',
  description: 'Dart website',
  tags: ['lang'],
  createdAt: DateTime.utc(2025, 1, 2),
  updatedAt: DateTime.utc(2025, 1, 2),
);
