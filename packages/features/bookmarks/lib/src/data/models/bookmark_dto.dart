import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_dto.freezed.dart';
part 'bookmark_dto.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class BookmarkDto with _$BookmarkDto {
  const factory BookmarkDto({
    required String id,
    required String title,
    required String url,
    required String description,
    required List<String> tags,
    @Default([]) List<String> imageUrls,
    String? videoUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    required int rev,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _BookmarkDto;

  factory BookmarkDto.fromJson(Map<String, dynamic> json) =>
      _$BookmarkDtoFromJson(json);
}
