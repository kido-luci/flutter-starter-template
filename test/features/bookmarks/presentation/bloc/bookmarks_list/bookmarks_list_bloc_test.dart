import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../test_utils.dart';

void main() {
  late MockListBookmarks mockList;
  late MockListLocalBookmarks mockListLocal;
  late MockDeleteBookmark mockDelete;
  late MockBookmarksSyncController mockSync;
  late MockAnalyticsService mockAnalytics;
  late MockShareService mockShare;
  late StreamController<BookmarksSyncStatus> statusController;

  setUp(() {
    mockList = MockListBookmarks();
    mockListLocal = MockListLocalBookmarks();
    mockDelete = MockDeleteBookmark();
    mockSync = MockBookmarksSyncController();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
    mockShare = MockShareService();
    stubShareService(mockShare);
    statusController = StreamController<BookmarksSyncStatus>.broadcast();
    when(
      () => mockSync.statusStream,
    ).thenAnswer((_) => statusController.stream);
  });

  tearDown(() {
    statusController.close();
  });

  BookmarksListBloc buildBloc() => BookmarksListBloc(
    mockList,
    mockListLocal,
    mockDelete,
    mockSync,
    mockAnalytics,
    mockShare,
  );

  group('BookmarksListBloc', () {
    test('initial state is empty', () {
      final bloc = buildBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.query, '');
      bloc.close();
    });

    group('load', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'emits loading then items on success',
        setUp: () {
          when(
            () => mockList(),
          ).thenAnswer((_) async => Ok([testBookmark, testBookmark2]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarksListLoadRequested()),
        expect: () => [
          predicate<BookmarksListState>((s) => s.isLoading && s.items.isEmpty),
          predicate<BookmarksListState>(
            (s) => !s.isLoading && s.items.length == 2,
          ),
        ],
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'emits loading then failure on error',
        setUp: () {
          when(
            () => mockList(),
          ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarksListLoadRequested()),
        expect: () => [
          predicate<BookmarksListState>((s) => s.isLoading),
          predicate<BookmarksListState>((s) => s.failure != null),
        ],
      );
    });

    group('sync status', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'syncing → idle reloads via listLocal without re-triggering a sync',
        setUp: () {
          when(
            () => mockListLocal(),
          ).thenAnswer((_) async => Ok([testBookmark]));
        },
        build: buildBloc,
        act: (bloc) async {
          statusController.add(BookmarksSyncStatus.syncing);
          await Future<void>.delayed(Duration.zero);
          statusController.add(BookmarksSyncStatus.idle);
        },
        expect: () => [
          predicate<BookmarksListState>(
            (s) => s.syncStatus == BookmarksSyncStatus.syncing,
          ),
          predicate<BookmarksListState>(
            (s) => s.syncStatus == BookmarksSyncStatus.idle,
          ),
          predicate<BookmarksListState>((s) => s.items.length == 1),
        ],
        verify: (_) {
          // The silent reload must read local only: a single listLocal() call
          // and no list() call, otherwise list() would fire another sync and
          // loop indefinitely.
          verify(() => mockListLocal()).called(1);
          verifyNever(() => mockList());
        },
      );
    });

    group('setQuery', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'updates query and filters visibleItems',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark, testBookmark2]),
        act: (bloc) => bloc.add(const BookmarksListQueryChanged('Dart')),
        wait:
            BookmarksListBloc.searchAnalyticsDebounce +
            const Duration(milliseconds: 10),
        expect: () => [
          predicate<BookmarksListState>(
            (s) => s.query == 'Dart' && s.visibleItems.length == 1,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_search',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'does nothing when query is unchanged',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark], query: 'flutter'),
        act: (bloc) => bloc.add(const BookmarksListQueryChanged('flutter')),
        expect: () => <BookmarksListState>[],
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'debounces analytics for rapid query changes',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark, testBookmark2]),
        act: (bloc) {
          bloc
            ..add(const BookmarksListQueryChanged('D'))
            ..add(const BookmarksListQueryChanged('Da'))
            ..add(const BookmarksListQueryChanged('Dar'));
        },
        wait:
            BookmarksListBloc.searchAnalyticsDebounce +
            const Duration(milliseconds: 10),
        expect: () => [
          predicate<BookmarksListState>((s) => s.query == 'D'),
          predicate<BookmarksListState>((s) => s.query == 'Da'),
          predicate<BookmarksListState>((s) => s.query == 'Dar'),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_search',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );
    });

    group('sort', () {
      test('defaults to newest first', () {
        final bloc = buildBloc();
        expect(bloc.state.sort, BookmarkSort.newest);
        bloc.close();
      });

      test('visibleItems orders by createdAt descending by default', () {
        final state = BookmarksListState(items: [testBookmark, testBookmark2]);
        // testBookmark2 (2025-01-02) is newer than testBookmark (2025-01-01).
        expect(state.visibleItems.first.id, testBookmark2.id);
      });

      blocTest<BookmarksListBloc, BookmarksListState>(
        'oldest sort orders by createdAt ascending',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark, testBookmark2]),
        act: (bloc) =>
            bloc.add(const BookmarksListSortChanged(BookmarkSort.oldest)),
        expect: () => [
          predicate<BookmarksListState>(
            (s) =>
                s.sort == BookmarkSort.oldest &&
                s.visibleItems.first.id == testBookmark.id,
          ),
        ],
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'titleAz sort orders alphabetically by title',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark, testBookmark2]),
        act: (bloc) =>
            bloc.add(const BookmarksListSortChanged(BookmarkSort.titleAz)),
        expect: () => [
          predicate<BookmarksListState>(
            // "Dart" sorts before "Flutter".
            (s) => s.visibleItems.first.title == 'Dart',
          ),
        ],
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'does nothing when sort is unchanged',
        build: buildBloc,
        seed: () => const BookmarksListState(sort: BookmarkSort.newest),
        act: (bloc) =>
            bloc.add(const BookmarksListSortChanged(BookmarkSort.newest)),
        expect: () => <BookmarksListState>[],
      );
    });

    group('delete', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'optimistically removes item',
        setUp: () {
          when(() => mockDelete('1')).thenAnswer((_) async => const Ok(null));
        },
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark]),
        act: (bloc) => bloc.add(const BookmarksListDeleteRequested('1')),
        expect: () => [predicate<BookmarksListState>((s) => s.items.isEmpty)],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_deleted',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'restores item and reloads on delete failure',
        setUp: () {
          when(
            () => mockDelete('1'),
          ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
          when(() => mockList()).thenAnswer((_) async => Ok([testBookmark]));
        },
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark]),
        act: (bloc) => bloc.add(const BookmarksListDeleteRequested('1')),
        expect: () => [
          predicate<BookmarksListState>((s) => s.items.isEmpty),
          predicate<BookmarksListState>((s) => s.items.length == 1),
          predicate<BookmarksListState>((s) => s.isLoading),
          predicate<BookmarksListState>((s) => !s.isLoading),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_delete_failed',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );
    });
  });
}
