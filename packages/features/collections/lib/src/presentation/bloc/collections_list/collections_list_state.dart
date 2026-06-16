import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/collection.dart';
import '../../../domain/services/collections_sync_controller.dart';

part 'collections_list_state.freezed.dart';

@freezed
abstract class CollectionsListState with _$CollectionsListState {
  const factory CollectionsListState({
    @Default(false) bool isLoading,
    @Default(CollectionsSyncStatus.idle) CollectionsSyncStatus syncStatus,
    @Default([]) List<Collection> items,
    Failure? failure,
  }) = _CollectionsListState;
}
