import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_starter_template/shared/domain/collections.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../test_utils.dart';

void main() {
  group('HomeBloc', () {
    test('initial state is default', () async {
      final bloc = HomeBloc(MockBookmarkStatsReader(), _emptyCollections());

      expect(bloc.state.totalBookmarks, 0);
      expect(bloc.state.recentBookmarks, 0);
      expect(bloc.state.uniqueTags, 0);
      expect(bloc.state.recentItems, isEmpty);
      expect(bloc.state.isLoading, false);

      await bloc.close();
    });

    test('maps stats into state on load', () async {
      const stats = BookmarkStats(
        total: 5,
        recent: 2,
        uniqueTags: 3,
        recentItems: [
          BookmarkSummary(
            id: '1',
            title: 'Flutter',
            url: 'https://flutter.dev',
            description: '',
            tags: ['dev'],
          ),
        ],
      );
      final bloc = HomeBloc(_reader(const Ok(stats)), _emptyCollections());

      bloc.add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.totalBookmarks, 5);
      expect(bloc.state.recentBookmarks, 2);
      expect(bloc.state.uniqueTags, 3);
      expect(bloc.state.recentItems.single.title, 'Flutter');

      await bloc.close();
    });

    test('handles empty stats', () async {
      final bloc = HomeBloc(
        _reader(const Ok(BookmarkStats())),
        _emptyCollections(),
      );
      bloc.add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.totalBookmarks, 0);
      expect(bloc.state.recentItems, isEmpty);

      await bloc.close();
    });

    test('stores failure when stats load fails', () async {
      const failure = UnknownFailure('Failed');
      final bloc = HomeBloc(_reader(const Err(failure)), _emptyCollections());

      bloc.add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.isLoading, false);
      expect(bloc.state.failure, failure);

      await bloc.close();
    });
  });
}

MockBookmarkStatsReader _reader(Result<BookmarkStats> result) {
  final reader = MockBookmarkStatsReader();
  when(reader.call).thenAnswer((_) async => result);
  return reader;
}

MockCollectionsReader _emptyCollections() {
  final reader = MockCollectionsReader();
  when(reader.call).thenAnswer(
    (_) async => const Ok<List<CollectionSummary>>([]),
  );
  return reader;
}
