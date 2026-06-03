import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/user_activity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';
part 'notifications_tabs.dart';
part 'notifications_lists.dart';
part 'notifications_tiles.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        // First load with no cached content yet — defer to the failure / empty
        // states below once it settles.
        if (state.failure != null && state.hasNoContent) {
          return AppScaffold(
            title: context.l10n.notificationsAppBarTitle,
            body: AppErrorView(
              message: context.l10n.notificationsLoadError,
              onRetry: () => context.read<NotificationsBloc>().add(
                const NotificationsLoadRequested(),
              ),
            ),
          );
        }

        return AppScaffold(
          title: context.l10n.notificationsAppBarTitle,
          isLoading: state.isLoading && state.hasNoContent,
          padding: EdgeInsets.zero,
          body: const _NotificationsTabs(),
        );
      },
    );
  }
}
