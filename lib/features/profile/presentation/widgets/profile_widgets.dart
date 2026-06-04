import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:theme/theme.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/presentation/session_scope.dart';
import '../../../auth/presentation/bloc/delete_account_cubit.dart';
import '../../../auth/presentation/bloc/delete_account_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
part 'profile_header.dart';
part 'profile_account.dart';
part 'profile_appearance.dart';
part 'profile_about.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  void _onDeleteAccountState(BuildContext context, DeleteAccountState state) {
    switch (state) {
      case DeleteAccountSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileDeleteAccountSuccess)),
        );
        // Clearing the session flips the app to signed-out, so the router
        // redirects to the login screen.
        SessionScope.of(context).clearSession();
      case DeleteAccountFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileDeleteAccountError)),
        );
      case DeleteAccountInitial() || DeleteAccountSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteAccountCubit, DeleteAccountState>(
      listener: _onDeleteAccountState,
      child: AppScaffold(
        title: context.l10n.profileAppBarTitle,
        padding: EdgeInsets.zero,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            const _ProfileHeader().animateSlideDown(),
            const SizedBox(height: AppSpacing.lg),
            const _AccountCard().animateSlideUp(delay: 120.ms),
            const SizedBox(height: AppSpacing.lg),
            const _AppearanceCard().animateSlideUp(delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),
            const _AboutCard().animateSlideUp(delay: 280.ms),
            const SizedBox(height: AppSpacing.xxl),
            const _SignOutButton().animateFadeIn(delay: 360.ms),
          ],
        ),
      ),
    );
  }
}

/// Bento-style surface used to group related settings: a white (lowest-tone)
/// rounded card with a soft ambient shadow, optionally led by a [title].
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isLight = theme.brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0A192F,
            ).withValues(alpha: isLight ? 0.05 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) _CardTitle(title!),
            child,
          ],
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        text,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Small uppercase caption used to label a group of controls inside a card.
class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Hairline separator between rows within a [_SettingsCard].
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}
