import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
// Deliberate cross-feature capability import: profile surfaces auth's
// delete-account flow. Single consumer, so it stays in auth rather than being
// promoted to `shared` (see the capability exception in CLAUDE.md).
import '../../../auth/presentation/bloc/delete_account_cubit.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileLoaded()),
        ),
        BlocProvider<DeleteAccountCubit>(
          create: (_) => getIt<DeleteAccountCubit>(),
        ),
      ],
      child: const ProfileBody(),
    );
  }
}
