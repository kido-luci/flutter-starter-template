import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_activity_dto.freezed.dart';
part 'user_activity_dto.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class UserActivityDto with _$UserActivityDto {
  const factory UserActivityDto({
    required String id,
    required String description,
    required String type,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserActivityDto;

  factory UserActivityDto.fromJson(Map<String, dynamic> json) =>
      _$UserActivityDtoFromJson(json);
}
