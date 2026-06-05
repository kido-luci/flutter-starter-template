import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/update_collection.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collection_form/collection_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockCreateCollection create;
  late MockUpdateCollection update;
  late MockGetCollection get;
  late CollectionFormCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeCollectionInput());
    registerFallbackValue(FakeUpdateCollectionParams());
  });

  setUp(() {
    create = MockCreateCollection();
    update = MockUpdateCollection();
    get = MockGetCollection();
    cubit = CollectionFormCubit(create, update, get);
  });

  tearDown(() => cubit.close());

  test('loadForEdit hydrates the initial collection', () async {
    when(() => get('c-1')).thenAnswer((_) async => Ok(buildCollection()));

    await cubit.loadForEdit('c-1');

    expect(cubit.state.initial?.id, 'c-1');
    expect(cubit.state.isEditing, isTrue);
  });

  test('submit creates a new collection when not editing', () async {
    when(() => create(any())).thenAnswer((_) async => Ok(buildCollection()));

    await cubit.submit(name: 'Design', icon: 'f5fd', color: 0xFF6366F1);

    expect(cubit.state.saved, isTrue);
    verify(() => create(any())).called(1);
    verifyNever(() => update(any()));
  });

  test('submit updates and preserves membership when editing', () async {
    when(() => get('c-1')).thenAnswer(
      (_) async => Ok(buildCollection(bookmarkIds: ['b-1', 'b-2'])),
    );
    when(() => update(any())).thenAnswer((_) async => Ok(buildCollection()));

    await cubit.loadForEdit('c-1');
    await cubit.submit(name: 'New name', icon: 'f02d', color: 0xFF10B981);

    final params =
        verify(() => update(captureAny())).captured.single
            as UpdateCollectionParams;
    expect(params.input.bookmarkIds, ['b-1', 'b-2']);
    expect(cubit.state.saved, isTrue);
  });

  test('submit surfaces failure', () async {
    when(
      () => create(any()),
    ).thenAnswer((_) async => const Err(ValidationFailure('bad')));

    await cubit.submit(name: '', icon: 'f5fd', color: 0xFF6366F1);

    expect(cubit.state.saved, isFalse);
    expect(cubit.state.failure, isA<ValidationFailure>());
  });
}
