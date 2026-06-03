import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';
import '../di/injection.dart';

/// Hosts the persistent adaptive navigation around the authenticated branches.
///
/// Renders an [AppAdaptiveScaffold] whose body is the [navigationShell] (the
/// indexed stack of branch navigators), so each destination keeps its own
/// navigation stack.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications on app start so the badge can be shown immediately
    // if there are unread notifications.
    getIt<NotificationsBloc>().add(const NotificationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsBloc>(),
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final destinations = [
            AppDestination(
              icon: FontAwesomeIcons.house,
              selectedIcon: FontAwesomeIcons.house,
              label: l10n.navHome,
            ),
            AppDestination(
              icon: FontAwesomeIcons.bookmark,
              selectedIcon: FontAwesomeIcons.solidBookmark,
              label: l10n.navBookmarks,
            ),
            AppDestination(
              icon: FontAwesomeIcons.bell,
              selectedIcon: FontAwesomeIcons.solidBell,
              label: l10n.navNotifications,
              hasBadge: state.unreadCount > 0,
            ),
            AppDestination(
              icon: FontAwesomeIcons.user,
              selectedIcon: FontAwesomeIcons.solidUser,
              label: l10n.navProfile,
            ),
          ];

          return AppAdaptiveScaffold(
            destinations: destinations,
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                // Refresh when tapping the tab to ensure it's up to date
                getIt<NotificationsBloc>().add(
                  const NotificationsLoadRequested(),
                );
              }
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
            body: widget.navigationShell,
          );
        },
      ),
    );
  }
}
