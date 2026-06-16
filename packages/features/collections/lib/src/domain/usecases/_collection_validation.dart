import 'package:architecture/architecture.dart';
import '../entities/collection.dart';

/// Domain validation for [CollectionInput]. Returns the first failure found, or
/// null when the input is acceptable.
Failure? validateCollectionInput(CollectionInput input) {
  if (input.name.trim().isEmpty) {
    return const ValidationFailure('Name is required.');
  }
  return null;
}
