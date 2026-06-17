import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_state.freezed.dart';

@freezed
sealed class DeleteAccountState with _$DeleteAccountState {
  const factory DeleteAccountState.initial() = DeleteAccountInitial;
  const factory DeleteAccountState.submitting() = DeleteAccountSubmitting;
  const factory DeleteAccountState.success() = DeleteAccountSuccess;
  const factory DeleteAccountState.failure(Failure failure) =
      DeleteAccountFailure;
}
