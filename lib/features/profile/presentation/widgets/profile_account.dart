part of 'profile_widgets.dart';

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: context.l10n.profileSectionAccount,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChangePasswordTile(),
          _SettingsDivider(),
          _DeleteAccountTile(),
          SizedBox(height: AppSpacing.xs),
        ],
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
