import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user_dto.dart';

part 'refresh_token_response.freezed.dart';
part 'refresh_token_response.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    required AuthUserDto user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}
