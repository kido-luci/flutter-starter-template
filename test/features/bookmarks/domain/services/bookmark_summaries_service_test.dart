import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmark_summaries_service.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils.dart';

void main() {
  late MockListBookmarks list;
  late BookmarkSummariesService service;

  setUp(() {
    list = MockListBookmarks();
    service = BookmarkSummariesService(list);
  });

  test('maps bookmarks to summaries', () async {
    final bookmark = Bookmark(
      id: 'b-1',
      title: 'Flutter',
      url: 'https://flutter.dev',
      description: 'desc',
      tags: const ['dev'],
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );
    when(() => list()).thenAnswer((_) async => Ok([bookmark]));

    final result = await service();

    final summary = (result as Ok<List<BookmarkSummary>>).value.single;
    expect(summary.id, 'b-1');
    expect(summary.title, 'Flutter');
    expect(summary.tags, ['dev']);
  });

  test('propagates failure', () async {
    when(() => list()).thenAnswer((_) async => const Err(UnknownFailure('x')));

    expect(await service(), isA<Err<List<BookmarkSummary>>>());
  });
}
