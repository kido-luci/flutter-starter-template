import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request.freezed.dart';
part 'register_request.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String username,
    required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
