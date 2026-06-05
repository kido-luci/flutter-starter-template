import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_dto.freezed.dart';
part 'collection_dto.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class CollectionDto with _$CollectionDto {
  const factory CollectionDto({
    required String id,
    required String name,
    required String icon,
    required int color,
    @JsonKey(name: 'bookmark_ids') @Default([]) List<String> bookmarkIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CollectionDto;

  factory CollectionDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionDtoFromJson(json);
}
