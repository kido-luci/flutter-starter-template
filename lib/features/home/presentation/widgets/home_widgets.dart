import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/presentation/session_scope.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
part 'home_welcome.dart';
part 'home_stats.dart';
part 'home_recent.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  static const double _contentMaxWidth = 720;
  static const double _bottomInset = 112;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.homeAppBarTitle,
      padding: EdgeInsets.zero,
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  _bottomInset,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WelcomeSection(
                          totalBookmarks: state.totalBookmarks,
                        ).animateFadeIn(delay: 100.ms),
                        const SizedBox(height: AppSpacing.lg),
                        _StatsDashboard(state: state),
                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryActionPanel(
                          onPressed: () =>
                              const BookmarksListRoute().push<void>(context),
                        ).animateSlideUp(delay: 350.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _RecentBookmarksSection(
                          recentItems: state.recentItems,
                          isEmpty: state.totalBookmarks == 0,
                          animationDelay: 450.ms,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
