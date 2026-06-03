import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../gen/assets.gen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    authBloc.add(
      AuthSignInRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _showPasswordRecoveryUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.loginPasswordRecoveryUnavailable)),
    );
  }

  void _showSocialUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.loginSocialUnavailable)),
    );
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;
            final horizontalPadding = isCompact
                ? AppSpacing.xl
                : AppSpacing.xxxl;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: isCompact ? AppSpacing.xxl : AppSpacing.xxxxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      (isCompact ? AppSpacing.xxxxl : AppSpacing.xxxxl * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.36,
                          ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: AppSpacing.xxxl,
                        ),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isSubmitting = state is AuthSubmitting;
                            final errorMessage = state is AuthFailure
                                ? _localizeFailure(state.failure)
                                : null;
                            return Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _BrandHeader().animateSlideDown(),
                                  const SizedBox(height: AppSpacing.xxxl),
                                  _LoginHeading(
                                    isCompact: isCompact,
                                  ).animateSlideDown(delay: 50.ms),
                                  const SizedBox(height: AppSpacing.xxxl),
                                  _LoginTextField(
                                    controller: _usernameController,
                                    label: context.l10n.loginUsernameLabel,
                                    hint: context.l10n.loginUsernameHint,
                                    icon: FontAwesomeIcons.envelope,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                      AutofillHints.email,
                                    ],
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? context.l10n.fieldRequired
                                        : null,
                                  ).animateSlideLeft(delay: 100.ms),
                                  const SizedBox(height: AppSpacing.xxl),
                                  _LoginTextField(
                                    controller: _passwordController,
                                    label: context.l10n.loginPasswordLabel,
                                    hint: context.l10n.loginPasswordHint,
                                    icon: FontAwesomeIcons.lock,
                                    obscureText: _obscurePassword,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    suffix: IconButton(
                                      tooltip: _obscurePassword
                                          ? context.l10n.loginShowPassword
                                          : context.l10n.loginHidePassword,
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      icon: FaIcon(
                                        _obscurePassword
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 18,
                                      ),
                                    ),
                                    onSubmitted: (_) => _submit(),
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? context.l10n.fieldRequired
                                        : null,
                                    trailingLabel: TextButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : _showPasswordRecoveryUnavailable,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        textStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        context.l10n.loginForgotPassword,
                                      ),
                                    ),
                                  ).animateSlideLeft(delay: 200.ms),
                                  if (errorMessage != null) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      errorMessage,
                                      style: TextStyle(
                                        color: context.colorScheme.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    ).animateShake(),
                                  ],
                                  const SizedBox(height: AppSpacing.xxxl),
                                  AppButton(
                                    label: context.l10n.loginSubmit,
                                    icon: FontAwesomeIcons.arrowRight,
                                    onPressed: _submit,
                                    isLoading: isSubmitting,
                                    expand: true,
                                  ).animateSlideUp(delay: 300.ms),
                                  const SizedBox(height: AppSpacing.xxxl),
                                  _LoginDivider(
                                    label: context.l10n.loginDividerLabel,
                                  ).animateSlideUp(delay: 350.ms),
                                  const SizedBox(height: AppSpacing.xxl),
                                  _SocialButton(
                                    label: context.l10n.loginGoogle,
                                    icon: FontAwesomeIcons.google,
                                    onPressed: isSubmitting
                                        ? null
                                        : _showSocialUnavailable,
                                  ).animateSlideUp(delay: 400.ms),
                                  const SizedBox(height: AppSpacing.lg),
                                  _SocialButton(
                                    label: context.l10n.loginApple,
                                    icon: FontAwesomeIcons.apple,
                                    onPressed: isSubmitting
                                        ? null
                                        : _showSocialUnavailable,
                                  ).animateSlideUp(delay: 450.ms),
                                  const SizedBox(height: AppSpacing.xxxl),
                                  _RegisterPrompt(
                                    isSubmitting: isSubmitting,
                                  ).animateSlideUp(delay: 500.ms),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Assets.icons.logo.image(
            width: 32,
            height: 32,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            context.l10n.appTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginHeading extends StatelessWidget {
  const _LoginHeading({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.loginHeadline,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontSize: isCompact ? 28 : 32,
            fontWeight: FontWeight.w700,
            height: isCompact ? 34 / 28 : 40 / 32,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.loginSubtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 16,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.trailingLabel,
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
  final Widget? trailingLabel;
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
    final outlineColor = colorScheme.outlineVariant;
    final iconColor = colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
              ),
              ?trailingLabel,
            ],
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
            fillColor: colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            constraints: const BoxConstraints(minHeight: 48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: outlineColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: outlineColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: context.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: context.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: context.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginDivider extends StatelessWidget {
  const _LoginDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final FaIconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        icon: FaIcon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.isSubmitting});

  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          context.l10n.loginRegisterPrompt,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: isSubmitting
              ? null
              : () => const RegisterRoute().go(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(context.l10n.loginNavigateToRegister),
        ),
      ],
    );
  }
}
