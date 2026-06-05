import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/domain/services/collections_summary_service.dart';
import 'package:flutter_starter_template/shared/domain/collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockListCollections list;
  late CollectionsSummaryService service;

  setUp(() {
    list = MockListCollections();
    service = CollectionsSummaryService(list);
  });

  test('maps collections to summaries with item counts', () async {
    when(() => list()).thenAnswer(
      (_) async => Ok([
        buildCollection(bookmarkIds: ['b-1', 'b-2']),
      ]),
    );

    final result = await service();

    final summary = (result as Ok<List<CollectionSummary>>).value.single;
    expect(summary.id, 'c-1');
    expect(summary.itemCount, 2);
  });

  test('propagates failure', () async {
    when(() => list()).thenAnswer((_) async => const Err(UnknownFailure('x')));

    final result = await service();

    expect(result, isA<Err<List<CollectionSummary>>>());
  });
}
