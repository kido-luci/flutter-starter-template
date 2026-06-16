import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../collections_routes.dart';
import '../widgets/collections_list_view.dart';

/// Standalone collections browser (reachable at `/collections`).
class CollectionsListScreen extends StatelessWidget {
  const CollectionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.collectionsTitle,
      padding: EdgeInsets.zero,
      floatingActionButton: FloatingActionButton(
        heroTag: 'collections-add-fab',
        tooltip: context.l10n.collectionsCreate,
        onPressed: () => context.push<void>(CollectionsRoutes.create),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      body: const CollectionsListView(),
    );
  }
}
