import 'package:architecture/architecture.dart';

import '../../../domain/entities/collection.dart';

/// State for the "add this bookmark to collections" bottom sheet.
class AddToCollectionState {
  const AddToCollectionState({
    this.isLoading = false,
    this.collections = const [],
    this.memberOf = const {},
    this.busyIds = const {},
    this.failure,
  });

  final bool isLoading;
  final List<Collection> collections;

  /// Ids of collections that currently contain the target bookmark.
  final Set<String> memberOf;

  /// Ids of collections with an in-flight toggle.
  final Set<String> busyIds;
  final Failure? failure;

  AddToCollectionState copyWith({
    bool? isLoading,
    List<Collection>? collections,
    Set<String>? memberOf,
    Set<String>? busyIds,
    Failure? failure,
  }) {
    return AddToCollectionState(
      isLoading: isLoading ?? this.isLoading,
      collections: collections ?? this.collections,
      memberOf: memberOf ?? this.memberOf,
      busyIds: busyIds ?? this.busyIds,
      failure: failure,
    );
  }
}
