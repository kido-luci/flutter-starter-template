import 'package:architecture/architecture.dart';

import '../../../domain/entities/collection.dart';

/// State for the create/edit collection form.
class CollectionFormState {
  const CollectionFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.initial,
    this.saved = false,
    this.failure,
  });

  final bool isLoading;
  final bool isSubmitting;

  /// The existing collection when editing; null when creating.
  final Collection? initial;

  /// Flips to true after a successful create/update so the screen can pop.
  final bool saved;
  final Failure? failure;

  bool get isEditing => initial != null;

  CollectionFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Collection? initial,
    bool? saved,
    Failure? failure,
  }) {
    return CollectionFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initial: initial ?? this.initial,
      saved: saved ?? this.saved,
      failure: failure,
    );
  }
}
