part of 'profile_widgets.dart';

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: context.l10n.profileSectionAbout,
      child: const _AppInfoTile(),
    );
  }
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
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.commonSignOut,
      message: l10n.profileSignOutConfirmMessage,
      confirmLabel: l10n.commonSignOut,
      cancelLabel: l10n.commonCancel,
      icon: FontAwesomeIcons.arrowRightFromBracket,
      isDestructive: false,
    );
    if (confirmed && context.mounted) {
      SessionScope.of(context).signOut();
    }
  }
}
