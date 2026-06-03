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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(
              context.l10n.profileSectionAccount,
            ).animateSlideRight(delay: 300.ms),
            const _ChangePasswordTile().animateSlideRight(delay: 325.ms),
            const _DeleteAccountTile().animateSlideRight(delay: 340.ms),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(
              context.l10n.profileSectionAppearance,
            ).animateSlideRight(delay: 350.ms),
            const _ThemeModeSelector().animateSlideRight(delay: 375.ms),
            const SizedBox(height: AppSpacing.sm),
            const _ColorSchemeSelector().animateSlideRight(delay: 400.ms),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(
              context.l10n.profileSectionAbout,
            ).animateSlideRight(delay: 425.ms),
            const _AppInfoTile().animateSlideRight(delay: 450.ms),
            const SizedBox(height: AppSpacing.xxxl),
            const _SignOutButton().animateSlideUp(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = SessionScope.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final user = session.currentUser;
        final username = user?.username ?? '';
        final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
        return Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ).animateScale(),
            const SizedBox(height: AppSpacing.md),
            Text(
              username,
              style: theme.textTheme.titleLarge,
            ).animateSlideDown(delay: 150.ms),
            const SizedBox(height: AppSpacing.xs),
            _CopyableId(id: user?.id ?? '').animateFadeIn(delay: 250.ms),
          ],
        );
      },
    );
  }
}

class _CopyableId extends StatelessWidget {
  const _CopyableId({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (id.isEmpty) return const SizedBox.shrink();
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () {
        Clipboard.setData(ClipboardData(text: id));
        context.read<ProfileBloc>().add(const ProfileUserIdCopied());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileUserIdCopied)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              id,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            FaIcon(
              FontAwesomeIcons.copy,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ChangePasswordTile extends StatelessWidget {
  const _ChangePasswordTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.key),
      title: Text(context.l10n.profileChangePassword),
      trailing: const FaIcon(FontAwesomeIcons.chevronRight),
      onTap: () {
        const ChangePasswordRoute().push<void>(context);
      },
    );
  }
}

class _DeleteAccountTile extends StatelessWidget {
  const _DeleteAccountTile();

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
      builder: (context, state) {
        final isSubmitting = state is DeleteAccountSubmitting;
        return ListTile(
          leading: FaIcon(FontAwesomeIcons.trash, color: error),
          title: Text(
            context.l10n.profileDeleteAccount,
            style: TextStyle(color: error),
          ),
          trailing: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: isSubmitting ? null : () => _confirmAndDelete(context),
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final username = SessionScope.of(context).currentUser?.username;
    if (username == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteAccountDialog(username: username),
    );
    if (confirmed == true && context.mounted) {
      await context.read<DeleteAccountCubit>().submit();
    }
  }
}

/// Confirmation dialog that requires the user to type their username before
/// the destructive delete button becomes enabled.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.username});

  final String username;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canDelete = _controller.text.trim() == widget.username;
    return AlertDialog(
      title: Text(l10n.profileDeleteAccountDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileDeleteAccountDialogMessage),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _controller,
            label: l10n.profileDeleteAccountConfirmLabel(widget.username),
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: l10n.commonCancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: l10n.commonDelete,
          variant: AppButtonVariant.tonal,
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return RadioGroup<ThemeMode>(
          groupValue: state.mode,
          onChanged: (selected) {
            if (selected != null) {
              context.read<ThemeBloc>().add(ThemeModeChanged(selected));
            }
          },
          child: Column(
            children: ThemeMode.values.map((option) {
              return RadioListTile<ThemeMode>(
                value: option,
                title: Text(_labelFor(context, option)),
                secondary: FaIcon(_iconFor(option)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _labelFor(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.l10n.profileThemeSystemDefault,
    ThemeMode.light => context.l10n.profileThemeLight,
    ThemeMode.dark => context.l10n.profileThemeDark,
  };

  FaIconData _iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => FontAwesomeIcons.circleHalfStroke,
    ThemeMode.light => FontAwesomeIcons.sun,
    ThemeMode.dark => FontAwesomeIcons.moon,
  };
}

class _ColorSchemeSelector extends StatelessWidget {
  const _ColorSchemeSelector();

  static const double _swatchSize = 40;
  static const double _swatchInnerSize = 28;

  static const List<FlexScheme> _schemes = [
    FlexScheme.material,
    FlexScheme.deepPurple,
    FlexScheme.indigo,
    FlexScheme.blue,
    FlexScheme.green,
    FlexScheme.red,
    FlexScheme.mango,
    FlexScheme.gold,
    FlexScheme.sakura,
    FlexScheme.hippieBlue,
    FlexScheme.aquaBlue,
    FlexScheme.jungle,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: _schemes.map((scheme) {
              final isActive = scheme == state.scheme;
              return GestureDetector(
                onTap: () =>
                    context.read<ThemeBloc>().add(ThemeSchemeChanged(scheme)),
                child: AnimatedContainer(
                  duration: AppDurations.xfast,
                  width: _swatchSize,
                  height: _swatchSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? context.colorScheme.primary
                          : context.colorScheme.outline.withValues(alpha: 0.3),
                      width: isActive ? 3 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: _swatchInnerSize,
                      height: _swatchInnerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _schemeColors(scheme),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Color> _schemeColors(FlexScheme scheme) => switch (scheme) {
    FlexScheme.material => const [Color(0xFF6750A4), Color(0xFFB4B0D0)],
    FlexScheme.deepPurple => const [Color(0xFF673AB7), Color(0xFFB39DDB)],
    FlexScheme.indigo => const [Color(0xFF3F51B5), Color(0xFF9FA8DA)],
    FlexScheme.blue => const [Color(0xFF2196F3), Color(0xFF90CAF9)],
    FlexScheme.green => const [Color(0xFF4CAF50), Color(0xFFA5D6A7)],
    FlexScheme.red => const [Color(0xFFF44336), Color(0xFFEF9A9A)],
    FlexScheme.mango => const [Color(0xFFFF9800), Color(0xFFFFCC80)],
    FlexScheme.gold => const [Color(0xFFFFC107), Color(0xFFFFE082)],
    FlexScheme.sakura => const [Color(0xFFE91E63), Color(0xFFF48FB1)],
    FlexScheme.hippieBlue => const [Color(0xFF4A90A2), Color(0xFFA8D8C8)],
    FlexScheme.aquaBlue => const [Color(0xFF03A9F4), Color(0xFF81D4FA)],
    FlexScheme.jungle => const [Color(0xFF388E3C), Color(0xFFA5D6A7)],
    _ => const [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
  };
}

class _AppInfoTile extends StatelessWidget {
  const _AppInfoTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final info = state.packageInfo;
        return ListTile(
          leading: const FaIcon(FontAwesomeIcons.circleInfo),
          title: Text(info?.appName ?? '—'),
          subtitle: info == null
              ? Text(context.l10n.commonLoading)
              : Text(
                  context.l10n.profileAppVersionBuild(
                    info.version,
                    info.buildNumber,
                  ),
                ),
        );
      },
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final isLoading = session.isSigningOut;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: AppButton(
            label: context.l10n.commonSignOut,
            icon: FontAwesomeIcons.arrowRightFromBracket,
            variant: AppButtonVariant.tonal,
            expand: true,
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _confirmSignOut(context),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonSignOut),
        content: Text(l10n.profileSignOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonSignOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      SessionScope.of(context).signOut();
    }
  }
}
