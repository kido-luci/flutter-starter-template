import 'package:architecture/architecture.dart';
import '../entities/bookmark.dart';

/// Domain validation for [BookmarkInput]. Returns the first failure found, or
/// null when the input is acceptable.
Failure? validateBookmarkInput(BookmarkInput input) {
  if (input.title.trim().isEmpty) {
    return const ValidationFailure('Title is required.');
  }
  if (input.url.trim().isEmpty) {
    return const ValidationFailure('URL is required.');
  }
  return null;
}
