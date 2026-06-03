import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmark_stats_service.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../test_utils.dart';

Bookmark _bookmark({
  required String id,
  List<String> tags = const [],
  List<String> imageUrls = const [],
  required DateTime createdAt,
}) => Bookmark(
  id: id,
  title: 'Title $id',
  url: 'https://example.com/$id',
  description: 'desc $id',
  tags: tags,
  imageUrls: imageUrls,
  createdAt: createdAt,
  updatedAt: createdAt,
);

void main() {
  group('BookmarkStatsService', () {
    test('aggregates totals, unique tags, and recent window', () async {
      final now = DateTime.now();
      final items = [
        _bookmark(id: '1', tags: ['a', 'b'], createdAt: now),
        _bookmark(
          id: '2',
          tags: ['b', 'c'],
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        _bookmark(
          id: '3',
          tags: ['a'],
          createdAt: now.subtract(const Duration(days: 30)),
        ),
      ];
      final list = MockListBookmarks();
      when(list.call).thenAnswer((_) async => Ok(items));

      final result = await BookmarkStatsService(list)();

      final stats = (result as Ok<BookmarkStats>).value;
      expect(stats.total, 3);
      expect(stats.recent, 2); // last 7 days
      expect(stats.uniqueTags, 3); // a, b, c
      expect(stats.recentItems.length, 3);
      expect(stats.recentItems.first.id, '1');
    });

    test('caps recent items at three', () async {
      final now = DateTime.now();
      final items = List.generate(
        5,
        (i) => _bookmark(id: '$i', createdAt: now),
      );
      final list = MockListBookmarks();
      when(list.call).thenAnswer((_) async => Ok(items));

      final result = await BookmarkStatsService(list)();

      expect((result as Ok<BookmarkStats>).value.recentItems.length, 3);
    });

    test('projects bookmark fields into the summary', () async {
      final item = _bookmark(
        id: '1',
        tags: ['x'],
        imageUrls: ['https://example.com/thumb.jpg'],
        createdAt: DateTime.now(),
      );
      final list = MockListBookmarks();
      when(list.call).thenAnswer((_) async => Ok([item]));

      final result = await BookmarkStatsService(list)();

      final summary = (result as Ok<BookmarkStats>).value.recentItems.single;
      expect(summary.id, item.id);
      expect(summary.title, item.title);
      expect(summary.url, item.url);
      expect(summary.description, item.description);
      expect(summary.tags, item.tags);
      expect(summary.imageUrls, item.imageUrls);
      expect(summary.fallbackThumbnailUrl, item.imageUrls.first);
    });

    test('fallbackThumbnailUrl returns first http(s) url, ignoring others', () {
      const summary = BookmarkSummary(
        id: '1',
        title: 'Title',
        url: 'https://example.com',
        description: 'Description',
        tags: [],
        imageUrls: [
          'ftp://example.com/image.jpg',
          'not a uri',
          'https://example.com/thumb.jpg',
        ],
      );

      expect(summary.fallbackThumbnailUrl, 'https://example.com/thumb.jpg');
      expect(
        const BookmarkSummary(
          id: '2',
          title: 'Title',
          url: 'https://example.com',
          description: 'Description',
          tags: [],
        ).fallbackThumbnailUrl,
        isNull,
      );
    });

    test('propagates failure', () async {
      const failure = UnknownFailure('boom');
      final list = MockListBookmarks();
      when(list.call).thenAnswer((_) async => const Err(failure));

      final result = await BookmarkStatsService(list)();

      expect((result as Err<BookmarkStats>).failure, failure);
    });
  });
}
