import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_request.freezed.dart';
part 'collection_request.g.dart';

/// Wire payload for both create (POST) and update (PUT). The optional `id`
/// is only used by POST so offline-minted client UUIDs become the server's
/// canonical id; PUT ignores it (path id wins).
@Freezed(copyWith: false, equal: false)
abstract class CollectionRequest with _$CollectionRequest {
  const factory CollectionRequest({
    String? id,
    required String name,
    required String icon,
    required int color,
    @JsonKey(name: 'bookmark_ids') @Default([]) List<String> bookmarkIds,
  }) = _CollectionRequest;

  factory CollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CollectionRequestFromJson(json);
}
