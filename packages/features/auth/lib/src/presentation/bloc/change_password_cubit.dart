import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/change_password.dart';
import 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePassword)
    : super(const ChangePasswordState.initial());

  final ChangePasswordUseCase _changePassword;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state is ChangePasswordSubmitting) return;

    emit(const ChangePasswordState.submitting());

    final result = await _changePassword((
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));

    switch (result) {
      case Ok():
        emit(const ChangePasswordState.success());
      case Err(:final failure):
        emit(ChangePasswordState.failure(failure));
    }
  }
}
