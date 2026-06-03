import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../bloc/change_password_cubit.dart';
import '../bloc/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangePasswordCubit>(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      return;
    }

    await context.read<ChangePasswordCubit>().submit(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }

  void _submitText(String _) => _submit();

  String _localizeFailure(Failure failure) => switch (failure) {
    InvalidCredentialsFailure() => context.l10n.errorInvalidInput,
    _ => context.l10n.errorUnknown,
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.changePasswordSuccessMessage)),
          );
          Navigator.of(context).pop();
        }
      },
      child: AppScaffold(
        title: context.l10n.changePasswordAppBarTitle,
        padding: EdgeInsets.zero,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                builder: (context, state) {
                  final isSubmitting = state is ChangePasswordSubmitting;
                  final errorMessage = state is ChangePasswordFailure
                      ? _localizeFailure(state.failure)
                      : null;

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _currentPasswordController,
                          label: context.l10n.changePasswordCurrentLabel,
                          prefixIcon: FontAwesomeIcons.lock,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: (value) => (value == null || value.isEmpty)
                              ? context.l10n.fieldRequired
                              : null,
                        ).animateSlideLeft(delay: 100.ms),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _newPasswordController,
                          label: context.l10n.changePasswordNewLabel,
                          prefixIcon: FontAwesomeIcons.arrowRotateRight,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: (value) => (value == null || value.isEmpty)
                              ? context.l10n.fieldRequired
                              : null,
                        ).animateSlideLeft(delay: 200.ms),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: context.l10n.changePasswordConfirmLabel,
                          prefixIcon: FontAwesomeIcons.arrowRotateRight,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _submitText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.l10n.fieldRequired;
                            }
                            if (value != _newPasswordController.text) {
                              return context.l10n.changePasswordMismatchError;
                            }
                            return null;
                          },
                        ).animateSlideLeft(delay: 300.ms),
                        if (errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            errorMessage,
                            style: TextStyle(color: context.colorScheme.error),
                            textAlign: TextAlign.center,
                          ).animateShake(),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton(
                          label: context.l10n.changePasswordSubmit,
                          onPressed: _submit,
                          isLoading: isSubmitting,
                          expand: true,
                        ).animateSlideUp(delay: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
