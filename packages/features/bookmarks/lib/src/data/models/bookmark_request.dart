import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_request.freezed.dart';
part 'bookmark_request.g.dart';

/// Wire payload for both create (POST) and update (PUT). The optional `id`
/// is only used by POST so offline-minted client UUIDs become the server's
/// canonical id; PUT ignores it (path id wins).
@Freezed(copyWith: false, equal: false)
abstract class BookmarkRequest with _$BookmarkRequest {
  const factory BookmarkRequest({
    String? id,
    required String title,
    required String url,
    required String description,
    required List<String> tags,
    @Default([]) List<String> imageUrls,
    String? videoUrl,
  }) = _BookmarkRequest;

  factory BookmarkRequest.fromJson(Map<String, dynamic> json) =>
      _$BookmarkRequestFromJson(json);
}
