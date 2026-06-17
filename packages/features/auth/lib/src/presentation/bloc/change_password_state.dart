import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password_state.freezed.dart';

@freezed
sealed class ChangePasswordState with _$ChangePasswordState {
  const factory ChangePasswordState.initial() = ChangePasswordInitial;
  const factory ChangePasswordState.submitting() = ChangePasswordSubmitting;
  const factory ChangePasswordState.success() = ChangePasswordSuccess;
  const factory ChangePasswordState.failure(Failure failure) =
      ChangePasswordFailure;
}
