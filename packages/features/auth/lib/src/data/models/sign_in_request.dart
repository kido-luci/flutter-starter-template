import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_request.freezed.dart';
part 'sign_in_request.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class SignInRequest with _$SignInRequest {
  const factory SignInRequest({
    required String username,
    required String password,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}
