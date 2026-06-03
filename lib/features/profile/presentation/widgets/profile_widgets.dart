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
