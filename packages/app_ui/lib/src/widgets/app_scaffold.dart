import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_ui.dart';

/// Wraps [Scaffold] with consistent app-bar styling and an optional full-screen
/// loading overlay driven by [isLoading].
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.safeArea = true,
    this.isLoading = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  }) : assert(
         appBar == null || title == null,
         'Provide either `title` or a custom `appBar`, not both.',
       );

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final EdgeInsetsGeometry padding;
  final bool safeArea;
  final bool isLoading;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar:
          appBar ??
          (title != null
              ? AppBar(
                  title: Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  centerTitle: true,
                  // Flat app bar styling (elevation, scrolled-under
                  // elevation) now comes from the theme's `appBarTheme`.
                  leading:
                      leading ??
                      (Navigator.of(context).canPop()
                          ? IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.chevronLeft,
                              ),
                              iconSize: AppIconSize.md,
                              onPressed: () => Navigator.of(context).maybePop(),
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                            )
                          : null),
                  actions: actions,
                )
              : null),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          content,
          AnimatedSwitcher(
            duration: AppDurations.medium,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isLoading
                ? Stack(
                    key: const ValueKey('AppScaffoldLoading'),
                    children: [
                      // Blurred dark overlay
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: const ColoredBox(color: Colors.black26),
                        ),
                      ),
                      // Elevated glassmorphism loading card
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxxl,
                            vertical: AppSpacing.xxxl,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: AppElevation.cardShadow,
                          ),
                          child: const AppLoading(),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
