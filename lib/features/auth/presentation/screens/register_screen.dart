import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../gen/assets.gen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    authBloc.add(
      AuthRegisterRequested(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    const LoginRoute().go(context);
  }

  String _localizeFailure(Failure failure) => switch (failure) {
    InvalidCredentialsFailure() => context.l10n.errorInvalidCredentials,
    _ => context.l10n.errorUnknown,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _RegisterTopBar(onBackPressed: _goBack),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 420;
                  final topPadding = isCompact
                      ? AppSpacing.xxxl
                      : AppSpacing.xxxxl;
                  const bottomPadding = AppSpacing.xxxl;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      topPadding,
                      AppSpacing.xl,
                      bottomPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - topPadding - bottomPadding,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isSubmitting = state is AuthSubmitting;
                              final errorMessage = state is AuthFailure
                                  ? _localizeFailure(state.failure)
                                  : null;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _RegisterIntro(
                                    isCompact: isCompact,
                                  ).animateSlideDown(),
                                  const SizedBox(height: AppSpacing.xxxl),
                                  _RegisterFormCard(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    isSubmitting: isSubmitting,
                                    errorMessage: errorMessage,
                                    onTogglePassword: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    onSubmit: _submit,
                                  ).animateSlideUp(delay: 100.ms),
                                  const SizedBox(height: AppSpacing.xxxl),
                                  _LoginPrompt(
                                    isSubmitting: isSubmitting,
                                  ).animateSlideUp(delay: 200.ms),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterTopBar extends StatelessWidget {
  const _RegisterTopBar({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: context.isDark ? 0.22 : 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onBackPressed,
                  icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl,
                ),
                child: Text(
                  context.l10n.appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterIntro extends StatelessWidget {
  const _RegisterIntro({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Assets.icons.logo.image(
            width: 80,
            height: 80,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          context.l10n.registerHeadline,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSurface,
            fontSize: isCompact ? 28 : 32,
            fontWeight: FontWeight.w700,
            height: isCompact ? 34 / 28 : 40 / 32,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.registerSubtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}

class _RegisterFormCard extends StatelessWidget {
  const _RegisterFormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onTogglePassword,
    required this.onSubmit,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: context.isDark ? 0.28 : 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RegisterTextField(
                controller: emailController,
                label: context.l10n.registerEmailLabel,
                hint: context.l10n.registerEmailHint,
                icon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.newUsername,
                  AutofillHints.email,
                ],
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return context.l10n.fieldRequired;
                  }
                  if (!_emailPattern.hasMatch(email)) {
                    return context.l10n.registerInvalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              _RegisterTextField(
                controller: passwordController,
                label: context.l10n.registerPasswordLabel,
                hint: context.l10n.registerPasswordHint,
                icon: FontAwesomeIcons.lock,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => onSubmit(),
                suffix: IconButton(
                  tooltip: obscurePassword
                      ? context.l10n.registerShowPassword
                      : context.l10n.registerHidePassword,
                  onPressed: onTogglePassword,
                  icon: FaIcon(
                    obscurePassword
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 18,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.fieldRequired;
                  }
                  if (value.length < 8) {
                    return context.l10n.registerPasswordMinLengthError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.registerPasswordHelp,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ).animateShake(),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.primaryContainer
                        .withValues(alpha: 0.62),
                    disabledForegroundColor: colorScheme.onPrimary.withValues(
                      alpha: 0.82,
                    ),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(context.l10n.registerSubmit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FaIconData icon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final iconColor = colorScheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 16,
            height: 24 / 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.textTheme.bodyLarge?.copyWith(
              color: iconColor,
              fontSize: 16,
              height: 24 / 16,
            ),
            prefixIcon: Center(
              widthFactor: 1,
              child: FaIcon(icon, color: iconColor, size: 20),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            constraints: const BoxConstraints(minHeight: 48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.isSubmitting});

  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          context.l10n.registerLoginPrompt,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: isSubmitting ? null : () => const LoginRoute().go(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(context.l10n.registerNavigateToLogin),
        ),
      ],
    );
  }
}
