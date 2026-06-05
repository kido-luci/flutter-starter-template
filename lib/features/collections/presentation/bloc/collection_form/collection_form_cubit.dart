import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/collection.dart';
import '../../../domain/usecases/create_collection.dart';
import '../../../domain/usecases/get_collection.dart';
import '../../../domain/usecases/update_collection.dart';
import 'collection_form_state.dart';

@injectable
class CollectionFormCubit extends Cubit<CollectionFormState> {
  CollectionFormCubit(this._create, this._update, this._get)
    : super(const CollectionFormState());

  final CreateCollection _create;
  final UpdateCollection _update;
  final GetCollection _get;

  /// Loads an existing collection for editing. No-op for the create flow.
  Future<void> loadForEdit(String id) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _get(id);
    switch (result) {
      case Ok(value: final collection):
        emit(state.copyWith(isLoading: false, initial: collection));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> submit({
    required String name,
    required String icon,
    required int color,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, failure: null));

    final existing = state.initial;
    final input = CollectionInput(
      name: name,
      icon: icon,
      color: color,
      // Preserve membership across edits; create starts empty.
      bookmarkIds: existing?.bookmarkIds ?? const [],
    );

    final result = existing == null
        ? await _create(input)
        : await _update(UpdateCollectionParams(id: existing.id, input: input));

    switch (result) {
      case Ok():
        emit(state.copyWith(isSubmitting: false, saved: true));
      case Err(:final failure):
        emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }
}
