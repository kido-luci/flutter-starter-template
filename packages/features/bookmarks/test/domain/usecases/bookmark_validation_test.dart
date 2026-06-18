import 'package:architecture/architecture.dart';
import 'package:feature_bookmarks/src/domain/entities/bookmark.dart';
import 'package:feature_bookmarks/src/domain/repositories/bookmarks_repository.dart';
import 'package:feature_bookmarks/src/domain/usecases/create_bookmark.dart';
import 'package:feature_bookmarks/src/domain/usecases/delete_bookmark.dart';
import 'package:feature_bookmarks/src/domain/usecases/get_bookmark.dart';
import 'package:feature_bookmarks/src/domain/usecases/list_bookmarks.dart';
import 'package:feature_bookmarks/src/domain/usecases/list_local_bookmarks.dart';
import 'package:feature_bookmarks/src/domain/usecases/update_bookmark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class _MockBookmarksRepository extends Mock implements BookmarksRepository {}

class _FakeBookmarkInput extends Fake implements BookmarkInput {}

void main() {
  late _MockBookmarksRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakeBookmarkInput());
  });

  setUp(() {
    repo = _MockBookmarksRepository();
  });

  group('CreateBookmarkUseCase', () {
    test('rejects empty title without hitting repository', () async {
      final result = await CreateBookmarkUseCase(repo)(
        const BookmarkInput(
          title: '',
          url: 'https://flutter.dev',
          description: '',
          tags: [],
        ),
      );

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<ValidationFailure>());
      expect(err.failure.message, 'Title is required.');
      verifyZeroInteractions(repo);
    });

    test('rejects empty url without hitting repository', () async {
      final result = await CreateBookmarkUseCase(repo)(
        const BookmarkInput(
          title: 'Flutter',
          url: '',
          description: '',
          tags: [],
        ),
      );

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<ValidationFailure>());
      expect(err.failure.message, 'URL is required.');
      verifyZeroInteractions(repo);
    });
  });

  group('UpdateBookmarkUseCase', () {
    test('rejects empty title without hitting repository', () async {
      final result = await UpdateBookmarkUseCase(repo)((
        id: 'b-1',
        input: const BookmarkInput(
          title: '',
          url: 'https://flutter.dev',
          description: '',
          tags: [],
        ),
      ));

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<ValidationFailure>());
      verifyZeroInteractions(repo);
    });
  });

  group('read and delete use cases', () {
    test('ListBookmarksUseCase delegates to repository', () async {
      when(() => repo.list()).thenAnswer((_) async => const Ok([]));

      final result = await ListBookmarksUseCase(repo)();

      expect(result, isA<Ok<List<Bookmark>>>());
      verify(() => repo.list()).called(1);
    });

    test('ListLocalBookmarksUseCase delegates to repository', () async {
      when(() => repo.listLocal()).thenAnswer((_) async => const Ok([]));

      final result = await ListLocalBookmarksUseCase(repo)();

      expect(result, isA<Ok<List<Bookmark>>>());
      verify(() => repo.listLocal()).called(1);
    });

    test('GetBookmarkUseCase delegates to repository', () async {
      final bookmark = Bookmark(
        id: 'b-1',
        title: 'Flutter',
        url: 'https://flutter.dev',
        description: '',
        tags: const [],
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );
      when(() => repo.get('b-1')).thenAnswer((_) async => Ok(bookmark));

      final result = await GetBookmarkUseCase(repo)('b-1');

      expect(result, isA<Ok<Bookmark>>());
      verify(() => repo.get('b-1')).called(1);
    });

    test('DeleteBookmarkUseCase delegates to repository', () async {
      when(() => repo.delete('b-1')).thenAnswer((_) async => const Ok(null));

      final result = await DeleteBookmarkUseCase(repo)('b-1');

      expect(result, isA<Ok<void>>());
      verify(() => repo.delete('b-1')).called(1);
    });
  });
}
