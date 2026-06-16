import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_form_state.freezed.dart';

enum BookmarkFormStatus { idle, loading, submitting, submitted, loadFailed }

@freezed
abstract class BookmarkFormState with _$BookmarkFormState {
  const factory BookmarkFormState({
    String? id,
    @Default(BookmarkFormStatus.idle) BookmarkFormStatus status,
    @Default('') String title,
    @Default('') String url,
    @Default('') String description,
    @Default([]) List<String> tags,
    @Default([]) List<String> imageUrls,
    String? videoUrl,
    Failure? failure,
  }) = _BookmarkFormState;
}
