import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user_dto.dart';

part 'sign_in_response.freezed.dart';
part 'sign_in_response.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class SignInResponse with _$SignInResponse {
  const factory SignInResponse({
    required AuthUserDto user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _SignInResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
